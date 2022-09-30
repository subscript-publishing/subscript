//! Compile math mode to the given target.
//!
//! Eventually the given options will be
//! * LaTeX math (for some external compiler such as MathJax when using the HTML target). 
//! * Native typesetter. 
use itertools::Itertools;
use lazy_static::lazy_static;
use std::iter::FromIterator;
use std::collections::HashSet;
use std::rc::Rc;
use std::borrow::Cow;
use crate::compiler::data::{
    Text,
    INLINE_MATH_TAG,
};
use crate::compiler::ast::{Ann, Node, NodeScope, Tag, Enclosure, EnclosureKind, Attributes,};

#[derive(Debug, Clone, Default)]
pub struct MathEnv {
    pub entries: Vec<MathCodeEntry>,
}

impl MathEnv {
    pub fn add_inline_entry<'a>(&mut self, code: String) -> Node {
        let id = crate::utils::ramdom_id();
        let mut attrs = Attributes::default();
        attrs.insert("id", &id);
        attrs.insert("macro", "math");
        attrs.insert("math-mode", "inline");
        let entry = MathCodeEntry {id, code, mode: ModeMode::Inline};
        self.entries.push(entry);
        Node::Tag(Tag::new_with_param(
            "span",
            attrs,
            vec![],
        ))
    }
    pub fn add_block_entry<'a>(&mut self, code: String) -> Node {
        let id = crate::utils::ramdom_id();
        let mut attrs = Attributes::default();
        attrs.insert("id", &id);
        attrs.insert("macro", "math");
        attrs.insert("math-mode", "block");
        let entry = MathCodeEntry {id, code, mode: ModeMode::Inline};
        self.entries.push(entry);
        Node::Tag(Tag::new_with_param(
            "div",
            attrs,
            vec![],
        ))
    }
    pub fn to_javascript(&self) -> String {
        self.entries
            .iter()
            .map(|x| {
                format!(
                    "katex.render({code}, document.getElementById('{id}'), {{throwOnError: true}});",
                    code=format!("{:?}", x.code),
                    id=x.id,
                )
            })
            .join("\n")
    }
}

#[derive(Debug, Clone)]
pub struct MathCodeEntry {
    pub id: String,
    pub code: String,
    pub mode: ModeMode,
}

#[derive(Debug, Clone)]
pub enum ModeMode {
    Inline,
    Block,
}

pub static LATEX_ENVIRONMENT_NAME_LIST: &'static [&'static str] = &[
    "equation",
    "split",
];

lazy_static! {
    pub static ref LATEX_ENV_NAMES: HashSet<&'static str> = {
        HashSet::from_iter(
            LATEX_ENVIRONMENT_NAME_LIST.to_vec()
        )
    };
}


// /// Converts math nodes to a valid latex code within the AST data model.
// // TODO - ADD STUFF HERE
// fn to_valid_latex_math(node: Node) -> Node {
//     // FUNCTION
//     fn f(env: NodeEnvironment, x: Node) -> Node {
//         // PROCESS SUBSCRIPT MATH MACROS HERE OR BEFORE THIS STAGE
//         match x {
//             x => x,
//         }
//     }
//     // GO! (BOTTOM UP)
//     node.transform(NodeEnvironment::empty(), Rc::new(f))
// }


/// Entrypoint.
pub fn latex_pass<'a>(env: &mut MathEnv, node: Node) -> Node {
    match node {
        Node::Tag(tag) if tag.has_name("equation") => {
            let node = tag.children
                .into_iter()
                // .flat_map(Node::unblock)
                .map(|x| x.to_string())
                .collect::<Vec<_>>()
                .join("");
            let start = "\\begin{equation}\\begin{split}";
            let end = "\\end{split}\\end{equation}";
            let code = format!(
                "{}{}{}",
                start,
                node,
                end,
            );
            env.add_block_entry(code)
        }
        Node::Tag(tag) if tag.has_name("math") => {
            // println!("math input {:#?}", tag.children);
            let code = tag.children
                .into_iter()
                // .flat_map(Node::unblock)
                .map(|x| x.to_string())
                .collect::<Vec<_>>()
                .join("");
            // println!("math output {:?}", code);
            env.add_block_entry(code)
        }
        Node::Tag(tag) if tag.has_name(INLINE_MATH_TAG) => {
            let code = tag.children
                .into_iter()
                // .flat_map(Node::unblock)
                .map(|x| x.to_string())
                .collect::<Vec<_>>()
                .join("");
            env.add_inline_entry(code)
        }
        Node::Tag(mut tag) => {
            tag.children = tag.children
                .into_iter()
                .map(|x| latex_pass(env, x))
                .collect();
            Node::Tag(tag)
        }
        Node::Enclosure(mut block) => {
            block.data.children = block.data.children
                .into_iter()
                .map(|x| latex_pass(env, x))
                .collect();
            Node::Enclosure(block)
        }
        node @ Node::Ident(_) => node,
        node @ Node::Text(_) => node,
        node @ Node::InvalidToken(_) => node,
        node @ Node::HtmlCode(_) => node,
    }
}

