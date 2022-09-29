#![allow(unused)]
use std::path::PathBuf;

use subscript_project::{utils, freehand, project};

fn main() {
    let project_dir = PathBuf::from("example-project");
    let manifest = project::SubscriptManifest::load(project_dir);
    manifest.compile_pages();
}

// #[tokio::main]
// pub async fn main() -> Result<(), std::io::Error> {
//     server::main().await
// }
