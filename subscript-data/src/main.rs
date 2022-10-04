#![allow(unused)]
#[macro_use] extern crate html5ever;
#[macro_use] extern crate markup5ever;

pub mod subscript;
pub mod cmds;
pub mod html;
pub mod data;
pub mod css;
pub mod latex;
pub mod codegen;

fn main() {
    let source = std::fs::read_to_string("sample.ss").unwrap();
    let node = subscript::parser::parse_source(source);
    let cmds = cmds::all_commands_map();
    let scope = cmds::data::SemanticScope::default();
    let node = node.apply_commands(&scope, &cmds);
    println!("{:#?}", node);
}
