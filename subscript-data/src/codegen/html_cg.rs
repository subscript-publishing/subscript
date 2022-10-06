use std::{collections::HashMap, borrow::BorrowMut};
use itertools::Itertools;
use crate::{subscript::ast::{Node, Ann, Attribute}, cmds::data::{CmdCall, CmdCodegen, CmdDeclaration, SemanticScope}};
use super::HtmlCodegenEnv;

pub fn default_cmd_html_cg(env: &mut HtmlCodegenEnv, scope: &SemanticScope, cmd: CmdCall) -> crate::html::ast::Node {
    let name = cmd.identifier.value.unwrap_remove_slash().to_string();
    let attributes = cmd.attributes
        .consume()
        .into_iter()
        .filter_map(Attribute::to_key_value_str)
        .map(|(k, v)| (k, v.unwrap_or_default()))
        .collect::<HashMap<_, _>>();
    let arguments = cmd.arguments
        .into_iter()
        .map(|x| x.to_html(env, scope))
        .collect_vec();
    crate::html::ast::Node::Element(crate::html::ast::Element{
        name,
        attributes,
        children: arguments,
    })
}

fn apply_cmd(
    env: &mut HtmlCodegenEnv,
    scope: &SemanticScope,
    cmd: CmdCall
) -> Option<crate::html::ast::Node> {
    let cmd_decl_set: Vec<CmdDeclaration> = env.commands.get(&cmd.identifier.value)?.clone();
    for cmd_decl in cmd_decl_set {
        let matches_cmd = scope.match_cmd(&cmd_decl.parent_env);
        if matches_cmd {
            let code_gen: &dyn CmdCodegen = cmd_decl.processors.0.as_ref();
            return Some(code_gen.to_html(env, scope, cmd));
        }
    }
    None
}

impl Node {
    pub fn to_html(self, env: &mut HtmlCodegenEnv, scope: &SemanticScope) -> crate::html::ast::Node {
        match self {
            Node::Cmd(cmd) => {
                // TODO
                apply_cmd(env, scope, cmd).unwrap()
            }
            Node::Ident(Ann{value, ..}) => {
                crate::html::ast::Node::Text(value.to_tex_ident().to_owned())
            }
            Node::Bracket(Ann{value, ..}) => {
                let brackets = value.to_unicode_brackets();
                let xs = value.children
                    .into_iter()
                    .map(|x| x.to_html(env, scope))
                    .collect_vec();
                match brackets {
                    Some((open, close)) => crate::html::ast::Node::Fragment({
                        let open = crate::html::ast::Node::Text(open.to_string());
                        let close = crate::html::ast::Node::Text(close.to_string());
                        let mut result = Vec::new();
                        result.push(open);
                        result.extend(xs);
                        result.push(close);
                        result
                    }),
                    None => crate::html::ast::Node::Fragment({
                        let mut result = Vec::new();
                        value.open
                            .clone()
                            .map(Ann::consume)
                            .map(crate::html::ast::Node::Text)
                            .map(|x| result.push(x));
                        result.extend(xs);
                        value.close
                            .clone()
                            .map(Ann::consume)
                            .map(crate::html::ast::Node::Text)
                            .map(|x| result.push(x));
                        result
                    })
                }
            }
            Node::Quotation(Ann{value, ..}) => {
                let brackets = value.to_unicode_quotation();
                let xs = value.children
                    .into_iter()
                    .map(|x| x.to_html(env, scope))
                    .collect_vec();
                match brackets {
                    Some((open, close)) => crate::html::ast::Node::Fragment({
                        let open = crate::html::ast::Node::Text(open.to_string());
                        let close = crate::html::ast::Node::Text(close.to_string());
                        let mut result = Vec::new();
                        result.push(open);
                        result.extend(xs);
                        result.push(close);
                        result
                    }),
                    None => crate::html::ast::Node::Fragment({
                        let mut result = Vec::new();
                        value.open
                            .clone()
                            .map(Ann::consume)
                            .map(crate::html::ast::Node::Text)
                            .map(|x| result.push(x));
                        result.extend(xs);
                        value.close
                            .clone()
                            .map(Ann::consume)
                            .map(crate::html::ast::Node::Text)
                            .map(|x| result.push(x));
                        result
                    })
                }
            }
            Node::Text(Ann{value, ..}) => {
                crate::html::ast::Node::Text(value.to_owned())
            }
            Node::Symbol(Ann{value, ..}) => {
                crate::html::ast::Node::Text(value.to_owned())
            }
            Node::InvalidToken(Ann{value, ..}) => {
                crate::html::ast::Node::Text(value.to_owned())
            }
            Node::Drawing(drawing) => {
                match drawing {
                    crate::ss_drawing::Drawing::Ssd1(ssd1) => {
                        crate::html::Node::Image(crate::html::Image::Svg {
                            kind: crate::html::LayoutKind::Block,
                            payload: ssd1.to_svg()
                        })
                    }
                }
            }
            Node::Fragment(xs) => {
                crate::html::ast::Node::Fragment(
                    xs  .into_iter()
                        .map(|x| x.to_html(env, scope))
                        .collect_vec()
                )
            }
        }
    }
}

