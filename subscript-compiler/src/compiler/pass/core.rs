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
    pattern: Vec<Node>,
    target: Vec<Node>,
    children: Vec<Node>,
) -> Vec<Node> {
    let mut left: Vec<Node> = Vec::<Node>::new();
    let mut current = children;
    while current.len() > 0 && current.len() >= pattern.len() {
        let matches = current
            .iter()
            .zip(pattern.iter())
            .all(|(x, y)| x.syntactically_equal(y));
        if matches {
            // ADD NEW PATTENR TO LEFT
            left.extend(target.clone());
            let _ = current
                .drain(..pattern.len())
                .collect::<Vec<_>>();
            continue;
        }
        left.push(current.remove(0));
    }
    left.extend(current);
    left
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
        }
    };
    node.transform(NodeScope::default(), Rc::new(f))
}


/// All node to node passes.
fn apply_node_passes<'a>(env: &mut crate::compiler::CompilerEnv, node: Node) -> Vec<Node> {
    fn apply_rewrite_rules(tag: Tag) -> Tag {
        let mut children = tag.children;
        for RewriteRule{from, to} in tag.rewrite_rules {
            let from = from.unwrap_curly_brace();
            let to = to.unwrap_curly_brace();
            match (from, to) {
                (Some(from), Some(to)) => {
                    children = match_and_apply_rewrite_rule(
                        from.clone(),
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
            rewrite_rules: Vec::new(),
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
        }
    };
    let g = |env: &mut crate::compiler::CompilerEnv, scope: NodeScope, node: Node| -> Vec<Node> {
        match node {
            Node::Tag(tag) if tag.has_name("include") => {
                let file_path = tag.attributes
                    .get("src")
                    .and_then(|x| x.value)
                    .map(|x| x.data)
                    .filter(|x| x.ends_with(".ss"));
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
                if let Some(file_path) = file_path {
                    let file_path = PathBuf::from(file_path);
                    let file_path = env.normalize_file_path(file_path);
                    let (sub_env, nodes) = crate::compiler::low_level_api::parse(file_path);
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
                vec![]
            }
            node @ Node::Tag(_) => vec![node],
            node @ Node::Enclosure(_) => vec![node],
            node @ Node::Text(_) => vec![node],
            node @ Node::Ident(_) => vec![node],
            node @ Node::InvalidToken(_) => vec![node],
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

