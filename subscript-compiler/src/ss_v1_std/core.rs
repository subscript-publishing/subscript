use either::{Either, Either::Left, Either::Right};
use itertools::Itertools;
use std::{collections::HashMap, hash::Hash, path::PathBuf, rc::Rc};

use crate::ss::ToNode;
use crate::ss::ast_data::HeadingType;
use crate::ss::SemanticScope;
use crate::ss::SymbolicModeType;
use crate::ss::ast_traits::SyntacticallyEq;

use super::*;

fn normalize_ref_headings(
    scope: &SemanticScope,
    baseline: HeadingType,
    node: Node
) -> Node {
    let decrement_amount = baseline.to_u8();
    let f = |node: Node| -> Node {
        match node {
            Node::Cmd(mut cmd) if cmd.is_heading_node() => {
                let heading_type = HeadingType::from_id(&cmd.identifier.value).unwrap();
                let heading_type = heading_type.decrement_by(decrement_amount);
                if !cmd.attributes.has_attr("source") {
                    scope.file_path
                        .clone()
                        .and_then(|x| x.to_str().map(ToString::to_string))
                        .map(|path| {
                            cmd.attributes.insert("source", path)
                        });
                }
                cmd.identifier = Ann::unannotated(heading_type.into_ident());
                Node::Cmd(cmd)
            }
            node => node,
        }
    };
    node.transform(Rc::new(f))
}

fn process_ss1_drawing(
    file_path: &PathBuf,
    rewrite_rules: Option<Vec<crate::ss::RewriteRule<Vec<Node>>>>,
) -> Vec<Node> {
    if let Ok(model) = ss_freeform_format::CanvasDataModel::parse_file(file_path) {
        let rewrite_rules = rewrite_rules
            .and_then(|rules| rules.first().map(Clone::clone))
            .and_then(|rule| -> Option<RewriteRule<Node>> {
                let pattern = Node::Fragment(rule.pattern.clone());
                let target = Node::Fragment(rule.target.clone());
                Some(RewriteRule { pattern, target })
            });
        if let Some(rewrite_rule) = rewrite_rules {
            let drawings = model.entries;
            let children = drawings
                .clone()
                .into_iter()
                .map(|drawing| -> Node {
                    let f = {
                        let drawing = drawing.clone();
                        let pattern = rewrite_rule.pattern.clone();
                        move |node: Node| -> Node {
                            if node.syn_eq(&pattern) {
                                return Node::Drawing(drawing.clone());
                            }
                            node
                        }
                    };
                    rewrite_rule.target.clone().transform(Rc::new(f))
                    // .unblock(crate::subscript::BracketType::CurlyBrace)
                })
                .collect_vec();
            return children;
        }
        let drawings = model.entries
            .into_iter()
            .map(Node::Drawing)
            .collect::<Vec<_>>();
        return drawings
    }
    Vec::new()
}

fn process_ss1_composition(
    scope: &SemanticScope,
    rewrite_rules: Option<Vec<RewriteRule<Vec<Node>>>>,
) -> Vec<Node> {
    use ss_freeform_format::PageDataModel;
    use ss_freeform_format::format::page_data_model::Title;
    let parse_result = PageDataModel::parse_file(scope.file_path.as_ref().unwrap());
    if let Ok(model) = parse_result {
        let mut nodes: Vec<Node> = Vec::with_capacity(1 + (model.entries.len() * 2));
        let dec_all_entry_titles = !model.page_title.trim().is_empty();
        let process_title = |title: Title| -> Option<Node> {
            if title.text.trim().is_empty() {
                return None
            }
            let kind = match title.r#type {
                ss_freeform_format::HeadingType::H1 => crate::ss::HeadingType::H1,
                ss_freeform_format::HeadingType::H2 => crate::ss::HeadingType::H2,
                ss_freeform_format::HeadingType::H3 => crate::ss::HeadingType::H3,
                ss_freeform_format::HeadingType::H4 => crate::ss::HeadingType::H4,
                ss_freeform_format::HeadingType::H5 => crate::ss::HeadingType::H5,
                ss_freeform_format::HeadingType::H6 => crate::ss::HeadingType::H6,
            };
            let kind = if dec_all_entry_titles {
                kind.decrement()
            } else {
                kind
            };
            Some(Node::Cmd(CmdCall{
                identifier: kind.into_ident().into(),
                attributes: Attributes::default(),
                arguments: vec![
                    title.text.to_node()
                ]
            }))
        };
        if !model.page_title.trim().is_empty() {
            nodes.push(Node::Cmd(CmdCall{
                identifier: crate::ss::HeadingType::H1.into_ident().into(),
                attributes: Attributes::default(),
                arguments: vec![
                    model.page_title.trim().to_node()
                ]
            }));
        }
        for entry in model.entries {
            let is_drawing = entry.is_drawing();
            if let Some(node) = process_title(entry.title) {
                nodes.push(node);
            }
            if is_drawing {
                let mut drawings = entry.drawing.for_each_drawing(Node::Drawing);
                nodes.extend(drawings);
            }
        }
        return nodes;
    }
    Vec::new()
}

fn handle_include(
    scope: &SemanticScope,
    attributes: &Option<Attributes>,
    rewrite_rules: Option<Vec<RewriteRule<Vec<Node>>>>,
) -> Option<Node> {
    let attributes = attributes.as_ref()?;
    let baseline = attributes
        .get("baseline")
        .and_then(|x| x.value.clone().as_stringified_attribute_value_str(""))
        .and_then(|x| match x.as_str() {
            "h1" => Some(HeadingType::H1),
            "h2" => Some(HeadingType::H2),
            "h3" => Some(HeadingType::H3),
            "h4" => Some(HeadingType::H4),
            "h5" => Some(HeadingType::H5),
            "h6" => Some(HeadingType::H6),
            _ => None,
        });
    let src_path_str = attributes
        .get("src")?
        .value
        .clone()
        .as_stringified_attribute_value_str("")?;
    let src_path = scope.normalize_file_path(&src_path_str)
        .unwrap_or_else(|()| PathBuf::from(&src_path_str));
    let ext = src_path.extension()?.to_str();
    match ext {
        Some("ss") => {
            let sub_scope = scope.new_file(&src_path);
            let mut nodes = crate::compiler::low_level_api::parse_process(&sub_scope).ok()?;
            if let Some(baseline) = baseline {
                nodes = normalize_ref_headings(&sub_scope, baseline, nodes);
            }
            return Some(nodes);
        }
        Some(ext) if ss_freeform_format::SS1FreeformSuite::is_ss1_drawing_file_ext(ext) => {
            let nodes = process_ss1_drawing(&src_path, rewrite_rules);
            return Some(Node::Fragment(nodes));
        }
        Some(ext) if ss_freeform_format::SS1FreeformSuite::is_ss1_composition_file_ext(ext) => {
            let sub_scope = scope.new_file(&src_path);
            let nodes = process_ss1_composition(&sub_scope, rewrite_rules);
            let mut nodes = Node::Fragment(nodes).defragment_node_tree();
            if let Some(baseline) = baseline {
                nodes = normalize_ref_headings(&sub_scope, baseline, nodes);
            }
            return Some(nodes.defragment_node_tree());
        }
        _ => None,
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// ALL SUBSCRIPT MACROS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

pub fn core_subscript_commands() -> Vec<cmd_decl::CmdDeclaration> {
    let include = CmdDeclBuilder::new(Ident::from("\\include").unwrap())
        .child_layout_mode(LayoutMode::Inline)
        .child_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .internal_cmd_options(cmd_decl::InternalCmdDeclOptions {
            automatically_apply_rewrites: false,
        })
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                () => {
                    let result = handle_include(
                        &metadata.scope,
                        &cmd_payload.attributes,
                        internal.rewrites.clone()
                    );
                    match result {
                        Some(result) => result,
                        None => Node::Fragment(Vec::new())
                    }
                },
            }
        })
        .finish();
    vec![
        include,
    ]
}
