use itertools::Itertools;
use uuid::Uuid;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use serde::de::{self, Visitor, DeserializeOwned};
use std::collections::HashMap;
use std::path::PathBuf;
use std::path::Path;
use git2::ErrorCode;
use git2::IndexAddOption;
use git2::{Cred, Error};
use git2::build::{CheckoutBuilder, RepoBuilder};
use git2::{FetchOptions, Progress, RemoteCallbacks};

#[derive(Debug, Clone)]
pub struct GitUserAuth {
    pub username: String,
    pub password: String,
}

impl GitUserAuth {
    pub fn load_dev() -> Self {
        let dev_password = include_str!("./git_db/token").trim();
        GitUserAuth{
            username: String::from("colbyn-git-bot1"),
            password: String::from(dev_password),
        }
    }
    /// Currying seems to fix lifetime issues. 
    pub fn get_credential_setter(&self) -> impl FnOnce(&mut RemoteCallbacks) -> () {
        // use git2_credentials::CredentialHandler;
        let git_config = git2::Config::open_default().unwrap();
        
        let user = self.clone();
        move |callbacks| {
            let user = user.clone();
            callbacks.credentials(move |_url, username_from_url, _allowed_types| {
                println!("_allowed_types {:?}", _allowed_types);
                let cred = Cred::userpass_plaintext(
                    user.username.as_str(),
                    user.password.as_str(),
                );
                // let cred = Cred::ssh_key_from_memory(username, publickey, privatekey, passphrase)
                // println!("INIT credentials");
                assert!(cred.is_ok());
                cred
            });
        }
    }
    /// Returns an object that was provisioned with the stored user credentials.
    pub fn provision_new_remote_callbacks(&self) -> RemoteCallbacks {;
        let mut callbacks = RemoteCallbacks::new();
        self.get_credential_setter()(&mut callbacks);
        callbacks
    }
}


#[derive(Debug, Clone)]
pub struct GitRemote {
    pub name: String,
    pub url: String,
}

#[derive(Debug, Clone, Default)]
pub struct GitSettings {
    auth_user: Option<GitUserAuth>,
    remotes: HashMap<String, GitRemote>,
}

pub struct GitRepoManager {
    settings: GitSettings,
    repository: git2::Repository,
}

impl GitRepoManager {
    pub fn open(path: impl AsRef<Path>) -> Result<Self, git2::Error> {
        let repository = git2::Repository::open(path.as_ref())?;
        Ok(GitRepoManager{repository, settings: GitSettings::default()})
    }
    pub fn init(path: impl AsRef<Path>) -> Result<Self, git2::Error> {
        let repository = git2::Repository::init(path.as_ref())?;
        Ok(GitRepoManager{repository, settings: GitSettings::default()})
    }
    pub fn clone(
        user_auth: Option<GitUserAuth>,
        url: impl AsRef<str>,
        target: impl AsRef<Path>,
    ) -> Result<Self, git2::Error> {
        // Prepare callbacks.
        let mut callbacks = RemoteCallbacks::new();
        user_auth
            .as_ref()
            .map(|user| user.get_credential_setter())
            .map(|f| f((&mut callbacks)));

        // Prepare fetch options.
        let mut fo = git2::FetchOptions::new();
        fo.remote_callbacks(callbacks);

        // Prepare builder.
        let mut builder = git2::build::RepoBuilder::new();
        builder.fetch_options(fo);

        // Clone the project.
        let _ = builder.clone(url.as_ref(), target.as_ref()).unwrap();
        Ok(GitRepoManager::open(target.as_ref()).unwrap())
    }
    pub fn set_auth_user(&mut self, user: GitUserAuth) {
        self.settings.auth_user = Some(user);
    }
    pub fn add_remote(&mut self, new_remote: GitRemote) -> git2::Remote {
        let mut remote = self.repository.remote(&new_remote.name, &new_remote.url).unwrap();
        self.settings.remotes.insert(new_remote.name.clone(), new_remote);
        remote
    }
    pub fn add_and_commit_all(&self, message: impl AsRef<str>) {
        self.add_and_commit(message, |index| {
            index.add_all(["*"].iter(), IndexAddOption::DEFAULT, None).unwrap();
        })
    }
    pub fn add_and_commit(&self, message: impl AsRef<str>, indexer: impl FnOnce(&mut git2::Index)) {
        let sig = self.repository.signature().unwrap();
        let mut index = self.repository.index().unwrap();
        indexer(&mut index);
        assert!(!index.has_conflicts());
        index.write().unwrap();
        let tree_oid = index.write_tree().unwrap();
        let tree = self.repository.find_tree(tree_oid).unwrap();
        let parent_commit = match self.repository.revparse_single("HEAD") {
            Ok(obj) => Some(obj.into_commit().unwrap()),
            // First commit so no parent commit
            Err(e) if e.code() == ErrorCode::NotFound => None,
            e => panic!("ERROR {e:?}"),
        };
        let mut parents = Vec::new();
        if parent_commit.is_some() {
            parents.push(parent_commit.as_ref().unwrap());
        }
        let signature = self.repository.signature().unwrap();
        let commit_oid = self.repository.commit(
            Some("HEAD"),
            &signature,
            &signature,
            message.as_ref(),
            &tree,
            &parents[..],
        ).unwrap();
        let commit = self.repository.find_commit(commit_oid).unwrap();
    }
    pub fn push_to_all_remotes(&self) {
        for remote in self.settings.remotes.values() {
            let mut remote = self.repository.find_remote(&remote.name).unwrap();
            let mut push_options = git2::PushOptions::new();
            let mut remote_callbacks = self.settings.auth_user
                .as_ref()
                .map(|user_auth| user_auth.provision_new_remote_callbacks())
                .unwrap_or_else(|| RemoteCallbacks::new());
            remote_callbacks.push_update_reference(|reference_name, server_status_message| {
                println!("ENTRY: {reference_name} {server_status_message:?}");
                Ok(())
            });
            push_options.remote_callbacks(remote_callbacks);
            let rev = self.repository.revparse_ext("HEAD").unwrap();
            let rev_name = rev.1.as_ref().unwrap().name().unwrap();
            remote.push::<&str>(&[rev_name], Some(&mut push_options)).unwrap();
        }
    }
    pub fn fetch(&mut self) {
        // let mut remote = self.repository.remote("origin", test_repo_url_http).unwrap();
        // let remote_callbacks = user_auth.provision_new_remote_callbacks();
        // let fetch_connection = remote.connect_auth(git2::Direction::Fetch, Some(remote_callbacks), None).unwrap();
        // let has_no_default_branch = fetch_connection
        //     .default_branch()
        //     .map_err(|err| err.code() == git2::ErrorCode::NotFound)
        //     .err()
        //     .unwrap_or(false);
        // if has_no_default_branch {
        //     // let mut remote = repository.find_remote("origin").unwrap();
        //     // let mut push_options = git2::PushOptions::new();
        //     // let remote_callbacks = user_auth.provision_new_remote_callbacks();
        //     // push_options.remote_callbacks(remote_callbacks);
        //     // remote.push::<&'static str>(&[], Some(&mut push_options)).unwrap();
        // }
    }
    /// Lookup the branch that HEAD points to
    pub fn head_branch(&self) -> Option<String> {
        self.repository
            .head()
            .ok()?
            .resolve()
            .ok()?
            .shorthand()
            .map(String::from)
    }
    /// Lookup the commit ID for `HEAD`
    pub fn head_id(&self) -> Option<git2::Oid> {
        self.repository.head().ok()?.resolve().ok()?.target()
    }
    pub fn is_dirty(&self) -> bool {
        if self.repository.state() != git2::RepositoryState::Clean {
            println!("Repository status is unclean: {:?}", self.repository.state());
            return true;
        }
        let status = self.repository
            .statuses(Some(git2::StatusOptions::new().include_ignored(false)))
            .unwrap();
        if status.is_empty() {
            false
        } else {
            println!(
                "Repository is dirty: {}",
                status
                    .iter()
                    .flat_map(|s| s.path().map(|s| s.to_owned()))
                    .join(", ")
            );
            true
        }
    }
    pub fn with_ll_git_ctx<T>(&mut self, f: impl FnOnce(&mut git2::Repository) -> T) -> T {
        f(&mut self.repository)
    }
}


pub struct NotebookArchiveManager {
    pub root_dir: PathBuf,
    pub git_backend: GitRepoManager,
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
        let git_backend = GitRepoManager::open(&root_dir)
            .unwrap_or_else(|_| {
                GitRepoManager::init(&root_dir).unwrap()
            });
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
    let test_repo_url_ssh = "git@github.com:colbyn-git-bot1/ss-notebook-db-genesis.git";
    let test_repo_url_http = "https://github.com/colbyn-git-bot1/ss-notebook-db-genesis.git";
    let mut notebook_package_path = PathBuf::from("/Users/colbyn/Developer/tmp/sample");
    notebook_package_path.set_extension(NotebookArchiveManager::package_file_extension());
    let mut notebook = NotebookArchiveManager::load_or_init(&notebook_package_path);
    let user_auth = GitUserAuth::load_dev();
    notebook.git_backend.set_auth_user(user_auth.clone());
    std::fs::write("/Users/colbyn/Developer/tmp/sample.ss1-notebook/alpha.txt", "Hello world").unwrap();
    notebook.git_backend.add_and_commit_all("test message");
    notebook.git_backend.with_ll_git_ctx(|repository| {
        let mut remote = repository.remote("origin", test_repo_url_http).unwrap();
        let remote_callbacks = user_auth.provision_new_remote_callbacks();
        let fetch_connection = remote.connect_auth(git2::Direction::Fetch, Some(remote_callbacks), None).unwrap();

        // let has_no_default_branch = fetch_connection
        //     .default_branch()
        //     .map_err(|err| err.code() == git2::ErrorCode::NotFound)
        //     .err()
        //     .unwrap_or(false);
        // if has_no_default_branch {
        //     let mut remote = repository.find_remote("origin").unwrap();
        //     let mut push_options = git2::PushOptions::new();
        //     let remote_callbacks = user_auth.provision_new_remote_callbacks();
        //     push_options.remote_callbacks(remote_callbacks);
        //     remote.push::<&'static str>(&[], Some(&mut push_options)).unwrap();
        // }
        // let mut remote = repository.find_remote("origin").unwrap();
        // let mut push_options = git2::PushOptions::new();
        // let mut remote_callbacks = user_auth.provision_new_remote_callbacks();
        // remote_callbacks.push_update_reference(|reference_name, server_status_message| {
        //     println!("ENTRY: {reference_name} {server_status_message:?}");
        //     Ok(())
        // });
        // push_options.remote_callbacks(remote_callbacks);
        // let rev = repository.revparse_ext("HEAD").unwrap();
        // let rev_name = rev.1.as_ref().unwrap().name().unwrap();
        // remote.push::<&str>(&[rev_name], Some(&mut push_options)).unwrap();
    });
    // let token_file_path = PathBuf::from("/Users/colbyn/Developer/tmp/token.json");
    // let token = ss_github_auth::load_or_init_new_token(
    //     "colbyn-git-bot1",
    //     "colbyn-git-bot1-password",
    //     Some(token_file_path)
    // );
    // println!("LOADED: {:#?}", token);
}

