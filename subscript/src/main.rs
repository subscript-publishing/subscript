#![allow(unused)]
pub mod project;
pub mod cli;

fn main() {
    let project_settings = project::manifest::ProjectSettings::parse_subscript_toml_file("../example-project/")
        .unwrap_or_else(|x| {
            panic!("Unable to load Subscript.toml file: {}", x)
        });
    project_settings.compile_pages();
}
