//! Frontend AST data types & related.
use std::cell::RefCell;
use std::fmt::Display;
use std::path::PathBuf;
use std::rc::Rc;
use std::borrow::{Borrow, Cow};
use std::collections::{HashSet, VecDeque, LinkedList, HashMap};
use std::iter::FromIterator;
use std::vec;
use itertools::Itertools;
use serde::{Serialize, Deserialize};
use crate::data::*;
pub use crate::cmds::data::{CmdCall, Attribute, Attributes, SemanticScope};
pub use crate::subscript::parser::{Ann, CharIndex, CharRange, Ident, IdentInitError};




// ////////////////////////////////////////////////////////////////////////////
// MISCELLANEOUS AST NODE LEAFS
// ////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone)]
pub struct RewriteRule {
    pub from: Node,
    pub to: Node,
}

#[derive(Debug, Clone)]
pub struct Bracket {
    pub open: Option<Ann<String>>,
    pub close: Option<Ann<String>>,
    pub children: Vec<Node>,
}

impl Bracket {
    pub fn kind(&self) -> Option<BracketType> {
        match ((self.open.as_ref(), self.close.as_ref())) {
            (Some(open), Some(close)) if open.value == "{" && close.value == "}" => {
                Some(BracketType::CurlyBrace)
            }
            (Some(open), Some(close)) if open.value == "[" && close.value == "]" => {
                Some(BracketType::SquareParen)
            }
            (Some(open), Some(close)) if open.value == "(" && close.value == ")" => {
                Some(BracketType::Parens)
            }
            _ => None
        }
    }
    pub fn to_unicode_brackets(&self) -> Option<(&'static str, &'static str)> {
        match self.kind()? {
            BracketType::Parens => Some(("（", "）")),
            BracketType::SquareParen => Some(("［", "］")),
            BracketType::CurlyBrace => Some(("｛", "｝")),
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
pub enum BracketType {
    CurlyBrace,
    SquareParen,
    Parens,
}


#[derive(Debug, Clone)]
pub struct Quotation {
    pub open: Option<Ann<String>>,
    pub close: Option<Ann<String>>,
    pub children: Vec<Node>,
}

impl Quotation {
    pub fn to_unicode_quotation(&self) -> Option<(&'static str, &'static str)> {
        match (self.open.as_ref()?.value.as_str(), self.close.as_ref()?.value.as_str()) {
            ("\"", "\"") => Some(("“", "”")),
            ("'", "'") => Some(("‘", "’")),
            _ => None
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct Text(String);



// ////////////////////////////////////////////////////////////////////////////
// ATTRIBUTES
// ////////////////////////////////////////////////////////////////////////////



// ////////////////////////////////////////////////////////////////////////////
// FRONTEND
// ////////////////////////////////////////////////////////////////////////////

// #[derive(Debug, Clone)]
// pub struct Cmd {
//     pub name: Ann<String>,
//     pub attributes: Attributes,
//     /// Each child node generally should be an `Enclosure` (with the `CurlyBrace` kind).
//     /// Until perhaps the codegen.
//     pub children: Vec<Node>,
//     pub rewrite_rules: Vec<RewriteRule>,
// }

// impl Cmd {
//     /// Some tag with no parameters and just children.
//     pub fn new<T: Into<Ann<String>>>(name: T, children: Vec<Node>) -> Self {
//         Cmd{
//             name: name.into(),
//             attributes: Default::default(),
//             children,
//             rewrite_rules: Vec::new(),
//         }
//     }
//     pub fn new_with_param<T: Into<Ann<String>>>(name: T, params: Attributes, children: Vec<Node>) -> Cmd {
//         Cmd{
//             name: name.into(),
//             attributes: params,
//             children,
//             rewrite_rules: Vec::new(),
//         }
//     }
//     pub fn has_name(&self, name: &str) -> bool {
//         return self.name() == name
//     }
//     pub fn has_attr(&self, key: &str) -> bool {
//         self.attributes.has_attr(key)
//     }
//     pub fn name(&self) -> &str {
//         &self.name.value
//     }
//     pub fn to_string(&self) -> String {
//         Node::Cmd(self.clone()).to_string()
//     }
//     pub fn is_heading_node(&self) -> bool {
//         HEADING_TAG_NAMES.contains(self.name())
//     }
// }

// #[derive(Debug, Clone, Default)]
// pub struct NodeScope {
//     pub parents: Vec<String>,
// }

// impl NodeScope {
//     pub fn push_parent(&mut self, name: String) {
//         self.parents.push(name)
//     }
//     pub fn is_math_env(&self) -> bool {
//         self.parents
//             .iter()
//             .any(|x| {
//                 let option1 = x == INLINE_MATH_TAG;
//                 let option2 = BLOCK_MATH_TAGS.iter().any(|y| {
//                     x == *y
//                 });
//                 option1 || option2
//             })
//     }
//     pub fn is_default_env(&self) -> bool {
//         !self.is_math_env()
//     }
//     pub fn has_parent(&self, parent: &str) -> bool {
//         self.parents
//             .iter()
//             .any(|x| x == parent)
//     }
// }


// ////////////////////////////////////////////////////////////////////////////
// AST
// ////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone)]
pub enum Node {
    /// Recognized commands. 
    Cmd(CmdCall),
    /// Some identifier that may or may not be followed by square parentheses
    /// and/or a curly brace enclosure. E.g. `\name`.
    Ident(Ann<Ident>),
    Bracket(Ann<Bracket>),
    Quotation(Ann<Quotation>),
    /// Arbitrary characters.
    Text(Ann<String>),
    Symbol(Ann<String>),
    // /// Some special character
    // Symbol(Ann<String>),
    /// Some unbalanced token that isn’t associated with an enclosure. 
    /// In Subscript, enclosure symbols must be balanced. If the author
    /// must use such in their publications, then use the tag version. 
    InvalidToken(Ann<String>),
    // MacroDecl(Ann<MacroDecl>),
    HtmlCode(String),
    /// An internal array of Nodes. 
    Fragment(Vec<Node>),
}


impl Node {
    /// Some tag with no parameters and just children.
    // pub fn new_tag<T: Into<Ann<String>>>(name: T, children: Vec<Node>) -> Self {
    //     Node::Cmd(Cmd::new(name.into(), children))
    // }
    pub fn new_ident<T: Into<Ann<String>>>(str: T) -> Result<Self, IdentInitError> {
        let ann: Ann<Ident> = str.into().to_ident()?;
        Ok(Node::Ident(ann))
    }
    pub fn match_ident_id(&self, id: &Ident) -> bool {
        match self {
            Node::Ident(Ann{value, ..}) => value == id,
            _ => false,
        }
    }
    pub fn is_fragment(&self) -> bool {
        match self {
            Node::Fragment(_) => true,
            _ => false,
        }
    }
    pub fn fragment_len(&self) -> Option<usize> {
        match self {
            Node::Fragment(xs) => Some(xs.len()),
            _ => None,
        }
    }
    pub fn new_bracket<T: Into<Ann<String>>>(
        range: CharRange,
        open: T,
        close: T,
        children: Vec<Node>,
    ) -> Self {
        Node::Bracket(Ann::new(range, Bracket {
            open: Some(open.into()),
            close: Some(close.into()),
            children
        }))
    }
    pub fn new_text<T: Into<Ann<String>>>(str: T) -> Self {
        Node::Text(str.into())
    }
    /// Used for converting attribute related nodes to strings. 
    /// Unwrap a `Node` that can be interpreted as a string
    /// Unwraps
    /// - `Node::Text`
    /// - `Node::Ident`
    /// - `Node::Symbol`
    /// - `Node::Quotation` (with quotes removed)
    /// - `Node::Fragment`
    pub fn as_stringified_attribute_value_str(self, join: &str) -> Option<String> {
        match self {
            Node::Ident(Ann{value, ..}) => Some(value.to_tex_ident().to_string()),
            Node::Text(Ann{value, ..}) => Some(value),
            Node::Symbol(Ann{value, ..}) => Some(value),
            Node::Quotation(Ann{value: Quotation{children, ..}, ..}) => {
                let mut contents: Vec<String> = Vec::new();
                for child in children {
                    contents.push(child.as_stringified_attribute_value_str(join)?);
                }
                Some(contents.join(join))
            }
            Node::Fragment(children) => {
                let mut contents: Vec<String> = Vec::new();
                for child in children {
                    contents.push(child.as_stringified_attribute_value_str(join)?);
                }
                Some(contents.join(join))
            }
            _ => None,
        }
    }
    // pub fn unannotated_curly_brace_enclosure(children: Vec<Node>) -> Self {
    //     Node::Enclosure(Ann::unannotated(Enclosure {
    //         open: Some(Ann::unannotated(String::from("{"))),
    //         close: Some(Ann::unannotated(String::from("}"))),
    //         children
    //     }))
    // }
    // pub fn unannotated_square_paren_enclosure(children: Vec<Node>) -> Self {
    //     Node::Enclosure(Ann::unannotated(Enclosure {
    //         open: Some(Ann::unannotated(String::from("["))),
    //         close: Some(Ann::unannotated(String::from("]"))),
    //         children
    //     }))
    // }
    // pub fn unannotated_paren_enclosure(children: Vec<Node>) -> Self {
    //     Node::Enclosure(Ann::unannotated(Enclosure {
    //         open: Some(Ann::unannotated(String::from("("))),
    //         close: Some(Ann::unannotated(String::from(")"))),
    //         children
    //     }))
    // }
    // pub fn unannotated_string_enclosure(children: Vec<Node>) -> Self {
    //     Node::Enclosure(Ann::unannotated(Enclosure {
    //         open: Some(Ann::unannotated(String::from("("))),
    //         close: Some(Ann::unannotated(String::from(")"))),
    //         children
    //     }))
    // }
    // pub fn unannotated_text<T: Into<Ann<String>>>(str: T) -> Self {
    //     Node::Text(str.into())
    // }
    pub fn is_whitespace(&self) -> bool {
        match self {
            Node::Text(txt) => {
                let x: &str = &txt.value;
                x.trim().is_empty()
            },
            _ => false
        }
    }
    pub fn is_cmd(&self) -> bool {
        match self {
            Node::Cmd(_) => true,
            _ => false,
        }
    }
    pub fn is_cmd_with_name<T: AsRef<str>>(&self, tag: T) -> bool {
        match self {
            Node::Cmd(node) => node.identifier.value == tag.as_ref(),
            _ => false,
        }
    }
    // pub fn is_ident_with_id<T: AsRef<str>>(&self, ) -> bool {
    //     match self {
    //         Node::Ident(node) => node.identifier.value == tag.as_ref(),
    //         _ => false,
    //     }
    // }
    pub fn has_attr<T: Into<Ann<String>>>(&self, key: T) -> bool {
        match self {
            Node::Cmd(node) => node.attributes.has_attr(key.into()),
            _ => false,
        }
    }
    pub fn is_ident(&self) -> bool {
        match self {
            Node::Ident(_) => true,
            _ => false,
        }
    }
    pub fn is_bracket(&self) -> bool {
        match self {
            Node::Bracket(_) => true,
            _ => false,
        }
    }
    pub fn bracket_kind(&self) -> Option<BracketType> {
        match self {
            Node::Bracket(x) => x.value.kind(),
            _ => None,
        }
    }
    pub fn is_quotation(&self) -> bool {
        match self {
            Node::Quotation(_) => true,
            _ => false,
        }
    }
    pub fn is_text(&self) -> bool {
        match self {
            Node::Text(_) => true,
            _ => false,
        }
    }
    pub fn text_equal_to(&self, value: &str) -> bool {
        match self {
            Node::Text(ann) => ann.value == value,
            _ => false,
        }
    }
    // pub fn is_any_enclosure(&self) -> bool {
    //     match self {
    //         Node::Enclosure(_) => true,
    //         _ => false,
    //     }
    // }
    // pub fn is_enclosure_of_kind(&self, k: EnclosureKind) -> bool {
    //     match self {
    //         Node::Enclosure(Ann{data, ..}) => {
    //             data.kind() == k
    //         },
    //         _ => false,
    //     }
    // }
    // pub fn unpack_enclosure_kind(&self) -> Option<EnclosureKind> {
    //     match self {
    //         Node::Enclosure(Ann{data, ..}) => {
    //             Some(data.kind())
    //         },
    //         _ => None,
    //     }
    // }
    // pub fn get_text(&self) -> Option<Ann<String>> {
    //     match self {
    //         Node::Text(val) => Some(val.clone()),
    //         _ => None,
    //     }
    // }
    // pub fn get_enclosure_children(&self, kind: EnclosureKind) -> Option<&Vec<Node>> {
    //     match self {
    //         Node::Enclosure(Ann{
    //             data: x,
    //             ..
    //         }) if x.kind() == kind => {
    //             Some(x.children.as_ref())
    //         }
    //         _ => None,
    //     }
    // }
    pub fn unblock(self, for_bracket: BracketType) -> Vec<Self> {
        match self {
            Node::Bracket(x) if x.value.kind() == Some(BracketType::CurlyBrace) => {
                x.value.children
            }
            x => vec![x]
        }
    }
    // pub fn unwrap_tag(&self) -> Option<&CmdCall> {
    //     match self {
    //         Node::Cmd(x) => Some(x),
    //         _ => None,
    //     }
    // }
    pub fn unwrap_quotation(&self, for_quote: &str) -> Option<&Vec<Node>> {
        match self {
            Node::Quotation(x) => {
                let open: Option<&str> = x.value.open.as_ref().map(|x| x.value.as_ref());
                let close: Option<&str> = x.value.close.as_ref().map(|x| x.value.as_ref());
                match (open, close) {
                    (Some(x), Some(y)) if x == for_quote && y == for_quote => {
                        unimplemented!()
                    }
                    _ => None
                }
            },
            _ => None,
        }
    }
    // pub fn unwrap_tag_mut(&mut self) -> Option<&mut CmdCall> {
    //     match self {
    //         Node::Cmd(x) => Some(x),
    //         _ => None,
    //     }
    // }
    pub fn unwrap_ident<'b>(&'b self) -> Option<&'b Ann<Ident>> {
        match self {
            Node::Ident(x) => Some(x),
            _ => None,
        }
    }
    pub fn unwrap_bracket<'b>(&'b self) -> Option<&Ann<Bracket>> {
        match self {
            Node::Bracket(x) => Some(x),
            _ => None,
        }
    }
    pub fn is_curly_brace(&self) -> bool {
        match self {
            Node::Bracket(Ann{value,..}) => value.kind() == Some(BracketType::CurlyBrace),
            _ => false,
        }
    }
    pub fn unpack_curly_brace(&self) -> Option<&[Node]> {
        match self {
            Node::Bracket(x) if x.value.kind() == Some(BracketType::CurlyBrace) => Some(x.value.children.as_ref()),
            _ => None,
        }
    }
    pub fn unwrap_curly_brace(self) -> Option<Vec<Node>> {
        match self {
            Node::Bracket(x) if x.value.kind() == Some(BracketType::CurlyBrace) => Some(x.value.children),
            _ => None,
        }
    }
    pub fn unwrap_square_paren(&self) -> Option<&[Node]> {
        match self {
            Node::Bracket(x) if x.value.kind() == Some(BracketType::SquareParen) => {
                Some(x.value.children.as_ref())
            },
            _ => None,
        }
    }
    pub fn unwrap_text<'b>(&'b self) -> Option<&'b Ann<String>> {
        match self {
            Node::Text(x) => Some(x),
            _ => None,
        }
    }
    pub fn consume_text(self) -> Option<Ann<String>> {
        match self {
            Node::Text(x) => Some(x),
            _ => None,
        }
    }
    pub fn unwrap_symbol<'b>(&'b self) -> Option<&'b Ann<String>> {
        match self {
            Node::Symbol(x) => Some(x),
            _ => None,
        }
    }
    pub fn unwrap_text_own(self) -> Option<Ann<String>> {
        match self {
            Node::Text(x) => Some(x),
            _ => None,
        }
    }
    pub fn unwrap_text_mut<'b>(&'b mut self) -> Option<&'b mut Ann<String>> {
        match self {
            Node::Text(x) => Some(x),
            _ => None,
        }
    }
    pub fn into_tag(self) -> Option<CmdCall> {
        match self {
            Node::Cmd(x) => Some(x),
            _ => None,
        }
    }

    // pub fn inspect<T, F: Fn(NodeScope, &Node, &mut T) -> ()>(
    //     &self,
    //     acc: &mut T,
    //     mut env: NodeScope,
    //     f: Rc<F>
    // ) {
    //     match self {
    //         node @ Node::Cmd(tag) => {
    //             env.push_parent(tag.name.value.clone());
    //             tag.children
    //                 .iter()
    //                 .map(|x| x.inspect(acc, env.clone(), f.clone()))
    //                 .collect::<Vec<_>>();
    //             tag.rewrite_rules
    //                 .iter()
    //                 .map(|rule| {
    //                     rule.from.inspect(acc, env.clone(), f.clone());
    //                     rule.to.inspect(acc, env.clone(), f.clone());
    //                 })
    //                 .collect::<Vec<_>>();
    //             f(env.clone(), node, acc)
    //         }
    //         node @ Node::Bracket(inner) => {
    //             inner.value.children
    //                 .iter()
    //                 .map(|x| x.inspect(acc, env.clone(), f.clone()))
    //                 .collect::<Vec<_>>();
    //             f(env.clone(), node, acc)
    //         }
    //         node @ Node::Quotation(inner) => {
    //             inner.value.children
    //                 .iter()
    //                 .map(|x| x.inspect(acc, env.clone(), f.clone()))
    //                 .collect::<Vec<_>>();
    //             f(env.clone(), node, acc)
    //         }
    //         node @ Node::Fragment(xs) => {
    //             xs
    //                 .iter()
    //                 .map(|x| x.inspect(acc, env.clone(), f.clone()))
    //                 .collect::<Vec<_>>();
    //             f(env.clone(), node, acc)
    //         }
    //         node @ Node::Ident(_) => {
    //             f(env.clone(), node, acc)
    //         }
    //         node @ Node::Text(_) => {
    //             f(env.clone(), node, acc)
    //         }
    //         node @ Node::Symbol(_) => {
    //             f(env.clone(), node, acc)
    //         }
    //         node @ Node::InvalidToken(_) => {
    //             f(env.clone(), node, acc)
    //         }
    //         node @ Node::HtmlCode(_) => {
    //             f(env.clone(), node, acc)
    //         }
    //     }
    // }

    /// **Dangerous!!** Only use for analysis on clones of the AST. 
    pub fn trim_whitespace(self) -> Self {
        let env = SemanticScope::default();
        fn f(env: SemanticScope, node: Node) -> Node {
            match node {
                Node::Text(txt) => {
                    let txt = txt.value.trim();
                    Node::Text(txt.into())
                }
                x => x
            }
        }
        fn g(nodes: Vec<Node>) -> Vec<Node> {
            nodes
                .into_iter()
                .filter(|x| {
                    match x {
                        Node::Text(txt) => {
                            !txt.value.is_empty()
                        }
                        x => true
                    }
                })
                .collect_vec()
        }
        self.transform(env, Rc::new(f))
            .transform_children(Rc::new(g))
    }

    /// Bottom up 'node to ndoe' transformation.
    pub fn transform<F: Fn(SemanticScope, Node) -> Node>(
        self,
        env: SemanticScope,
        f: Rc<F>
    ) -> Self {
        match self {
            Node::Cmd(mut cmd) => {
                let sub_env = env.new_scope(cmd.identifier.value.clone());
                // env.push_parent(node.name.value.clone());
                cmd.arguments = cmd.arguments
                    .into_iter()
                    .map(|x| x.transform(sub_env.clone(), f.clone()))
                    .collect();
                // let rewrite_rules = node.rewrite_rules
                //     .into_iter()
                //     .map(|rule| -> RewriteRule {
                //         RewriteRule {
                //             from: rule.from.transform(env.clone(), f.clone()),
                //             to: rule.to.transform(env.clone(), f.clone()),
                //         }
                //     })
                //     .collect();
                f(env.clone(), Node::Cmd(cmd))
            }
            Node::Bracket(node) => {
                let range = node.range;
                let children = node.value.children
                    .into_iter()
                    .map(|x| x.transform(env.clone(), f.clone()))
                    .collect();
                let data = Bracket{
                    open: node.value.open,
                    close: node.value.close,
                    children,
                };
                let node = Node::Bracket(Ann::join(range, data));
                f(env.clone(), node)
            }
            Node::Quotation(node) => {
                let range = node.range;
                let children = node.value.children
                    .into_iter()
                    .map(|x| x.transform(env.clone(), f.clone()))
                    .collect();
                let data = Quotation{
                    open: node.value.open,
                    close: node.value.close,
                    children,
                };
                let node = Node::Quotation(Ann::join(range, data));
                f(env.clone(), node)
            }
            Node::Fragment(xs) => {
                let xs = xs
                    .into_iter()
                    .map(|x| x.transform(env.clone(), f.clone()))
                    .collect();
                let node = Node::Fragment(xs);
                f(env.clone(), node)
            }
            node @ Node::Ident(_) => {
                f(env.clone(), node)
            }
            node @ Node::Text(_) => {
                f(env.clone(), node)
            }
            node @ Node::Symbol(_) => {
                f(env.clone(), node)
            }
            node @ Node::InvalidToken(_) => {
                f(env.clone(), node)
            }
            node @ Node::HtmlCode(_) => {
                f(env.clone(), node)
            }
        }
    }

    pub fn transform_mut<F: FnMut(SemanticScope, Node) -> Node>(
        self,
        scope: SemanticScope,
        f: Rc<RefCell<F>>
    ) -> Self {
        match self {
            Node::Cmd(mut cmd) => {
                let sub_scope = scope.new_scope(cmd.identifier.value.clone());
                cmd.arguments = cmd.arguments
                    .into_iter()
                    .map(|x| x.transform_mut(sub_scope.clone(), f.clone()))
                    .collect();
                // let rewrite_rules = node.rewrite_rules
                //     .into_iter()
                //     .map(|rule| -> RewriteRule {
                //         RewriteRule {
                //             from: rule.from.transform_mut(scope.clone(), f.clone()),
                //             to: rule.to.transform_mut(scope.clone(), f.clone()),
                //         }
                //     })
                //     .collect();
                (f.borrow_mut())(scope.clone(), Node::Cmd(cmd))
            }
            Node::Bracket(node) => {
                let range = node.range;
                let children = node.value.children
                    .into_iter()
                    .map(|x| x.transform_mut(scope.clone(), f.clone()))
                    .collect();
                let data = Bracket{
                    open: node.value.open,
                    close: node.value.close,
                    children,
                };
                let node = Node::Bracket(Ann::join(range, data));
                (f.borrow_mut())(scope.clone(), node)
            }
            Node::Quotation(node) => {
                let range = node.range;
                let children = node.value.children
                    .into_iter()
                    .map(|x| x.transform_mut(scope.clone(), f.clone()))
                    .collect();
                let data = Quotation{
                    open: node.value.open,
                    close: node.value.close,
                    children,
                };
                let node = Node::Quotation(Ann::join(range, data));
                (f.borrow_mut())(scope.clone(), node)
            }
            Node::Fragment(xs) => {
                let xs = xs
                    .into_iter()
                    .map(|x| x.transform_mut(scope.clone(), f.clone()))
                    .collect();
                let node = Node::Fragment(xs);
                (f.borrow_mut())(scope.clone(), node)
            }
            node @ Node::Ident(_) => {
                (f.borrow_mut())(scope.clone(), node)
            }
            node @ Node::Text(_) => {
                (f.borrow_mut())(scope.clone(), node)
            }
            node @ Node::Symbol(_) => {
                (f.borrow_mut())(scope.clone(), node)
            }
            node @ Node::InvalidToken(_) => {
                (f.borrow_mut())(scope.clone(), node)
            }
            node @ Node::HtmlCode(_) => {
                (f.borrow_mut())(scope.clone(), node)
            }
        }
    }
    /// Bottom up transformation of AST child nodes within the same enclosure.
    pub fn transform_children<F>(
        self,
        f: Rc<F>
    ) -> Self where F: Fn(Vec<Node>) -> Vec<Node> {
        match self {
            Node::Cmd(mut cmd) => {
                cmd.arguments = cmd.arguments
                    .into_iter()
                    .map(|x| -> Node {
                        x.transform_children(f.clone())
                    })
                    .collect::<Vec<_>>();
                cmd.arguments = f(cmd.arguments);
                // let rewrite_rules = node.rewrite_rules
                //     .into_iter()
                //     .map(|rule| -> RewriteRule {
                //         RewriteRule {
                //             from: rule.from.transform_children(f.clone()),
                //             to: rule.to.transform_children(f.clone()),
                //         }
                //     })
                //     .collect();
                Node::Cmd(cmd)
            }
            Node::Bracket(node) => {
                let range = node.range();
                let children = node.value.children
                    .into_iter()
                    .map(|x| x.transform_children(f.clone()))
                    .collect();
                let children = (f)(children);
                let data = Bracket{
                    open: node.value.open,
                    close: node.value.close,
                    children,
                };
                Node::Bracket(Ann::join(range, data))
            }
            Node::Quotation(node) => {
                let range = node.range();
                let children = node.value.children
                    .into_iter()
                    .map(|x| x.transform_children(f.clone()))
                    .collect();
                let children = (f)(children);
                let data = Quotation{
                    open: node.value.open,
                    close: node.value.close,
                    children,
                };
                Node::Quotation(Ann::join(range, data))
            }
            Node::Fragment(xs) => {
                let xs = xs
                    .into_iter()
                    .map(|x| x.transform_children(f.clone()))
                    .collect();
                let xs = (f)(xs);
                Node::Fragment(xs)
            }
            node @ Node::Ident(_) => node,
            node @ Node::Text(_) => node,
            node @ Node::Symbol(_) => node,
            node @ Node::InvalidToken(_) => node,
            node @ Node::HtmlCode(_) => node,
        }
    }
    pub fn to_string(&self) -> String {
        fn enclosure(
            start: String,
            content: String,
            end: Option<String>,
        ) -> String {
            let end = end
                .map(|x| x.to_string())
                .unwrap_or(String::new());
            format!("{}{}{}", start, content, end)
        }
        fn enclosure_str(
            start: &str,
            content: String,
            end: &str,
        ) -> String {
            format!("{}{}{}", start, content, end)
        }
        match self {
            Node::Cmd(cmd) => {
                let name = cmd.identifier.value.to_tex_ident();
                let children = cmd.arguments
                    .iter()
                    .map(|x| x.to_string())
                    .collect::<Vec<_>>()
                    .join("");
                format!("\\{}{}", name, children)
            }
            Node::Bracket(node) => {
                let children = node.value.children
                    .iter()
                    .map(|x| x.to_string())
                    .collect::<Vec<_>>()
                    .join("");
                match node.value.kind() {
                    Some(BracketType::CurlyBrace) => {
                        enclosure_str("{", children, "}")
                    }
                    Some(BracketType::Parens) => {
                        enclosure_str("(", children, ")")
                    }
                    Some(BracketType::SquareParen) => {
                        enclosure_str("[", children, "]")
                    }
                    None => {
                        unimplemented!("todo {:#?}", node.value)
                    }
                }
            }
            Node::Quotation(node) => {
                let children = node.value.children
                    .iter()
                    .map(|x| x.to_string())
                    .collect::<Vec<_>>()
                    .join("");
                let open = node.value.open.as_ref().map(|x| x.value.as_str());
                let close = node.value.close.as_ref().map(|x| x.value.as_str());
                match ((open, close)) {
                    (Some("\""), Some("\"")) => {
                        enclosure_str("\"", children, "\"")
                    }
                    (Some("'"), Some("'")) => {
                        enclosure_str("'", children, "'")
                    }
                    (_, _) => {
                        unimplemented!()
                    }
                }
            }
            Node::Fragment(xs) => {
                xs  .into_iter()
                    .map(|x| x.to_string())
                    .join(" ")
            },
            Node::Ident(x) => x.value.to_tex_ident().to_owned(),
            Node::Text(x) => x.value.clone(),
            Node::Symbol(x) => x.value.clone(),
            Node::InvalidToken(x) => x.value.clone(),
            Node::HtmlCode(_) => "HtmlCode(...)".to_owned()
        }
    }
    /// If the node is a fragment the contents of such are returned.
    /// If the node is not a fragment, it simply returns `vec![x]` for 
    /// a given node `x`. 
    pub fn unpack_fragment(self) -> Vec<Node> {
        match self {
            Node::Fragment(xs) => xs,
            node => vec![node],
        }
    }
    /// Attempt to reduce and eliminate `Node::Fragment` values where possible.
    pub fn defragment_node_tree(self) -> Node {
        match self {
            Node::Cmd(mut cmd) => {
                cmd.arguments = cmd.arguments
                    .into_iter()
                    .flat_map(|x| {
                        x.unpack_fragment()
                    })
                    .collect_vec();
                // node.rewrite_rules = node.rewrite_rules
                //     .into_iter()
                //     .map(|mut x: RewriteRule| {
                //         x.from = x.from.defragment_node_tree();
                //         x.to = x.to.defragment_node_tree();
                //         x
                //     })
                //     .collect_vec();
                Node::Cmd(cmd)
            },
            Node::Bracket(mut node) => {
                node.value.children = node.value.children
                    .into_iter()
                    .flat_map(|x| {
                        x.unpack_fragment()
                    })
                    .collect_vec();
                Node::Bracket(node)
            },
            Node::Quotation(mut node) => {
                node.value.children = node.value.children
                    .into_iter()
                    .flat_map(|x| {
                        x.unpack_fragment()
                    })
                    .collect_vec();
                Node::Quotation(node)
            },
            Node::Fragment(xs) => {
                let xs = xs
                    .into_iter()
                    .flat_map(|x| {
                        x.unpack_fragment()
                    })
                    .collect_vec();
                if xs.len() == 1 {
                    return xs[0].clone()
                }
                Node::Fragment(xs)
            },
            Node::Ident(x) => Node::Ident(x),
            Node::Text(x) => Node::Text(x),
            Node::Symbol(x) => Node::Symbol(x),
            Node::InvalidToken(x) => Node::InvalidToken(x),
            Node::HtmlCode(x) => Node::HtmlCode(x),
        }
    }
    /// You may wanna call `Node::trim_whitespace` and `Node::defragment_node_tree`
    /// before calling this function.
    /// 
    /// WARNING:
    /// * TODO: Should we check attributes?
    pub fn syntactically_equal(&self, other: &Self) -> bool {
        match (self, other) {
            (Node::Cmd(x1), Node::Cmd(x2)) => {
                let check1 = x1.identifier == x2.identifier;
                let check2 = x1.arguments.len() == x2.arguments.len();
                if check1 && check2 {
                    return x1.arguments
                        .iter()
                        .zip(x2.arguments.iter())
                        .all(|(x, y)| {
                            x.syntactically_equal(y)
                        })
                }
                false
            }
            (Node::Bracket(x1), Node::Bracket(x2)) => {
                let check1 = x1.value.kind() == x2.value.kind();
                let check2 = x1.value.children.len() == x2.value.children.len();
                if check1 && check2 {
                    return x1.value.children
                        .iter()
                        .zip(x2.value.children.iter())
                        .all(|(x, y)| {
                            x.syntactically_equal(y)
                        })
                }
                false
            }
            (Node::Quotation(x1), Node::Quotation(x2)) => {
                let check1 = x1.value.open == x2.value.open;
                let check1 = x1.value.close == x2.value.close;
                let check2 = x1.value.children.len() == x2.value.children.len();
                if check1 && check2 {
                    return x1.value.children
                        .iter()
                        .zip(x2.value.children.iter())
                        .all(|(x, y)| {
                            x.syntactically_equal(y)
                        })
                }
                false
            }
            (Node::Ident(x1), Node::Ident(x2)) => {
                &x1.value == &x2.value
            }
            (Node::Text(x1), Node::Text(x2)) => {
                &x1.value == &x2.value
            }
            (Node::InvalidToken(x1), Node::InvalidToken(x2)) => {
                &x1.value == &x2.value
            }
            (Node::Fragment(xs), Node::Fragment(ys)) => {
                xs  .into_iter()
                    .zip(ys.into_iter())
                    .all(|(l, r)| {
                        l.syntactically_equal(r)
                    })
            }
            (Node::Fragment(xs), y) if xs.len() == 1 && !y.is_fragment() => {
                let x = &xs[0];
                x.syntactically_equal(y)
            }
            (x, Node::Fragment(ys)) if ys.len() == 1 && !x.is_fragment() => {
                let y = &ys[0];
                x.syntactically_equal(y)
            }
            (_, _) => false
        }
    }
}

// ////////////////////////////////////////////////////////////////////////////
// MISCELLANEOUS
// ////////////////////////////////////////////////////////////////////////////


impl Display for Node {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.to_string())
    }
}

#[derive(Debug, Clone)]
pub struct Children(pub Vec<Node>);

impl Display for Children {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let xs = self.0.iter().map(|x| format!("{}", x)).join("\n");
        write!(f, "{}", xs)
    }
}

pub trait ToNode {
    fn to_node(self) -> Node;
}

impl ToNode for Node {
    fn to_node(self) -> Node {self}
}

impl ToNode for String {
    fn to_node(self) -> Node {
        Node::Text(Ann::unannotated(self))
    }
}
impl ToNode for &str {
    fn to_node(self) -> Node {
        Node::Text(Ann::unannotated(self.to_string()))
    }
}
impl ToNode for Ann<String> {
    fn to_node(self) -> Node {
        Node::Text(self)
    }
}
impl ToNode for Ann<&str> {
    fn to_node(self) -> Node {
        Node::Text(self.map(|x| x.to_string()))
    }
}

pub trait AsNodeRef {
    fn as_node_ref(&self) -> Cow<Node>;
}
impl AsNodeRef for &Node {
    fn as_node_ref(&self) -> Cow<Node> {
        Cow::Borrowed(self)
    }
}
impl<T> AsNodeRef for T where T: ToNode + Clone {
    fn as_node_ref(&self) -> Cow<Node> {
        let x: T = (*self).clone();
        let x = x.to_node();
        Cow::Owned(x)
    }
}


pub trait ToNodeList {
    fn to_nodes(self) -> Vec<Node>;
}

impl ToNodeList for Vec<Node> {
    fn to_nodes(self) -> Vec<Node> {self}
}
impl ToNodeList for VecDeque<Node> {
    fn to_nodes(self) -> Vec<Node> {
        self.into_iter().collect_vec()
    }
}
impl<T> ToNodeList for T where T: ToNode {
    fn to_nodes(self) -> Vec<Node> {vec![
        unimplemented!()
    ]}
}

