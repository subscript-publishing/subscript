// #![feature(fn_traits, unboxed_closures)]
#![allow(unused)]

use std::path::PathBuf;

use subscript::SemanticScope;

use crate::codegen::HtmlCodegenEnv;
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
pub mod ss_drawing;
pub mod utils;

fn main() {
    let file_path = PathBuf::from("source.ss");
    let result = compiler::low_level_api::parse_process(&file_path).unwrap();
    let line = "-".repeat(80);
    println!("{line}");
    println!("RESULT\n{result:#?}");
    let html = result
        .to_html(&mut HtmlCodegenEnv::default(), &SemanticScope::default())
        .to_html_str();
    std::fs::write("test/output.html", html).unwrap();
    // println!("{:#?}", result);

    // let svgs = ss_drawing::api::parse_file("test/sample.ssd1").unwrap().canvas.entries;
    // assert!(svgs.len() == 1);
    // let svg = svgs[0].to_svg();
    // std::fs::write("test/output.svg", svg).unwrap();

    // let pdf_bytes = svgs[0].to_pdf();
    // std::fs::write("test/test.pdf", pdf_bytes).unwrap();
}
