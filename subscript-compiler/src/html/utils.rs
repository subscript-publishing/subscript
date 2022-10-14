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

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

pub fn math_env_to_html_script(math: &crate::ss::env::MathEnv) -> Node {
    Node::Element(Element{
        name: String::from("script"),
        attributes: Default::default(),
        children: vec![
            Node::Text(math.to_javascript())
        ]
    })
}
