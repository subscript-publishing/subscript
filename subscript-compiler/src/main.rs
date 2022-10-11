#![allow(unused)]
#[macro_use] extern crate html5ever;
#[macro_use] extern crate markup5ever;

pub mod ss;
pub mod html;
pub mod data;
pub mod css;
pub mod compiler;
pub mod utils;
pub mod ss_std;
mod dev;

fn main() {
    dev::dev();
}