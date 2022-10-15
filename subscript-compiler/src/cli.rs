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
            SubscriptCompilerCommand::Build { project_dir, filter, watch } => {
                let project_settings = ProjectSettings::parse_subscript_toml_file(&project_dir)
                    .expect("Should be a valid Subscript.toml file");
                let compiler = project_settings.init_compiler();
                println!("filter: {filter:?}");
                let compiler = match filter {
                    Some(pattern) => compiler.filter_matching_files(
                        pattern,
                        &project_settings.project_dir,
                    ),
                    None => compiler,
                };
                if watch {
                    compiler.compile_html_watch_sources()
                } else {
                    let mut resource_env = ResourceEnv::default();
                    compiler.compile_pages_to_html(&mut resource_env);
                    println!("resource_env: {resource_env:#?}");
                }
            }
            SubscriptCompilerCommand::CompileFile { source, output, watch, debug_print_ast } => {
                let compiler = crate::compiler::Compiler::new()
                    .add_file(&source, &output);
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
                    let mut resource_env = ResourceEnv::default();
                    compiler.compile_pages_to_html(&mut resource_env);
                    println!("resource_env: {resource_env:#?}");
                    resource_env.write_sym_links(output.parent().unwrap());
                }
            }
        }
    }
}


