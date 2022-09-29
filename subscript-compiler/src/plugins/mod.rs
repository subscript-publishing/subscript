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
    pub scope: String,
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