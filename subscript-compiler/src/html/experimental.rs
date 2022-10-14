use std::collections::HashSet;
use std::rc::Rc;

use itertools::Itertools;
use crate::html;
use crate::ss;

impl html::Node {
    pub fn all_tags(self) -> HashSet<String> {
        match self {
            html::Node::Element(node) => {
                let mut xs = HashSet::new();
                xs.insert(node.name.clone());
                let results = node.children
                    .into_iter()
                    .flat_map(|x| x.all_tags().into_iter().collect_vec())
                    .collect::<HashSet<_>>();
                xs.extend(results);
                xs
            }
            html::Node::Fragment(children) => {
                children
                    .into_iter()
                    .flat_map(|x| x.all_tags())
                    .collect()
            }
            html::Node::Text(_) => Default::default(),
            html::Node::Drawing(_) => Default::default(),
        }
    }
    pub fn html_to_subscript(self) -> Option<ss::Node> {
        fn to_cmd_call(node: html::Element) -> ss::CmdCall {
            let attributes = node.attributes
                .into_iter()
                .map(|(k, v)| {
                    if k == "cols" {
                        return (String::from("col"), v);
                    }
                    (k, v)
                })
                .collect_vec();
            let arguments = node.children
                .into_iter()
                .filter_map(|x| x.html_to_subscript())
                .collect::<Vec<_>>();
            let attributes = ss::Attributes::from_iter(attributes);
            let node = ss::CmdCall{
                identifier: {
                    match node.name.as_str() {
                        "layout" => ss::Ident::from("\\grid").unwrap().into(),
                        _ => ss::Ident::from(format!("\\{}", node.name)).unwrap().into()
                    }
                },
                attributes,
                arguments: {
                    if arguments.is_empty() {
                        vec![]
                    } else {
                        vec![
                            ss::Node::new_curly_brace(arguments)
                        ]
                    }
                },
            };
            node
        }
        fn escape_latex_math(value: String) -> String {
            let try_parse = |value: &str| {
                std::panic::catch_unwind({
                    let value = value.clone();
                    move || {
                        let scope = ss::SemanticScope::test_mode_empty();
                        ss::parser::parse_source(&scope, value)
                    }
                })
                .is_ok()
            };
            if try_parse(&value) {
                return value;
            }
            let value = value
                // .replace("\\left\\{", "\\left\\lbrace")
                // .replace("\\left\\[", "\\left\\lbrack")
                // .replace("\\left\\(", "\\left\\lparen")
                // .replace("\\right\\}", "\\right\\rbrace")
                // .replace("\\right\\]", "\\right\\rbrack")
                // .replace("\\right\\)", "\\right\\rparen")
                .replace("[", "\\lbrack-inline")
                .replace("]", "\\rbrack-inline")
                .replace("{", "\\lbrace-inline")
                .replace("}", "\\rbrace-inline")
                .replace("(", "\\lparen-inline")
                .replace(")", "\\rparen-inline");
            let value = value
                .replace("\\lbrack-inline", "\\lbrack[inline]")
                .replace("\\rbrack-inline", "\\rbrack[inline]")
                .replace("\\lbrace-inline", "\\lbrace[inline]")
                .replace("\\rbrace-inline", "\\rbrace[inline]")
                .replace("\\lparen-inline", "\\lparen[inline]")
                .replace("\\rparen-inline", "\\rparen[inline]");
            assert!(try_parse(&value));
            return value;

            // let mut unbalanaced = false;
            // if value.contains("\\left\\{") {
            //     unbalanaced = true
            // }
            // if value.contains("\\left\\{") {
            //     unbalanaced = true
            // }
            // if value.contains("\\right\\}") {
            //     unbalanaced = true
            // }
            // if unbalanaced {
            //     let value = value
            //         .replace("\\left\\{", "\\left\\lbrace")
            //         .replace("\\right\\}", "\\right\\rbrace")
            //         .replace("\\left\\[", "\\left\\lbrack")
            //         .replace("\\right\\]", "\\right\\rbrack")
            //         .replace("\\left\\(", "\\right\\rbrack")
            //         .replace("[", "\\lbrack{}")
            //         .replace("]", "\\rbrack{}")
            //         .replace("{", "\\lbrace{}")
            //         .replace("}", "\\rbrace{}")
            //         .replace("(", "\\lparen{}")
            //         .replace(")", "\\rparen{}");
            //     assert!(try_parse(value.clone()));
            //     return value;
            // }

            // let pack = |value: String| -> String {
            //     value
            //     // value
            //     //     .lines()
            //     //     .map(|l| l.trim())
            //     //     .collect_vec()
            //     //     .join("\n")
            // };
            // if try_parse(value.clone()) {
            //     return value;
            // }

            // let origional = value.clone();
            
            // let value = origional
            //     .replace("[", "\\lbrack{}")
            //     .replace("]", "\\rbrack{}")
            //     .replace("(", "\\lparen{}")
            //     .replace(")", "\\rparen{}");
            // if try_parse(value.clone()) {
            //     // return pack(value)
            //     return value;
            // }

            // let value = origional
            //     .replace("(", "\\lparen")
            //     .replace(")", "\\rparen");
            // if try_parse(value.clone()) {
            //     // return pack(value)
            //     return value;
            // }

            // let value = origional
            //     .replace("(", "\\lparen")
            //     .replace(")", "\\rparen");
            // if try_parse(value.clone()).is_ok() {
            //     return pack(value)
            // }

            // let value = origional
            //     .replace("[", "\\lbrack{}")
            //     .replace("]", "\\rbrack{}")
            //     .replace("(", "\\lparen")
            //     .replace(")", "\\rparen");
            // if try_parse(value.clone()).is_ok() {
            //     return pack(value)
            // }
            // unimplemented!()
            // let value = value;
                // .replace("[", "\\lbrack{}")
                // .replace("]", "\\rbrack{}")
                // .replace("(", "\\lparen")
                // .replace(")", "\\rparen");
            // assert!(try_parse(value.clone()));
            // value
        }
        match self {
            html::Node::Element(node) if &node.name == "tex" => {
                let str = html::Node::Fragment(node.children).to_html_fragment_str();
                let str = escape_latex_math(str);
                let cmd = ss::CmdCall{
                    identifier: ss::Ident::from("\\").unwrap().into(),
                    attributes: Default::default(),
                    arguments: vec![
                        ss::Node::new_curly_brace(vec![
                            ss::Node::Text(str.into())
                        ])
                    ],
                };
                Some(ss::Node::Cmd(cmd))
            }
            html::Node::Element(node) if &node.name == "equation" => {
                let str = html::Node::Fragment(node.children).to_html_fragment_str();
                let str = escape_latex_math(str);
                let cmd = ss::CmdCall{
                    identifier: ss::Ident::from("\\equation").unwrap().into(),
                    attributes: Default::default(),
                    arguments: vec![
                        ss::Node::new_curly_brace(vec![
                            ss::Node::Text(str.into())
                        ])
                    ],
                };
                Some(ss::Node::Cmd(cmd))
            }
            html::Node::Element(node) if &node.name == "texblock" => {
                let str = html::Node::Fragment(node.children).to_html_fragment_str();
                let str = escape_latex_math(str);
                let cmd = ss::CmdCall{
                    identifier: ss::Ident::from("\\math").unwrap().into(),
                    attributes: Default::default(),
                    arguments: vec![
                        ss::Node::new_curly_brace(vec![
                            ss::Node::Text(str.into())
                        ])
                    ],
                };
                Some(ss::Node::Cmd(cmd))
            }
            // html::Node::Element(node) if &node.name == "th" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "mark" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "tr" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "h3" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "p" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "dl" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "table" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "hr" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "h6" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "h4" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "note" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "ul" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "tbody" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "thead" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "u" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "h1" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "li" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "span" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "dt" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "h5" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "td" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "img" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "h2" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "dd" => {
            //     unimplemented!()
            // }
            // html::Node::Element(node) if &node.name == "layout" => {
            //     unimplemented!()
            // }
            html::Node::Element(node) => {
                Some(ss::Node::Cmd(to_cmd_call(node)))
            }
            html::Node::Fragment(children) => {
                let children = children
                    .into_iter()
                    .filter_map(|x| x.html_to_subscript())
                    .collect();
                let node = ss::Node::Fragment(children);
                Some(node)
            }
            html::Node::Text(text) => {
                Some(ss::Node::Text(text.into()))
            }
            html::Node::Drawing(drawing) => {
                unimplemented!()
            }
        }
    }
}
