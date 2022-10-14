#![allow(unused)]

use std::rc::Rc;
use std::sync::{Arc, Mutex, RwLock};
use std::collections::{HashSet, HashMap};
use std::path::PathBuf;
use std::path::Path;
use structopt::StructOpt;
use serde::{Serialize, Deserialize};
use std::iter::FromIterator;


#[derive(Debug, StructOpt)]
pub enum Cli {
    ConvertFile {
        #[structopt(long)]
        input: PathBuf,
        #[structopt(long)]
        output: PathBuf,
    },
}

fn main() {
    match Cli::from_args() {
        Cli::ConvertFile { input, output } => {
            let html_tree = std::fs::read_to_string(&input).unwrap();
            let html_tree = subscript_compiler::html::Node::parse_str(&html_tree);
            let subscript = html_tree.html_to_subscript().unwrap();
            let subscript_source = subscript.to_string();
            std::fs::write(&output, subscript_source).unwrap();
        }
    }
}
