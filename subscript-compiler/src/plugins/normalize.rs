use std::iter::FromIterator;
use std::collections::{HashSet, HashMap};
use std::rc::Rc;
use std::cell::RefCell;
use std::borrow::Cow;
use std::convert::TryFrom;
use either::Either;
use itertools::Itertools;
use crate::compiler::data::*;
use crate::compiler::ast::*;
use super::TagRewrite;

macro_rules! register_tag_macros_impl {
    ($list:ident;) => {};
    ($list:ident; $(#[$($attrss:tt)*])* fn $namespace:ident::$tag_name:ident($env:ident, $tag:ident)$block:block $($rest:tt)*) => {{
        fn f($env: NodeScope, mut $tag: Tag) -> Node $block
        let namespace = stringify!($namespace).to_string();
        let tag_name = stringify!($tag_name).to_string();
        $list.insert(
            tag_name.clone(),
            Box::new(TagRewrite{namespace, tag: tag_name, apply: Box::new(f)})
        );
        register_tag_macros_impl!{$list; $($rest)*}
    }};
}

macro_rules! register_tag_macros {
    ($($x:tt)*) => {
        pub fn all_tag_macros() -> HashMap<String, Box<TagRewrite>> {
            let mut xs: HashMap<String, Box<TagRewrite>> = Default::default();
            register_tag_macros_impl!(xs; $($x)*);
            xs
        }
    };
}


register_tag_macros!{
    ///////////////////////////////////////////////////////////////////////////
    // HTML HEADINGS
    ///////////////////////////////////////////////////////////////////////////
    fn global::h1(env, tag) {
        Node::Tag(tag)
    }
    fn global::h2(env, tag) {
        Node::Tag(tag)
    }
    fn global::h3(env, tag) {
        Node::Tag(tag)
    }
    fn global::h4(env, tag) {
        Node::Tag(tag)
    }
    fn global::h5(env, tag) {
        Node::Tag(tag)
    }
    fn global::h6(env, tag) {
        Node::Tag(tag)
    }
    fn global::h6(env, tag) {
        Node::Tag(tag)
    }

    ///////////////////////////////////////////////////////////////////////////
    // HTML TABLES
    ///////////////////////////////////////////////////////////////////////////
    /// `\row{1}{2}...{N}` is syntactic sugar for `<tr><td>1</td><td>2</td>...<td>N</td></tr>`
    fn table::row(env, tag) {
        tag.children = tag.children
            .into_iter()
            .map(|child| {
                if !child.has_tag("td") {
                    return Node::new_tag("td", vec![child])
                }
                child
            })
            .collect_vec();
        tag.name = "tr".into();
        Node::Tag(tag)
    }
    // This is implemented internally since the plugin API doesn’t support
    // expanded nodes, I.e. returning a Vec<Node> instead of a Node.
    fn global::include(env, tag) {
        Node::Tag(tag)
    }
}



