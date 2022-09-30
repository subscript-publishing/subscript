//! Core AST passes.

use std::iter::FromIterator;
use std::collections::{HashSet, HashMap};
use std::path::PathBuf;
use std::rc::Rc;
use std::cell::RefCell;
use std::borrow::Cow;
use std::convert::TryFrom;
use either::Either;
use itertools::Itertools;
use crate::compiler::data::*;
use crate::compiler::ast::*;

///////////////////////////////////////////////////////////////////////////////
// TABLE OF CONTENTS
///////////////////////////////////////////////////////////////////////////////

fn generate_toc_heading_id_from_child_nodes<'a>(children: &Vec<Node>) -> String {
    use pct_str::PctStr;
    let contents = generate_toc_heading_title_from_child_nodes(children);
    let pct_str = PctStr::new(&contents).unwrap();
    pct_str.as_str().to_owned()
}

fn generate_toc_heading_title_from_child_nodes(children: &Vec<Node>) -> String {
    children.iter()
        .map(Node::to_string)
        .collect::<Vec<_>>()
        .join("")
}

fn get_headings(node: &Node) -> Vec<(Vec<String>, String, String, String)> {
    let headings = Rc::new(RefCell::new(Vec::new()));
    let f = {
        let headings = headings.clone();
        move |env: NodeScope, node: Node| {
            match &node {
                Node::Tag(tag) if tag.is_heading_node() => {
                    let id = generate_toc_heading_id_from_child_nodes(&tag.children);
                    let parents = env.parents
                        .into_iter()
                        .map(|x| x.to_string())
                        .collect::<Vec<_>>()
                        .clone();
                    let name = tag.name.data.to_string();
                    let text = tag.children
                        .iter()
                        // .flat_map(|x| x.clone().unblock())
                        .map(|x| x.to_string())
                        .collect::<Vec<_>>()
                        .join("");
                    headings.borrow_mut().push((parents, name, text, id));
                }
                _ => ()
            }
            node
        }
    };
    let _ = node.clone().transform(
        NodeScope::default(),
        Rc::new(f),
    );
    let info = headings
        .clone()
        .borrow()
        .iter()
        .map(|x| {
            x.clone()
        })
        .collect::<Vec<_>>();
    info
}

pub(crate) fn generate_table_of_contents_tree<'a>(input: Vec<Node>) -> Node {
    let children = input
        .into_iter()
        .map(|x| get_headings(&x))
        .flatten()
        .map(|(parents, ty, contents, id)| {
            let mut a = Tag::new(
                Ann::unannotated("a"),
                vec![Node::new_text(contents)]
            );
            a.attributes.insert("href", id);
            let a = Node::Tag(a);
            let mut li = Tag::new(
                Ann::unannotated("li"),
                vec![a]
            );
            // li.insert_parameter(
            //     &format!("type={}", ty)
            // );
            li.attributes.insert("type", ty);
            let li = Node::Tag(li);
            li
        })
        .collect::<Vec<_>>();
    let mut tag = Tag::new(
        Ann::unannotated("ul"),
        children
    );
    // tag.insert_unannotated_parameter("id=toc");
    tag.attributes.insert("id", "toc");
    let node = Node::Tag(tag);
    node
}

pub fn annotate_heading_nodes<'a>(input: Node) -> Node {
    let f = |env: NodeScope, node: Node| -> Node {
        match node {
            Node::Tag(mut tag) if tag.is_heading_node() => {
                let id = generate_toc_heading_id_from_child_nodes(&tag.children);
                tag.attributes.insert("id", id);
                Node::Tag(tag)
            }
            x => x,
        }
    };
    input.transform(NodeScope::default(), Rc::new(f))
}


///////////////////////////////////////////////////////////////////////////////
// WHERE TAG PROCESSING
///////////////////////////////////////////////////////////////////////////////

/// This is where we expand the patterns defined in `\!where` tags.
fn match_and_apply_rewrite_rule<'a>(
    pattern: Node,
    target: Vec<Node>,
    children: Vec<Node>,
) -> Vec<Node> {
    let f = |nodes: Vec<Node>| -> Vec<Node> {
        nodes
            .into_iter()
            .flat_map(|x| {
                if x.syntactically_equal(&pattern) {
                    return target.clone()
                }
                vec![x]
            })
            .collect_vec()
    };
    children
        .into_iter()
        .map(|child| {
            let scope = NodeScope::default();
            child.transform_children(Rc::new(f))
        })
        .collect_vec()
}


///////////////////////////////////////////////////////////////////////////////
// AST-TO-AST PASSES
///////////////////////////////////////////////////////////////////////////////

/// All compiler passes for same scope children.
fn child_list_passes<'a>(children: Vec<Node>) -> Vec<Node> {
    // APPLY AFTER REMOVING ALL TOKENS
    // fn merge_text_content<'a>(xs: Vec<Node>) -> Vec<Node> {
    //     let mut results = Vec::new();
    //     for current in xs.into_iter() {
    //         let left = results
    //             .last_mut()
    //             .and_then(Node::unwrap_text_mut);
    //         if let Some(left) = left {
    //             if let Some(txt) = current.unwrap_text() {
    //                 *left = Ann::unannotated(
    //                     left.data.to_owned() + &txt.data
    //                 );
    //                 continue;
    //             }
    //         }
    //         results.push(current);
    //     }
    //     results
    // }
    fn block_passes<'a>(xs: Vec<Node>) -> Vec<Node> {
        // Put all 'block passes' here
        xs
    }
    // let node = Node::new_fragment(children);
    // let node = node.transform_children(Rc::new(block_passes));
    children
        .into_iter()
        .map(|node| {
            node.transform_children(Rc::new(block_passes))
        })
        .collect::<Vec<_>>()
}


fn normalize_ref_headings(baseline: HeadingType, node: Node) -> Node {
    let decrement_amount = baseline.to_u8();
    let f = |env: NodeScope, node: Node| -> Node {
        match node {
            Node::Tag(mut tag) if tag.is_heading_node() => {
                let heading_type = HeadingType::from_str(&tag.name.data).unwrap();
                let heading_type = heading_type.decrement_by(decrement_amount);
                tag.name = heading_type.to_str().into();
                Node::Tag(tag)
            }
            node @ Node::Tag(_) => node,
            node @ Node::Enclosure(_) => node,
            node @ Node::Text(_) => node,
            node @ Node::Ident(_) => node,
            node @ Node::InvalidToken(_) => node,
            node @ Node::HtmlCode(_) => node,
        }
    };
    node.transform(NodeScope::default(), Rc::new(f))
}


/// All node to node passes.
fn apply_node_passes<'a>(env: &mut crate::compiler::CompilerEnv, node: Node) -> Vec<Node> {
    fn apply_rewrite_rules(tag: Tag) -> Tag {
        let mut children = tag.children;
        let rewrite_rules = tag.rewrite_rules.clone();
        // println!("apply_rewrite_rules: {:#?}", tag.rewrite_rules);
        for RewriteRule{from, to} in tag.rewrite_rules {
            let from = from.unwrap_curly_brace();
            let to = to.unwrap_curly_brace();
            match (from, to) {
                (Some(from), Some(to)) if from.len() == 1 => {
                    children = match_and_apply_rewrite_rule(
                        from[0].clone(),
                        to.clone(),
                        children,
                    );
                }
                _ => ()
            }
        }
        Tag {
            name: tag.name,
            attributes: tag.attributes,
            children,
            rewrite_rules: rewrite_rules.clone(),
        }
    }
    let ref all_tag_macros = crate::plugins::normalize::all_tag_macros();
    let f = |env: NodeScope, node: Node| -> Node {
        match node {
            Node::Tag(tag) => {
                let tag = apply_rewrite_rules(tag);
                if let Some(rewrite) = all_tag_macros.get(&tag.name.data) {
                    rewrite.apply(env, tag)
                } else {
                    Node::Tag(tag)
                }
            }
            node @ Node::Enclosure(_) => node,
            node @ Node::Text(_) => node,
            node @ Node::Ident(_) => node,
            node @ Node::InvalidToken(_) => node,
            node @ Node::HtmlCode(_) => node,
        }
    };
    let g = |env: &mut crate::compiler::CompilerEnv, scope: NodeScope, node: Node| -> Vec<Node> {
        fn process_ss_include(
            env: &mut crate::compiler::CompilerEnv,
            file_path: &str,
            tag: Tag
        ) -> Vec<Node> {
            let baseline = tag.attributes
                .get("baseline")
                .and_then(|x| x.value)
                .map(|x| x.data)
                .and_then(|x| match x.as_str()  {
                    "h1" => Some(HeadingType::H1),
                    "h2" => Some(HeadingType::H2),
                    "h3" => Some(HeadingType::H3),
                    "h4" => Some(HeadingType::H4),
                    "h5" => Some(HeadingType::H5),
                    "h6" => Some(HeadingType::H6),
                    _ => None
                });
            let file_path = PathBuf::from(file_path);
            let file_path = env.normalize_file_path(file_path);
            let (sub_env, nodes) = crate::compiler::low_level_api::parse(file_path).unwrap();
            let nodes = nodes
                .into_iter()
                .map(|x| {
                    if let Some(baseline) = baseline.clone() {
                        return normalize_ref_headings(baseline, x)
                    }
                    x
                })
                .collect_vec();
            env.append_math_env(sub_env.math_env);
            return nodes
        }
        fn process_ssd1_include(
            env: &mut crate::compiler::CompilerEnv,
            file_path: &str,
            tag: Tag
        ) -> Vec<Node> {
            let file_path = PathBuf::from(file_path);
            let file_path = env.normalize_file_path(file_path);
            if let Ok(svgs) = format_ss_drawing::api::compile(file_path) {
                let rule = tag.rewrite_rules
                    .first()
                    .and_then(|rule| {
                        rule.from.clone().unblock()
                            .first()
                            .map(|x| (x.clone(), rule.to.clone()))
                    });
                // println!("process_ssd1_include: {:?}", tag.rewrite_rules);
                if let Some((from, to)) = rule {
                    let children = svgs
                        .clone()
                        .into_iter()
                        .flat_map(|svg| {
                            let f = {
                                let from = from.clone();
                                let svg = svg.clone();
                                move |scope: NodeScope, node: Node| -> Node {
                                    if node.syntactically_equal(&from) {
                                        return Node::HtmlCode(svg.clone())
                                    }
                                    node
                                    // nodes
                                    //     .into_iter()
                                    //     .flat_map(|x| {
                                    //         if x.syntactically_equal(&from) {
                                    //             return vec![Node::HtmlCode(svg.clone())]
                                    //         }
                                    //         vec![x]
                                    //     })
                                    //     .collect_vec()
                                }
                            };
                            let scope = NodeScope::default();
                            to.clone().transform(scope, Rc::new(f)).unblock()
                        })
                        .collect_vec();
                    return children
                }
                return svgs
                    .into_iter()
                    .map(|svg| {
                        Node::HtmlCode(svg)
                    })
                    .collect_vec()
            }
            vec![]
        }
        match node {
            Node::Tag(tag) if tag.has_name("include") => {
                let file_path = tag.attributes
                    .get("src")
                    .and_then(|x| x.value)
                    .map(|x| x.data);
                if let Some(ssd1_file_path) = file_path.as_ref().filter(|x| x.ends_with(".ssd1")) {
                    return process_ssd1_include(env, &ssd1_file_path, tag)
                }
                if let Some(ss_file_path) = file_path.as_ref().filter(|x| x.ends_with(".ss")) {
                    return process_ss_include(env, &ss_file_path, tag)
                }
                vec![]
            }
            node @ Node::Tag(_) => vec![node],
            node @ Node::Enclosure(_) => vec![node],
            node @ Node::Text(_) => vec![node],
            node @ Node::Ident(_) => vec![node],
            node @ Node::InvalidToken(_) => vec![node],
            node @ Node::HtmlCode(_) => vec![node],
        }
    };
    node
        .transform(NodeScope::default(), Rc::new(f))
        .transform_expand(env, NodeScope::default(), Rc::new(g))
}


///////////////////////////////////////////////////////////////////////////////
// AST TO CODEGEN
///////////////////////////////////////////////////////////////////////////////

/// Internal
pub fn core_passes<'a>(
    env: &mut crate::compiler::CompilerEnv,
    nodes: Vec<Node>
) -> Vec<Node> {
    let nodes = nodes
        .into_iter()
        .flat_map(|x| {
            apply_node_passes(env, x)
                .into_iter()
                .map(|x| {
                    crate::compiler::pass::math::latex_pass(&mut env.math_env, x)
                })
                .collect_vec()
        })
        .collect();
    let nodes = child_list_passes(nodes);
    let nodes = nodes
        .into_iter()
        .collect::<Vec<_>>();
    nodes
}

