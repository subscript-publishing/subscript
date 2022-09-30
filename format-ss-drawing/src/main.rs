#![allow(unused)]

pub mod format;
pub mod stroke_points;
pub mod utils;
pub mod api;


fn main() {
    let result = api::parse_file("Untitled.ssd1").unwrap();
    println!("{:?}", result);
}
