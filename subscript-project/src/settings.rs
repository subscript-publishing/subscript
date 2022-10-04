//! See the example-project for an example of the TOML data layout.
use std::path::{Path, PathBuf};

#[derive(Debug, Clone)]
pub struct ProjectSettings {
    manifest: manifest_format::RootManifestFile,
    project_dir: PathBuf,
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

pub fn parse_subscript_toml_file<T: Into<PathBuf>>(project_dir: T) -> Result<ProjectSettings, SettingsError> {
    let project_dir = project_dir.into();
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
    manifest_file_path
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
        })
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
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct Project {
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

    impl Default for Project {
        fn default() -> Self {
            Project{
                locations: ProjectLocations::default()
            }
        }
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