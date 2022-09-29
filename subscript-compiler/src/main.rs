#![allow(unused)]
pub mod codegen;
pub mod cli;
pub mod compiler;
pub mod utils;
pub mod plugins;

fn main() {
    cli::run_cli();
    // plugins::run();
}
