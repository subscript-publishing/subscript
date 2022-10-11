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
pub use crate::ss::parser::{Ann, CharIndex, CharRange, Ident, IdentInitError};
use crate::ss::SemanticScope;
use crate::ss::ast_traits::{SyntacticallyEq, StrictlyEq};

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone)]
pub struct RewriteRule<T> {
    pub pattern: T,
    pub target: T,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS - AST METADATA TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Debug, Clone, PartialEq)]
pub enum BracketType {
    CurlyBrace,
    SquareParen,
    Parens,
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS AST NODE LEAFS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Debug, Clone)]
pub struct Bracket {
    pub open: Option<Ann<String>>,
    pub close: Option<Ann<String>>,
    pub children: Vec<Node>,
}

#[derive(Debug, Clone)]
pub struct Quotation {
    pub open: Option<Ann<String>>,
    pub close: Option<Ann<String>>,
    pub children: Vec<Node>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct Text(String);


// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COMMAND CALL
// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone)]
pub struct CmdCall {
    pub identifier: Ann<Ident>,
    /// WARNING: At the time of this writing, syntactic
    /// equality does not check attributes. 
    pub attributes: Attributes,
    pub arguments: Vec<Node>,
}


// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COMMAND ATTRIBUTES
// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Default)]
pub struct Attributes(VecDeque<Attribute>);

impl Attributes {
    pub fn from_iter<K, V>(
        xs: impl IntoIterator<Item = (K, V)>
    ) -> Attributes where K: crate::ss::ast_traits::ToNode, V: crate::ss::ast_traits::ToNode {
        let xs = xs
            .into_iter()
            .map(|(key, value)| {
                let key = key
                    .to_node()
                    .defragment_node_tree()
                    .trim_whitespace();
                let value = value
                    .to_node()
                    .defragment_node_tree()
                    .trim_whitespace();
                Attribute{key, value}
            })
            .collect::<VecDeque<_>>();
        Attributes(xs)
    }
    pub fn insert(
        &mut self,
        key: impl crate::ss::ast_traits::ToNode,
        value: impl crate::ss::ast_traits::ToNode
    ) -> Option<Attribute> {
        let key = key.to_node();
        let value = value.to_node();
        let new_attribute = Attribute{key, value};
        for entry in self.0.iter_mut() {
            if entry.key.syn_eq(&new_attribute.key) {
                let old = entry.clone();
                *entry = new_attribute;
                return Some(old)
            }
        }
        self.0.push_back(new_attribute);
        None
    }
    pub fn get(&self, key: impl crate::ss::ast_traits::AsNodeRef) -> Option<&Attribute> {
        let key = key.as_node_ref();
        for entry in self.0.iter() {
            match key {
                Cow::Borrowed(x_key) => {
                    if entry.key.syn_eq(x_key) {
                        return Some(entry)
                    }
                }
                Cow::Owned(ref x_key) => {
                    if entry.key.syn_eq(x_key) {
                        return Some(entry)
                    }
                }
            }
        }
        None
    }
    pub fn has_attr(&self, key: impl crate::ss::ast_traits::AsNodeRef) -> bool {
        self.get(key).is_some()
    }
    pub fn consume(self) -> VecDeque<Attribute> {
        self.0
    }
    pub fn get_str_keys(&self) -> HashSet<String> {
        self.0
            .iter()
            .filter_map(|Attribute {key, ..}| {
                key.clone()
                    .trim_whitespace()
                    .into_text()
                    .map(|x| x.value.clone())
            })
            .collect::<HashSet<_>>()
    }
    // pub fn map(self, f: impl Fn(Node) -> Node) -> Attributes {
    //     let xs = self.0
    //         .into_iter()
    //         .map(|mut attr| {
    //             attr.key = f(attr.key);
    //             attr.value = f(attr.value);
    //             attr
    //         })
    //         .collect_vec();
    //     unimplemented!()
    // }
}

#[derive(Debug, Clone)]
pub struct Attribute {
    pub key: Node,
    pub value: Node,
}



//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// AST
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone)]
pub enum Node {
    /// Recognized commands. 
    Cmd(CmdCall),
    /// Some identifier.
    /// 
    /// After post-parser processing, any `Node::Ident` values mean that such
    /// did not match against the given list of commands.
    Ident(Ann<Ident>),
    Bracket(Ann<Bracket>),
    Quotation(Ann<Quotation>),
    /// Arbitrary characters.
    /// WARNING (at the time of this writing):
    /// * Two `Node::Text(…)` values are always syntactically equal to
    ///   each other.
    /// * In contrast, `Node::Symbol(x)` is only syntactically equal to
    ///   `Node::Symbol(y)` if `x` is syntactically equal to `y`.
    /// UPDATE:
    /// * Nevermind, I’m currently `Text` values as well. Unless I happen to
    ///   change it and forget to update this doc comment.
    Text(Ann<String>),
    Symbol(Ann<String>),
    // /// Some special character
    // Symbol(Ann<String>),
    /// Some unbalanced token that isn’t associated with an enclosure. 
    /// In Subscript, enclosure symbols must be balanced. If the author
    /// must use such in their publications, then use the tag version. 
    InvalidToken(Ann<String>),
    /// WARNING:
    /// * Two `Node::Drawing(…)` values are always syntactically equal to
    /// each other.
    Drawing(ss_freeform_format::DrawingDataModel),
    /// An internal array of Nodes. 
    /// 
    /// This value really complicates syntactic equality. 
    Fragment(Vec<Node>),
}

impl Display for Node {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.to_string())
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Debug, Clone)]
pub struct Children(pub Vec<Node>);

impl Display for Children {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let xs = self.0.iter().map(|x| format!("{}", x)).join("\n");
        write!(f, "{}", xs)
    }
}

