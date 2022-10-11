//! Everything herein should be safe with no e.g. `unwrap` or `expect` usage
//! (because otherwise if it fails at runtime, the error message will point to
//! this source file which isn’t all the useful). 

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
use crate::ss::parser::IdentInitError;
use crate::ss::ast_data::CmdCall;
use crate::ss::SemanticScope;
use crate::ss::ast_data::{Node, Ann, Ident, Bracket, BracketType, Quotation};

use super::{Attribute, Attributes};


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// NODE CONSTRUCTORS CONVENIENCE METHODS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Node {
    pub fn new_ident<T: Into<Ann<String>>>(str: T) -> Result<Self, IdentInitError> {
        let ann: Ann<Ident> = str.into().to_ident()?;
        Ok(Node::Ident(ann))
    }
    pub fn new_curly_brace(children: Vec<Node>) -> Self {
        Node::Bracket(Ann::unannotated(Bracket{
            open: Some("{".into()),
            close: Some("}".into()),
            children
        }))
    }
    pub fn new_text<T: Into<Ann<String>>>(str: T) -> Self {
        Node::Text(str.into())
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// NODE PREDICATE CONVENIENCE METHODS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Node {
    pub fn match_ident_id(&self, id: &Ident) -> bool {
        match self {
            Node::Ident(Ann{value, ..}) => value == id,
            _ => false,
        }
    }
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
    pub fn is_ident(&self) -> bool {
        match self {
            Node::Ident(_) => true,
            _ => false,
        }
    }
    pub fn is_fragment(&self) -> bool {
        match self {
            Node::Fragment(_) => true,
            _ => false,
        }
    }
    pub fn is_bracket(&self) -> bool {
        match self {
            Node::Bracket(_) => true,
            _ => false,
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
    pub fn is_curly_brace(&self) -> bool {
        match self {
            Node::Bracket(Ann{value,..}) => value.kind() == Some(BracketType::CurlyBrace),
            _ => false,
        }
    }
    pub fn has_attr<T: Into<Ann<String>>>(&self, key: T) -> bool {
        match self {
            Node::Cmd(node) => node.attributes.has_attr(key.into()),
            _ => false,
        }
    }
    pub fn text_equal_to(&self, value: &str) -> bool {
        match self {
            Node::Text(ann) => ann.value == value,
            _ => false,
        }
    }
    pub fn ident_equal_to_str(&self, value: &str) -> bool {
        match self {
            Node::Ident(ann) => ann.value == value,
            _ => false,
        }
    }
    // This is too general, doesn’t convey if it refers to a `CmdCall`
    // identifier or lone `Ident` identifier. 
    // pub fn named(&self, val: &str) -> bool {
    //     match self {
    //         Node::Cmd(cmd) => {
    //             cmd.identifier.value == Ident::from(val).unwrap()
    //         }
    //         _ => false,
    //     }
    // }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// NODE UNWRAPPING CONVENIENCE METHODS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Node {
    pub fn get_ident_ref<'b>(&'b self) -> Option<&'b Ann<Ident>> {
        match self {
            Node::Ident(x) => Some(x),
            _ => None,
        }
    }
    pub fn get_curly_brace_children(&self) -> Option<&[Node]> {
        match self {
            Node::Bracket(x) if x.value.kind() == Some(BracketType::CurlyBrace) => Some(x.value.children.as_ref()),
            _ => None,
        }
    }
    pub fn get_square_paren_children(&self) -> Option<&[Node]> {
        match self {
            Node::Bracket(x) if x.value.kind() == Some(BracketType::SquareParen) => {
                Some(x.value.children.as_ref())
            },
            _ => None,
        }
    }
    pub fn get_whitespace_ref<'b>(&'b self) -> Option<&'b Ann<String>> {
        match self {
            Node::Text(x) if self.is_whitespace() => Some(x),
            _ => None,
        }
    }
    pub fn get_text_ref<'b>(&'b self) -> Option<&'b Ann<String>> {
        match self {
            Node::Text(x) => Some(x),
            _ => None,
        }
    }
    pub fn get_symbol<'b>(&'b self) -> Option<&'b Ann<String>> {
        match self {
            Node::Symbol(x) => Some(x),
            _ => None,
        }
    }
    pub fn into_ident(self) -> Option<Ann<Ident>> {
        match self {
            Node::Ident(x) => Some(x),
            _ => None,
        }
    }
    pub fn into_text(self) -> Option<Ann<String>> {
        match self {
            Node::Text(x) => Some(x),
            _ => None,
        }
    }
    pub fn into_curly_brace_children(self) -> Option<Vec<Node>> {
        match self {
            Node::Bracket(x) if x.value.kind() == Some(BracketType::CurlyBrace) => Some(x.value.children),
            _ => None,
        }
    }
    pub fn bracket_kind(&self) -> Option<BracketType> {
        match self {
            Node::Bracket(x) => x.value.kind(),
            _ => None,
        }
    }
    /// If the given node matches the `BracketType` argument, return its
    /// children, or return a singleton vector of the given node.
    /// 
    /// This is only applied at the topmost (root) level. 
    pub fn unblock_root(self, for_bracket: BracketType) -> Vec<Self> {
        match self {
            Node::Bracket(x) if x.value.kind() == Some(for_bracket) => {
                x.value.children
            }
            x => vec![x]
        }
    }
    /// If the given node is a curly curly brace, returns its children,
    /// otherwise return a singleton vector of the given node. 
    /// 
    /// This is only applied at the topmost (root) level. 
    pub fn unblock_root_curly_brace(self) -> Vec<Self> {
        self.unblock_root(BracketType::CurlyBrace)
    }
    /// If the node is a fragment the contents of such are returned.
    /// If the node is not a fragment, it simply returns `vec![x]` for 
    /// a given node `x`. 
    pub fn unfragment_root(self) -> Vec<Node> {
        match self {
            Node::Fragment(xs) => xs,
            node => vec![node],
        }
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// NODE UNWRAPPING METHODS - WITH SMART/COMPLEX PROCESSING
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Node {
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
    /// **Dangerous!!** Only use for analysis on clones of the AST. 
    pub fn trim_whitespace(self) -> Self {
        fn f(node: Node) -> Node {
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
        self.transform(Rc::new(f))
            .transform_children(Rc::new(g))
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// NODE TRAVERSAL CONVENIENCE METHODS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Node {
    /// Bottom up 'node to ndoe' transformation.
    pub fn transform<F: Fn(Node) -> Node>(self, f: Rc<F>) -> Self {
        match self {
            Node::Cmd(mut cmd) => {
                cmd.arguments = cmd.arguments
                    .into_iter()
                    .map(|x| x.transform(f.clone()))
                    .collect();
                f(Node::Cmd(cmd))
            }
            Node::Bracket(node) => {
                let range = node.range;
                let children = node.value.children
                    .into_iter()
                    .map(|x| x.transform(f.clone()))
                    .collect();
                let data = Bracket{
                    open: node.value.open,
                    close: node.value.close,
                    children,
                };
                let node = Node::Bracket(Ann::join(range, data));
                f(node)
            }
            Node::Quotation(node) => {
                let range = node.range;
                let children = node.value.children
                    .into_iter()
                    .map(|x| x.transform(f.clone()))
                    .collect();
                let data = Quotation{
                    open: node.value.open,
                    close: node.value.close,
                    children,
                };
                let node = Node::Quotation(Ann::join(range, data));
                f(node)
            }
            Node::Fragment(xs) => {
                let xs = xs
                    .into_iter()
                    .map(|x| x.transform(f.clone()))
                    .collect();
                let node = Node::Fragment(xs);
                f(node)
            }
            node @ Node::Ident(_) => {
                f(node)
            }
            node @ Node::Text(_) => {
                f(node)
            }
            node @ Node::Symbol(_) => {
                f(node)
            }
            node @ Node::InvalidToken(_) => {
                f(node)
            }
            node @ Node::Drawing(_) => {
                f(node)
            }
        }
    }
    /// Bottom up transformation of AST child nodes.
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
            node @ Node::Drawing(_) => node,
        }
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// NODE MTHODS - OTHER/MISCELLANEOUS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


impl Node {
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
            Node::Drawing(_) => "HtmlCode(...)".to_owned()
        }
    }
    /// Attempt to reduce and eliminate `Node::Fragment` values where possible.
    pub fn defragment_node_tree(self) -> Node {
        match self {
            Node::Cmd(mut cmd) => {
                cmd.arguments = cmd.arguments
                    .into_iter()
                    .flat_map(|x| {
                        x.unfragment_root()
                    })
                    .collect_vec();
                Node::Cmd(cmd)
            },
            Node::Bracket(mut node) => {
                node.value.children = node.value.children
                    .into_iter()
                    .flat_map(|x| {
                        x.unfragment_root()
                    })
                    .collect_vec();
                Node::Bracket(node)
            },
            Node::Quotation(mut node) => {
                node.value.children = node.value.children
                    .into_iter()
                    .flat_map(|x| {
                        x.unfragment_root()
                    })
                    .collect_vec();
                Node::Quotation(node)
            },
            Node::Fragment(xs) => {
                let xs = xs
                    .into_iter()
                    .flat_map(|x| {
                        x.unfragment_root()
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
            Node::Drawing(x) => Node::Drawing(x),
        }
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// BRACKET & QUOTATION METHODS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

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

impl Quotation {
    pub fn to_unicode_quotation(&self) -> Option<(&'static str, &'static str)> {
        match (self.open.as_ref()?.value.as_str(), self.close.as_ref()?.value.as_str()) {
            ("\"", "\"") => Some(("“", "”")),
            ("'", "'") => Some(("‘", "’")),
            _ => None
        }
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// ATTRIBUTES' METHODS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


impl Attributes {
    pub fn parse_as_attribute_node(node: &Node) -> Option<Attributes> {
        if let Some(attrs) = node.clone().defragment_node_tree().trim_whitespace().get_square_paren_children() {
            let xs = attrs
                .into_iter()
                .group_by(|x| {
                    x.get_symbol()
                        .map(|x| x.value == ",")
                        .unwrap_or(false)
                })
                .into_iter()
                .filter_map(|(key, xs)| -> Option<(Node, Node)> {
                    if key == true {
                        return None
                    }
                    let xs = xs
                        .collect_vec()
                        .into_iter()
                        .group_by(|x| {
                            x.get_symbol()
                            .map(|x| x.value == "=")
                            .unwrap_or(false)
                        })
                        .into_iter()
                        .map(|(key, ys)| {
                            ys.collect_vec()
                        })
                        .map(|xs| {
                            xs  .into_iter()
                                .map(Clone::clone)
                                .collect_vec()
                        })
                        .collect_vec();
                    let mut left: Vec<Node> = Vec::new();
                    let mut equal: Option<Ann<String>> = None;
                    let mut right: Vec<Node> = Vec::new();
                    for mut ys in xs.into_iter() {
                        if equal.is_some() {
                            right.extend(ys);
                            continue;
                        }
                        'inner: for y in ys {
                            if let Some(sym) = y.get_symbol() {
                                if sym.value == "=" {
                                    equal = Some(sym.clone());
                                    continue 'inner;
                                }
                            }
                            left.push(y);
                        }
                    }
                    let left = Node::Fragment(left)
                        .defragment_node_tree()
                        .trim_whitespace();
                    let right = Node::Fragment(right)
                        .defragment_node_tree()
                        .trim_whitespace();
                    return Some((left, right))
                    
                })
                .collect_vec();
            return Some(Attributes::from_iter(xs))
        }
        None
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// CMD-CALL METHODS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl CmdCall {
    fn has_name(&self, ident: &str) -> bool {
        self.identifier.value == ident
    }
    fn has_attr(&self, key: impl crate::ss::ast_traits::AsNodeRef) -> bool {
        self.attributes.has_attr(key)
    }
    pub fn is_heading_node(&self) -> bool {
        self.has_name("\\h1") ||
        self.has_name("\\h2") ||
        self.has_name("\\h3") ||
        self.has_name("\\h4") ||
        self.has_name("\\h5") ||
        self.has_name("\\h6")
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// ATTRIBUTE METHODS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Attribute {
    pub fn to_tuple(&self) -> (&Node, &Node) {
        (&self.key, &self.value)
    }
    pub fn to_key_value_str(self) -> Option<(String, Option<String>)> {
        let key = self.key
            .defragment_node_tree()
            .trim_whitespace()
            .into_text()?
            .consume();
        let value: Option<String> = self.value.as_stringified_attribute_value_str(" ");
        Some((key, value))
    }
}
