//! Miscellaneous stuff used throughout the compiler.
use std::path::PathBuf;
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
