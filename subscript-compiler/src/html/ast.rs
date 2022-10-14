use std::borrow::BorrowMut;
use std::collections::HashMap;
use std::rc::Rc;
use std::cell::RefCell;

use itertools::Itertools;

impl<T: Into<String>> From<T> for Node {
    fn from(val: T) -> Self {
        Node::Text(val.into())
    }
}

#[derive(Debug, Clone)]
pub enum LayoutKind {
    Block,
    Inline,
}


#[derive(Debug, Clone)]
pub struct TagBuilder {
    pub name: String,
    pub attributes: HashMap<String, String>,
    pub children: Vec<Node>,
}

impl TagBuilder {
    pub fn new(tag: impl Into<String>) -> Self {
        let name = tag.into();
        TagBuilder {
            name,
            attributes: Default::default(),
            children: Default::default(),
        }
    }
    pub fn with_attr<K, V>(
        mut self,
        key: K,
        value: V
    ) -> Self where K: Into<String>, V: Into<String> {
        self.attributes.insert(key.into(), value.into());
        self
    }
    pub fn with_attr_if<K, V>(
        mut self,
        show: bool,
        key: K,
        value: V
    ) -> Self where K: Into<String>, V: Into<String> {
        if show {
            self.attributes.insert(key.into(), value.into());
        }
        self
    }
    pub fn with_attr_key<K: Into<String>>(mut self, key: K) -> Self {
        self.attributes.insert(key.into(), String::new());
        self
    }
    pub fn with_id<T: AsRef<str>>(mut self, value: T) -> Self {
        self.attributes.insert(String::from("id"), value.as_ref().to_string());
        self
    }
    pub fn with_class<T: AsRef<str>>(mut self, name: T) -> Self {
        if let Some(val) = self.attributes.get_mut("class") {
            val.push(' ');
            val.push_str(name.as_ref());
            return self
        }
        self.attributes.insert(String::from("class"), name.as_ref().to_string());
        self
    }
    pub fn with_class_if<T: AsRef<str>>(mut self, show: bool, name: T) -> Self {
        if show {
            if let Some(val) = self.attributes.get_mut("class") {
                val.push(' ');
                val.push_str(name.as_ref());
                return self
            }
            self.attributes.insert(String::from("class"), name.as_ref().to_string());
        }
        self
    }
    pub fn with_children<T: Into<Node>>(mut self, children: impl IntoIterator<Item=T>) -> Self {
        self.children.extend(children.into_iter().map(|x| x.into()));
        self
    }
    pub fn push_child<T: Into<Node>>(mut self, child: T) -> Self {
        self.children.push(child.into());
        self
    }
    pub fn push_child_if<T: Into<Node>>(mut self, show: bool, f: impl Fn() -> T) -> Self {
        if show {
            self.children.push(f().into());
        }
        self
    }
    pub fn finalize(self) -> Node {
        Node::Element(Element{
            name: self.name,
            attributes: self.attributes,
            children: self.children,
        })
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// BASICS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

// #[derive(Clone)]
// pub enum Image {
//     Svg {dark_ui_mode: String, light_ui_mode: String},
// }

// impl std::fmt::Debug for Image {
//     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
//         match self {
//             Image::Svg{..} => {
//                 write!(f, "Svg(…)")
//             }
//         }
//     }
// }


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// HTML TREE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone)]
pub struct Element {
    pub name: String,
    pub attributes: HashMap<String, String>,
    pub children: Vec<Node>,
}

impl Element {
    pub fn has_name<T: AsRef<str>>(&self, name: T) -> bool {
        self.name == name.as_ref()
    }
    pub fn has_attr<T: AsRef<str>>(&self, key: T) -> bool {
        self.attributes.contains_key(key.as_ref())
    }
    pub fn get_attr_value<T: AsRef<str>>(&self, key: T) -> Option<&String> {
        self.attributes.get(key.as_ref())
    }
    pub fn is_heading_node(&self) -> bool {
        self.unpack_heading_node().is_some()
    }
    pub fn unpack_heading_node(&self) -> Option<crate::ss::ast_data::HeadingType> {
        match self.name.as_str() {
            "h1" => Some(crate::ss::ast_data::HeadingType::H1),
            "h2" => Some(crate::ss::ast_data::HeadingType::H2),
            "h3" => Some(crate::ss::ast_data::HeadingType::H3),
            "h4" => Some(crate::ss::ast_data::HeadingType::H4),
            "h5" => Some(crate::ss::ast_data::HeadingType::H5),
            "h6" => Some(crate::ss::ast_data::HeadingType::H6),
            _ => None,
        }
    }
}


#[derive(Debug, Clone)]
pub enum Node {
    Element(Element),
    Text(String),
    Drawing(ss_freeform_format::DrawingDataModel),
    Fragment(Vec<Node>),
}

impl Node {
    pub fn new_text<T: Into<String>>(val: T) -> Self {
        Node::Text(val.into())
    }
    pub fn into_element(self) -> Option<Element> {
        match self {
            Node::Element(x) => Some(x),
            _ => None
        }
    }
    pub fn parse_str<T: AsRef<str>>(html_str: T) -> Self {
        Node::Fragment(crate::html::parser::parse_html_str(html_str.as_ref()).payload)
    }
    /// TODO: Check that self is a root html tag.
    pub fn to_html_document(self) -> String {
        let html = self.to_html_fragment_str();
        format!("<!DOCTYPE html>\n{html}")
    }
    pub fn to_html_fragment_str(self) -> String {
        match self {
            Node::Text(node) => node,
            Node::Element(node) => {
                let attributes = node.attributes
                    .into_iter()
                    .map(|(left, right)| -> String {
                        let mut result = String::new();
                        let key: &str = &left;
                        let value: &str = &right;
                        let value = value.strip_prefix("\'").unwrap_or(value);
                        let value = value.strip_prefix("\"").unwrap_or(value);
                        let value = value.strip_suffix("\'").unwrap_or(value);
                        let value = value.strip_suffix("\"").unwrap_or(value);
                        result.push_str(key);
                        result.push_str("=");
                        result.push_str(&format!("{:?}", value));
                        result
                    })
                    .collect::<Vec<_>>()
                    .join(" ");
                let attributes = {
                    if attributes.is_empty() {
                        String::new()
                    } else {
                        let mut attrs = attributes;
                        attrs.insert(0, ' ');
                        attrs
                    }
                };
                let children = node.children
                    .into_iter()
                    .map(Node::to_html_fragment_str)
                    // .map(|x| x.0)
                    .collect::<Vec<_>>()
                    .join("");
                let children = children;
                format!(
                    "<{name}{attrs}>{children}</{name}>",
                    name=node.name,
                    attrs=attributes,
                    children=children,
                )
            }
            Node::Fragment(nodes) => {
                let children = nodes
                    .into_iter()
                    .map(Node::to_html_fragment_str)
                    // .map(|x| x.0)
                    .collect::<Vec<_>>()
                    .join("");
                children
            }
            Node::Drawing(model) => {
                let dark_ui_mode = model.to_svg(&ss_freeform_format::ColorScheme::Dark);
                let light_ui_mode = model.to_svg(&ss_freeform_format::ColorScheme::Light);
                vec![dark_ui_mode, light_ui_mode].join("\n")
            }
        }
    }
    pub fn transform<F: Fn(Node) -> Node>(self, mut f: Rc<F>) -> Node {
        match self {
            Node::Element(node) => {
                let children = node.children
                    .into_iter()
                    .map(|x| x.transform(f.clone()))
                    .collect::<Vec<_>>();
                let node = Element {
                    name: node.name,
                    attributes: node.attributes,
                    children,
                };
                f(Node::Element(node))
            }
            Node::Fragment(children) => {
                let children = children
                    .into_iter()
                    .map(|x| x.transform(f.clone()))
                    .collect();
                let node = Node::Fragment(children);
                f(node)
            }
            node @ Node::Text(_) => {
                f(node)
            }
            node @ Node::Drawing(_) => {
                f(node)
            }
        }
    }
    pub fn has_tag<T: AsRef<str>>(&self, name: T) -> bool {
        match self {
            Node::Element(element) => &element.name == name.as_ref(),
            _ => false
        }
    }
    pub fn has_attr<T: AsRef<str>>(&self, key: T) -> bool {
        match self {
            Node::Element(element) => element.attributes.contains_key(key.as_ref()),
            _ => false
        }
    }
    pub fn get_attr_value<T: AsRef<str>>(&self, key: T) -> Option<&String> {
        match self {
            Node::Element(element) => element.attributes.get(key.as_ref()),
            _ => None
        }
    }

    /// We try to generate stable titles irrespective of formatting.
    pub fn to_dashed_title(&self) -> String {
        fn pack(value: &str) -> String {
            value
                .chars()
                .flat_map(|ch| {
                    ch.to_lowercase()
                        .filter(|x| x.is_alphanumeric())
                })
                .collect::<String>()
        }
        match self {
            Node::Element(cmd) => {
                cmd.children
                    .iter()
                    .map(Node::to_dashed_title)
                    .collect::<String>()
            },
            Node::Fragment(xs) => {
                xs  .iter()
                    .map(Node::to_dashed_title)
                    .collect::<String>()
            },
            Node::Text(value) => pack(value),
            Node::Drawing(x) => String::default(),
        }
    }
}




