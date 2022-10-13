use std::{fmt::Display, path::{PathBuf, Path}, collections::HashMap};

use crate::ss::{SemanticScope, HtmlCodegenEnv};

pub mod low_level_api {
    use std::path::Path;
    use super::*;
    #[derive(Debug, Clone)]
    pub enum CompilerError {
        NoFilePath,
        FileNotFound {file_path: PathBuf},
    }
    impl Display for CompilerError {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            match self {
                CompilerError::FileNotFound { file_path } => {
                    write!(f, "File not found: {:?}", file_path)
                }
                CompilerError::NoFilePath => {
                    write!(f, "You didn't define a file path and tried to use a compiler feature that expected such.")
                }
            }
        }
    }
    /// Make sure that `Scope::file_path` is set to the file you want to parse.
    pub fn parse_file(scope: &SemanticScope) -> Result<crate::ss::Node, CompilerError> {
        if let Some(file_path) = scope.file_path.clone() {
            if !file_path.exists() {
                return Err(CompilerError::FileNotFound { file_path: file_path.to_owned() });
            }
            let source = std::fs::read_to_string(file_path).unwrap();
            let node = crate::ss::parser::parse_source(scope, source).defragment_node_tree();
            return Ok(node)
        }
        Err(CompilerError::NoFilePath)
    }

    /// Make sure that `Scope::file_path` is set to the file you want to parse.
    pub fn process_commands(scope: &SemanticScope, ast: crate::ss::Node) -> crate::ss::Node {
        let node = ast.apply_commands(&scope);
        node
    }
    
    /// Make sure that `Scope::file_path` is set to the file you want to parse.
    pub fn parse_process(scope: &SemanticScope) -> Result<crate::ss::Node, CompilerError> {
        let nodes = parse_file(&scope)?;
        let nodes = process_commands(&scope, nodes);
        Ok(nodes)
    }
}



pub fn compile_to_html(
    scope: &SemanticScope
) -> Result<(HtmlCodegenEnv, crate::html::Node), low_level_api::CompilerError> {
    let ss_ast = low_level_api::parse_process(scope)?;
    // let ss_ast = crate::ss::utils::toc_rewrites(ss_ast, options.base_path, options.output_path);
    let mut html_cg_env = crate::ss::HtmlCodegenEnv::from_scope(scope);
    let html_ast = ss_ast.to_html(&mut html_cg_env, scope);
    Ok((html_cg_env, html_ast))
}


