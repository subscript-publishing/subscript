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
use crate::ss::ast_traits::{AsNodeRef, ToNode};

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone)]
pub struct RewriteRule<T> {
    pub pattern: T,
    pub target: T,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum HeadingType {
    H1,
    H2,
    H3,
    H4,
    H5,
    H6,
}

impl HeadingType {
    pub fn into_ident(&self) -> Ident {
        match self {
            HeadingType::H1 => Ident::from("\\h1").unwrap(),
            HeadingType::H2 => Ident::from("\\h2").unwrap(),
            HeadingType::H3 => Ident::from("\\h3").unwrap(),
            HeadingType::H4 => Ident::from("\\h4").unwrap(),
            HeadingType::H5 => Ident::from("\\h5").unwrap(),
            HeadingType::H6 => Ident::from("\\h6").unwrap(),
        }
    }
    pub fn from_id(id: &Ident) -> Option<HeadingType> {
        match id.clone().to_tex_ident() {
            "\\h1" => Some(HeadingType::H1),
            "\\h2" => Some(HeadingType::H2),
            "\\h3" => Some(HeadingType::H3),
            "\\h4" => Some(HeadingType::H4),
            "\\h5" => Some(HeadingType::H5),
            "\\h6" => Some(HeadingType::H6),
            _ => None,
        }
    }
    pub fn from_u8(ix: u8) -> Option<HeadingType> {
        match ix {
            0 => Some(HeadingType::H1),
            1 => Some(HeadingType::H2),
            2 => Some(HeadingType::H3),
            3 => Some(HeadingType::H4),
            4 => Some(HeadingType::H5),
            5 => Some(HeadingType::H6),
            _ => None,
        }
    }
    pub fn to_u8(&self) -> u8 {
        match self {
            HeadingType::H1 => 0,
            HeadingType::H2 => 1,
            HeadingType::H3 => 2,
            HeadingType::H4 => 3,
            HeadingType::H5 => 4,
            HeadingType::H6 => 5,
        }
    }
    pub fn to_decrement_amount(&self) -> u8 {
        match self {
            HeadingType::H1 => 0,
            HeadingType::H2 => 1,
            HeadingType::H3 => 2,
            HeadingType::H4 => 3,
            HeadingType::H5 => 4,
            HeadingType::H6 => 5,
        }
    }
    pub fn decrement(&self) -> HeadingType {
        match self {
            HeadingType::H1 => HeadingType::H2,
            HeadingType::H2 => HeadingType::H3,
            HeadingType::H3 => HeadingType::H4,
            HeadingType::H4 => HeadingType::H5,
            HeadingType::H5 => HeadingType::H6,
            HeadingType::H6 => HeadingType::H6,
        }
    }
    pub fn decrement_by(&self, amount: u8) -> HeadingType {
        match amount {
            0 => *self,
            1 => self.decrement(),
            2 => self.decrement().decrement(),
            3 => self.decrement().decrement().decrement(),
            4 => self.decrement().decrement().decrement().decrement(),
            5 | _ => self
                .decrement()
                .decrement()
                .decrement()
                .decrement()
                .decrement(),
        }
    }
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
                    .trim_whitespace()
                    .as_stringified_attribute_value_str("")
                    .unwrap();
                let key = Node::Text(key.into());
                let value = value
                    .to_node()
                    .defragment_node_tree()
                    .trim_whitespace();
                Attribute{key, value}
            })
            .collect::<VecDeque<_>>();
        Attributes(xs)
    }
    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }
    pub fn has_attr(&self, key: impl AsNodeRef) -> bool {
        self.get(key).is_some()
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
    pub fn get(&self, key: impl AsNodeRef) -> Option<&Attribute> {
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
    pub fn get_str_value(&self, key: impl AsNodeRef) -> Option<String> {
        self.get(key)
            .map(Attribute::value)
            .and_then(|x| x.clone().as_stringified_attribute_value_str(""))
    }
    /// Returns true if the attribute key exists, and DOES NOT has a value that
    /// could be interpreted as ‘false’, i.e. isn’t `false` or `0`. 
    pub fn has_truthy_option(&self, key: impl AsNodeRef) -> bool {
        self.get_str_value(key)
            .map(|x| -> bool {
                let check2 = match x.as_str() {
                    "0" => false,
                    "false" => false,
                    _ => true,
                };
                check2
            })
            .unwrap_or(false)
    }
    pub fn add_style(&mut self, style: impl AsRef<str>) {
        self.upsert_key_value(
            "style",
            |value| {
                let mut value = value.as_stringified_attribute_value_str("").unwrap();
                if value.ends_with(";") {
                    value.push_str(style.as_ref());
                } else {
                    value.push(';');
                    value.push_str(style.as_ref());
                }
                value
            },
            || {
                Some(style.as_ref().to_string())
            }
        )
    }
    pub fn update_value<V: ToNode>(
        &mut self,
        key: impl AsNodeRef,
        update_value: impl FnMut(Node) -> V,
    ) {
        self.upsert_key_value(key, update_value, || {None::<Node>})
    }
    pub fn upsert_key_value<V1: ToNode, V2: ToNode>(
        &mut self,
        key: impl AsNodeRef,
        mut update_value: impl FnMut(Node) -> V1,
        maybe_init_value: impl Fn() -> Option<V2>,
    ) {
        let key_ref = key.as_node_ref();
        for entry in self.0.iter_mut() {
            match key_ref {
                Cow::Borrowed(x_key) => {
                    if entry.key.syn_eq(x_key) {
                        entry.value = update_value(entry.value.clone()).to_node();
                        return ();
                    }
                }
                Cow::Owned(ref x_key) => {
                    if entry.key.syn_eq(x_key) {
                        entry.value = update_value(entry.value.clone()).to_node();
                        return ();
                    }
                }
            }
        }
        if let Some(value) = maybe_init_value() {
            let key = match key_ref {
                Cow::Borrowed(x) => x.to_owned(),
                Cow::Owned(x) => x,
            };
            assert!(self.insert(key, value).is_none());
        }
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
    /// This value really complicates syntactic equality, but it’s incredibly
    /// convenient. 
    Fragment(Vec<Node>),
}

impl Display for Node {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.to_string_impl(false, false, 0))
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

