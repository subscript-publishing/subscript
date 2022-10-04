//! The different between `normalize.rs` and `pre_html.rs` is somewhat
//! arbitrary. But generally speaking, `pre_html.rs` is for HTML specific
//! rewrites that we apply before passing the AST onto the HTML codegen
//! (for instance if it's shared between a possible PDF backend and the
//! HTML backend alike, add it to `normalize.rs`). 

use std::iter::FromIterator;
use std::collections::{HashSet, HashMap};
use std::rc::Rc;
use std::cell::RefCell;
use std::borrow::Cow;
use std::convert::TryFrom;
use either::Either;
use crate::compiler::data::*;
use crate::compiler::ast::*;

pub mod pre_html;
pub mod normalize;

#[derive(Debug, Clone)]
pub struct TagRewrite {
    pub namespace: String,
    pub tag: String,
    pub apply: Box<fn(NodeScope, Tag) -> Node>
}


impl TagRewrite {
    pub fn apply(&self, env: NodeScope, tag: Tag) -> Node {
        assert!(tag.name.data == self.tag);
        (self.apply)(env, tag)
    }
}


// pub fn run() {
//     let funs = normalize::all_tag_macros();
//     for f in funs {
//         let mut env = NodeEnvironment::default();
//         let mut tag = Tag::new("div", vec![]);
//         f(env, tag);
//     }
// }