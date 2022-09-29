//! Common data types used throughout the compiler.
use std::borrow::Cow;
use std::collections::{HashSet, VecDeque, LinkedList};
use std::iter::FromIterator;
use lazy_static::lazy_static;
use serde::{Serialize, Deserialize};


pub static INLINE_MATH_TAG: &'static str = "[inline-math]";
pub static BLOCK_MATH_TAGS: &[&'static str] = &[
    "equation",
];


lazy_static! {
    pub static ref HEADING_TAG_NAMES: HashSet<&'static str> = HashSet::from_iter(vec![
        "h1",
        "h2",
        "h3",
        "h4",
        "h5",
        "h6",
    ]);
}

pub static ALL_SUBSCRIPT_TAGS: &[&'static str] = &[
    "note",
    "layout",
    "equation",
];

pub static ALLOWED_HTML_TAGS: &[&'static str] = &[
    "address",
    "article",
    "aside",
    "footer",
    "header",
    "h1",
    "section",
    "blockquote",
    "dd",
    "dl",
    "dt",
    "figcaption",
    "figure",
    "hr",
    "li",
    "ol",
    "p",
    "pre",
    "ul",
    "a",
    "abbr",
    "b",
    "bdi",
    "bdo",
    "br",
    "cite",
    "code",
    "data",
    "dfn",
    "em",
    "i",
    "kbd",
    "mark",
    "q",
    "s",
    "samp",
    "small",
    "span",
    "strong",
    "sub",
    "sup",
    "time",
    "u",
    "var",
    "wbr",
    "audio",
    "img",
    "map",
    "area",
    "track",
    "video",
    "object",
    "picture",
    "source",
    "del",
    "ins",
    "caption",
    "col",
    "colgroup",
    "table",
    "tbody",
    "td",
    "tfoot",
    "th",
    "thead",
    "tr",
    "details",
    "summary",
];

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum HeadingType {H1, H2, H3, H4, H5, H6}

impl HeadingType {
    pub fn to_str(&self) -> &'static str {
        match self {
            HeadingType::H1 => "h1",
            HeadingType::H2 => "h2",
            HeadingType::H3 => "h3",
            HeadingType::H4 => "h4",
            HeadingType::H5 => "h5",
            HeadingType::H6 => "h6",
        }
    }
    pub fn from_str(str: &str) -> Option<HeadingType> {
        match str {
            "h1" => Some(HeadingType::H1),
            "h2" => Some(HeadingType::H2),
            "h3" => Some(HeadingType::H3),
            "h4" => Some(HeadingType::H4),
            "h5" => Some(HeadingType::H5),
            "h6" => Some(HeadingType::H6),
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
            _ => None
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
            0 => {
                *self
            }
            1 => {
                self.decrement()
            }
            2 => {
                self.decrement().decrement()
            }
            3 => {
                self.decrement().decrement().decrement()
            }
            4 => {
                self.decrement().decrement().decrement().decrement()
            }
            5 | _ => {
                self.decrement().decrement().decrement().decrement().decrement()
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////////
// LAYOUT
///////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone)]
pub enum LayoutKind {
    Block,
    Inline,
}


///////////////////////////////////////////////////////////////////////////////
// STRING DATA TYPES
///////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone, Hash, Default, Serialize, Deserialize)]
/// This implements a custom instance of equality that compares string values
/// without regard to ownership. 
pub struct Text<'a>(pub Cow<'a, str>);

impl<'a> PartialEq for Text<'a> {
    fn eq(&self, other: &Text<'a>) -> bool {
        match (&self.0, &other.0) {
            (Cow::Borrowed(x), Cow::Borrowed(y)) => {x == y}
            (Cow::Owned(x), Cow::Owned(y)) => {x == y},
            (Cow::Borrowed(x), Cow::Owned(y)) => {x == y},
            (Cow::Owned(x), Cow::Borrowed(y)) => {x == y},
        }
    }
}

impl<'a> Eq for Text<'a> {}

impl<'a> Text<'a> {
    pub fn new(value: &'a str) -> Self {
        Text(Cow::Borrowed(value))
    }
    pub fn from_string(value: String) -> Self {
        Text(Cow::Owned(value))
    }
    pub fn len(&self) -> usize {
        self.0.len()
    }
    pub fn append(self, other: Text<'a>) -> Self {
        Text(self.0 + other.0)
    }
    pub fn to_string(&'a self) -> String {
        self.0.to_string()
    }
}
impl<'a> std::fmt::Display for Text<'a> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}




pub static TOKEN_SET: &'static [&'static str] = &["\\", "[", "]", "{", "}", "(", ")", "=>", "_", "^"];

fn get_end_kind_for(begin_kind: &str) -> &str {
    match begin_kind {
        "{" => "}",
        "[" => "]",
        "(" => ")",
        _ => unreachable!()
    }
}

fn get_begin_kind_for(end_kind: &str) -> &str {
    match end_kind {
        "}" => "{",
        "]" => "[",
        ")" => "(",
        _ => unreachable!()
    }
}

pub fn is_token<'a>(value: &'a str) -> bool {
    for tk in TOKEN_SET {
        if *tk == value {
            return true;
        }
    }
    false
}



