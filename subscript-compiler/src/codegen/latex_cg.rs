use std::{collections::HashMap, borrow::BorrowMut, fmt::format};
use itertools::Itertools;
use crate::subscript::ast::{Node, Ident, Ann, Attribute};
use crate::cmds::data::{CmdCall, CmdCodegen, CmdDeclaration, SemanticScope, LayoutMode};
use crate::cmds::CommandDeclarations;
use super::LatexCodegenEnv;

pub fn default_cmd_latex_cg(env: &mut LatexCodegenEnv, scope: &SemanticScope, cmd: CmdCall) -> String {
    let name = cmd.identifier.value.to_tex_ident();
    let arguments = cmd.arguments
        .into_iter()
        .map(|x| x.to_latex(env, scope))
        .collect_vec()
        .join("");
    format!("{name}{arguments}")
}

// fn apply_cmd(env: &mut LatexCodegenEnv, scope: &SemanticScope, cmd: CmdCall) -> Option<String> {
//     // let cmd_decl: CmdDeclaration = env.commands.get(&cmd.identifier.value)?.clone();
//     // let code_gen: &dyn CmdCodegen = cmd_decl.processors.0.as_ref();
//     // Some(code_gen.to_latex(env, cmd))
//     let cmd_decl_set: Vec<CmdDeclaration> = env.commands.get(&cmd.identifier.value)?.clone();
//     for cmd_decl in cmd_decl_set {
//         let matches_cmd = scope.match_cmd(&cmd_decl.parent_env);
//         if matches_cmd {
//             let code_gen: &dyn CmdCodegen = cmd_decl.processors.0.as_ref();
//             return Some(code_gen.to_latex(env, scope, cmd));
//         }
//     }
//     None
// }

impl Node {
    pub fn to_latex(self, env: &mut LatexCodegenEnv, scope: &SemanticScope) -> String {
        match self {
            Node::Cmd(cmd) => {
                // TODO
                scope.cmd_call_to_latex(env, cmd).unwrap()
            }
            Node::Ident(Ann{value, ..}) => {
                value.to_tex_ident().to_owned()
            }
            Node::Bracket(Ann{value, ..}) => {
                let brackets = value.to_unicode_brackets();
                let children = value.children
                    .into_iter()
                    .map(|x| x.to_latex(env, scope))
                    .collect::<String>();
                match brackets {
                    Some((open, close)) => {
                        format!("{open}{children}{close}")
                    },
                    None => {
                        let mut result = String::new();
                        value.open
                            .clone()
                            .map(Ann::consume)
                            .map(|x| result.push_str(&x));
                        result.push_str(&children);
                        value.close.clone()
                            .map(Ann::consume)
                            .map(|x| result.push_str(&x));
                        result
                    }
                }
            }
            Node::Quotation(Ann{value, ..}) => {
                let brackets = value.to_unicode_quotation();
                let children = value.children
                    .into_iter()
                    .map(|x| x.to_latex(env, scope))
                    .collect::<String>();
                match brackets {
                    Some((open, close)) => {
                        format!("{open}{children}{close}")
                    },
                    None => {
                        let mut result = String::new();
                        value.open
                            .clone()
                            .map(Ann::consume)
                            .map(|x| result.push_str(&x));
                        result.push_str(&children);
                        value.close.clone()
                            .map(Ann::consume)
                            .map(|x| result.push_str(&x));
                        result
                    }
                }
            }
            Node::Text(Ann{value, ..}) => {
                value
            }
            Node::Symbol(Ann{value, ..}) => {
                value
            }
            Node::InvalidToken(Ann{value, ..}) => {
                value
            }
            Node::Drawing(str) => {
                unimplemented!()
            }
            Node::Fragment(xs) => {
                xs  .into_iter()
                    .map(|x| x.to_latex(env, scope))
                    .collect::<String>()
            }
        }
    }
}

