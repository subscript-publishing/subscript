// #![feature(fn_traits, unboxed_closures)]
#![allow(unused)]

use std::path::PathBuf;
#[macro_use] extern crate html5ever;
#[macro_use] extern crate markup5ever;

pub mod subscript;
pub mod cmds;
pub mod html;
pub mod data;
pub mod css;
pub mod latex;
pub mod codegen;
pub mod compiler;

fn main() {
    let file_path = PathBuf::from("sample.ss");
    let result = compiler::low_level_api::parse_process(&file_path).unwrap();
    let line = "-".repeat(80);
    println!("{line}");
    println!("{:#?}", result);
}
