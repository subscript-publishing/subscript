//! Frontend AST data types & related.
use std::cell::RefCell;
use std::path::PathBuf;
use std::rc::Rc;
use std::borrow::{Borrow, Cow};
use std::collections::{HashSet, VecDeque, LinkedList, HashMap};
use std::iter::FromIterator;
use std::vec;
use itertools::Itertools;
use serde::{Serialize, Deserialize};
use crate::compiler::data::*;

///////////////////////////////////////////////////////////////////////////////
// COMMON AST RELATED DATA TYPES
///////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone, PartialEq)]
pub struct RewriteRule<T, U> {
    pub from: T,
    pub to: U,
}

#[derive(Debug, Clone)]
pub struct CurlyBrace<T>{
    open: Ann<String>,
    children: Vec<T>,
    close: Ann<String>,
}

#[derive(Debug, Clone)]
pub struct SquareParen<T>(pub Vec<T>);

#[derive(Debug, Clone, PartialEq)]
pub enum EnclosureKind {
    CurlyBrace,
    SquareParen,
    Parens,
    String,
    Error,
}


#[derive(Debug, Clone, PartialEq)]
pub struct Enclosure<T> {
    pub open: Option<Ann<String>>,
    pub close: Option<Ann<String>>,
    pub children: Vec<T>,
}

impl Ann<Enclosure<Node>> {
    pub fn is_curly_brace(&self) -> bool {
        self.data.is_curly_brace()
    }
    pub fn is_square_parens(&self) -> bool {
        self.data.is_square_parens()
    }
    pub fn is_parens(&self) -> bool {
        self.data.is_parens()
    }
    pub fn is_quote(&self) -> bool {
        self.data.is_quote()
    }
    pub fn is_error(&self) -> bool {
        self.data.is_error()
    }
}

impl<T> Enclosure<T> {
    pub fn is_curly_brace(&self) -> bool {
        self.open.as_ref().map(|x| x.equal_to("{")).unwrap_or(false) &&
        self.close.as_ref().map(|x| x.equal_to("}")).unwrap_or(false)
    }
    pub fn is_square_parens(&self) -> bool {
        self.open.as_ref().map(|x| x.equal_to("[")).unwrap_or(false) &&
        self.close.as_ref().map(|x| x.equal_to("]")).unwrap_or(false)
    }
    pub fn is_parens(&self) -> bool {
        self.open.as_ref().map(|x| x.equal_to("(")).unwrap_or(false) &&
        self.close.as_ref().map(|x| x.equal_to(")")).unwrap_or(false)
    }
    pub fn is_quote(&self) -> bool {
        self.open.as_ref().map(|x| x.equal_to("\"")).unwrap_or(false) &&
        self.close.as_ref().map(|x| x.equal_to("\"")).unwrap_or(false)
    }
    pub fn is_error(&self) -> bool {
        match (self.open.as_ref(), self.close.as_ref()) {
            (Some(x), Some(y)) => {
                x.data != y.data
            }
            (_, _) => true,
        }
    }
    pub fn kind(&self) -> EnclosureKind {
        match (self.open.as_ref(), self.close.as_ref()) {
            (Some(x), Some(y)) => {
                match (x.data.as_ref(), y.data.as_ref()) {
                    ("{", "}") => EnclosureKind::CurlyBrace,
                    ("[", "]") => EnclosureKind::SquareParen,
                    ("(", ")") => EnclosureKind::Parens,
                    ("\"", "\"") => EnclosureKind::String,
                    _ => EnclosureKind::Error
                }
            }
            _ => EnclosureKind::Error
        }
    }
}

///////////////////////////////////////////////////////////////////////////////
// INDEXING DATA TYPES
///////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone, Copy, PartialEq, Hash, Serialize, Deserialize)]
pub struct CharIndex {
    pub byte_index: usize,
    pub char_index: usize,
}

impl CharIndex {
    pub fn zero() -> Self {
        CharIndex{
            byte_index: 0,
            char_index: 0,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Hash, Serialize, Deserialize)]
pub struct CharRange {
    pub start: CharIndex,
    pub end: CharIndex,
}

impl CharRange {
    pub fn join(start: Option<CharIndex>, end: Option<CharIndex>) -> Option<Self> {
        if let Some(start) = start {
            if let Some(end) = end {
                return Some(CharRange{start, end})
            }
        }
        None
    }
    pub fn new(start: CharIndex, end: CharIndex) -> Self {
        CharRange{start, end}
    }
    pub fn byte_index_range(&self, source: &str) -> Option<(usize, usize)> {
        fn find_utf8_end(s: &str, i: usize) -> Option<usize> {
            s.char_indices().nth(i).map(|(_, x)| x.len_utf8())
        }
        let start_byte = self.start.byte_index;
        let end_byte = self.end.byte_index;
        let real_end_byte = source
            .get(start_byte..=end_byte)
            .map(|_| end_byte)
            .or_else(|| {
                let corrected_end = find_utf8_end(source, end_byte)?;
                source
                    .get(start_byte..=corrected_end)
                    .map(|_| corrected_end)
            });
        real_end_byte.map(|l| (start_byte, l))
    }
    pub fn substrng<'a>(&self, source: &'a str) -> Option<&'a str> {
        if let Some((start, end)) = self.byte_index_range(source) {
            let sub_str = source.get(start..end).unwrap();
            Some(sub_str)
        } else {
            None
        }
    }
    pub fn into_annotated_tree<T>(self, data: T) -> Ann<T> {
        Ann {
            range: Some(self),
            data,
        }
    }
}

#[derive(Debug, Clone)]
pub struct Ann<T> {
    range: Option<CharRange>,
    pub data: T,
}

impl<T: std::cmp::PartialEq> std::cmp::PartialEq for Ann<T> {
    fn eq(&self, other: &Self) -> bool {
        self.data == other.data
    }
}

impl Ann<String> {
    pub fn equal_to(&self, value: &str) -> bool {
        &self.data == value
    }
}

impl<T> Ann<T> {
    pub fn unannotated(data: T) -> Self {
        let range = None;
        Ann {range, data}
    }
    pub fn new(range: CharRange, data: T) -> Self {
        Ann {range: Some(range), data}
    }
    pub fn join(range: Option<CharRange>, data: T) -> Self {
        Ann {range, data}
    }
    pub fn range(&self) -> Option<CharRange> {
        self.range
    }
    pub fn start(&self) -> Option<CharIndex> {
        if let Some(range) = self.range {
            return Some(range.start)
        }
        None
    }
    pub fn end(&self) -> Option<CharIndex> {
        if let Some(range) = self.range {
            return Some(range.end)
        }
        None
    }
    pub fn map<U>(self, f: impl Fn(T) -> U) -> Ann<U> {
        Ann {
            range: self.range,
            data: f(self.data),
        }
    }
}

impl From<String> for Ann<String> {
    fn from(value: String) -> Self {Ann::unannotated(value)}
}
// impl From<Cow<'a, str>> for Ann<String> {
//     fn from(value: Cow<'a, str>) -> Self {Ann::unannotated(Text(value))}
// }
impl From<&str> for Ann<String> {
    fn from(value: &str) -> Self {Ann::unannotated(value.to_string())}
}
impl From<&String> for Ann<String> {
    fn from(value: &String) -> Self {Ann::unannotated(value.to_string())}
}
impl From<Ann<&str>> for Ann<String> {
    fn from(value: Ann<&str>) -> Self {
        Ann{data: value.data.to_string(), range: value.range}
    }
}


///////////////////////////////////////////////////////////////////////////////
// FRONTEND
///////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone, Default)]
pub struct Attributes(HashMap<AttrKey, Option<Ann<String>>>);
#[derive(Debug, Clone)]
pub struct Attribute {
    pub key: Ann<String>,
    pub value: Option<Ann<String>>,
}


impl Attributes {
    pub fn insert<T: Into<Ann<String>>, U: Into<Ann<String>>>(
        &mut self, key: T,
        value: U
    ) -> Option<Ann<String>> {
        self.0.insert(AttrKey(key.into()), Some(value.into())).flatten()
    }
    pub fn insert_key<T: Into<Ann<String>>>(&mut self, key: T) -> Option<Ann<String>> {
        self.0.insert(AttrKey(key.into()), None).flatten()
    }
    pub fn get<T: Into<Ann<String>>>(&self, key: T) -> Option<Attribute> {
        let key: AttrKey = AttrKey(key.into());
        let (key, value) = self.0.get_key_value(&key)?;
        Some(Attribute{
            key: key.0.to_owned(),
            value: value.to_owned(),
        })
    }
    pub fn has_attr<T: Into<Ann<String>>>(&self, key: T) -> bool {
        let key: AttrKey = AttrKey(key.into());
        self.0.contains_key(&key)
    }
    pub fn into_vec(self) -> Vec<(Ann<String>, Option<Ann<String>>)> {
        self.0
            .into_iter()
            .map(|(k, v)| (k.0, v))
            .collect_vec()
    }
    /// Got single attribute tags. 
    pub fn into_singleton(&self) -> Option<String> {
        let xs = self.0.iter()
            .map(|(k, v)| {
                (k.to_owned(), v.to_owned())
            })
            .collect::<Vec<_>>();
        match &xs[..] {
            [(k, None)] => {
                Some(k.0.data.to_owned())
            }
            _ => None
        }
    }
}

#[derive(Debug, Clone)]
struct AttrKey(Ann<String>);
impl PartialEq for AttrKey {
    fn eq(&self, other: &AttrKey) -> bool {
        self.0.data == other.0.data
    }
}
impl Eq for AttrKey {}
impl std::hash::Hash for AttrKey {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.0.data.hash(state);
    }
}


#[derive(Debug, Clone)]
pub struct Tag {
    pub name: Ann<String>,
    pub attributes: Attributes,
    /// Each child node generally should be an `Enclosure` (with the `CurlyBrace` kind).
    /// Until perhaps the codegen.
    pub children: Vec<Node>,
    pub rewrite_rules: Vec<RewriteRule<Node, Node>>,
}

impl Tag {
    /// Some tag with no parameters and just children.
    pub fn new<T: Into<Ann<String>>>(name: T, children: Vec<Node>) -> Self {
        Tag{
            name: name.into(),
            attributes: Default::default(),
            children,
            rewrite_rules: Vec::new(),
        }
    }
    pub fn new_with_param<T: Into<Ann<String>>>(name: T, params: Attributes, children: Vec<Node>) -> Tag {
        Tag{
            name: name.into(),
            attributes: params,
            children,
            rewrite_rules: Vec::new(),
        }
    }
    pub fn has_name(&self, name: &str) -> bool {
        return self.name() == name
    }
    pub fn has_attr(&self, key: &str) -> bool {
        self.attributes.has_attr(key)
    }
    // pub fn insert_parameter(&mut self, key: Ann<&str>) {
    //     let mut args = self.parameters.clone().unwrap_or(Vec::new());
    //     args.push(Node::String(Ann::join(
    //         value.range,
    //         Text(Cow::Owned(value.data.to_owned())),
    //     )));
    //     self.parameters = Some(args);
    // }
    // pub fn insert_unannotated_parameter(&mut self, value: &str) {
    //     let mut args = self.parameters.clone().unwrap_or(Vec::new());
    //     args.push(Node::String(Ann::unannotated(
    //         Text(Cow::Owned(value.to_owned()))
    //     )));
    //     self.parameters = Some(args);
    // }
    // /// Short for `Tag::insert_unannotated_parameter`
    // pub fn insert_attr(&mut self, value: &str) {
    //     self.insert_unannotated_parameter(value)
    // }
    // pub fn get_attr(key: &str) {
        
    // }
    // pub fn get_parameter(&self, key: &str) -> Option<Ann<String>> {
    //     self.parameters
    //         .as_ref()
    //         .unwrap_or(&Vec::new())
    //         .iter()
    //         .filter_map(Node::unwrap_string)
    //         .find(|x| {
    //             let str: &str = &x.data.0;
    //             let str = str
    //                 .split_once("=")
    //                 .map(|(x, _)| x)
    //                 .unwrap_or(str);
    //             return str.trim() == key
    //         })
    //         .map(Clone::clone)
    // }
    pub fn name(&self) -> &str {
        &self.name.data
    }
    pub fn to_string(&self) -> String {
        Node::Tag(self.clone()).to_string()
    }
    pub fn is_heading_node(&self) -> bool {
        HEADING_TAG_NAMES.contains(self.name())
    }
}

#[derive(Debug, Clone, Default)]
pub struct NodeScope {
    pub parents: Vec<String>,
}

impl NodeScope {
    // pub fn new<T: Into<PathBuf>>(file_path: T) -> Self {
    //     NodeScope {
    //         file_path: Some(file_path.into()),
    //         parents: Vec::new(),
    //     }
    // }
    // /// Don’t readily use - improver use of this function can break things… 
    // pub fn empty() -> Self {
    //     NodeScope {
    //         file_path: None,
    //         parents: Vec::new(),
    //     }
    // }
    pub fn push_parent(&mut self, name: String) {
        self.parents.push(name)
    }
    pub fn is_math_env(&self) -> bool {
        self.parents
            .iter()
            .any(|x| {
                let option1 = x == INLINE_MATH_TAG;
                let option2 = BLOCK_MATH_TAGS.iter().any(|y| {
                    x == *y
                });
                option1 || option2
            })
    }
    pub fn is_default_env(&self) -> bool {
        !self.is_math_env()
    }
    pub fn has_parent(&self, parent: &str) -> bool {
        self.parents
            .iter()
            .any(|x| x == parent)
    }
}


///////////////////////////////////////////////////////////////////////////////
// AST
///////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone)]
pub enum Node {
    /// The parser doesn’t emit AST `Tag` nodes. This is done in a later
    /// processing phase.
    Tag(Tag),
    /// Some identifier that may or may not be followed by square parentheses
    /// and/or a curly brace enclosure. E.g. `\name`.
    Ident(Ann<String>),
    /// An enclosure can be a multitude of things:
    /// * Some syntactic enclosure: 
    ///     * Curly braces
    ///     * Parentheses
    ///     * Square parentheses
    /// * Some error with it’s invalid start & end token (i.e. a opening `[` and closing `}`)
    Enclosure(Ann<Enclosure<Node>>),
    /// Some string of arbitrary characters or a single special token.
    Text(Ann<String>),
    /// Some unbalanced token that isn’t associated with an enclosure. 
    /// In Subscript, enclosure symbols must be balanced. If the author
    /// must use such in their publications, then use the tag version. 
    InvalidToken(Ann<String>),
    // MacroDecl(Ann<MacroDecl>),
    HtmlCode(String),
}


impl Node {
    /// Some tag with no parameters and just children.
    pub fn new_tag<T: Into<Ann<String>>>(name: T, children: Vec<Node>) -> Self {
        Node::Tag(Tag::new(name.into(), children))
    }
    pub fn new_ident<T: Into<Ann<String>>>(str: T) -> Self {
        Node::Ident(str.into())
    }
    pub fn new_enclosure<T: Into<Ann<String>>>(
        range: CharRange,
        open: T,
        close: T,
        children: Vec<Node>,
    ) -> Self {
        Node::Enclosure(Ann::new(range, Enclosure {
            open: Some(open.into()),
            close: Some(close.into()),
            children
        }))
    }
    pub fn new_text<T: Into<Ann<String>>>(str: T) -> Self {
        Node::Ident(str.into())
    }
    pub fn unannotated_curly_brace_enclosure(children: Vec<Node>) -> Self {
        Node::Enclosure(Ann::unannotated(Enclosure {
            open: Some(Ann::unannotated(String::from("{"))),
            close: Some(Ann::unannotated(String::from("}"))),
            children
        }))
    }
    pub fn unannotated_square_paren_enclosure(children: Vec<Node>) -> Self {
        Node::Enclosure(Ann::unannotated(Enclosure {
            open: Some(Ann::unannotated(String::from("["))),
            close: Some(Ann::unannotated(String::from("]"))),
            children
        }))
    }
    pub fn unannotated_paren_enclosure(children: Vec<Node>) -> Self {
        Node::Enclosure(Ann::unannotated(Enclosure {
            open: Some(Ann::unannotated(String::from("("))),
            close: Some(Ann::unannotated(String::from(")"))),
            children
        }))
    }
    pub fn unannotated_string_enclosure(children: Vec<Node>) -> Self {
        Node::Enclosure(Ann::unannotated(Enclosure {
            open: Some(Ann::unannotated(String::from("("))),
            close: Some(Ann::unannotated(String::from(")"))),
            children
        }))
    }
    // pub fn unannotated_text<T: Into<Ann<String>>>(str: T) -> Self {
    //     Node::Text(str.into())
    // }
    pub fn is_whitespace(&self) -> bool {
        match self {
            Node::Text(txt) => {
                let x: &str = &txt.data;
                x.trim().is_empty()
            },
            _ => false
        }
    }
    pub fn is_tag(&self) -> bool {
        match self {
            Node::Tag(_) => true,
            _ => false,
        }
    }
    pub fn has_tag<T: Into<Ann<String>>>(&self, tag: T) -> bool {
        match self {
            Node::Tag(node) => node.name == tag.into(),
            _ => false,
        }
    }
    pub fn has_attr<T: Into<Ann<String>>>(&self, key: T) -> bool {
        match self {
            Node::Tag(node) => node.attributes.has_attr(key.into()),
            _ => false,
        }
    }
    pub fn is_ident(&self) -> bool {
        match self {
            Node::Ident(_) => true,
            _ => false,
        }
    }
    pub fn is_enclosure(&self) -> bool {
        match self {
            Node::Enclosure(_) => true,
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
            Node::Text(ann) => ann.data == value,
            _ => false,
        }
    }
    pub fn is_any_enclosure(&self) -> bool {
        match self {
            Node::Enclosure(_) => true,
            _ => false,
        }
    }
    pub fn is_enclosure_of_kind(&self, k: EnclosureKind) -> bool {
        match self {
            Node::Enclosure(Ann{data, ..}) => {
                data.kind() == k
            },
            _ => false,
        }
    }
    pub fn unpack_enclosure_kind(&self) -> Option<EnclosureKind> {
        match self {
            Node::Enclosure(Ann{data, ..}) => {
                Some(data.kind())
            },
            _ => None,
        }
    }
    pub fn is_named_block(&self, name: &str) -> bool {
        self.unwrap_tag()
            .map(|x| x.name.data == name)
            .unwrap_or(false)
    }
    pub fn get_text(&self) -> Option<Ann<String>> {
        match self {
            Node::Text(val) => Some(val.clone()),
            _ => None,
        }
    }
    pub fn get_enclosure_children(&self, kind: EnclosureKind) -> Option<&Vec<Node>> {
        match self {
            Node::Enclosure(Ann{
                data: x,
                ..
            }) if x.kind() == kind => {
                Some(x.children.as_ref())
            }
            _ => None,
        }
    }
    pub fn unblock(self) -> Vec<Self> {
        match self {
            Node::Enclosure(
                Ann{data: block, ..}
            ) if block.kind() == EnclosureKind::CurlyBrace => {
                block.children
            }
            x => vec![x]
        }
    }
    pub fn unwrap_tag(&self) -> Option<&Tag> {
        match self {
            Node::Tag(x) => Some(x),
            _ => None,
        }
    }
    pub fn unwrap_string(&self) -> Option<&Vec<Node>> {
        match self {
            Node::Enclosure(Ann{data, ..}) if data.kind() == EnclosureKind::String => {
                Some(&data.children)
            },
            _ => None,
        }
    }
    pub fn unwrap_tag_mut(&mut self) -> Option<&mut Tag> {
        match self {
            Node::Tag(x) => Some(x),
            _ => None,
        }
    }
    pub fn unwrap_ident<'b>(&'b self) -> Option<&'b Ann<String>> {
        match self {
            Node::Ident(x) => Some(x),
            _ => None,
        }
    }
    pub fn unwrap_enclosure<'b>(&'b self) -> Option<&'b Ann<Enclosure<Node>>> {
        match self {
            Node::Enclosure(x) => Some(x),
            _ => None,
        }
    }
    pub fn unwrap_curly_brace(self) -> Option<Vec<Node>> {
        match self {
            Node::Enclosure(
                Ann{data, ..}
            ) if data.kind() == EnclosureKind::CurlyBrace => Some(data.children),
            _ => None,
        }
    }
    pub fn unwrap_text<'b>(&'b self) -> Option<&'b Ann<String>> {
        match self {
            Node::Text(x) => Some(x),
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
    pub fn into_tag(self) -> Option<Tag> {
        match self {
            Node::Tag(x) => Some(x),
            _ => None,
        }
    }

    pub fn scan<T, F: Fn(NodeScope, &Node, &mut T) -> ()>(
        &self,
        acc: &mut T,
        mut env: NodeScope,
        f: Rc<F>
    ) {
        match self {
            node @ Node::Tag(tag) => {
                env.push_parent(tag.name.data.clone());
                tag.children
                    .iter()
                    .map(|x| x.scan(acc, env.clone(), f.clone()))
                    .collect::<Vec<_>>();
                tag.rewrite_rules
                    .iter()
                    .map(|rule| {
                        rule.from.scan(acc, env.clone(), f.clone());
                        rule.to.scan(acc, env.clone(), f.clone());
                    })
                    .collect::<Vec<_>>();
                f(env.clone(), node, acc)
            }
            node @ Node::Enclosure(inner) => {
                inner.data.children
                    .iter()
                    .map(|x| x.scan(acc, env.clone(), f.clone()))
                    .collect::<Vec<_>>();
                f(env.clone(), node, acc)
            }
            node @ Node::Ident(_) => {
                f(env.clone(), node, acc)
            }
            node @ Node::Text(_) => {
                f(env.clone(), node, acc)
            }
            node @ Node::InvalidToken(_) => {
                f(env.clone(), node, acc)
            }
            node @ Node::HtmlCode(_) => {
                f(env.clone(), node, acc)
            }
        }
    }

    /// **Dangerous!!** Only use for analysis on clones of the AST. 
    pub fn trim_whitespace(self) -> Self {
        let env = NodeScope::default();
        fn f(env: NodeScope, node: Node) -> Node {
            match node {
                Node::Text(txt) => {
                    let txt = txt.data.trim();
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
                            !txt.data.is_empty()
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
    pub fn transform<F: Fn(NodeScope, Node) -> Node>(
        self,
        mut env: NodeScope, f: Rc<F>
    ) -> Self {
        match self {
            Node::Tag(node) => {
                env.push_parent(node.name.data.clone());
                let children = node.children
                    .into_iter()
                    .map(|x| x.transform(env.clone(), f.clone()))
                    .collect();
                let rewrite_rules = node.rewrite_rules
                    .into_iter()
                    .map(|rule| -> RewriteRule<Node, Node> {
                        RewriteRule {
                            from: rule.from.transform(env.clone(), f.clone()),
                            to: rule.to.transform(env.clone(), f.clone()),
                        }
                    })
                    .collect();
                let node = Tag {
                    name: node.name,
                    attributes: node.attributes,
                    children,
                    rewrite_rules,
                };
                f(env.clone(), Node::Tag(node))
            }
            Node::Enclosure(node) => {
                let range = node.range;
                let children = node.data.children
                    .into_iter()
                    .map(|x| x.transform(env.clone(), f.clone()))
                    .collect();
                let data = Enclosure{
                    open: node.data.open,
                    close: node.data.close,
                    children,
                };
                let node = Node::Enclosure(Ann::join(range, data));
                f(env.clone(), node)
            }
            node @ Node::Ident(_) => {
                f(env.clone(), node)
            }
            node @ Node::Text(_) => {
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

    /// TODO -be careful with this- not everthing is covered
    /// E.g. RewriteRules in where blocks...
    pub fn transform_expand<F: Fn(&mut super::CompilerEnv, NodeScope, Node) -> Vec<Node>>(
        self,
        env: &mut super::CompilerEnv,
        mut scope: NodeScope, f: Rc<F>,
    ) -> Vec<Self> {
        match self {
            Node::Tag(node) => {
                scope.push_parent(node.name.data.clone());
                let children = node.children
                    .into_iter()
                    .flat_map(|x| x.transform_expand(env, scope.clone(), f.clone()))
                    .collect::<Vec<_>>();
                let rewrite_rules = node.rewrite_rules;
                    // .into_iter()
                    // .flat_map(|rule| -> RewriteRule<Node, Node> {
                    //     RewriteRule {
                    //         from: rule.from.transform_expand(env.clone(), f.clone()),
                    //         to: rule.to.transform_expand(env.clone(), f.clone()),
                    //     }
                    // })
                    // .collect();
                let node = Tag {
                    name: node.name,
                    attributes: node.attributes,
                    children,
                    rewrite_rules,
                };
                f(env, scope.clone(), Node::Tag(node))
            }
            Node::Enclosure(node) => {
                let range = node.range;
                let children = node.data.children
                    .into_iter()
                    .flat_map(|x| x.transform_expand(env, scope.clone(), f.clone()))
                    .collect();
                let data = Enclosure{
                    open: node.data.open,
                    close: node.data.close,
                    children,
                };
                let node = Node::Enclosure(Ann::join(range, data));
                f(env, scope.clone(), node)
            }
            node @ Node::Ident(_) => {
                f(env, scope.clone(), node)
            }
            node @ Node::Text(_) => {
                f(env, scope.clone(), node)
            }
            node @ Node::InvalidToken(_) => {
                f(env, scope.clone(), node)
            }
            node @ Node::HtmlCode(_) => {
                f(env, scope.clone(), node)
            }
        }
    }

    pub fn transform_mut<F: FnMut(NodeScope, Node) -> Node>(
        self,
        mut scope: NodeScope,
        f: Rc<RefCell<F>>
    ) -> Self {
        match self {
            Node::Tag(node) => {
                scope.push_parent(node.name.data.clone());
                let children = node.children
                    .into_iter()
                    .map(|x| x.transform_mut(scope.clone(), f.clone()))
                    .collect();
                let rewrite_rules = node.rewrite_rules
                    .into_iter()
                    .map(|rule| -> RewriteRule<Node, Node> {
                        RewriteRule {
                            from: rule.from.transform_mut(scope.clone(), f.clone()),
                            to: rule.to.transform_mut(scope.clone(), f.clone()),
                        }
                    })
                    .collect();
                let node = Tag {
                    name: node.name,
                    attributes: node.attributes,
                    children,
                    rewrite_rules,
                };
                (f.borrow_mut())(scope.clone(), Node::Tag(node))
            }
            Node::Enclosure(node) => {
                let range = node.range;
                let children = node.data.children
                    .into_iter()
                    .map(|x| x.transform_mut(scope.clone(), f.clone()))
                    .collect();
                let data = Enclosure{
                    open: node.data.open,
                    close: node.data.close,
                    children,
                };
                let node = Node::Enclosure(Ann::join(range, data));
                (f.borrow_mut())(scope.clone(), node)
            }
            node @ Node::Ident(_) => {
                (f.borrow_mut())(scope.clone(), node)
            }
            node @ Node::Text(_) => {
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
            Node::Tag(node) => {
                let children = node.children
                    .into_iter()
                    .map(|x| -> Node {
                        x.transform_children(f.clone())
                    })
                    .collect::<Vec<_>>();
                let children = f(children);
                let rewrite_rules = node.rewrite_rules
                    .into_iter()
                    .map(|rule| -> RewriteRule<Node, Node> {
                        RewriteRule {
                            from: rule.from.transform_children(f.clone()),
                            to: rule.to.transform_children(f.clone()),
                        }
                    })
                    .collect();
                let attributes = node.attributes;
                let node = Tag {
                    name: node.name,
                    attributes,
                    children,
                    rewrite_rules,
                };
                Node::Tag(node)
            }
            Node::Enclosure(node) => {
                let range = node.range();
                let children = node.data.children
                    .into_iter()
                    .map(|x| x.transform_children(f.clone()))
                    .collect();
                let children = (f)(children);
                let data = Enclosure{
                    open: node.data.open,
                    close: node.data.close,
                    children,
                };
                Node::Enclosure(Ann::join(range, data))
            }
            node @ Node::Ident(_) => node,
            node @ Node::Text(_) => node,
            node @ Node::InvalidToken(_) => node,
            node @ Node::HtmlCode(_) => node,
        }
    }
    pub fn to_string(&self) -> String {
        // fn pack<T: Into<String>>(x: T) -> String {
        //     match x {
        //         Cow::Borrowed(x) => String::from(x),
        //         Cow::Owned(x) => x,
        //     }
        // }
        fn ident<T: Into<String>>(x: T) -> String {
            let mut txt = x.into();
            txt.insert(0, '\\');
            txt
        }
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
            Node::Tag(tag) => {
                let name = tag.name.data.clone();
                let children = tag.children
                    .iter()
                    .map(|x| x.to_string())
                    .collect::<Vec<_>>()
                    .join("");
                format!("\\{}{}", name, children)
            }
            Node::Enclosure(Ann{data, ..}) => {
                let children = data.children
                    .iter()
                    .map(|x| x.to_string())
                    .collect::<Vec<_>>()
                    .join("");
                match data.kind() {
                    EnclosureKind::CurlyBrace => {
                        enclosure_str("{", children, "}")
                    }
                    EnclosureKind::Parens => {
                        enclosure_str("(", children, ")")
                    }
                    EnclosureKind::SquareParen => {
                        enclosure_str("[", children, "]")
                    }
                    EnclosureKind::String => {
                        enclosure_str("“", children, "”")
                    }
                    EnclosureKind::Error => {
                        // enclosure(data.open, children, data.close)
                        unimplemented!("todo")
                    }
                }
            }
            Node::Ident(x) => ident(x.data.clone()),
            Node::Text(x) => x.data.clone(),
            Node::InvalidToken(x) => x.data.clone(),
            Node::HtmlCode(_) => "HtmlCode(...)".to_owned()
        }
    }
    pub fn syntactically_equal(&self, other: &Self) -> bool {
        match (self, other) {
            (Node::Tag(x1), Node::Tag(x2)) => {
                let check1 = x1.name() == x2.name();
                let check2 = x1.children.len() == x2.children.len();
                if check1 && check2 {
                    return x1.children
                        .iter()
                        .zip(x2.children.iter())
                        .all(|(x, y)| {
                            x.syntactically_equal(y)
                        })
                }
                false
            }
            (Node::Enclosure(x1), Node::Enclosure(x2)) => {
                let check1 = x1.data.kind() == x2.data.kind();
                let check2 = x1.data.children.len() == x2.data.children.len();
                if check1 && check2 {
                    return x1.data.children
                        .iter()
                        .zip(x2.data.children.iter())
                        .all(|(x, y)| {
                            x.syntactically_equal(y)
                        })
                }
                false
            }
            (Node::Ident(x1), Node::Ident(x2)) => {
                &x1.data == &x2.data
            }
            (Node::Text(x1), Node::Text(x2)) => {
                &x1.data == &x2.data
            }
            (Node::InvalidToken(x1), Node::InvalidToken(x2)) => {
                &x1.data == &x2.data
            }
            (_, _) => false
        }
    }
}

#[derive(Debug, Clone)]
pub struct MacroDecl {
    pub macro_rules_token: Ann<String>,
    pub rewrite_rules: Vec<RewriteRuleDecl>,
}

#[derive(Debug, Clone)]
pub struct RewriteRuleDecl {
    pattern: RewriteRulePattern,
    forward_arrow: Ann<String>,
    target: RewriteRulePattern,
}

#[derive(Debug, Clone)]
pub struct RewriteRulePattern {
    open_token: Ann<String>,
    pattern: Vec<Node>,
    close_token: Ann<String>,
}



///////////////////////////////////////////////////////////////////////////////
// DOCUMENTS
///////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////
// HIGHLIGHTER RELATED DATA TYPES
///////////////////////////////////////////////////////////////////////////////

// #[derive(Debug, Clone, Serialize, Deserialize)]
// pub struct Highlight {
//     pub range: Option<CharRange>,
//     pub kind: HighlightKind,
//     pub binder: Option<String>,
//     pub nesting: Vec<String>,
// }

// #[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
// pub enum HighlightKind {
//     CurlyBrace,
//     SquareParen,
//     Parens,
//     Fragment,
//     Error {
//         open: String,
//         close: Option<String>,
//     },
//     InvalidToken(String),
//     Ident(String),
// }

