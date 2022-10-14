use std::path::PathBuf;
use structopt::StructOpt;
use crate::project::manifest::ProjectSettings;

#[derive(StructOpt, Debug, Clone)]
#[structopt(name = "The Subscript Compiler CLI")]
pub enum SubscriptCompilerCommand {
    /// Uses preconfigured settings VIA a `Subscript.toml` file
    /// that should be a child of the given `--project-dir` path.
    Build {
        #[structopt(long, default_value = ".")]
        project_dir: PathBuf,
        #[structopt(long)]
        filter: Option<String>,
        #[structopt(long)]
        watch: bool,
    },
}


impl SubscriptCompilerCommand {
    pub fn run_from_args() {
        SubscriptCompilerCommand::from_args().execute_cmd()
    }
    pub fn execute_cmd(self) {
        match self {
            SubscriptCompilerCommand::Build { project_dir, filter, watch } => {
                let project_settings = ProjectSettings::parse_subscript_toml_file(&project_dir)
                    .expect("Should be a valid Subscript.toml file");
                let compiler = project_settings.init_compiler();
                let compiler = match filter {
                    Some(pattern) => compiler.filter_matching_files(
                        pattern,
                        &project_settings.manifest.project.locations.pages,
                    ),
                    None => compiler,
                };
                if watch {
                    compiler.compile_html_watch_sources()
                } else {
                    compiler.compile_pages_to_html()
                }
            }
        }
    }
}


