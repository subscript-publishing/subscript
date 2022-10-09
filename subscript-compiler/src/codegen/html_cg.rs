use std::{collections::HashMap, borrow::BorrowMut};
use itertools::Itertools;
use crate::subscript::ast::{Node, Ident, Ann, Attribute};
use crate::cmds::data::{CmdCall, CmdCodegen, CmdDeclaration, SemanticScope, LayoutMode};
use crate::cmds::CommandDeclarations;
use crate::html;

// ////////////////////////////////////////////////////////////////////////////
// MISCELLANEOUS
// ////////////////////////////////////////////////////////////////////////////



// ////////////////////////////////////////////////////////////////////////////
// DATA TYPES
// ////////////////////////////////////////////////////////////////////////////


#[derive(Default)]
pub struct HtmlCodegenEnv {
    pub math_env: MathEnv,
}

// impl Default for HtmlCodegenEnv {
//     fn default() -> Self {
//         HtmlCodegenEnv {
//             commands: crate::cmds::all_commands(),
//             math_env: MathEnv::default(),
//         }
//     }
// }

#[derive(Debug, Clone, Default)]
pub struct MathEnv {
    pub entries: Vec<MathCodeEntry>,
}

impl MathEnv {
    pub fn add_inline_entry<'a>(&mut self, code: String) -> html::Node {
        let id = crate::utils::ramdom_id();
        let mut attributes: HashMap<String, String> = Default::default();
        attributes.insert("id".to_owned(), id.clone());
        attributes.insert("data-math-node".to_owned(), "inline".to_owned());
        let entry = MathCodeEntry {id, code, mode: LayoutMode::Inline};
        self.entries.push(entry);
        html::Node::Element(html::Element{
            name: String::from("span"),
            attributes,
            children: Vec::new(),
        })
    }
    pub fn add_block_entry<'a>(&mut self, code: String) -> html::Node {
        let id = crate::utils::ramdom_id();
        let mut attributes: HashMap<String, String> = Default::default();
        attributes.insert("id".to_owned(), id.clone());
        attributes.insert("data-math-node".to_owned(), "block".to_owned());
        let entry = MathCodeEntry {id, code, mode: LayoutMode::Block};
        self.entries.push(entry);
        html::Node::Element(html::Element{
            name: String::from("div"),
            attributes,
            children: Vec::new(),
        })
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
    pub mode: LayoutMode,
}

// ////////////////////////////////////////////////////////////////////////////
// CODE-GEN
// ////////////////////////////////////////////////////////////////////////////


pub fn default_cmd_html_cg(env: &mut HtmlCodegenEnv, scope: &SemanticScope, cmd: CmdCall) -> crate::html::ast::Node {
    let name = cmd.identifier.value.unwrap_remove_slash().to_string();
    let child_scope = scope.new_scope(cmd.identifier.value.clone());
    let attributes = cmd.attributes
        .consume()
        .into_iter()
        .filter_map(Attribute::to_key_value_str)
        .map(|(k, v)| (k, v.unwrap_or_default()))
        .collect::<HashMap<_, _>>();
    let arguments = cmd.arguments
        .into_iter()
        .flat_map(Node::unblock_curly_brace)
        .map(|x| x.to_html(env, &child_scope))
        .collect_vec();
    crate::html::ast::Node::Element(crate::html::ast::Element{
        name,
        attributes,
        children: arguments,
    })
}

// fn apply_cmd(
//     env: &mut HtmlCodegenEnv,
//     scope: &SemanticScope,
//     cmd: CmdCall
// ) -> Option<crate::html::ast::Node> {
//     let cmd_decl_set: Vec<CmdDeclaration> = env.commands.get(&cmd.identifier.value)?.clone();
//     for cmd_decl in cmd_decl_set {
//         let matches_cmd = scope.match_cmd(&cmd_decl.parent_env);
//         if matches_cmd {
//             let code_gen: &dyn CmdCodegen = cmd_decl.processors.0.as_ref();
//             return Some(code_gen.to_html(env, scope, cmd));
//         }
//     }
//     None
// }

impl Node {
    pub fn to_html(self, env: &mut HtmlCodegenEnv, scope: &SemanticScope) -> crate::html::ast::Node {
        match self {
            Node::Cmd(cmd) => {
                // TODO
                scope.cmd_call_to_html(env, cmd).unwrap()
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
                crate::html::Node::Drawing(drawing)
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

