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
use crate::ss::ast_data::{Attributes, Attribute};


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

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
        self.to_node()
    ]}
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// DIFFERENT NOTIONS OF EQUALITY
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// At the time of this writing, I’m refactoring the compiler and removing
// `PartialEq` instances since in some places I had custom instances that
// made things convenient for syntactic equality but causes issues in e.g.
// unit tests where I want full/strict equality checking. To make things
// convenient, I’m going to remove `PartialEq` instances from AST data types,
// so the compiler will emit errors wherever such is used, so I can rewrite such
// cases to be more specific with the intended type of equality. Perhaps over
// time perhaps I’ll add `PartialEq` back, but currently it's absence this is
// more useful. 
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

pub trait SyntacticallyEq<Rhs: ?Sized = Self> {
    fn syn_eq(&self, other: &Rhs) -> bool;
}

impl SyntacticallyEq for str {
    fn syn_eq(&self, other: &Self) -> bool {
        self == other
    }
}
impl SyntacticallyEq for String {
    fn syn_eq(&self, other: &Self) -> bool {
        self == other
    }
}
impl<T: SyntacticallyEq> SyntacticallyEq for Ann<T> {
    fn syn_eq(&self, other: &Self) -> bool {
        self.value.syn_eq(&other.value)
    }
}
impl SyntacticallyEq for Ident {
    fn syn_eq(&self, other: &Self) -> bool {
        self == other
    }
}
impl SyntacticallyEq for BracketType {
    fn syn_eq(&self, other: &Self) -> bool {
        match (self, other) {
            (BracketType::CurlyBrace, BracketType::CurlyBrace) => true,
            (BracketType::SquareParen, BracketType::SquareParen) => true,
            (BracketType::Parens, BracketType::Parens) => true,
            // Make sure that if we add more bracket types, we’ll
            // get an error message if we forget to add cases. 
            (BracketType::CurlyBrace, _) => false,
            (BracketType::SquareParen, _) => false,
            (BracketType::Parens, _) => false,
        }
    }
}
impl SyntacticallyEq for Attributes {
    fn syn_eq(&self, other: &Self) -> bool {
        let left = self.get_str_keys();
        let right = other.get_str_keys();
        left == right
    }
}
impl SyntacticallyEq for CmdCall {
    fn syn_eq(&self, other: &Self) -> bool {
        let check1 = self.identifier.syn_eq(&other.identifier);
        let check2 = self.attributes.syn_eq(&other.attributes);
        let check3 = self.arguments.syn_eq(&other.arguments);
        check1 && check2 && check3
    }
}
impl SyntacticallyEq for Node {
    fn syn_eq(&self, other: &Self) -> bool {
        let left = self
            .clone()
            .defragment_node_tree()
            .trim_whitespace();
        let right = other
            .clone()
            .defragment_node_tree()
            .trim_whitespace();
        match (left, right) {
            (Node::Cmd(l), Node::Cmd(r)) => l.syn_eq(&r),
            (Node::Ident(l), Node::Ident(r)) => l.syn_eq(&r),
            (Node::Bracket(l), Node::Bracket(r)) => l.syn_eq(&r),
            (Node::Quotation(l), Node::Quotation(r)) => l.syn_eq(&r),
            (Node::Symbol(l), Node::Symbol(r)) => l.syn_eq(&r),
            (Node::InvalidToken(l), Node::InvalidToken(r)) => l.syn_eq(&r),
            (Node::Fragment(l), Node::Fragment(r)) => l.syn_eq(&r),
            (Node::Text(l), Node::Text(r)) => l.syn_eq(&r),
            (Node::Drawing(_), Node::Drawing(_)) => true,
            (_, _) => false,
        }
    }
}
impl SyntacticallyEq for Bracket {
    fn syn_eq(&self, other: &Self) -> bool {
        let check1 = match (self.open.as_ref(), other.open.as_ref()) {
            (Some(l), Some(r)) => l.syn_eq(r),
            (None, None) => true,
            _ => false 
        };
        let check2 = match (self.close.as_ref(), other.close.as_ref()) {
            (Some(l), Some(r)) => l.syn_eq(r),
            (None, None) => true,
            _ => false 
        };
        let check3 = self.children.syn_eq(&other.children);
        check1 && check2 && check3
    }
}
impl SyntacticallyEq for Quotation {
    fn syn_eq(&self, other: &Self) -> bool {
        let check1 = match (self.open.as_ref(), other.open.as_ref()) {
            (Some(l), Some(r)) => l.syn_eq(r),
            (None, None) => true,
            _ => false 
        };
        let check2 = match (self.close.as_ref(), other.close.as_ref()) {
            (Some(l), Some(r)) => l.syn_eq(r),
            (None, None) => true,
            _ => false 
        };
        let check3 = self.children.syn_eq(&other.children);
        check1 && check2 && check3
    }
}
impl SyntacticallyEq for Vec<Node> {
    fn syn_eq(&self, other: &Self) -> bool {
        let left = Node::Fragment(self.clone())
            .defragment_node_tree()
            .trim_whitespace()
            .unfragment_root();
        let right = Node::Fragment(other.clone())
            .defragment_node_tree()
            .trim_whitespace()
            .unfragment_root();
        if left.len() == right.len() {
            return left
                .into_iter()
                .zip(right.into_iter())
                .all(|(l, r)| l.syn_eq(&r))
        }
        false
    }
}


/// Instead of using `PartialEq`, we use `StrictlyEq` to be explicit with our
/// intentions (i.e. to convey the intent of **not using semantic equality**).
/// 
/// At the time of this writing, I’m refactoring the compiler and removing
/// `PartialEq` instances since in some places I had custom instances that
/// made things convenient for syntactic equality but causes issues in e.g.
/// unit tests where I want full/strict equality checking. To make things
/// convenient, I’m going to remove `PartialEq` instances from AST data types,
/// so the compiler will emit errors wherever such is used, so I can rewrite
/// such cases to be more specific with the intended type of equality. Perhaps
/// over time perhaps I’ll add back `PartialEq` back, but currently it's
/// absence is more useful. 
pub trait StrictlyEq<Rhs: ?Sized = Self> {
    fn strictly_eq_to(&self, other: &Rhs) -> bool;
}

impl StrictlyEq for str {
    fn strictly_eq_to(&self, other: &Self) -> bool {
        self == other
    }
}
impl StrictlyEq for String {
    fn strictly_eq_to(&self, other: &Self) -> bool {
        self == other
    }
}
impl<T: StrictlyEq> StrictlyEq for Ann<T> {
    fn strictly_eq_to(&self, other: &Self) -> bool {
        self.value.strictly_eq_to(&other.value)
            && self.range == other.range
    }
}
impl StrictlyEq for Ident {
    fn strictly_eq_to(&self, other: &Self) -> bool {
        self == other
    }
}
impl StrictlyEq for BracketType {
    fn strictly_eq_to(&self, other: &Self) -> bool {
        match (self, other) {
            (BracketType::CurlyBrace, BracketType::CurlyBrace) => true,
            (BracketType::SquareParen, BracketType::SquareParen) => true,
            (BracketType::Parens, BracketType::Parens) => true,
            // Make sure that if we add more bracket types, we’ll
            // get an error message if we forget to add cases. 
            (BracketType::CurlyBrace, _) => false,
            (BracketType::SquareParen, _) => false,
            (BracketType::Parens, _) => false,
        }
    }
}
impl StrictlyEq for Attributes {
    fn strictly_eq_to(&self, other: &Self) -> bool {
        let left = self.clone().consume();
        let right = other.clone().consume();
        if left.len() == right.len() {
            return left.into_iter()
                .zip(right.into_iter())
                .all(|(l, r)| {
                    let check1 = l.key.strictly_eq_to(&r.key);
                    let check2 = l.value.strictly_eq_to(&r.value);
                    check1 && check2
                })
        }
        false
    }
}
impl StrictlyEq for CmdCall {
    fn strictly_eq_to(&self, other: &Self) -> bool {
        let check1 = self.identifier.strictly_eq_to(&other.identifier);
        let check2 = self.attributes.strictly_eq_to(&other.attributes);
        let check3 = self.arguments.strictly_eq_to(&other.arguments);
        check1 && check2 && check3
    }
}
impl StrictlyEq for Node {
    fn strictly_eq_to(&self, other: &Self) -> bool {
        match (self, other) {
            (Node::Cmd(l), Node::Cmd(r)) => l.strictly_eq_to(&r),
            (Node::Ident(l), Node::Ident(r)) => l.strictly_eq_to(&r),
            (Node::Bracket(l), Node::Bracket(r)) => l.strictly_eq_to(&r),
            (Node::Quotation(l), Node::Quotation(r)) => l.strictly_eq_to(&r),
            (Node::Symbol(l), Node::Symbol(r)) => l.strictly_eq_to(&r),
            (Node::InvalidToken(l), Node::InvalidToken(r)) => l.strictly_eq_to(&r),
            (Node::Fragment(l), Node::Fragment(r)) => l.strictly_eq_to(&r),
            (Node::Text(l), Node::Text(r)) => l.strictly_eq_to(&r),
            (Node::Drawing(_), Node::Drawing(_)) => unimplemented!(),
            (_, _) => false,
        }
    }
}
impl StrictlyEq for Bracket {
    fn strictly_eq_to(&self, other: &Self) -> bool {
        let check1 = match (self.open.as_ref(), other.open.as_ref()) {
            (Some(l), Some(r)) => l.strictly_eq_to(r),
            (None, None) => true,
            _ => false 
        };
        let check2 = match (self.close.as_ref(), other.close.as_ref()) {
            (Some(l), Some(r)) => l.strictly_eq_to(r),
            (None, None) => true,
            _ => false 
        };
        let check3 = self.children.strictly_eq_to(&other.children);
        check1 && check2 && check3
    }
}
impl StrictlyEq for Quotation {
    fn strictly_eq_to(&self, other: &Self) -> bool {
        let check1 = match (self.open.as_ref(), other.open.as_ref()) {
            (Some(l), Some(r)) => l.strictly_eq_to(r),
            (None, None) => true,
            _ => false 
        };
        let check2 = match (self.close.as_ref(), other.close.as_ref()) {
            (Some(l), Some(r)) => l.strictly_eq_to(r),
            (None, None) => true,
            _ => false 
        };
        let check3 = self.children.strictly_eq_to(&other.children);
        check1 && check2 && check3
    }
}
impl StrictlyEq for Vec<Node> {
    fn strictly_eq_to(&self, other: &Self) -> bool {
        if self.len() == other.len() {
            return self
                .iter()
                .zip(other.iter())
                .all(|(l, r)| l.strictly_eq_to(&r))
        }
        false
    }
}

