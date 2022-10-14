use crate::ss::ast_data::HeadingType;
use crate::ss::SemanticScope;
use crate::ss::SymbolicModeType;
use crate::ss::ast_traits::SyntacticallyEq;

use super::*;

pub fn all_block_formatting_commands() -> Vec<cmd_decl::CmdDeclaration> {
    let layout = CmdDeclBuilder::new(Ident::from("\\layout").unwrap())
        .arguments(
            arguments! {
                for (internal, metadata, cmd_payload) match {
                    ({xs}) => {
                        Node::Cmd(CmdCall {
                            identifier: cmd_payload.identifier,
                            attributes: cmd_payload.attributes.unwrap_or_default(),
                            arguments: vec![xs]
                        })
                    },
                }
            }
        )
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let is_section = {
                    if !cmd.attributes.has_attr("section") {
                        cmd .first_non_empty_node()
                            .filter(|x| {
                                x.is_heading()
                            })
                            .is_some()
                    } else {
                        cmd.attributes.has_truthy_option("section")
                    }
                };
                let mut attributes = HashMap::default();
                attributes.insert(String::from("data-cmd"), String::from("layout"));
                if cmd.attributes.has_truthy_option("vr") || cmd.attributes.has_truthy_option("show-rule") {
                    attributes.insert(String::from("show-rule"), String::from("true"));
                }
                let col_value = cmd.attributes
                    .get("col")
                    .map(|x| x.value.clone().defragment_node_tree().trim_whitespace())
                    .and_then(Node::into_text)
                    .map(Ann::consume)
                    .map(|value| {
                        attributes.insert(String::from("data-col"), value);
                    });
                let children = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_html(env, scope))
                    .collect_vec();
                crate::html::Node::Element(crate::html::Element {
                    name: {
                        if is_section {
                            String::from("section")
                        } else {
                            String::from("div")
                        }
                    },
                    attributes,
                    children,
                })
            }
        })
        .finish();
    let grid = CmdDeclBuilder::new(Ident::from("\\grid").unwrap())
        .arguments(
            arguments! {
                for (internal, metadata, cmd_payload) match {
                    ({xs}) => {
                        Node::Cmd(CmdCall {
                            identifier: cmd_payload.identifier,
                            attributes: cmd_payload.attributes.unwrap_or_default(),
                            arguments: vec![xs]
                        })
                    },
                }
            }
        )
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let is_section = {
                    if !cmd.attributes.has_attr("section") {
                        cmd .first_non_empty_node()
                            .filter(|x| {
                                x.is_heading()
                            })
                            .is_some()
                    } else {
                        cmd.attributes.has_truthy_option("section")
                    }
                };
                let mut attributes = HashMap::default();
                attributes.insert(String::from("data-cmd"), String::from("grid"));
                let col_value = cmd.attributes
                    .get("col")
                    .map(|x| x.value.clone().defragment_node_tree().trim_whitespace())
                    .and_then(Node::into_text)
                    .map(Ann::consume)
                    .map(|value| {
                        attributes.insert(String::from("data-col"), value);
                    });
                let children = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_html(env, scope))
                    .collect_vec();
                crate::html::Node::Element(crate::html::Element {
                    name: {
                        if is_section {
                            String::from("section")
                        } else {
                            String::from("div")
                        }
                    },
                    attributes,
                    children,
                })
            }
        })
        .finish();
    let note = CmdDeclBuilder::new(Ident::from("\\note").unwrap())
        .arguments(
            arguments! {
                for (internal, metadata, cmd_payload) match {
                    ({xs}) => {
                        Node::Cmd(CmdCall {
                            identifier: cmd_payload.identifier,
                            attributes: cmd_payload.attributes.unwrap_or_default(),
                            arguments: vec![xs]
                        })
                    },
                }
            }
        )
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let mut attributes = HashMap::default();
                attributes.insert(String::from("data-cmd"), String::from("note"));
                let children = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_html(env, scope))
                    .collect_vec();
                crate::html::Node::Element(crate::html::Element {
                    name: String::from("section"),
                    attributes,
                    children,
                })
            }
        })
        .finish();
    vec![
        layout,
        grid,
        note,
    ]
}

pub fn all_inline_formatting_commands() -> Vec<cmd_decl::CmdDeclaration> {
    vec![
        
    ]
}
