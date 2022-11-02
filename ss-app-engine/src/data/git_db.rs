use std::collections::HashMap;
use std::path::PathBuf;
use std::path::Path;
use git2::{Cred, Error};
use git2::build::{CheckoutBuilder, RepoBuilder};
use git2::{FetchOptions, Progress, RemoteCallbacks};


#[derive(Debug, Clone)]
pub struct GitDatabase {
    pub root_dir: PathBuf,
    pub repos: HashMap<String, GitDatabaseRepo>,
}

impl GitDatabase {
    pub fn new() -> Self {
        let user_dirs = directories_next::UserDirs::new().unwrap();
        let mut root_dir = user_dirs.document_dir().unwrap().to_path_buf();
        root_dir.push("SubScript");
        root_dir.push("GitDatabaseRoot");
        println!("root_dir: {root_dir:?}");
        std::fs::create_dir_all(&root_dir).unwrap();
        GitDatabase {root_dir, repos: Default::default()}
    }
    pub fn clone_remote(&mut self, url: &str, name: &str) {
        let mut repo_dir = self.root_dir.clone();
        repo_dir.push(name);
        if repo_dir.exists() {
            self.repos.insert(name.to_string(), GitDatabaseRepo{
                name: name.to_string(),
                repo_root: repo_dir
            });
            return ()
        }
        // Prepare callbacks.
        let mut callbacks = RemoteCallbacks::new();
        callbacks.credentials(|_url, username_from_url, _allowed_types| {
            Cred::ssh_key(
                username_from_url.unwrap(),
                None,
                Path::new(&format!("{}/.ssh/id_rsa", std::env::var("HOME").unwrap())),
                None,
            )
        });

        // Prepare fetch options.
        let mut fo = git2::FetchOptions::new();
        fo.remote_callbacks(callbacks);

        // Prepare builder.
        let mut builder = git2::build::RepoBuilder::new();
        builder.fetch_options(fo);

        // Clone the project.
        builder.clone(url, &repo_dir);

        println!("DONE");
        self.repos.insert(name.to_string(), GitDatabaseRepo{
            name: name.to_string(),
            repo_root: repo_dir
        });
    }
}

#[derive(Debug, Clone)]
pub struct GitDatabaseRepo {
    pub name: String,
    pub repo_root: PathBuf,
}
