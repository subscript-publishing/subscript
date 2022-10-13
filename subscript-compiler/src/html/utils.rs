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
use crate::ss::ast_data::HeadingType;

pub fn math_env_to_html_script(math: &crate::ss::env::MathEnv) -> Node {
    Node::Element(Element{
        name: String::from("script"),
        attributes: Default::default(),
        children: vec![
            Node::Text(math.to_javascript())
        ]
    })
}

pub fn toc_rewrites(
    base_path: PathBuf,
    current_file: PathBuf,
    node: Node,
    toc_entry: &mut TocPageEntry,
) -> Node {
    match node {
        Node::Element(mut element) if element.is_heading_node() => {
            let mut dashed_title = element.children
                .iter()
                .map(Node::to_dashed_title)
                .collect::<String>();
            let mut original_title = dashed_title.clone();
            let mut ix = 1;
            while toc_entry.used_ids.contains(&dashed_title) {
                dashed_title = format!("{original_title}{ix}");
                ix = ix + 1;
            }
            std::mem::drop(original_title);
            toc_entry.used_ids.insert(dashed_title.clone());
            let mut is_local = false;
            let path = element
                .get_attr_value("source")
                .map(PathBuf::from)
                .unwrap_or_else(|| {
                    is_local = true;
                    current_file.clone()
                });
            let mut path = path
                .strip_prefix(&base_path)
                .map(Path::to_path_buf)
                .unwrap_or(path);
            path.set_extension("html");
            let path = path.to_str().unwrap().to_string();
            let _ = element.attributes.remove("source");
            let href = (String::from("href"), format!("/{path}#{dashed_title}"));
            let li_entry = Node::Element(Element {
                name: String::from("li"),
                attributes: HashMap::from_iter([
                    (String::from("data-level"), match element.unpack_heading_node().unwrap() {
                        HeadingType::H1 => String::from("h1"),
                        HeadingType::H2 => String::from("h2"),
                        HeadingType::H3 => String::from("h3"),
                        HeadingType::H4 => String::from("h4"),
                        HeadingType::H5 => String::from("h5"),
                        HeadingType::H6 => String::from("h6"),
                    })
                ]),
                children: vec![
                    Node::Element(Element {
                        name: String::from("a"),
                        attributes: HashMap::from_iter([href.clone()]),
                        children: element.children.clone(),
                    })
                ]
            });
            let source_type = {
                if is_local {
                    TocLiEntryType::Local
                } else {
                    TocLiEntryType::External
                }
            };
            toc_entry.li_entries.push(TocLiEntry {node: li_entry, kind: source_type });
            element.attributes.insert(String::from("id"), dashed_title);
            element.children = vec![
                Node::Element(Element {
                    name: String::from("a"),
                    attributes: HashMap::from_iter([href]),
                    children: element.children
                })
            ];
            Node::Element(element)
        }
        Node::Element(mut element) => {
            element.children = element.children
                .into_iter()
                .map(|x| toc_rewrites(
                    base_path.clone(),
                    current_file.clone(),
                    x,
                    toc_entry
                ))
                .collect::<Vec<_>>();
            Node::Element(element)
        }
        Node::Fragment(mut children) => {
            children = children
                .into_iter()
                .map(|x| toc_rewrites(
                    base_path.clone(),
                    current_file.clone(),
                    x,
                    toc_entry
                ))
                .collect();
            Node::Fragment(children)
        }
        node @ Node::Text(_) => node,
        node @ Node::Drawing(_) => node,
    }
}


#[derive(Debug, Clone)]
pub struct TocPageEntry {
    pub used_ids: HashSet<String>,
    pub src_path: PathBuf,
    pub out_path: PathBuf,
    pub math_entries: Vec<crate::ss::env::MathCodeEntry>,
    pub li_entries: Vec<TocLiEntry>,
}

#[derive(Debug, Clone)]
pub struct TocLiEntry {
    kind: TocLiEntryType,
    node: Node,
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

impl TocPageEntry {
    pub fn to_page_toc(&self, root_index: &PathBuf) -> Node {
        let ul_children = self.li_entries
            .iter()
            .map(|TocLiEntry{kind, node: element}| {
                let mut element = element.clone().into_element().unwrap();
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
            .push_child(
                TagBuilder::new("p")
                    .with_id("toc-list-info")
                    .push_child("Table Of Contents")
                    .finalize()
            )
            .push_child(
                TagBuilder::new("ul")
                    .with_id("toc-list")
                    .with_children(ul_children)
                    .finalize()
            )
            .finalize();
        // <span class="material-symbols-outlined">arrow_circle_left</span>
        // let left_icon = Node::new_element(
        //     "span",
        //     HashMap::from_iter([(String::from())])
        // );
        // let homepage = Node::Element(Element {
        //     name: String::from("div"),
        //     attributes: HashMap::default(),
        //     children: ul_children
        // });
        let site_title = TagBuilder::new("div")
            .with_class("site-header-row")
            .with_id("site-title-wrapper")
            .push_child(
                TagBuilder::new("a")
                    .with_class("left-link")
                    .with_attr("href", "/")
                    .push_child(
                        TagBuilder::new("span")
                            .with_class("material-symbols-outlined")
                            .push_child("house")
                            .finalize()
                    )
                    .finalize()
            )
            .push_child(
                TagBuilder::new("div")
                    .with_id("site-title-box")
                    .push_child(
                        TagBuilder::new("h1")
                            .with_attr_key("data-title")
                            .push_child(
                                "Colbyn's School Notes"
                            )
                            .finalize()
                    )
                    .finalize()
            )
            .finalize();
        let site_nav = TagBuilder::new("nav")
            .with_class("site-header-row")
            .with_id("site-nav-wrapper")
            .push_child(
                TagBuilder::new("a")
                    .with_class("left-link")
                    .with_attr("href", "/")
                    .push_child(
                        TagBuilder::new("span")
                            .with_class("material-symbols-outlined")
                            .push_child("arrow_circle_left")
                            .finalize()
                    )
                    .finalize()
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

pub fn compile_index_page() {

}

