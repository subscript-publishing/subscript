use std::{collections::HashMap, path::PathBuf};
use itertools::Itertools;
use crate::subscript::ast::{Node, Ann, Bracket, Ident, IdentInitError};

pub mod data;
pub mod apply;
use data::{
    CmdDeclaration,
    SemanticScope,
    AttributeKey,
    AttributeValue,
    AttributeValueType,
    ArgumentDecl,
    ArgumentType,
    ContentMode,
    SymbolicModeType,
    LayoutMode,
    IsRequired,
    ParentEnvNamespaceDecl,
    ChildEnvNamespaceDecl,
    Attributes,
    SimpleCmdProcessor,
    CmdCodegenRef,
};


macro_rules! declare_cmd {
    () => ();
}

pub fn all_commands_list() -> Vec<CmdDeclaration> {
    fn header_cmd(name: &str) -> CmdDeclaration {
        CmdDeclaration{
            identifier: Ident::from(name).unwrap(),
            parent_env: ParentEnvNamespaceDecl {
                parent: None,
                content_mode: ContentMode::Text,
                layout_mode: LayoutMode::Block,
            },
            child_env: Some(ChildEnvNamespaceDecl{
                content_mode: ContentMode::Text,
                layout_mode: LayoutMode::Inline,
            }),
            attributes: HashMap::default(),
            arguments: vec![
                ArgumentDecl{
                    ty: ArgumentType::CurlyBrace,
                },
            ],
            processors: CmdCodegenRef::new(SimpleCmdProcessor::default()),
        }
    }
    vec![
        header_cmd("\\h1"),
        header_cmd("\\h2"),
        header_cmd("\\h3"),
        header_cmd("\\h4"),
        header_cmd("\\h5"),
        header_cmd("\\h6"),
        CmdDeclaration{
            identifier: Ident::from("\\math").unwrap(),
            parent_env: ParentEnvNamespaceDecl {
                parent: None,
                content_mode: ContentMode::Text,
                layout_mode: LayoutMode::Block,
            },
            child_env: Some(ChildEnvNamespaceDecl {
                content_mode: ContentMode::Symbolic(SymbolicModeType::All),
                layout_mode: LayoutMode::Block,
            }),
            attributes: HashMap::default(),
            arguments: vec![
                ArgumentDecl{
                    ty: ArgumentType::CurlyBrace,
                },
                ArgumentDecl{
                    ty: ArgumentType::CurlyBrace,
                },
            ],
            processors: CmdCodegenRef::new(SimpleCmdProcessor::default()),
        },
        CmdDeclaration{
            identifier: Ident::from("\\frac").unwrap(),
            parent_env: ParentEnvNamespaceDecl {
                parent: None,
                content_mode: ContentMode::Symbolic(SymbolicModeType::All),
                layout_mode: LayoutMode::Both,
            },
            child_env: None,
            attributes: HashMap::default(),
            arguments: vec![
                ArgumentDecl{
                    ty: ArgumentType::CurlyBrace,
                },
                ArgumentDecl{
                    ty: ArgumentType::CurlyBrace,
                },
            ],
            processors: CmdCodegenRef::new(SimpleCmdProcessor::default()),
        }
    ]
}

pub fn all_commands_map() -> HashMap<Ident, CmdDeclaration> {
    all_commands_list()
        .into_iter()
        .map(|cmd| {
            (cmd.identifier.clone(), cmd)
        })
        .collect::<HashMap<_, _>>()
}





pub fn dev() {
    // dev1();
    // let mut iter1 = (0..);
    // let xs = vec!['a', 'b', 'c', 'd'];
    // let res = iter1.zip_longest(other)
}

