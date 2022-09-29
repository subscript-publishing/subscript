use std::borrow::Cow;
use std::collections::HashMap;
use crate::compiler::data::{LayoutKind, Text};
use crate::compiler::MathEnv;

///////////////////////////////////////////////////////////////////////////////
// BASICS
///////////////////////////////////////////////////////////////////////////////

#[derive(Clone)]
pub enum Image {
    Svg {
        kind: LayoutKind,
        payload: String,
    },
}

impl std::fmt::Debug for Image {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Image::Svg{kind, payload} => {
                f.debug_struct("Svg")
                    .field("kind", &kind)
                    .field("payload", &String::from("DataNotShown"))
                    .finish()
            }
        }
    }
}

#[derive(Debug, Clone)]
pub enum ImageType {
    Svg,
}

impl Image {
    pub fn layout(&self) -> LayoutKind {
        match self {
            Self::Svg { kind, payload } => kind.clone(),
        }
    }
    pub fn image_type(&self) -> ImageType {
        match self {
            Self::Svg {..} => ImageType::Svg,
        }
    }
}


///////////////////////////////////////////////////////////////////////////////
// HTML TREE
///////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone)]
pub struct Element {
    pub name: String,
    pub attributes: HashMap<String, String>,
    pub children: Vec<Node>,
}


#[derive(Debug, Clone)]
pub enum Node {
    Element(Element),
    Text(String),
    Image(Image),
    Fragment(Vec<Node>),
}

impl Node {
    pub fn new_text<T: Into<String>>(val: T) -> Self {
        Node::Text(val.into())
    }
    pub fn to_html_str(self) -> String {
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
                        Text::default()
                    } else {
                        let mut attrs = attributes;
                        attrs.insert(0, ' ');
                        Text::from_string(attrs)
                    }
                };
                let children = node.children
                    .into_iter()
                    .map(Node::to_html_str)
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
                    .map(Node::to_html_str)
                    // .map(|x| x.0)
                    .collect::<Vec<_>>()
                    .join("");
                children
            }
            Node::Image(image) => {
                unimplemented!()
            }
        }
    }
}


/// Render the entire document.
#[derive(Debug, Clone)]
pub struct Document {
    pub toc: Option<Node>,
    pub math: MathEnv,
    pub body: Vec<Node>
}

impl Document {
    // pub fn from_source(source: &str) -> Document {
    //     // let body = crate::frontend::pass::pp_normalize::run_compiler_frontend(source);
    //     // let body = crate::frontend::pass::html_normalize::html_canonicalization(body);
    //     // let mut env = crate::frontend::pass::math::MathEnv::default();
    //     // let body = body
    //     //     .into_iter()
    //     //     .map(crate::frontend::pass::math::latex_pass)
    //     //     .collect::<Vec<_>>();
    //     // let toc = crate::frontend
    //     //     ::pass
    //     //     ::html_normalize
    //     //     ::generate_table_of_contents_tree(body.clone());
    //     // let toc = crate::frontend::pass::math::latex_pass(toc).node_to_html();
    //     // let body = body
    //     //     .into_iter()
    //     //     .map(crate::frontend::pass::html_normalize::annotate_heading_nodes)
    //     //     .map(crate::frontend::ast::Node::node_to_html)
    //     //     .collect::<Vec<_>>();
    //     // Document{toc, body}
    //     unimplemented!()
    // }
    pub fn render_to_string(self) -> String {
        let no_toc = self.toc.is_none();
        fn pack_toc(toc: String) -> String {
            format!(
                "<div id=\"toc-wrapper\"><h1>Table of Contents</h1>{}</div>",
                toc
            )
        }
        let toc = {
            self.toc
                .map(|x| x.to_html_str().to_string())
                .map(pack_toc)
                .unwrap_or(String::new())
        };
        let javascript = format!("<script>addEventListener('load', (event) => {{{}}});</script>", self.math.to_javascript());
        let body = self.body
            .into_iter()
            .map(Node::to_html_str)
            // .map(|x| x.0)
            .collect::<Vec<_>>()
            .join("\n");
        String::from(include_str!("../../assets/template.html"))
            .replace("<!--{{deps}}-->", include_str!("../../assets/deps.html"))
            .replace("/*{{css}}*/", include_str!("../../assets/styling.css"))
            .replace("<!--{{toc}}-->", &toc)
            .replace("<!--{{body}}-->", &body)
            .replace("<!--{{JAVASCRIPT}}-->", &javascript)
    }
}



