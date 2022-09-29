use std::{collections::{HashSet, BTreeSet, BTreeMap, VecDeque}, path::PathBuf};
use serde::{Serialize, Deserialize};
use wax::{Glob, Pattern};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Manifest {
    
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Object {
    /// The parent folder/directory paths. 
    location: Vec<String>,
    object_name: String,
    object_type: ObjectType,
    tags: HashSet<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ObjectType {
    Drawing,
    SubscriptMarkup,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum FileTree {
    File(File),
    Folder(Folder)
}

impl FileTree {
    fn merge_file(self, other: Self) -> Vec<FileTree> {
        match (self, other) {
            (FileTree::Folder(f1), FileTree::Folder(f2)) => {
                unimplemented!()
            }
            (FileTree::File(f1), FileTree::File(f2)) => {
                unimplemented!()
            }
            (FileTree::Folder(f1), FileTree::File(f2)) => {
                unimplemented!()
            }
            (FileTree::File(f1), FileTree::Folder(f2)) => {
                unimplemented!()
            }
        }
    }
    fn merge_files(left: Vec<FileTree>, other: Vec<FileTree>) -> Vec<FileTree> {
        unimplemented!()
    }
    fn buildup(parents: Vec<String>, mut paths: VecDeque<String>) -> Vec<FileTree> {
        if let Some(left) = paths.pop_front() {
            if left.ends_with(".ss") {
                let left = left.trim_end_matches(".ss").to_owned();
                return vec![FileTree::File(File {
                    location: parents,
                    name: left.clone(),
                    ext: String::from("ss")
                })]
            }
            let mut sub_parents = parents.clone();
            sub_parents.push(left.clone());
            let sub_tree = FileTree::Folder(Folder::new(&left, FileTree::buildup(sub_parents, paths)));
            return vec![sub_tree]
        }
        return vec![]
    }
    pub fn get_directory_tree(topics_path: &str) -> Self {
        let file_glob = Glob::new("**/*.{ss,ss-drawing}").unwrap();
        let file_tree = file_glob.walk(topics_path)
            .flatten()
            .map(|file| {
                file.into_path().strip_prefix(topics_path).unwrap().to_owned()
            })
            .map(|path| {
                path
                    .components()
                    .flat_map(|x| {
                        match x {
                            std::path::Component::Normal(path) => {
                                path.to_str().map(ToOwned::to_owned)
                            }
                            _ => None
                        }
                    })
                    .collect::<VecDeque<_>>()
            })
            .fold(vec![], |left, right| -> Vec<FileTree> {
                let right = FileTree::buildup(vec![], right);
                FileTree::merge_files(left, right)
            });
        println!("{:#?}", file_tree);
        unimplemented!()
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct File {
    location: Vec<String>,
    name: String,
    ext: String
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Folder {
    name: String,
    entries: Vec<FileTree>
}

impl Folder {
    pub fn new<T: Into<String>>(name: T, children: Vec<FileTree>) -> Self {
        Folder{name: name.into(), entries: children}
    }
}

