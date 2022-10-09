use std::{collections::HashMap, path::PathBuf};
use itertools::Itertools;
use crate::subscript::ast::{Node, Ann, Bracket, Ident, IdentInitError};
use super::data::{
    CmdDeclaration,
    SemanticScope,
    AttributeKey,
    AttributeValue,
    AttributeValueType,
    ArgumentType,
    ContentMode,
    SymbolicModeType,
    LayoutMode,
    IsRequired,
    ParentEnvNamespaceDecl,
    ChildEnvNamespaceDecl,
    Attributes,
    SimpleCodegen,
    CmdCodegenRef,
    CmdCall,
};


macro_rules! declare_cmd {
    ($($x:tt)*) => ();
}

macro_rules! declare_cmd_processors {
    () => ({
        let mut to_cmd: Option<fn(&SemanticScope, &CmdDeclaration, Ann<Ident>, Option<Attributes>, &[Node]) -> CmdCall> = None;
        let mut to_html: Option<fn(&mut crate::codegen::HtmlCodegenEnv, CmdCall) -> crate::html::ast::Node> = None;
        let mut to_latex: Option<fn(&mut crate::codegen::LatexCodegenEnv, CmdCall) -> String> = None;
    });
}

// fn referecne() {
//     let math_cmd_decl = CmdDeclaration{
//         identifier: Ident::from("\\math").unwrap(),
//         parent_env: ParentEnvNamespaceDecl {
//             parent: None,
//             content_mode: ContentMode::Text,
//             layout_mode: LayoutMode::Block,
//         },
//         child_env: Some(ChildEnvNamespaceDecl {
//             content_mode: ContentMode::Symbolic(SymbolicModeType::All),
//             layout_mode: LayoutMode::Block,
//         }),
//         ignore_attributes: false,
//         attributes: HashMap::default(),
//         arguments: vec![
//             ArgumentDecl{
//                 ty: ArgumentType::CurlyBrace,
//             },
//             ArgumentDecl{
//                 ty: ArgumentType::CurlyBrace,
//             },
//         ],
//         processors: CmdCodegenRef::new(SimpleCmdProcessor::default()),
//     };
//     let note_cmd_decl = CmdDeclaration{
//         identifier: Ident::from("\\note").unwrap(),
//         parent_env: ParentEnvNamespaceDecl {
//             parent: None,
//             content_mode: ContentMode::Text,
//             layout_mode: LayoutMode::Block,
//         },
//         child_env: None,
//         ignore_attributes: false,
//         attributes: HashMap::default(),
//         arguments: vec![
//             ArgumentDecl{
//                 ty: ArgumentType::CurlyBrace,
//             },
//             ArgumentDecl{
//                 ty: ArgumentType::CurlyBrace,
//             },
//         ],
//         processors: CmdCodegenRef::new({
//             fn to_html(
//                 env: &mut crate::codegen::HtmlCodegenEnv,
//                 cmd: CmdCall
//             ) -> crate::html::ast::Node {
//                 // crate::codegen::html_cg::default_cmd_html_cg(env, cmd)
//                 unimplemented!()
//             }
//             fn to_latex(
//                 env: &mut crate::codegen::LatexCodegenEnv,
//                 cmd: CmdCall
//             ) -> String {
//                 // crate::codegen::latex_cg::default_cmd_latex_cg(env, cmd)
//                 unimplemented!()
//             }
//             SimpleCmdProcessor::default()
//                 .with_html_cg(to_html)
//                 .with_latex_cg(to_latex)
//         }),
//     };
// }

// #[derive(Debug, Clone)]
// pub struct CmdDeclNamespace {
//     pub parent: ParentEnvNamespaceDecl,
//     pub child: ChildEnvNamespaceDecl,
// }

// declare_cmd!{
//     fn namespace() -> CmdDeclNamespace {
//         CmdDeclNamespace {
//             parent_env: ParentEnvNamespaceDecl {
//                 parent: None,
//                 content_mode: ContentMode::Text,
//                 layout_mode: LayoutMode::Block,
//             },
//             child_env: ChildEnvNamespaceDecl {
//                 content_mode: ContentMode::Symbolic(SymbolicModeType::All),
//                 layout_mode: LayoutMode::Block,
//             },
//         }
//     }
//     fn to_cmd(arg1: CurlyBrace, arg2: CurlyBrace, arg3: CurlyBrace) {
        
//     }
//     fn to_html(env, cmd_call) {
        
//     }
//     fn to_latex(env, cmd_call) {

//     }
// }




// #[derive(Debug, PartialEq, Eq)]
// struct Ishmael;
// #[derive(Debug, PartialEq, Eq)]
// struct Maybe;
// struct CallMe;
// impl FnOnce<(Ishmael,)> for CallMe {
//     type Output = Ishmael;
//     extern "rust-call" fn call_once(self, _args: (Ishmael,)) -> Ishmael {
//         println!("Split your lungs with blood and thunder!");
//         Ishmael
//     }
// }
// impl FnOnce<(Maybe,)> for CallMe {
//     type Output = Maybe;
//     extern "rust-call" fn call_once(self, _args: (Maybe,)) -> Maybe {
//         println!("So we just met, and this is crazy");
//         Maybe
//     }
// }
// fn main() {
//     assert_eq!(CallMe(Ishmael), Ishmael);
//     assert_eq!(CallMe(Maybe), Maybe);
// }


fn dev() {

}