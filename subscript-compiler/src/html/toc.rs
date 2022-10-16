use std::borrow::BorrowMut;
use std::collections::HashMap;
use std::collections::HashSet;
use std::path::Path;
use std::cell::RefCell;
use std::path::PathBuf;
use std::rc::Rc;
use itertools::Itertools;

use super::Element;
use super::Node;
use super::TagBuilder;
use super::NodeElementMutTraversal;
use crate::ss::ast_data::HeadingType;
use crate::data::Store;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


pub struct TocRewritesTraversal<'a> {
    route_prefix: Option<String>,
    base_path: &'a PathBuf,
    current_file: &'a PathBuf,
    toc_entry: &'a Store<TocPageEntry>,
}

impl<'a> NodeElementMutTraversal for TocRewritesTraversal<'a> {
    fn element(&self, element: &mut Element) {
        if element.is_heading_node() {
            let mut dashed_title = element.children
                .iter()
                .map(Node::to_dashed_title)
                .collect::<String>();
            let mut original_title = dashed_title.clone();
            let mut ix = 1;
            while {self.toc_entry.map(|x| x.used_ids.contains(&dashed_title))} {
                dashed_title = format!("{original_title}{ix}");
                ix = ix + 1;
            }
            std::mem::drop(original_title);
            self.toc_entry.map_mut(|x| x.used_ids.insert(dashed_title.clone()));
            let mut is_local = false;
            let path = element
                .get_attr_value("source")
                .map(PathBuf::from)
                .unwrap_or_else(|| {
                    is_local = true;
                    self.current_file.clone()
                });
            let mut path = path
                .strip_prefix(&self.base_path)
                .map(Path::to_path_buf)
                .unwrap_or(path);
            path.set_extension("html");
            let path = path.to_str().unwrap().to_string();
            let _ = element.attributes.remove("source");
            let href = (String::from("href"), match self.route_prefix.as_ref() {
                None => format!("/{path}#{dashed_title}"),
                Some(prefix) => format!("/{prefix}/{path}#{dashed_title}"),
            });
            let li_entry = Element {
                name: String::from("li"),
                attributes: HashMap::from_iter([
                    (String::from("data-level"), match element.unpack_heading_node().unwrap() {
                        HeadingType::H1 => String::from("h1"),
                        HeadingType::H2 => String::from("h2"),
                        HeadingType::H3 => String::from("h3"),
                        HeadingType::H4 => String::from("h4"),
                        HeadingType::H5 => String::from("h5"),
                        HeadingType::H6 => String::from("h6"),
                    }),
                    (String::from("top-level"), {
                        if element.has_attr("top-level") {
                            String::from("true")
                        } else {
                            String::from("false")
                        }
                    })
                ]),
                children: vec![
                    Node::Element(Element {
                        name: String::from("a"),
                        attributes: HashMap::from_iter([href.clone()]),
                        children: element.children.clone(),
                    })
                ]
            };
            let source_type = {
                if is_local {
                    TocLiEntryType::Local
                } else {
                    TocLiEntryType::External
                }
            };
            self.toc_entry.map_mut(move |entry| {
                entry.li_entries.push(TocLiEntry {node: li_entry, kind: source_type })
            });
            element.attributes.insert(String::from("id"), dashed_title);
            element.children = vec![
                Node::Element(Element {
                    name: String::from("a"),
                    attributes: HashMap::from_iter([href]),
                    children: element.children.drain(..).collect_vec(),
                })
            ];
        }
    }
}

pub fn toc_rewrites(
    route_prefix: Option<String>,
    base_path: &PathBuf,
    current_file: &PathBuf,
    toc_entry: &mut TocPageEntry,
    mut node: Node,
) -> Node {
    let toc_entry_ref = Store::new(toc_entry.clone());
    let visitor = TocRewritesTraversal {
        route_prefix,
        base_path,
        current_file,
        toc_entry: &toc_entry_ref,
    };
    node.node_element_traversal(&visitor);
    *toc_entry = toc_entry_ref.into_clone();
    node
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TOC-PAGE-ENTRY
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone)]
pub struct TocPageEntry {
    pub used_ids: HashSet<String>,
    pub src_path: PathBuf,
    pub out_path: PathBuf,
    pub math_entries: Vec<crate::ss::env::MathCodeEntry>,
    pub page_title: Option<TocLiEntry>,
    pub li_entries: Vec<TocLiEntry>,
}

#[derive(Debug, Clone)]
pub struct TocLiEntry {
    kind: TocLiEntryType,
    node: Element,
}

#[derive(Debug, Clone)]
pub enum TocLiEntryType {
    Local,
    External,
}

impl TocLiEntryType {
    pub fn is_local(&self) -> bool {
        match self {
            TocLiEntryType::Local => true,
            _ => false,
        }
    }
    pub fn is_external(&self) -> bool {
        match self {
            TocLiEntryType::External => true,
            _ => false,
        }
    }
}

#[derive(Default)]
pub struct TocPageRenderingOptions {
    pub is_index_page: bool,
    pub site_title: Option<String>,
    pub route_prefix: Option<String>,
}

impl TocPageEntry {
    pub fn to_page_toc(
        &self,
        root_index: Option<&PathBuf>,
        options: TocPageRenderingOptions,
    ) -> Node {
        // let is_topics_empty = self.topic_section.is_empty();
        let toc_ul_children = self.li_entries
            .iter()
            .map(|TocLiEntry{kind, node: element}| {
                let mut element = element.clone();
                match kind {
                    TocLiEntryType::Local => {
                        element.attributes.insert(String::from("data-source"), String::from("local"));
                    },
                    TocLiEntryType::External => {
                        element.attributes.insert(String::from("data-source"), String::from("external"));
                    }
                }
                Node::Element(element)
            })
            .collect_vec();
        let toc_ul_topics_children = self.li_entries
            .iter()
            .filter_map(|entry| {
                if entry.node.has_truthy_attr("top-level") {
                    Some(entry.clone())
                } else {
                    None
                }
            })
            .map(|TocLiEntry{kind, node: element}| {
                let mut element = element.clone();
                match kind {
                    TocLiEntryType::Local => {
                        element.attributes.insert(String::from("data-source"), String::from("local"));
                    },
                    TocLiEntryType::External => {
                        element.attributes.insert(String::from("data-source"), String::from("external"));
                    }
                }
                Node::Element(element)
            })
            .collect_vec();
        let toc_list_wrapper = TagBuilder::new("div")
            .with_id("toc-list-wrapper")
            .push_child_if(
                !toc_ul_topics_children.is_empty(),
                || {
                    TagBuilder::new("p")
                        .with_id("topic-list-info")
                        .with_class("toc-info-banner")
                        .push_child("Topics")
                        .finalize()
                }
            )
            .push_child_if(
                !toc_ul_topics_children.is_empty(),
                move || {
                    TagBuilder::new("ul")
                        .with_id("topic-list")
                        .with_children(toc_ul_topics_children.clone())
                        .finalize()
                }
            )
            .push_child(
                TagBuilder::new("p")
                    .with_id("toc-list-info")
                    .with_class("toc-info-banner")
                    .push_child("Table Of Contents")
                    .finalize()
            )
            .push_child(
                TagBuilder::new("ul")
                    .with_id("toc-list")
                    .with_children(toc_ul_children)
                    .finalize()
            )
            .finalize();
        let single_col = {
            root_index.is_some() || options.is_index_page
        };
        let site_title = TagBuilder::new("div")
            .with_class("site-header-row")
            .with_attr_if(single_col, "data-col", "1")
            .with_attr_if(!single_col, "data-col", "2")
            .with_id("site-title-wrapper")
            .push_child_if(
                !single_col,
                || {
                    TagBuilder::new("a")
                        .with_class("left-link")
                        .with_attr("href", match options.route_prefix.as_ref() {
                            None => String::from("/index.html"),
                            Some(prefix) => format!("/{prefix}/index.html"),
                        })
                        .push_child(
                            TagBuilder::new("span")
                                .with_class("material-symbols-outlined")
                                .push_child("house")
                                .finalize()
                        )
                        .finalize()
                }
            )
            .push_child_option(
                options.site_title.as_ref(),
                |title| TagBuilder::new("div")
                    .with_id("site-title-box")
                    .push_child(
                        TagBuilder::new("h1")
                            .with_attr_key("data-title")
                            .push_child(title)
                            .finalize()
                    )
                    .finalize()
            )
            .finalize();
        let site_nav = TagBuilder::new("nav")
            .with_class("site-header-row")
            .with_class_if(single_col, "single-col")
            .with_class_if(!single_col, "two-col")
            .with_id("site-nav-wrapper")
            .push_child_if(
                !single_col,
                || {
                    TagBuilder::new("a")
                        .with_class("left-link")
                        .with_attr("href", match options.route_prefix.as_ref() {
                            None => String::from("/index.html"),
                            Some(prefix) => format!("/{prefix}/index.html"),
                        })
                        .push_child(
                            TagBuilder::new("span")
                                .with_class("material-symbols-outlined")
                                .push_child("arrow_circle_left")
                                .finalize()
                        )
                        .finalize()
                }
            )
            .push_child(toc_list_wrapper)
            .finalize();
        let settings = TagBuilder::new("div")
            .with_id("site-settings-wrapper")
            .push_child(
                TagBuilder::new("button")
                    .with_id("set-single-col-to-off-btn")
                    .with_class("pill")
                    .with_attr("onclick", "setForceSingleColumnToOff()")
                    .push_child(
                        TagBuilder::new("span")
                            .push_child("Force Single Column")
                            .finalize()
                    )
                    .push_child(
                        TagBuilder::new("span")
                            .push_child("On")
                            .finalize()
                    )
                    .finalize()
            )
            .push_child(
                TagBuilder::new("button")
                    .with_id("set-single-col-to-on-btn")
                    .with_class("pill")
                    .with_attr("onclick", "setForceSingleColumnToOn()")
                    .push_child(
                        TagBuilder::new("span")
                            .push_child("Force Single Column")
                            .finalize()
                    )
                    .push_child(
                        TagBuilder::new("span")
                            .push_child("Off")
                            .finalize()
                    )
                    .finalize()
            )
            .finalize();
        TagBuilder::new("header")
            .with_id("page-header")
            .with_children([
                site_title,
                site_nav,
                settings,
            ])
            .finalize()
    }
}
