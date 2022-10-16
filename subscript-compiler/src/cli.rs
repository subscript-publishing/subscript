use std::path::PathBuf;
use structopt::StructOpt;
use crate::project::manifest::ProjectSettings;
use crate::ss::ResourceEnv;

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
        /// Used for publishing to GitHub Pages. 
        #[structopt(long)]
        route_prefix: Option<String>,
        /// Overrides the default output dir. 
        #[structopt(long)]
        output_dir: Option<PathBuf>,
        /// By default Subscript uses symlinks in the HTML output folder,
        /// this option will override that behavior and instead copy images
        /// to such. Especially useful for publishing to Github Pages. 
        #[structopt(long)]
        copy_images: bool,
    },
    CompileFile {
        #[structopt(long)]
        source: PathBuf,
        #[structopt(long)]
        output: PathBuf,
        #[structopt(long)]
        watch: bool,
        #[structopt(long)]
        debug_print_ast: bool,
    }
}


impl SubscriptCompilerCommand {
    pub fn run_from_args() {
        SubscriptCompilerCommand::from_args().execute_cmd()
    }
    pub fn execute_cmd(self) {
        match self {
            SubscriptCompilerCommand::Build { project_dir, filter, watch, route_prefix, output_dir, copy_images } => {
                let mut project_settings = ProjectSettings::parse_subscript_toml_file(&project_dir)
                    .expect("Should be a valid Subscript.toml file");
                if let Some(output_dir) = output_dir {
                    project_settings.manifest.project.locations.output = output_dir;
                }
                let compiler = project_settings
                    .init_compiler()
                    .with_output_dir(&project_settings.manifest.project.locations.output)
                    .with_project_dir(&project_settings.project_dir)
                    .sort_files();
                let compiler = match project_settings.manifest.project.title.as_ref() {
                    Some(title) => compiler.with_project_info(crate::compiler::ProjectInfo{
                        title: Some(title.clone())
                    }),
                    None => compiler,
                };
                let compiler = match copy_images {
                    true => compiler.copy_images(true),
                    _ => compiler,
                };
                let compiler = match route_prefix {
                    Some(prefix) => compiler.with_route_prefix(prefix),
                    None => compiler,
                };
                // println!("filter: {filter:?}");
                let compiler = match filter {
                    Some(pattern) => compiler.filter_matching_files(
                        pattern,
                        &project_settings.project_dir,
                    ),
                    None => compiler,
                };
                if watch {
                    compiler.compile_html_watch_sources();
                } else {
                    compiler.compile_pages_to_html();
                }
            }
            SubscriptCompilerCommand::CompileFile { source, output, watch, debug_print_ast } => {
                let compiler = crate::compiler::Compiler::new()
                    .add_file(&source, &output)
                    .with_output_dir(&output.parent().unwrap())
                    .with_project_dir(source.parent().unwrap())
                    .sort_files();
                let compiler = {
                    if debug_print_ast {
                        compiler.with_debug_settings(crate::compiler::DebugSettings{
                            print_ast: true,
                            ..Default::default()
                        })
                    } else {
                        compiler
                    }
                };
                if watch {
                    compiler.compile_html_watch_sources();
                } else {
                    compiler.compile_pages_to_html();
                }
            }
        }
    }
}


