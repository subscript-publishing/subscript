use std::rc::Rc;
use std::sync::{Arc, Mutex, RwLock};
use std::collections::{HashSet, HashMap};
use std::path::{Path, PathBuf};
use structopt::StructOpt;
use serde::{Serialize, Deserialize};
use std::iter::FromIterator;
// use rayon::prelude::*;


/// The Subscript CLI frontend. 
#[derive(Debug, StructOpt)]
pub enum Cli {
    /// Compile the given HTML files.
    Compile {
        /// Explicit path to the manifest file
        #[structopt(long, default_value="./subscript.toml")]
        manifest: String,
        /// Used for e.g. GitHub pages.
        #[structopt(long)]
        base_url: Option<String>,
        /// Override output directory.
        #[structopt(long)]
        output_dir: Option<PathBuf>,
    },
    Serve {
        /// Explicit path to the manifest file
        #[structopt(long, default_value="./subscript.toml")]
        manifest: String,

        #[structopt(long, default_value="3000")]
        port: u16,

        /// Automatically open chrome in kiosk mode.
        #[structopt(long)]
        open_browser: bool,
    },
}