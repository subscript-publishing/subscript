//! Frontend AST to HTML AST conversion.
use std::iter::FromIterator;
use std::collections::{HashSet, HashMap};
use std::rc::Rc;
use std::borrow::Cow;
use crate::compiler::data::*;
use crate::compiler::ast::*;
use crate::compiler::pass;

use crate::codegen::html;

impl Node {
    /// Ensure that `Node` is first canonicalized!
    /// - I.e. make sure the inputs have been passes through the `html_canonicalization` function.
    pub(crate) fn node_to_html(self) -> html::Node {
        enum OpenCloseMode {
            Open,
            Close,
        }
        fn pretty_enclosure_token<'a>(mode: OpenCloseMode, value: String) -> String {
            match (value.as_ref(), mode) {
                ("\"", OpenCloseMode::Open) => String::from("“"),
                ("\"", OpenCloseMode::Close) => String::from("”"),
                // ("{", _) => String::new(),
                // ("}", _) => String::new(),
                (tk, _) => tk.to_string()
            }
        }
        fn map_children(children: Vec<Node>) -> Vec<html::Node> {
            children
                .into_iter()
                .flat_map(crate::compiler::Node::unblock)
                .map(Node::node_to_html)
                .collect::<Vec<_>>()
        }
        fn to_html_attributes(parameters: Attributes) -> HashMap<String, String> {
            parameters
                .into_vec()
                .into_iter()
                // .filter_map(|node| -> Option<String> {
                //     match node {
                //         Node::String(Ann{data: txt, ..}) if !txt.0.trim().is_empty() => {
                //             Some(txt)
                //         }
                //         _ => None
                //     }
                // })
                .map(|(k, v)| -> (String, String) {
                    // if let Some((l, r)) = x.0.split_once("=") {
                    //     (Text(Cow::Owned(l.to_owned())), Text(Cow::Owned(r.to_owned())))
                    // } else {
                    //     (x, Text(Cow::Owned("".to_owned())))
                    // }
                    (k.data, v.map(|x| x.data).unwrap_or_default())
                })
                .collect::<HashMap<_, _>>()
        }
        match self {
            Node::Tag(node) => {
                html::Node::Element(html::Element {
                    name: node.name.data,
                    attributes: to_html_attributes(node.attributes),
                    children: map_children(node.children),
                })
            },
            Node::Enclosure(Ann{data: enclosure, ..}) => {
                let open = enclosure.open
                    .map(|x| pretty_enclosure_token(OpenCloseMode::Open, x.data))
                    .map(|x| vec![html::Node::new_text(x)])
                    .unwrap_or(Vec::new());
                let close = enclosure.close
                    .map(|x| pretty_enclosure_token(OpenCloseMode::Close, x.data))
                    .map(|x| vec![html::Node::new_text(x)])
                    .unwrap_or(Vec::new());
                let children = enclosure.children
                    .into_iter()
                    .map(Node::node_to_html)
                    .collect::<Vec<_>>();
                html::Node::Fragment(vec![open, children, close].concat())
            },
            Node::Ident(Ann{data, ..}) => {
                html::Node::Element(html::Element {
                    name: data,
                    attributes: Default::default(),
                    children: Default::default(),
                })
            },
            Node::Text(Ann{data, ..}) => {
                html::Node::Text(data)
            },
            Node::InvalidToken(Ann{data, ..}) => {
                html::Node::Text(data)
            }
            Node::HtmlCode(code) => {
                html::Node::Text(code)
            }
        }
    }
}
