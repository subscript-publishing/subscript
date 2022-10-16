use std::cell::RefCell;
use std::rc::Rc;
use std::sync::{Arc, Mutex};
use std::{fmt::Display, path::{PathBuf, Path}, collections::HashMap};
use itertools::Itertools;
use rayon::prelude::*;
use ss_freeform_format::PageEntryType;
pub mod watch;
use crate::html::toc::TocPageEntry;
use crate::html::template::TemplateFile;
use crate::ss::{SemanticScope, HtmlCodegenEnv, ResourceEnv};


pub mod low_level_api {
    use std::path::Path;
    use super::*;
    #[derive(Debug, Clone)]
    pub enum CompilerError {
        NoFilePath,
        FileNotFound {file_path: PathBuf},
    }
    impl Display for CompilerError {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            match self {
                CompilerError::FileNotFound { file_path } => {
                    write!(f, "File not found: {:?}", file_path)
                }
                CompilerError::NoFilePath => {
                    write!(f, "You didn't define a file path and tried to use a compiler feature that expected such.")
                }
            }
        }
    }
    pub fn parse_source(
        scope: &SemanticScope,
        source: impl AsRef<str>
    ) -> Result<crate::ss::Node, CompilerError> {
        let node = crate::ss::parser::parse_source(scope, source.as_ref()).defragment_node_tree();
        Ok(node)
    }
    /// Make sure that `Scope::file_path` is set to the file you want to parse.
    pub fn parse_file(scope: &SemanticScope) -> Result<crate::ss::Node, CompilerError> {
        if let Some(file_path) = scope.file_path.clone() {
            if !file_path.exists() {
                return Err(CompilerError::FileNotFound { file_path: file_path.to_owned() });
            }
            let source = std::fs::read_to_string(file_path).unwrap();
            let node = parse_source(scope, source)?;
            return Ok(node)
        }
        Err(CompilerError::NoFilePath)
    }

    /// Make sure that `Scope::file_path` is set to the file you want to parse.
    pub fn process_commands(
        env: &ResourceEnv,
        scope: &SemanticScope,
        ast: crate::ss::Node
    ) -> crate::ss::Node {
        let node = ast.apply_commands(env, scope);
        node
    }
    
    /// Make sure that `Scope::file_path` is set to the file you want to parse.
    pub fn parse_process(
        env: &ResourceEnv,
        scope: &SemanticScope
    ) -> Result<crate::ss::Node, CompilerError> {
        let nodes = parse_file(&scope)?;
        // let start = std::time::Instant::now();
        let nodes = process_commands(env, scope, nodes);
        // scope.file_path.as_ref().map(|file| {
        //     let elapsed = start.elapsed();
        //     println!("Elapsed Time [{:?}]: {:.2?}", file, elapsed);
        // });
        Ok(nodes)
    }
    pub fn compile_to_html(
        env: &ResourceEnv,
        scope: &SemanticScope,
        debug_settings: Option<&DebugSettings>,
    ) -> Result<(HtmlCodegenEnv, crate::html::Node), CompilerError> {
        // let start = std::time::Instant::now();
        let ss_ast = parse_process(env, scope)?;
        if debug_settings.map(|x| x.print_ast).unwrap_or(false) {
            if let Some(path) = scope.file_path.as_ref() {
                println!("[{:?}]: {ss_ast:#?}", path);
            } else {
                println!("{ss_ast:#?}");
            }
        }
        // scope.file_path.as_ref().map(|file| {
        //     let elapsed = start.elapsed();
        //     println!("Elapsed Time [{:?}]: {:.2?}", file, elapsed);
        // });
        let mut html_cg_env = crate::ss::HtmlCodegenEnv::from_scope(scope);
        let html_ast = ss_ast.to_html(&mut html_cg_env, scope);
        // scope.file_path.as_ref().map(|file| {
        //     let elapsed = start.elapsed();
        //     println!("Elapsed Time [{:?}]: {:.2?}", file, elapsed);
        // });
        Ok((html_cg_env, html_ast))
    }
}



//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COMPILER DATA TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone)]
pub struct FileIOEntry {
    pub src_file: PathBuf,
    pub out_file: PathBuf,
    pub page_mode: Option<FileIOPageMode>,
}

impl FileIOEntry {
    pub fn matches_path(&self, other_path: impl AsRef<Path>) -> bool {
        let other_path = other_path.as_ref().canonicalize();
        self.src_file
            .canonicalize()
            .and_then(|x| other_path.map(|y| (x, y)))
            .map(|(x, y)| {
                x == y
            })
            .unwrap()
    }
}

#[derive(Debug, Clone)]
pub struct FileIOPageMode {
    pub src_base_dir: PathBuf,
    pub is_root_index_page: bool,
}

impl FileIOEntry {
    pub fn new_src<I, O>(
        mut self,
        src_file_path: I,
        out_file_path: O,
    ) -> Self where I: AsRef<Path>, O: AsRef<Path> {
        unimplemented!()
    }
    pub fn compile(&self, compiler: &Compiler) {
        
    }
}

#[derive(Debug, Clone)]
pub struct HtmlMetadata {
    pub html_index_path: Option<PathBuf>,
    pub html_template_path: Option<PathBuf>,
}

#[derive(Debug, Clone, Default)]
pub struct Compiler {
    pub project_info: Option<ProjectInfo>,
    pub project_dir: Option<PathBuf>,
    pub copy_images: Option<bool>,
    pub output_dir: Option<PathBuf>,
    pub files: Vec<FileIOEntry>,
    pub html_metadata: Option<HtmlMetadata>,
    pub template_file: Option<TemplateFile>,
    pub route_prefix: Option<String>,
    pub debug_settings: Option<DebugSettings>,
}

#[derive(Debug, Clone, Default)]
pub struct ProjectInfo {
    pub title: Option<String>
}

#[derive(Debug, Clone, Default)]
pub struct DebugSettings {
    pub print_ast: bool,
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COMPILER - SETUP API
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Compiler {
    pub fn new() -> Self {
        Compiler::default()
    }
    pub fn with_project_info(mut self, info: ProjectInfo) -> Self {
        self.project_info = Some(info);
        self
    }
    pub fn with_route_prefix(mut self, prefix: String) -> Self {
        self.route_prefix = Some(prefix);
        self
    }
    pub fn copy_images(mut self, toggle: bool) -> Self {
        self.copy_images = Some(toggle);
        self
    }
    pub fn add_file<I, O>(
        mut self,
        src_file_path: I,
        out_file_path: O
    ) -> Self where I: Into<PathBuf>, O: Into<PathBuf> {
        let file_io_entry = FileIOEntry{
            src_file: src_file_path.into(),
            out_file: out_file_path.into(),
            page_mode: None,
        };
        self.files.push(file_io_entry);
        self
    }
    pub fn add_file_multi_page_mode(
        mut self,
        src_base_dir: impl AsRef<Path>,
        src_file_path: impl AsRef<Path>,
        out_dir: impl AsRef<Path>,
        out_ext: impl AsRef<str>,
    ) -> Self {
        let rel_file_path = src_file_path
            .as_ref()
            .strip_prefix(&src_base_dir.as_ref())
            .unwrap();
        let mut out_file_path = out_dir.as_ref().to_path_buf();
        out_file_path.push(rel_file_path);
        assert!(out_file_path.set_extension(out_ext.as_ref()));
        let is_root_index_page = src_file_path
            .as_ref()
            .strip_prefix(src_base_dir.as_ref())
            .ok()
            .filter(|page| page.as_os_str() == "index.ss")
            .is_some();
        let file_io_entry = FileIOEntry{
            src_file: src_file_path.as_ref().to_path_buf(),
            out_file: out_file_path,
            page_mode: Some(FileIOPageMode {
                src_base_dir: src_base_dir.as_ref().to_path_buf(),
                is_root_index_page
            }),
        };
        self.files.push(file_io_entry);
        self
    }
    pub fn add_files_via_glob(
        mut self,
        source_base_dir: impl AsRef<Path>,
        source_glob: impl AsRef<str>,
        out_dir: impl AsRef<Path>,
        out_ext: impl AsRef<str>,
    ) -> Self {
        wax::Glob::new(source_glob.as_ref())
            .unwrap()
            .walk(source_base_dir.as_ref())
            .flatten()
            .map(|x| x.into_path())
            .fold(self, move |compiler, src_file_path| -> Compiler {
                compiler.add_file_multi_page_mode(
                    &source_base_dir,
                    &src_file_path,
                    &out_dir,
                    &out_ext
                )
            })
    }
    pub fn filter_matching_files(
        mut self,
        pattern: impl AsRef<str>,
        base_dir: impl AsRef<Path>,
    ) -> Self {
        let ref filtered = wax::Glob::new(pattern.as_ref())
            .unwrap()
            .walk(base_dir.as_ref())
            .flatten()
            .map(|x| x.into_path())
            .collect_vec();
        self.files = self.files
            .into_iter()
            .filter(|entry| {
                for filter in filtered.iter() {
                    if entry.matches_path(filter) {
                        return true;
                    }
                }
                false
            })
            .collect_vec();
        self
    }
    pub fn with_debug_settings(mut self, debug_settings: DebugSettings) -> Self {
        self.debug_settings = Some(debug_settings);
        self
    }
    pub fn with_output_dir(mut self, out: impl AsRef<Path>) -> Self {
        self.output_dir = Some(out.as_ref().to_path_buf());
        self
    }
    pub fn with_project_dir(mut self, root_dir: impl AsRef<Path>) -> Self {
        self.project_dir = Some(root_dir.as_ref().to_path_buf());
        self
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COMPILER - COMPILE API
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Compiler {
    fn compile_template(mut self) -> Self {
        let template_file = self.html_metadata
            .as_ref()
            .and_then(|html_options| {
                html_options.html_template_path
                    .as_ref()
                    .map(crate::html::template::TemplateFile::pre_compile)
            })
            .unwrap_or_else(|| {
                crate::html::template::TemplateFile::pre_compile_default()
            });
        self.template_file = Some(template_file);
        self
    }
    /// Files with longer paths tend to be dependencies of files with shorter
    /// paths, so until dependency tracking is implemented, this heuristic is
    /// a quick and dirty alternative. 
    pub fn sort_files(mut self) -> Self {
        self.files = self.files
            .into_iter()
            .sorted_by(|l, r| {
                let l = l.src_file.canonicalize().unwrap();
                let l = l.to_str().unwrap().len();
                let r = r.src_file.canonicalize().unwrap();
                let r = r.to_str().unwrap().len();
                l.cmp(&r).reverse()
            })
            .collect_vec();
        self
    }
    pub fn compile_pages_to_html(&self) {
        let resource_env = ResourceEnv::default();
        let mut nav_entries: Vec<TocPageEntry> = Default::default();
        let ref root_path = PathBuf::from("/");
        let system_start = std::time::Instant::now();
        let (tocs, envs): (Vec<TocPageEntry>, Vec<ResourceEnv>) = self.files
            .par_iter()
            .map(|file_io_entry| {
                let mut env = resource_env.clone();
                let html = self.compile_page_to_html(&mut env, file_io_entry);
                (html, env)
            })
            .unzip();
        let result = self.output_dir
            .as_ref()
            .map(|out_dir| {
                match self.copy_images.as_ref() {
                    Some(true) => resource_env.write_file_paths(out_dir),
                    _ => resource_env.write_sym_links(out_dir),
                }
            });
        if !resource_env.empty_images() && result.is_none() {
            eprintln!("[Warning] The Compiler has found images in your source code but no output dir has been specified.")
        }
    }
    fn compile_page_to_html(
        &self,
        env: &ResourceEnv,
        file_io_entry: &FileIOEntry
    ) -> TocPageEntry {
        assert!(file_io_entry.out_file.extension().unwrap() == "html");
        let subscript_std = crate::ss_v1_std::all_commands_list();
        let base_dir = file_io_entry.page_mode
            .as_ref()
            .map(|page_mode| {
                page_mode.src_base_dir.clone()
            })
            .unwrap_or_else(|| {
                crate::utils::file_path_union(
                    file_io_entry.src_file.as_path(),
                    file_io_entry.out_file.as_path(),
                ).unwrap()
            });
        let scope = crate::ss::SemanticScope::new(
            self.project_dir.as_ref().unwrap(),
            &file_io_entry.src_file,
            subscript_std,
        );
        let scope = match self.route_prefix.as_ref() {
            Some(route_prefix) => scope.with_route_prefix(route_prefix),
            None => scope,
        };
        // let scope = scope.with_route_prefix()
        let (html_env, page_html) = crate::compiler::low_level_api::compile_to_html(
            env,
            &scope,
            self.debug_settings.as_ref(),
        ).unwrap();
        let page_script = crate::html::utils::math_env_to_html_script(
            &html_env.math_env_clone()
        );
        let mut toc_page_entry = TocPageEntry{
            used_ids: Default::default(),
            src_path: file_io_entry.src_file.clone(),
            out_path: file_io_entry.out_file.clone(),
            math_entries: html_env
                .math_env_clone()
                .entries
                .into_par_iter()
                .filter(|x| !x.unique)
                .collect(),
            page_title: None,
            li_entries: Default::default(),
        };
        let page_html = crate::html::toc::toc_rewrites(
            self.route_prefix.clone(),
            &base_dir,
            &file_io_entry.src_file,
            &mut toc_page_entry,
            page_html,
        );
        let main = crate::html::Node::Element(crate::html::Element{
            name: String::from("main"),
            attributes: HashMap::default(),
            children: vec![page_html]
        });
        let html = crate::html::Node::Fragment(vec![
            toc_page_entry.to_page_toc(
                self.html_metadata.as_ref().and_then(|meta| meta.html_index_path.as_ref()),
                crate::html::toc::TocPageRenderingOptions{
                    route_prefix: self.route_prefix.clone(),
                    is_index_page: file_io_entry.page_mode
                        .as_ref()
                        .map(|page_mode| page_mode.is_root_index_page)
                        .unwrap_or(false),
                    site_title: self.project_info.as_ref().and_then(|x| x.title.clone()),
                    ..Default::default()
                }
            ),
            main,
            page_script,
        ]);
        // Ideally the template file should be precompiled.
        // But if it's missing, we just compile it on the spot.
        let html = self.template_file
            .clone()
            .unwrap_or_else(TemplateFile::pre_compile_default)
            .pack_content(html);
        file_io_entry.out_file.parent().map(|dir| {
            std::fs::create_dir_all(dir).unwrap();
        });
        std::fs::write(&file_io_entry.out_file, html.to_html_document()).unwrap();
        toc_page_entry
    }
}


