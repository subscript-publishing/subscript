#![allow(unused)]

use std::path::PathBuf;
#[macro_use] extern crate html5ever;
#[macro_use] extern crate markup5ever;

pub mod html;
pub mod data;
pub mod css;

fn main() {
    let res = html::compile_template_file("example-project/template/page.html");
}
