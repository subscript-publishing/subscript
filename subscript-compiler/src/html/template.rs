use std::{path::{Path, PathBuf}, rc::Rc, fmt::Display, collections::HashMap};
use itertools::Itertools;

use crate::html::ast::{Element, Node};
// use crate::html::NodeScope;

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

// fn compile_scss_string<T: Into<String>>(contents: T) -> Result<String, grass::Error> {
//     let mut options = grass::Options::default();
//     let result = grass::from_string(
//         contents.into(),
//         &options,
//     );
//     match result {
//         Ok(contents) => {
//             Ok(contents)
//         }
//         Err(msg) => {
//             Err(*msg.clone())
//         }
//     }
// }


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

#[derive(Debug, Clone)]
pub struct TemplateFile {
    template_src_path: Option<PathBuf>,
    html: Node,
}

impl TemplateFile {
    pub fn pre_compile_default() -> Self {
        let source = include_str!("../../assets/template/template.html");
        let html = Node::parse_str(source);
        let template = TemplateFile{html, template_src_path: None};
        template.include_subscript_defaults()
    }
    pub fn pre_compile<P: AsRef<Path>>(src_path: P) -> Self {
        let dir_path = src_path.as_ref().parent().map(|x| x.to_path_buf()).unwrap_or(PathBuf::from("./"));
        let source = std::fs::read_to_string(src_path.as_ref()).unwrap();
        let html = Node::parse_str(source);
        let template_src_path = Some(src_path.as_ref().to_path_buf());
        let template = TemplateFile{html, template_src_path};
        template
            .include_subscript_defaults()
            .process_user_deps()
    }
    pub fn pack_content(mut self, content: Node) -> Node {
        let f = |node: Node| -> Node {
            match node {
                Node::Element(mut elem) if elem.has_name("content") => {
                    content.clone()
                }
                x => x,
            }
        };
        self.html.transform(Rc::new(f))
    }
    fn process_user_deps(mut self) -> Self {
        let template_src_path = self.template_src_path.clone();
        let f = |node: Node| -> Node {
            match node {
                Node::Element(elem) if elem.has_name("link") => {
                    let result = elem
                        .get_attr_value("href")
                        .map(PathBuf::from)
                        .filter(|path| {
                            path.extension()
                                .map(|ext| {
                                    ext == "scss"
                                })
                                .unwrap_or(false)
                        })
                        .and_then(|x| {
                            template_src_path
                                .clone()
                                .map(|mut file_path| {
                                    file_path.push(x);
                                    file_path
                                })
                        })
                        .and_then(|x| x.canonicalize().ok())
                        .filter(|x| x.exists())
                        .ok_or_else(|| {
                            let file_path = elem.get_attr_value("href").unwrap().to_owned();
                            HtmlCompileError::ScssFileNotFound{file_path}
                        })
                        .and_then(|scss_path| -> Result<String, HtmlCompileError> {
                            let css = compile_scss_file(&scss_path)
                                .map_err(|msg| {
                                    let file_path = scss_path.to_str().unwrap().to_owned();
                                    HtmlCompileError::ScssCompileError { msg, file_path}
                                })?;
                            let css = crate::css::rewrite_stylesheet(css);
                            Ok(css)
                        })
                        .map(|css_styling| {
                            Node::Element(Element {
                                name: String::from("style"),
                                attributes: HashMap::default(),
                                children: vec![
                                    Node::Text(css_styling)
                                ]
                            })
                        });
                    result.unwrap_or(Node::Element(elem))
                }
                x => x,
            }
        };
        self.html = self.html.transform(Rc::new(f));
        self
    }
    fn include_subscript_defaults(mut self) -> Self {
        let f = |node: Node| -> Node {
            match node {
                Node::Element(mut elem) if elem.has_name("html") => {
                    if !elem.has_attr("lang") {
                        elem.attributes.insert(String::from("lang"), String::from("en"));
                    }
                    Node::Element(elem)
                }
                Node::Element(mut elem) if elem.has_name("head") => {
                    let default_styling = String::from(include_str!("../../assets/template/index.css"));
                    let default_styling = Node::Element(Element{
                        name: String::from("style"),
                        attributes: HashMap::default(),
                        children: vec![Node::Text(default_styling)]
                    });
                    let ss_runtime = String::from(include_str!("../../assets/template/ss-runtime.js"));
                    let ss_runtime = Node::Element(Element{
                        name: String::from("script"),
                        attributes: HashMap::default(),
                        children: vec![Node::Text(ss_runtime)]
                    });
                    let head_mixin = String::from(include_str!("../../assets/template/head.html"));
                    let head_contents = Node::Fragment(vec![
                        Node::Text(head_mixin),
                        default_styling,
                        ss_runtime,
                    ]);
                    if elem.children.is_empty() {
                        elem.children.push(head_contents);
                    } else {
                        elem.children.insert(0, head_contents);
                    }
                    Node::Element(elem)
                }
                x => x,
            }
        };
        self.html = self.html.transform(Rc::new(f));
        self
    }
}



#[derive(Debug, Clone)]
pub struct TemplatePayload {
    pub content: Node,
}

impl TemplatePayload {

}

pub fn compile_template_file<T: Into<PathBuf>>(
    file_path: Option<T>,
    payload: TemplatePayload
) -> Node {
    unimplemented!()
    // let file_path: PathBuf = file_path.into();
    // let dir_path = file_path.parent().map(|x| x.to_path_buf()).unwrap_or(PathBuf::from("./"));
    // let source = std::fs::read_to_string(&file_path).unwrap();
    // let html = Node::parse_str(source);
    // let f = |node: Node| -> Node {
    //     match node {
    //         Node::Element(mut elem) if elem.has_name("html") => {
    //             if !elem.has_attr("lang") {
    //                 elem.attributes.insert(String::from("lang"), String::from("en"));
    //             }
    //             Node::Element(elem)
    //         }
    //         Node::Element(mut elem) if elem.has_name("head") => {
    //             let default_styling = String::from(include_str!("../../assets/template/index.css"));
    //             let default_styling = Node::Element(Element{
    //                 name: String::from("style"),
    //                 attributes: HashMap::default(),
    //                 children: vec![Node::Text(default_styling)]
    //             });
    //             let ss_runtime = String::from(include_str!("../../assets/template/ss-runtime.js"));
    //             let ss_runtime = Node::Element(Element{
    //                 name: String::from("script"),
    //                 attributes: HashMap::default(),
    //                 children: vec![Node::Text(ss_runtime)]
    //             });
    //             let head_mixin = String::from(include_str!("../../assets/template/head.html"));
    //             let head_contents = Node::Fragment(vec![
    //                 Node::Text(head_mixin),
    //                 default_styling,
    //                 ss_runtime,
    //             ]);
    //             if elem.children.is_empty() {
    //                 elem.children.push(head_contents);
    //             } else {
    //                 elem.children.insert(0, head_contents);
    //             }
    //             Node::Element(elem)
    //         }
    //         Node::Element(elem) if elem.has_name("link") => {
    //             let result = elem
    //                 .get_attr_value("href")
    //                 .map(PathBuf::from)
    //                 .filter(|path| {
    //                     path.extension()
    //                         .map(|ext| {
    //                             ext == "scss"
    //                         })
    //                         .unwrap_or(false)
    //                 })
    //                 .map(|x| {
    //                     let mut file_path = dir_path.clone();
    //                     file_path.push(x);
    //                     file_path
    //                 })
    //                 .and_then(|x| x.canonicalize().ok())
    //                 .filter(|x| x.exists())
    //                 .ok_or_else(|| {
    //                     let file_path = elem.get_attr_value("href").unwrap().to_owned();
    //                     HtmlCompileError::ScssFileNotFound{file_path}
    //                 })
    //                 .and_then(|scss_path| -> Result<String, HtmlCompileError> {
    //                     let css = compile_scss_file(&scss_path)
    //                         .map_err(|msg| {
    //                             let file_path = scss_path.to_str().unwrap().to_owned();
    //                             HtmlCompileError::ScssCompileError { msg, file_path}
    //                         })?;
    //                     let css = crate::css::rewrite_stylesheet(css);
    //                     Ok(css)
    //                 })
    //                 .map(|css_styling| {
    //                     Node::Element(Element {
    //                         name: String::from("style"),
    //                         attributes: HashMap::default(),
    //                         children: vec![
    //                             Node::Text(css_styling)
    //                         ]
    //                     })
    //                 });
    //             result.unwrap_or(Node::Element(elem))
    //         }
    //         Node::Element(elem) if elem.has_name("content") => {
    //             payload.content.clone()
    //         }
    //         x => x,
    //     }
    // };
    // html.transform(Rc::new(f))
}

