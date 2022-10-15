//! This is for testing/dev.
#![allow(unused)]
use futures::{
    channel::mpsc::{channel, Receiver},
    SinkExt, StreamExt,
};
use notify::{Event, RecommendedWatcher, RecursiveMode, Watcher, Config};
use std::path::{PathBuf, Path};
use itertools::Itertools;


fn translate<P: AsRef<Path>>(input: P) -> String {
    let html_tree = std::fs::read_to_string(input.as_ref()).unwrap();
    let html_tree = subscript_compiler::html::Node::parse_str(&html_tree);
    let subscript = html_tree.html_to_subscript().unwrap();
    let subscript_source = subscript.to_string();
    subscript_source
}

fn dev() {
    // {
    //     let html_src_path = "../html-to-subscript/test2.html";
    //     let ss_source = translate(html_src_path);
    //     std::fs::write("output.ss", ss_source).unwrap();
    //     println!("DONE!");
    // }
    // println!("DONE!\n{ss_source}");
    // let source_path = "output.ss";
    // let source = std::fs::read_to_string(source_path).unwrap();
    // let scope = subscript_compiler::ss::SemanticScope::new(
    //     source_path,
    //     subscript_compiler::ss_v1_std::all_commands_list(),
    // );
    // let scope = subscript_compiler::ss::SemanticScope::test_mode_empty();
    // let scope = subscript_compiler::ss::SemanticScope::new(
    //     source_path,
    //     subscript_compiler::ss_v1_std::all_commands_list()
    // );
    // let ss_ast = subscript_compiler::ss::parser::parse_source(&scope, &source);
    // let (result, html) = subscript_compiler::compiler::compile_to_html_with_scripts(&scope).unwrap();
    // println!("{ss_ast:#?}");
    // let source = sub
    // std::fs::write("out-out.html", html.to_html_fragment_str());
    // println!("SUCCESS!!!!");
}



fn main() {
    // let source_path = "sample.ss";
    // let source = std::fs::read_to_string(source_path).unwrap();
    // let scope = subscript_compiler::ss::SemanticScope::new(
    //     source_path,
    //     subscript_compiler::ss_v1_std::all_commands_list()
    // );
    // let (html_env, html) = subscript_compiler::compiler::compile_to_html_with_scripts(&scope).unwrap();
    // std::fs::write("sample.html", html.to_html_fragment_str());

    // let ss_ast = subscript_compiler::compiler::low_level_api::parse_file(&scope).unwrap();
    // let ss_ast = subscript_compiler::compiler::low_level_api::parse_process(&scope).unwrap();
    // println!("{ss_ast:#?}");
    // let mut env = subscript_compiler::ss::LatexCodegenEnv::from_scope(&scope);
    // let latec_code = ss_ast.to_latex(&mut env, &scope);
    // println!("{latec_code:#?}");
    // dev();
    // let source_file = "sample.ss";
    // let output_file = "sample.html";
    // let compiler = subscript_compiler::Compiler::new()
    //     .add_file(source_file, output_file);
    // compiler.compile_html_watch_sources();
    // futures::executor::block_on(async {
    //     compiler.compile_html_watch_sources().await;
    // });
    subscript_compiler::cli::SubscriptCompilerCommand::run_from_args()
}



