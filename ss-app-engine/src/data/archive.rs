use itertools::Itertools;
use uuid::Uuid;
use serde::{Serializer, Deserializer, Serialize, Deserialize, de::DeserializeOwned};
use std::collections::HashMap;
use std::path::{PathBuf, Path};
use ss_git_client::GitManager;

pub struct NotebookArchiveManager {
    pub root_dir: PathBuf,
    pub git_backend: ss_git_client::GitManager,
    pub index_page: PageArchiveManager,
}

impl NotebookArchiveManager {
    pub const fn package_file_extension() -> &'static str {"ss1-notebook"}
}

impl NotebookArchiveManager {
    pub fn load_or_init(notebook_package_path: impl AsRef<Path>) -> Self {
        let root_dir = notebook_package_path.as_ref().to_path_buf();
        std::fs::create_dir_all(&root_dir).unwrap();
        let mut index_page_path = root_dir.clone();
        index_page_path.push("index");
        index_page_path.set_extension(PageArchiveManager::file_extension());
        let index_page = PageArchiveManager::load_or_init(&index_page_path);
        let user_auth = ss_git_client::UserAuth::load_dev();
        let user_sig = ss_git_client::UserSignature::load_dev();
        let mut git_backend = GitManager::open_repo(&root_dir)
            .unwrap_or_else(|_| GitManager::init_repo(&root_dir).unwrap())
            .with_user_auth(user_auth)
            .with_user_signature(user_sig);
        NotebookArchiveManager {
            root_dir,
            git_backend,
            index_page,
        }
    }
    pub fn add_new_page(&mut self, namespace: impl AsRef<Namespace>, page_name: impl AsRef<str>) {
        let namespace = namespace.as_ref();
        let page_name = page_name.as_ref();
        let mut page_path = self.root_dir.clone();
        page_path.push(namespace.as_ref());
        page_path.push(page_name);
        page_path.set_extension(PageArchiveManager::file_extension());
        let new_page = PageArchiveManager::init_new(&page_path);
    }
    pub fn pages(&self) -> Vec<PageArchiveManager> {
        let file_ext = PageArchiveManager::file_extension();
        wax::Glob::new(&format!("**/*.{file_ext}"))
            .unwrap()
            .walk(&self.root_dir)
            .flatten()
            .filter_map(|x| {
                let file_path = x.into_path();
                if !file_path.is_file() {
                    return None
                }
                let page_archive = PageArchiveManager::load(&file_path).unwrap();
                Some(page_archive)
            })
            .collect_vec()
    }
}

pub struct PageArchiveManager {
    pub file_path: PathBuf,
    pub payload: super::notebook::Page,
}

impl PageArchiveManager {
    pub const fn file_extension() -> &'static str {"ss1-page"}
    pub const fn file_encoding_type() -> FormatType {FormatType::Bson}
}

impl PageArchiveManager {
    pub fn load_or_init(path: impl AsRef<Path>) -> Self {
        let path = path.as_ref();
        PageArchiveManager::load(path).unwrap_or_else(|| PageArchiveManager::init_new(path))
    }
    pub fn init_new(path: impl AsRef<Path>) -> Self {
        let file_path = path.as_ref().to_path_buf();
        let payload = super::notebook::Page::new_sample();
        let page_archive_manager = PageArchiveManager {file_path, payload};
        page_archive_manager.save();
        page_archive_manager
    }
    pub fn load(path: impl AsRef<Path>) -> Option<Self> {
        let file_path = path.as_ref().to_owned();
        if !file_path.exists() {
            return None;
        }
        let payload = std::fs::read(&file_path).unwrap();
        let payload = PageArchiveManager::file_encoding_type().parse(payload);
        Some(PageArchiveManager{
            file_path,
            payload
        })
    }
    pub fn save(&self) {
        let bytes = PageArchiveManager::file_encoding_type().serialize(&self.payload);
        std::fs::write(&self.file_path, bytes).unwrap();
    }
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum FormatType {
    Json,
    Bson,
}

impl FormatType {
    pub fn use_json() -> Self {FormatType::Json}
    pub fn use_bson() -> Self {FormatType::Bson}
    pub fn infer_from_path_ext(path: impl AsRef<Path>) -> Option<Self> {
        let path = path.as_ref();
        if path.ends_with("bson") {
            return Some(FormatType::Bson)
        }
        if path.ends_with("json") {
            return Some(FormatType::Json)
        }
        None
    }
    pub fn parse<T: DeserializeOwned>(&self, bytes: impl AsRef<[u8]>) -> T {
        match self {
            FormatType::Bson => {
                ::bson::from_slice::<T>(bytes.as_ref()).unwrap()
            }
            FormatType::Json => {
                ::serde_json::from_slice::<T>(bytes.as_ref()).unwrap()
            }
        }
    }
    pub fn serialize<T: Serialize>(&self, value: &T) -> Vec<u8> {
        match self {
            FormatType::Bson => {
                ::bson::to_vec::<T>(value).unwrap()
            }
            FormatType::Json => {
                ::serde_json::to_vec_pretty(value).unwrap()
            }
        }
    }
}

pub struct Namespace {
    pub rel_dir: PathBuf,
}

impl Namespace {
    pub fn new(rel_dir: impl AsRef<Path>) -> Self {
        Namespace {rel_dir: rel_dir.as_ref().to_path_buf()}
    }
}

impl AsRef<Path> for Namespace {
    fn as_ref(&self) -> &Path {
        self.rel_dir.as_path()
    }
}


pub fn dev() {
    // let test_repo_url_ssh = "git@github.com:colbyn-git-bot1/ss-notebook-db-genesis.git";
    // let test_repo_url_http = "https://github.com/colbyn-git-bot1/ss-notebook-db-genesis.git";
    // let mut notebook_package_path = PathBuf::from("/Users/colbyn/Developer/tmp/sample");
    // notebook_package_path.set_extension(NotebookArchiveManager::package_file_extension());
    // let mut notebook = NotebookArchiveManager::load_or_init(&notebook_package_path);
    // let user_auth = GitUserAuth::load_dev();
    // notebook.git_backend.set_auth_user(user_auth.clone());
    // std::fs::write("/Users/colbyn/Developer/tmp/sample.ss1-notebook/alpha.txt", "Hello world").unwrap();
    // notebook.git_backend.add_and_commit_all("test message");
    // notebook.git_backend.with_ll_git_ctx(|repository| {
    //     let mut remote = repository.remote("origin", test_repo_url_http).unwrap();
    //     let remote_callbacks = user_auth.provision_new_remote_callbacks();
    //     let fetch_connection = remote.connect_auth(git2::Direction::Fetch, Some(remote_callbacks), None).unwrap();

    //     // let has_no_default_branch = fetch_connection
    //     //     .default_branch()
    //     //     .map_err(|err| err.code() == git2::ErrorCode::NotFound)
    //     //     .err()
    //     //     .unwrap_or(false);
    //     // if has_no_default_branch {
    //     //     let mut remote = repository.find_remote("origin").unwrap();
    //     //     let mut push_options = git2::PushOptions::new();
    //     //     let remote_callbacks = user_auth.provision_new_remote_callbacks();
    //     //     push_options.remote_callbacks(remote_callbacks);
    //     //     remote.push::<&'static str>(&[], Some(&mut push_options)).unwrap();
    //     // }
    //     // let mut remote = repository.find_remote("origin").unwrap();
    //     // let mut push_options = git2::PushOptions::new();
    //     // let mut remote_callbacks = user_auth.provision_new_remote_callbacks();
    //     // remote_callbacks.push_update_reference(|reference_name, server_status_message| {
    //     //     println!("ENTRY: {reference_name} {server_status_message:?}");
    //     //     Ok(())
    //     // });
    //     // push_options.remote_callbacks(remote_callbacks);
    //     // let rev = repository.revparse_ext("HEAD").unwrap();
    //     // let rev_name = rev.1.as_ref().unwrap().name().unwrap();
    //     // remote.push::<&str>(&[rev_name], Some(&mut push_options)).unwrap();
    // });
    // let token_file_path = PathBuf::from("/Users/colbyn/Developer/tmp/token.json");
    // let token = ss_github_auth::load_or_init_new_token(
    //     "colbyn-git-bot1",
    //     "colbyn-git-bot1-password",
    //     Some(token_file_path)
    // );
    // println!("LOADED: {:#?}", token);
}

