use std::path::{PathBuf, Path};
use serde::{Serialize, Deserialize};
use wax::{Glob, Pattern};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubscriptManifest {
    project: SubscriptProject,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubscriptProject {
    pub output_dir: PathBuf,
    pub pages_dir: PathBuf,
    pub template: Option<PathBuf>,
}

impl SubscriptProject {
    pub fn to_output_html_file_path(&self, input_path: PathBuf) -> PathBuf {
        let mut base_path = input_path.strip_prefix(&self.pages_dir).unwrap().to_path_buf();
        assert!(base_path.set_extension("html"));
        let mut output_path = self.output_dir.clone();
        output_path.push(base_path);
        output_path
    }
}

impl SubscriptManifest {
    pub fn load(dir_path: PathBuf) -> Self {
        let mut manifest_path = dir_path.clone();
        manifest_path.push("subscript.toml");
        let data = std::fs::read_to_string(&manifest_path).unwrap();
        let mut manifest = toml::from_str::<SubscriptManifest>(&data).unwrap();
        let output_dir = manifest.project.output_dir.clone();
        let topics_dir = manifest.project.pages_dir.clone();
        manifest.project.output_dir = dir_path.clone();
        manifest.project.pages_dir = dir_path.clone();
        manifest.project.output_dir.push(output_dir);
        manifest.project.pages_dir.push(topics_dir);
        manifest
    }
    pub fn compile_pages(&self) {
        let file_glob = Glob::new("**/index.{ss}").unwrap();
        let index_file_paths = file_glob.walk(&self.project.pages_dir)
            .flatten()
            .map(|x| x.into_path())
            .collect::<Vec<_>>();
        for src_file_path in index_file_paths {
            let html_contents = subscript_compiler::compiler::compile(src_file_path.clone());
            let output_path = self.project.to_output_html_file_path(src_file_path);
            output_path.parent().map(|dir| {
                std::fs::create_dir_all(dir).unwrap();
            });
            std::fs::write(&output_path, html_contents).unwrap();
        }
    }
}
