#![allow(unused)]
pub mod project;
pub mod settings;
pub mod template;

fn main() {
    let result = settings::parse_subscript_toml_file("example-project")
        .unwrap_or_else(|x| {
            panic!("Unable to load Subscript.toml file: {}", x)
        });
}