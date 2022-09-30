use std::{rc::Rc, path::{Path, PathBuf}};
use itertools::Itertools;
mod parser;
pub mod data;
pub mod ast;
mod pass;
use ast::Node;
use self::ast::NodeScope;
pub use pass::math::MathEnv;

#[derive(Debug, Clone)]
pub struct CompilerEnv {
    pub file_path: PathBuf,
    pub math_env: pass::math::MathEnv,
}

impl CompilerEnv {
    pub fn new(file_path: PathBuf) -> Self {
        CompilerEnv{
            file_path,
            math_env: MathEnv::default(),
        }
    }
    /// Use this to normalize file paths relative to the source file.
    pub fn normalize_file_path(&self, path: PathBuf) -> PathBuf {
        if let Some(rel_path) = self.file_path.parent() {
            let mut rel_path = rel_path.to_path_buf();
            rel_path.push(path);
            return rel_path
        }
        path
    }
    pub fn append_math_env(&mut self, mut math_env: MathEnv) {
        self.math_env.entries.append(&mut math_env.entries);
    }
}

pub mod low_level_api {
    use super::*;
    pub fn parse(file_path: PathBuf) -> Result<(CompilerEnv, Vec<Node>), String> {
        let source = std::fs::read_to_string(&file_path)
            .map_err(|x| format!("{:?}", x))?;
        let mut env = CompilerEnv::new(file_path);
        let body = crate::compiler::pass::pp_normalize::post_parser_normalize(&source);
        let body = crate::compiler::pass::core::core_passes(&mut env, body);
        Ok((env, body))
    }
    pub fn to_html_doc(env: CompilerEnv, nodes: Vec<Node>) -> String {
        let all_pre_html_rewrites = crate::plugins::pre_html::all_tag_macros();
        let f = |env: NodeScope, node: Node| -> Node {
            match node {
                Node::Tag(tag) => {
                    let mut tag = tag;
                    if let Some(rewrite) = all_pre_html_rewrites.get(&tag.name.data) {
                        rewrite.apply(env, tag)
                    } else {
                        Node::Tag(tag)
                    }
                }
                node @ Node::Enclosure(_) => node,
                node @ Node::Text(_) => node,
                node @ Node::Ident(_) => node,
                node @ Node::InvalidToken(_) => node,
                node @ Node::HtmlCode(_) => node,
            }
        };
        let nodes = nodes
            .into_iter()
            .map(|node| node.transform(NodeScope::default(), Rc::new(f)))
            .map(crate::compiler::ast::Node::node_to_html)
            .collect::<Vec<_>>();
        let doc = crate::codegen::html::Document {
            toc: None,
            math: env.math_env.clone(),
            body: nodes
        };
        doc.render_to_string()
    }
}

pub fn compile(file_path: PathBuf) -> String {
    let (env, nodes) = low_level_api::parse(file_path.clone())
        .expect(&format!("looking for file {:?}", file_path));
    low_level_api::to_html_doc(env, nodes)
}


// pub fn run_highlighter<'a>(source: &'a str) -> Vec<ast::Highlight<'a>> {
//     let children = parser::parse_source(source);
//     let children = Node::new_fragment(children);
//     children.into_highlight_ranges(Default::default(), None)
// }

pub fn get_subtopics<'a, T: Into<PathBuf>>(file_path: T) -> Vec<String> {
    let file_path = file_path.into();
    let (env, body) = low_level_api::parse(file_path).unwrap();
    // let source = std::fs::read_to_string(file_path).unwrap();
    // let body = crate::frontend::pass::pp_normalize::run_compiler_frontend(&source);
    // let body = crate::frontend::pass::html_normalize::html_canonicalization(body);
    // let body = body
    //     .into_iter()
    //     .map(crate::frontend::pass::math::latex_pass)
    //     .collect::<Vec<_>>();
    // fn process(env: NodeEnvironment, node: &Node, metas: &mut Vec<String>) {
    //     // println!("{:?}", node);
    //     // match node {
    //     //     Node::Tag(tag) => {
    //     //         let check1 = tag.name.data.0.to_owned() == "meta".to_owned();
    //     //         let check2 = tag.name == "meta".into();
    //     //         if check1 {
    //     //             assert!(node.has_attr("subtopics"));
    //     //         }
    //     //     },
    //     //     _ => (),
    //     // }
    //     let node = node.clone().trim_whitespace();
    //     if node.has_tag("meta") && node.has_attr("subtopics") {
    //         let tag = node.unwrap_tag().unwrap();
    //         for child in tag.children.iter() {
    //             // println!("{:#?}", child);
    //             let content = child.to_owned().unwrap_curly_brace().unwrap();
    //             let content = &content[0].unwrap_string().unwrap();
    //             let content = content
    //                 .iter()
    //                 .map(|x| x.to_string())
    //                 .collect::<String>();
    //             metas.push(content);
    //         }
    //     }
    // }
    // let mut xs: Vec<String> = Vec::new();
    // let body = body
    //     .into_iter()
    //     .map(|node| {
    //         let env = NodeEnvironment::default();
    //         let node = node.scan(&mut xs, env, Rc::new(process));
    //     })
    //     .collect_vec();
    // xs
    unimplemented!()
}
