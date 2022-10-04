//! Transform tags into their HTML like structure.

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
    // HTML TABLES
    ///////////////////////////////////////////////////////////////////////////
    /// To properly implement horizontally scrollable tables on Safari, we have
    /// to wrap tables in a div with the appropriate CSS (until a better
    /// workaround is discovered). 
    fn global::table(env, table) {
        let mut attrs = Attributes::default();
        attrs.insert_key("data-table-wrapper");
        let wrapper = Tag::new_with_param("div", attrs, vec![Node::Tag(table)]);
        Node::Tag(wrapper)
    }

    ///////////////////////////////////////////////////////////////////////////
    // Subscript Specific Semantic Layout and Content Tags
    ///////////////////////////////////////////////////////////////////////////
    fn global::note(env, tag) {
        tag.attributes.insert("data-tag", "note");
        tag.name = "section".into();
        Node::Tag(tag)
    }
    fn global::layout(env, tag) {
        tag.attributes.insert("data-tag", "layout");
        tag.name = "div".into();
        Node::Tag(tag)
    }
}
