use std::{path::{Path, PathBuf}, rc::Rc, fmt::Display};
use crate::html::ast::{Element, Node, NodeScope};

fn compile_scss_file<T: AsRef<Path>>(file_path: T) -> Result<String, grass::Error> {
    let mut options = grass::Options::default();
    let result = grass::from_path(
        file_path.as_ref().to_str().unwrap(),
        &options,
    );
    match result {
        Ok(contents) => {
            Ok(contents)
        }
        Err(msg) => {
            Err(*msg.clone())
        }
    }
}


#[derive(Debug, Clone)]
enum HtmlCompileError {
    ScssFileNotFound {file_path: String},
    ScssCompileError {msg: grass::Error, file_path: String}
}

impl Display for HtmlCompileError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            HtmlCompileError::ScssCompileError{msg, file_path} => {
                write!(f, "failed to compile scss file {}: {}", file_path, msg)
            }
            HtmlCompileError::ScssFileNotFound{file_path} => {
                write!(f, "failed to find scss file {}", file_path)
            }
        }
    }
}

pub fn compile_template_file<T: Into<PathBuf>>(
    file_path: T
) {
    let file_path: PathBuf = file_path.into();
    let dir_path = file_path.parent().map(|x| x.to_path_buf()).unwrap_or(PathBuf::from("./"));
    let source = std::fs::read_to_string(&file_path).unwrap();
    let html = Node::parse_str(source);
    let f = |env: NodeScope, node: Node| -> Node {
        match node {
            Node::Element(elem) if elem.has_tag("link") => {
                let result = elem.get_attr_value("href")
                    .map(PathBuf::from)
                    .filter(|path| {
                        path.extension()
                            .map(|ext| {
                                ext == "scss"
                            })
                            .unwrap_or(false)
                    })
                    .map(|x| {
                        let mut file_path = dir_path.clone();
                        file_path.push(x);
                        file_path
                    })
                    .and_then(|x| x.canonicalize().ok())
                    .filter(|x| x.exists())
                    .ok_or_else(|| {
                        let file_path = elem.get_attr_value("href").unwrap().to_owned();
                        HtmlCompileError::ScssFileNotFound{file_path}
                    })
                    .map(|scss_path| -> Result<(), HtmlCompileError> {
                        let css = compile_scss_file(&scss_path)
                            .map_err(|msg| {
                                let file_path = scss_path.to_str().unwrap().to_owned();
                                HtmlCompileError::ScssCompileError { msg, file_path}
                            })?;
                        let css = crate::css::rewrite_stylesheet(css);
                        Ok(())
                    });
                Node::Element(elem)
            }
            x => x,
        }
    };
    let html = html.transform(NodeScope::default(), Rc::new(f));
    // println!("{:#?}", html);
}

