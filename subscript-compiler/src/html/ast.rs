use std::collections::HashMap;
use std::rc::Rc;

#[derive(Debug, Clone)]
pub enum LayoutKind {
    Block,
    Inline,
}

///////////////////////////////////////////////////////////////////////////////
// BASICS
///////////////////////////////////////////////////////////////////////////////

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

#[derive(Debug, Clone, Default)]
pub struct NodeScope {
    pub parents: Vec<String>,
}

impl NodeScope {
    pub fn push_parent(&mut self, name: String) {
        self.parents.push(name)
    }
    pub fn has_parent(&self, parent: &str) -> bool {
        self.parents
            .iter()
            .any(|x| x == parent)
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

impl Element {
    pub fn has_tag<T: AsRef<str>>(&self, name: T) -> bool {
        self.name == name.as_ref()
    }
    pub fn has_attr<T: AsRef<str>>(&self, key: T) -> bool {
        self.attributes.contains_key(key.as_ref())
    }
    pub fn get_attr_value<T: AsRef<str>>(&self, key: T) -> Option<&String> {
        self.attributes.get(key.as_ref())
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
    pub fn new_element<T: Into<String>>(tag: T, attrs: HashMap<String, String>, children: Vec<Node>) -> Self {
        Node::Element(Element{
            name: tag.into(),
            attributes: attrs,
            children
        })
    }
    pub fn parse_str<T: AsRef<str>>(html_str: T) -> Self {
        Node::Fragment(crate::html::parser::parse_html_str(html_str.as_ref()).payload)
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
                        String::new()
                    } else {
                        let mut attrs = attributes;
                        attrs.insert(0, ' ');
                        attrs
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
            Node::Drawing(model) => {
                let dark_ui_mode = model.to_svg(&ss_freeform_format::ColorScheme::Dark);
                let light_ui_mode = model.to_svg(&ss_freeform_format::ColorScheme::Light);
                vec![dark_ui_mode, light_ui_mode].join("\n")
            }
        }
    }
    pub fn transform<F: Fn(NodeScope, Node) -> Node>(
        self,
        mut env: NodeScope,
        f: Rc<F>
    ) -> Node {
        match self {
            Node::Element(node) => {
                env.push_parent(node.name.clone());
                let children = node.children
                    .into_iter()
                    .map(|x| x.transform(env.clone(), f.clone()))
                    .collect::<Vec<_>>();
                let node = Element {
                    name: node.name,
                    attributes: node.attributes,
                    children,
                };
                f(env.clone(), Node::Element(node))
            }
            Node::Fragment(children) => {
                let children = children
                    .into_iter()
                    .map(|x| x.transform(env.clone(), f.clone()))
                    .collect();
                let node = Node::Fragment(children);
                f(env.clone(), node)
            }
            node @ Node::Text(_) => {
                f(env.clone(), node)
            }
            node @ Node::Drawing(_) => {
                f(env.clone(), node)
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
}




