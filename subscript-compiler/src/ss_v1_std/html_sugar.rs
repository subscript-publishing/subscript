//! HTML syntactic sugar extras.
use crate::ss::ast_data::HeadingType;
use crate::ss::SemanticScope;
use crate::ss::SymbolicModeType;
use crate::ss::ast_traits::SyntacticallyEq;

use super::*;

pub fn html_syntactic_sugar_extras() -> Vec<cmd_decl::CmdDeclaration> {
    let table_row = CmdDeclBuilder::new(Ident::from("\\row").unwrap())
        .parent_layout_mode(LayoutMode::Block)
        .parent(Ident::from("\\table").unwrap())
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                (.. as nodes) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: nodes
                    })
                },
            }
        })
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let children = cmd.arguments
                    .into_iter()
                    .flat_map(|x| {
                        if let Some(block) = x.clone().into_curly_brace_children() {
                            if block.len() == 1 && block[0].is_cmd_with_name("\\td") {
                                return block
                                    .into_iter()
                                    .map(|x| x.to_html(env, scope))
                                    .collect_vec()
                            }
                            return vec![
                                crate::html::Node::Element(crate::html::Element {
                                    name: String::from("td"),
                                    attributes: HashMap::default(),
                                    children: block
                                        .into_iter()
                                        .map(|x| x.to_html(env, scope))
                                        .collect_vec(),
                                })
                            ]
                        }
                        return vec![x.to_html(env, scope)]
                    })
                    .collect_vec();
                crate::html::Node::Element(crate::html::Element {
                    name: String::from("tr"),
                    attributes: HashMap::default(),
                    children,
                })
            }
        })
        .finish();
    // let table_row = CmdDeclBuilder::new(Ident::from("\\liX").unwrap())
    //     .parent_layout_mode(LayoutMode::Block)
    //     .parent(Ident::from("\\ul").unwrap())
    //     .arguments(arguments! {
    //         for (internal, metadata, cmd_payload) match {
    //             (.. as nodes) => {
    //                 Node::Cmd(CmdCall {
    //                     identifier: cmd_payload.identifier,
    //                     attributes: cmd_payload.attributes.unwrap_or_default(),
    //                     arguments: nodes
    //                 })
    //             },
    //         }
    //     })
    //     .to_html(to_html! {
    //         fn (env, scope, cmd) {
    //             let children = cmd.arguments
    //                 .into_iter()
    //                 .flat_map(|x| {
    //                     if let Some(block) = x.clone().into_curly_brace_children() {
    //                         if block.len() == 1 && block[0].is_cmd_with_name("\\td") {
    //                             return block
    //                                 .into_iter()
    //                                 .map(|x| x.to_html(env, scope))
    //                                 .collect_vec()
    //                         }
    //                         return vec![
    //                             crate::html::Node::Element(crate::html::Element {
    //                                 name: String::from("td"),
    //                                 attributes: HashMap::default(),
    //                                 children: block
    //                                     .into_iter()
    //                                     .map(|x| x.to_html(env, scope))
    //                                     .collect_vec(),
    //                             })
    //                         ]
    //                     }
    //                     return vec![x.to_html(env, scope)]
    //                 })
    //                 .collect_vec();
    //             crate::html::Node::Element(crate::html::Element {
    //                 name: String::from("tr"),
    //                 attributes: HashMap::default(),
    //                 children,
    //             })
    //         }
    //     })
    //     .finish();
    vec![
        table_row,
    ]
}