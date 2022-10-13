use crate::ss::ast_data::HeadingType;
use crate::ss::SemanticScope;
use crate::ss::SymbolicModeType;
use crate::ss::ast_traits::SyntacticallyEq;

use super::*;

pub fn all_block_formatting_commands() -> Vec<cmd_decl::CmdDeclaration> {
    let layout = CmdDeclBuilder::new(Ident::from("\\layout").unwrap())
        .arguments(default_arg1_type())
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let mut attributes = HashMap::default();
                attributes.insert(String::from("data-cmd"), String::from("layout"));
                let col_value = cmd.attributes
                    .get("col")
                    .map(|x| x.value.clone().defragment_node_tree().trim_whitespace())
                    .and_then(Node::into_text)
                    .map(Ann::consume)
                    .map(|value| {
                        attributes.insert(String::from("data-col"), value);
                    });
                let children = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_html(env, scope))
                    .collect_vec();
                crate::html::Node::Element(crate::html::Element {
                    name: String::from("div"),
                    attributes,
                    children,
                })
            }
        })
        .finish();
    let grid = CmdDeclBuilder::new(Ident::from("\\grid").unwrap())
        .arguments(default_arg1_type())
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let mut attributes = HashMap::default();
                attributes.insert(String::from("data-cmd"), String::from("grid"));
                let col_value = cmd.attributes
                    .get("col")
                    .map(|x| x.value.clone().defragment_node_tree().trim_whitespace())
                    .and_then(Node::into_text)
                    .map(Ann::consume)
                    .map(|value| {
                        attributes.insert(String::from("data-col"), value);
                    });
                let children = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_html(env, scope))
                    .collect_vec();
                crate::html::Node::Element(crate::html::Element {
                    name: String::from("div"),
                    attributes,
                    children,
                })
            }
        })
        .finish();
    vec![
        layout,
        grid,
    ]
}

pub fn all_inline_formatting_commands() -> Vec<cmd_decl::CmdDeclaration> {
    // let layout = CmdDeclBuilder::new(Ident::from("\\layout").unwrap())
    //     .arguments(default_arg1_type())
    //     .to_html(to_html! {
    //         fn (env, scope, cmd) {
    //             let mut attributes = HashMap::default();
    //             attributes.insert(String::from("data-cmd"), String::from("layout"));
    //             let col_value = cmd.attributes
    //                 .get("col")
    //                 .map(|x| x.value.clone().defragment_node_tree().trim_whitespace())
    //                 .and_then(Node::into_text)
    //                 .map(Ann::consume)
    //                 .map(|value| {
    //                     attributes.insert(String::from("data-col"), value);
    //                 });
    //             let children = cmd.arguments
    //                 .into_iter()
    //                 .flat_map(Node::unblock_root_curly_brace)
    //                 .map(|x| x.to_html(env, scope))
    //                 .collect_vec();
    //             crate::html::Node::Element(crate::html::Element {
    //                 name: String::from("div"),
    //                 attributes,
    //                 children,
    //             })
    //         }
    //     })
    //     .finish();
    vec![
        
    ]
}
