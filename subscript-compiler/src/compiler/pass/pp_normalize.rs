//! AST post-parser canonicalization.
use std::rc::Rc;
use std::borrow::Cow;
use std::collections::{HashSet, VecDeque, LinkedList};
use std::iter::FromIterator;
use std::vec;
use itertools::Itertools;

use crate::compiler::data::*;
use crate::compiler::ast::*;


///////////////////////////////////////////////////////////////////////////////
// PARSER AST TO BACKEND AST & NORMALIZATION
///////////////////////////////////////////////////////////////////////////////


fn to_unnormalized_backend_ir(children: Vec<Node>) -> Vec<Node> {
    let mut results: Vec<Node> = Default::default();
    for child in children {
        let last = {
            let mut valid_left_pos = None;
            for ix in (0..results.len()).rev() {
                let leftward = results
                    .get(ix)
                    .filter(|x| !x.is_whitespace());
                if valid_left_pos.is_none() && leftward.is_some() {
                    valid_left_pos = Some(ix);
                    break;
                }
            }
            // results.back_mut()
            // unimplemented!()
            if let Some(ix) = valid_left_pos {
                results.get_mut(ix)
            } else {
                None
            }
        };
        let last_is_ident = last.as_ref().map(|x| x.is_ident()).unwrap_or(false);
        let last_is_tag = last.as_ref().map(|x| x.is_tag()).unwrap_or(false);
        // RETURN NONE IF CHILD IS ADDED TO SOME EXISTING NODE
        let new_child = match child {
            Node::Tag(..) => unimplemented!(),
            Node::Enclosure(node) if last_is_ident && node.data.is_square_parens() => {
                fn to_text<'a>(node: Node) -> Option<String> {
                    match node {
                        Node::Text(txt) => Some(txt.data.to_string()),
                        Node::Enclosure(enclosure) if enclosure.data.is_quote() => {
                            Some(enclosure.data.children
                                .into_iter()
                                .filter_map(to_text)
                                .collect::<String>())
                        },
                        _ => None,
                    }
                }
                let last = last.unwrap();
                let mut name = last
                    .unwrap_ident()
                    .unwrap()
                    .clone();
                let mut segments: Vec<Vec<Node>> = vec![vec![]];
                for child in node.data.children {
                    if child.text_equal_to(",") {
                        segments.push(Vec::new());
                    } else {
                        segments.last_mut().unwrap().push(child);
                    }
                }
                let mut attributes: Attributes = Attributes::default();
                for segment in segments {
                    let mut key: Vec<Node> = Vec::new();
                    let mut value: Vec<Node> = Vec::new();
                    let mut fill_value: bool = false;
                    for child in segment {
                        if child.text_equal_to("=") {
                            fill_value = true;
                            continue;
                        }
                        if fill_value {
                            value.push(child)
                        } else {
                            key.push(child)
                        }
                    }
                    let key = key
                        .into_iter()
                        .filter_map(to_text)
                        .map(|x| x.trim().to_owned())
                        .filter(|x| !x.is_empty())
                        .collect::<String>();
                    let value = value
                        .into_iter()
                        .filter_map(to_text)
                        .map(|x| x.trim().to_owned())
                        .filter(|x| !x.is_empty())
                        .collect::<String>();
                    if !key.is_empty() {
                        if value.is_empty() {
                            attributes.insert_key(key);
                        } else {
                            attributes.insert(
                                key,
                                value
                            );
                        }
                    }
                }
                let new_node = Node::Tag(Tag {
                    name: name.clone(),
                    attributes,
                    children: Vec::new(),
                    rewrite_rules: Vec::new(),
                });
                *last = new_node;
                None
            }
            Node::Enclosure(node) if last_is_ident && node.data.is_curly_brace() => {
                let last = last.unwrap();
                let mut name = last
                    .unwrap_ident()
                    .unwrap()
                    .clone();
                let children = to_unnormalized_backend_ir(node.data.children);
                let new_node = Node::Tag(Tag {
                    name,
                    attributes: Default::default(),
                    children: vec![
                        Node::unannotated_curly_brace_enclosure(children)
                    ],
                    rewrite_rules: Vec::new(),
                });
                *last = new_node;
                None
            }
            Node::Enclosure(node) if last_is_tag && node.data.is_curly_brace() => {
                let tag = last.unwrap();
                let children = to_unnormalized_backend_ir(node.data.children);
                tag.unwrap_tag_mut()
                    .unwrap()
                    .children
                    .push(Node::unannotated_curly_brace_enclosure(children));
                None
            }
            Node::Enclosure(node) => {
                let children = to_unnormalized_backend_ir(node.data.children);
                let new_node = Node::Enclosure(Ann::unannotated(Enclosure {
                    open: node.data.open,
                    close: node.data.close,
                    children,
                }));
                Some(new_node)
            }
            Node::Ident(node) => {
                let new_node = Node::Ident(node);
                Some(new_node)
            }
            Node::InvalidToken(node) => {
                let new_node = Node::Text(node);
                Some(new_node)
            }
            Node::Text(node) => {
                let mut is_token = false;
                for sym in TOKEN_SET {
                    if *sym == &node.data {
                        is_token = true;
                        break;
                    }
                }
                if is_token {
                    Some(Node::Text(node))
                } else {
                    Some(Node::Text(node))
                }
            }
        };
        if let Some(new_child) = new_child {
            results.push(new_child);
        }
    }
    results
}


fn into_rewrite_rules<'a>(
    children: Vec<Node>
) -> Vec<RewriteRule<Node, Node>> {
    let mut results = Vec::new();
    for ix in 0..children.len() {
        if ix == 0 {
            continue;
        }
        let left = children.get(ix - 1);
        let current = children
            .get(ix)
            .and_then(|x| x.unwrap_text())
            .filter(|x| &x.data == "=>");
        let right = children.get(ix + 1);
        match (left, current, right) {
            (Some(left), Some(_), Some(right)) => {
                results.push(RewriteRule {
                    from: left.clone(),
                    to: right.clone(),
                })
            }
            _ => ()
        }
    }
    results
}

fn block_level_normalize<'a>(children: Vec<Node>) -> Vec<Node> {
    let mut results = Vec::new();
    for child in children {
        if child.is_named_block("!where") {
            let child = child.into_tag().unwrap();
            let last = results
                .last_mut()
                .and_then(Node::unwrap_tag_mut);
            if let Some(last) = last {
                let rewrite_rule = into_rewrite_rules(
                    child.children,
                );
                last.rewrite_rules.extend(rewrite_rule);
                continue;
            }
        } else {
            results.push(child);
        }
    }
    results
}

// pub fn parameter_level_normalize_pass(node: Node) -> Node {
//     fn go(parameters: Vec<Node>) -> Vec<Node> {
//         parameters
//             .iter()
//             .filter_map(Node::get_string)
//             .map(|x| x.data.0)
//             .collect::<Vec<_>>()
//             .join("")
//             .split_whitespace()
//             .map(ToOwned::to_owned)
//             .map(|x| Node::String(Ann::unannotated(Text(Cow::Owned(x)))))
//             .collect::<Vec<_>>()
//     }
//     match node {
//         Node::Tag(mut tag) => {
//             tag.parameters = tag.parameters.map(go);
//             Node::Tag(tag)
//         }
//         x => x
//     }
// }


/// Parses the given source code and returns a normalized backend AST vector.
pub fn post_parser_normalize<'a>(source: &'a str) -> Vec<Node> {
    // PARSE SOURCE CODE
    let children = crate::compiler::parser::parse_source(source);
    // NORMALIZE IR
    let children = to_unnormalized_backend_ir(children);
    // NORMALIZE IR
        // .transform(
        //     NodeEnvironment::default(),
        //     Rc::new(|_, x| parameter_level_normalize_pass(x))
        // );
    // DONE
    // node.into_fragment()
    children
        .into_iter()
        .map(|node| node.transform_children(Rc::new(block_level_normalize)))
        .collect_vec()
}
