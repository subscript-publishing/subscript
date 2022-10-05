use std::{fmt::Display, path::PathBuf};

use crate::subscript::ast::*;
pub use crate::cmds::data::CompilerEnv;

pub mod low_level_api {
    use std::path::Path;

    use super::*;
    #[derive(Debug, Clone)]
    pub enum CompilerError {
        FileNotFound {file_path: PathBuf}
    }

    impl Display for CompilerError {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            match self {
                CompilerError::FileNotFound { file_path } => {
                    write!(f, "File not found: {:?}", file_path)
                }
            }
        }
    }

    pub fn parse_file(file_path: &Path) -> Result<Node, CompilerError> {
        if !file_path.exists() {
            return Err(CompilerError::FileNotFound { file_path: file_path.to_owned() });
        }
        let source = std::fs::read_to_string(file_path).unwrap();
        let node = crate::subscript::parser::parse_source(source).defragment_node_tree();
        Ok(node)
    }

    pub fn process_commands(env: &CompilerEnv, ast: Node) -> Node {
        let cmds = crate::cmds::all_commands_map();
        let scope = crate::cmds::data::SemanticScope::default();
        let node = ast.apply_commands(env, &scope, &cmds);
        node
    }

    pub fn parse_process(file_path: &Path) -> Result<Node, CompilerError> {
        let ref env = CompilerEnv {file_path: file_path.to_owned()};
        let nodes = parse_file(&env.file_path)?;
        let nodes = process_commands(&env, nodes);
        Ok(nodes)
    }
}


