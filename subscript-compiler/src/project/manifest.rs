//! See the example-project for an example of the TOML data layout.
use std::time::Instant;
use std::{path::{Path, PathBuf}, collections::HashMap};
use itertools::Itertools;
use wax::{Glob, Pattern};
use rayon::prelude::*;

#[derive(Debug, Clone)]
pub struct ProjectSettings {
    pub manifest: manifest_format::RootManifestFile,
    pub project_dir: PathBuf,
}

impl ProjectSettings {
    pub fn parse_subscript_toml_file(project_dir: impl AsRef<Path>) -> Result<ProjectSettings, SettingsError> {
        let project_dir = project_dir.as_ref().to_path_buf();
        let (manifest_file_path, default_file_path) = {
            let mut manifest_file_path1: PathBuf = project_dir.clone();
            let mut manifest_file_path2: PathBuf = project_dir.clone();
            manifest_file_path1.push("Subscript.toml");
            manifest_file_path2.push("subscript.toml");
            if manifest_file_path1.exists() {
                (Some(manifest_file_path1.clone()), manifest_file_path1)
            } else if manifest_file_path2.exists() {
                (Some(manifest_file_path2), manifest_file_path1)
            } else {
                (None, manifest_file_path1)
            }
        };
        let mut project_settings = manifest_file_path
            .ok_or(SettingsError::NoManifestFile)
            .and_then(|path| -> Result<ProjectSettings, SettingsError> {
                let contents = std::fs::read(&path)
                    .map_err(|_| {
                        let file_path = default_file_path.clone();
                        SettingsError::UnableToReadFile{file_path}
                    })?;
                toml::from_slice::<manifest_format::RootManifestFile>(&contents)
                    .map_err(|_| SettingsError::UnableToParseManifestFile)
                    .map(|manifest| {
                        let project_dir = project_dir.clone();
                        ProjectSettings {manifest, project_dir}
                    })
            })?;
        
        project_settings.project_dir = project_settings.project_dir;
        
        let mut output_path: PathBuf = project_dir.clone();
        output_path.push(project_settings.manifest.project.locations.output.clone());
        project_settings.manifest.project.locations.output = output_path;

        let mut pages_path: PathBuf = project_dir.clone();
        pages_path.push(project_settings.manifest.project.locations.pages.clone());
        project_settings.manifest.project.locations.pages = pages_path;

        let mut template_path: PathBuf = project_dir.clone();
        template_path.push(project_settings.manifest.project.locations.template.clone());
        project_settings.manifest.project.locations.template = template_path;

        Ok(project_settings)
    }
    pub fn to_output_file_path<T: AsRef<Path>, U: AsRef<str>>(&self, src_file_path: T, ext: U) -> PathBuf {
        let page_dir = &self.manifest.project.locations.pages;
        let rel_file_path = src_file_path
            .as_ref()
            .strip_prefix(&page_dir)
            .expect("The source file should be nested under pages dir.");
        let mut output_path = self.manifest.project.locations.output.clone();
        output_path.push(rel_file_path);
        assert!(output_path.set_extension(ext.as_ref()));
        output_path
    }
    pub fn init_compiler(&self) -> crate::compiler::Compiler {
        // let file_glob = Glob::new("**/index.{ss}").unwrap();
        let src_file_glob = "**/index.{ss}";
        let compiler = crate::compiler::Compiler::new().add_files_via_glob(
            &self.manifest.project.locations.pages,
            src_file_glob,
            &self.manifest.project.locations.output,
            "html",
        );
        compiler
    }
}


#[derive(Debug, Clone)]
pub enum SettingsError {
    NoManifestFile,
    UnableToReadFile {file_path: PathBuf},
    UnableToParseManifestFile
}

impl std::fmt::Display for SettingsError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        // write!(f, "({}, {})", self.x, self.y)
        match self {
            SettingsError::NoManifestFile => write!(f, "No manifest file"),
            SettingsError::UnableToReadFile{file_path} => write!(f, "Unable to read file {:?}", file_path),
            SettingsError::UnableToParseManifestFile => write!(f, "Unable to parse manifest file"),
        }
    }
}

pub mod manifest_format {
    //! The types herein are 1-to-1 with the format of the TOML file.
    use std::path::PathBuf;
    use serde::{Serialize, Deserialize};

    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct RootManifestFile {
        #[serde(default)]
        pub project: Project
    }
    #[derive(Debug, Clone, Serialize, Deserialize, Default)]
    pub struct Project {
        #[serde(default)]
        pub title: Option<String>,
        #[serde(alias = "location")]
        #[serde(default)]
        pub locations: ProjectLocations
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct ProjectLocations {
        #[serde(default = "output_default_value")]
        pub output: PathBuf,
        #[serde(default = "pages_default_value")]
        pub pages: PathBuf,
        #[serde(default = "template_default_value")]
        pub template: PathBuf,
    }
    impl Default for ProjectLocations {
        fn default() -> Self {
            ProjectLocations{
                output: output_default_value(),
                pages: pages_default_value(),
                template: template_default_value(),
            }
        }
    }
    fn output_default_value() -> PathBuf {PathBuf::from("output")}
    fn pages_default_value() -> PathBuf {PathBuf::from("pages")}
    fn template_default_value() -> PathBuf {PathBuf::from("template")}
}

