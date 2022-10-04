use std::{collections::HashMap, borrow::BorrowMut, fmt::format};
use itertools::Itertools;
use crate::{subscript::ast::{Node, Ann, Attribute}, cmds::data::{CmdCall, CmdCodegen, CmdDeclaration}};
use super::LatexCodegenEnv;

pub fn default_cmd_latex_cg(env: &mut LatexCodegenEnv, cmd: CmdCall) -> String {
    let name = cmd.identifier.value.to_tex_ident();
    // let attributes = cmd.attributes
    //     .consume()
    //     .into_iter()
    //     .filter_map(Attribute::to_key_value_str)
    //     .map(|(k, v)| format!("{k}"))
    //     .collect::<HashMap<_, _>>();
    let arguments = cmd.arguments
        .into_iter()
        .map(|x| x.to_latex(env))
        .collect_vec()
        .join("");
    format!("{name}{arguments}")
}

fn apply_cmd(env: &mut LatexCodegenEnv, cmd: CmdCall) -> Option<String> {
    let cmd_decl: CmdDeclaration = env.commands.get(&cmd.identifier.value)?.clone();
    let code_gen: &dyn CmdCodegen = cmd_decl.processors.0.as_ref();
    Some(code_gen.to_latex(env, cmd))
}

impl Node {
    pub fn to_latex(self, env: &mut LatexCodegenEnv) -> String {
        match self {
            Node::Cmd(cmd) => {
                // TODO
                apply_cmd(env, cmd).unwrap()
            }
            Node::Ident(Ann{value, ..}) => {
                value.to_tex_ident().to_owned()
            }
            Node::Bracket(Ann{value, ..}) => {
                let brackets = value.to_unicode_brackets();
                let children = value.children
                    .into_iter()
                    .map(|x| x.to_latex(env))
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
                    .map(|x| x.to_latex(env))
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
            Node::HtmlCode(str) => {
                unimplemented!()
            }
            Node::Fragment(xs) => {
                xs  .into_iter()
                    .map(|x| x.to_latex(env))
                    .collect::<String>()
            }
        }
    }
}

