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
    ($list:ident; $(#[$($attrss:tt)*])* fn $scope:ident::$tag_name:ident($env:ident, $tag:ident)$block:block $($rest:tt)*) => {{
        fn f($env: NodeScope, mut $tag: Tag) -> Node $block
        let scope = stringify!($scope).to_string();
        let tag_name = stringify!($tag_name).to_string();
        $list.insert(
            tag_name.clone(),
            Box::new(TagRewrite{scope, tag: tag_name, apply: Box::new(f)})
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
    fn global::table(env, tag) {
        // #[derive(Debug, Clone)]
        // struct Row {
        //     size: usize,
        //     elements: Vec<Node>
        // }
        // #[derive(Debug, Clone)]
        // enum TableElement {
        //     Row(Vec<TableElement>),
        //     Entry(Vec<TableElement>),
        //     Node(Node),
        // }
        // #[derive(Debug, Clone)]
        // enum AnnTableElement {
        //     Row(Meta, Vec<AnnTableElement>),
        //     Entry(Meta, Vec<AnnTableElement>),
        //     Node(Node),
        // }
        // #[derive(Debug, Clone, Default)]
        // pub struct Meta {
        //     row_width: usize,
        //     row_height: usize,
        // }
        // impl Meta {
        //     fn merge(self, other: Meta) -> Meta {
        //         Meta {
        //             row_width: self.row_width + other.row_width,
        //             row_height: self.row_height + other.row_height,
        //         }
        //     }
        // }
        // fn to_table_element(node: Node) -> TableElement {
        //     match node {
        //         Node::Enclosure(x) => {
        //             let kind = x.data.kind();
        //             let mut children = x.data.children
        //                 .into_iter()
        //                 .map(|x| to_table_element(x))
        //                 .collect_vec();
        //             match kind {
        //                 EnclosureKind::SquareParen => {
        //                     TableElement::Row(children)
        //                 }
        //                 EnclosureKind::CurlyBrace => {
        //                     TableElement::Entry(children)
        //                 }
        //                 EnclosureKind::Parens => {
        //                     TableElement::Entry(children)
        //                 }
        //                 EnclosureKind::String => {
        //                     TableElement::Entry(children)
        //                 }
        //                 EnclosureKind::Error => {
        //                     TableElement::Entry(children)
        //                 }
        //             }
        //         }
        //         x @ Node::Ident(_) => TableElement::Node(x),
        //         x @Node::Tag(_) => TableElement::Node(x),
        //         x @ Node::Text(_) => TableElement::Node(x),
        //         x @ Node::InvalidToken(_) => TableElement::Node(x),
        //     }
        // }
        // fn compute_meta(parent: &mut Meta, element: &TableElement) -> Option<Meta> {
        //     match element {
        //         TableElement::Entry(entry) => {
        //             // let sub_meta = entry
        //             //     .iter()
        //             //     .filter_map(|x| compute_meta(parent, x))
        //             //     .fold(Meta {row_width: 1, row_height: 1}, Meta::merge);
        //             // Some(sub_meta)
        //             None
        //         },
        //         TableElement::Row(entry) => {
        //             parent.row_height = parent.row_height + 1;
        //             let sub_meta = entry
        //                 .iter()
        //                 .filter_map(|x| compute_meta(parent, x))
        //                 .fold(Meta::default(), Meta::merge);
        //             Some(sub_meta)
        //         },
        //         TableElement::Node(node) => None
        //     }
        // }
        // fn to_ann_table_element(parent: &mut Meta, element: TableElement) -> AnnTableElement {
        //     let mut child_meta = compute_meta(parent, &element).unwrap_or_default();
        //     match element {
        //         TableElement::Entry(entry) => {
        //             let entry = entry
        //                 .into_iter()
        //                 .map(|x| to_ann_table_element(&mut child_meta, x))
        //                 .collect_vec();
        //             AnnTableElement::Entry(parent.clone().merge(child_meta), entry)
        //         }
        //         TableElement::Row(entry) => {
        //             let entry = entry
        //                 .into_iter()
        //                 .map(|x| to_ann_table_element(&mut child_meta, x))
        //                 .collect_vec();
        //             AnnTableElement::Row(parent.clone().merge(child_meta), entry)
        //         }
        //         TableElement::Node(entry) => {
        //             AnnTableElement::Node(entry)
        //         }
        //     }
        // }
        // fn process_sugar(parent: &mut Row, node: &Node) -> TableElement {
        //     match node {
        //         Node::Enclosure(enclosure) if enclosure.is_curly_brace() => {
        //             // let td = Node::new_tag("td", );
        //             unimplemented!()
        //         }
        //         Node::Enclosure(enclosure) if enclosure.is_square_parens() => {
        //             let mut sub_row = Row {size: 1, elements: Vec::new()};
        //             let mut children = enclosure.data.children
        //                 .iter()
        //                 .map(|x| process_sugar(&mut sub_row, x))
        //                 .collect_vec();
        //             unimplemented!()
        //         }
        //         node @ _ => unimplemented!()
        //     }
        // }
        // if tag.has_attr("sugar") {
        //     for child in tag.children.clone().into_iter().map(Node::trim_whitespace).flat_map(Node::unblock) {
        //         println!("child-kind {:?}", child.unpack_enclosure_kind());
        //         let row = to_table_element(child);
        //         let mut child_meta = Meta::default();
        //         let ann = to_ann_table_element(&mut child_meta, row.clone());
        //         println!("{:#?}", ann);
        //     }
        // }
        Node::Tag(tag)
    }
    /// `\row{1}{2}...{N}` is syntactic sugar for `<tr><td>1</td><td>2</td>...<td>N</td></tr>`
    fn table::row(env, tag) {
        tag.children = tag.children
            .into_iter()
            .map(|child| {
                Node::new_tag("td", vec![child])
            })
            .collect_vec();
        tag.name = "tr".into();
        Node::Tag(tag)
    }
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
    // This is implemented internally since the plugin API doesn’t support
    // expanded nodes, I.e. returning a Vec<Node> instead of a Node.
    fn global::include(env, tag) {
        Node::Tag(tag)
    }
}



