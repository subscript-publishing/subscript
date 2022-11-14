#![allow(unused)]
use std::{path::{Path, PathBuf}, fmt::Display};
use git_repository as git;

mod git2_api;
mod git_oxide_api;
mod data;
pub use data::{AnyError, GitOxError, UserAuth, UserSignature};
use itertools::Itertools;


pub struct GitManager {
    root_dir: PathBuf,
    user_auth: Option<UserAuth>,
    user_signature: Option<UserSignature>,
}

impl GitManager {
    pub fn open_repo(path: impl AsRef<Path>) -> Result<Self, AnyError> {
        let root_dir = path.as_ref().to_path_buf();
        let _ = git2_api::open_repo(&root_dir)?;
        Ok(GitManager {root_dir, user_auth: None, user_signature: None})
    }
    pub fn init_repo(path: impl AsRef<Path>) -> Result<Self, AnyError> {
        let root_dir = path.as_ref().to_path_buf();
        let _ = git2_api::init_repo(&root_dir)?;
        Ok(GitManager {root_dir, user_auth: None, user_signature: None})
    }
    pub fn with_user_auth(mut self, user_auth: UserAuth) -> Self {
        self.set_user_auth(user_auth);
        self
    }
    pub fn with_user_signature(mut self, user_signature: UserSignature) -> Self {
        self.set_user_signature(user_signature);
        self
    }
    pub fn set_user_auth(&mut self, user_auth: UserAuth) {
        self.user_auth = Some(user_auth);
    }
    pub fn set_user_signature(&mut self, user_signature: UserSignature) {
        self.user_signature = Some(user_signature);
    }
    pub fn with_git2_repo<T>(&self, f: impl FnOnce(git2::Repository) -> T) -> Result<T, AnyError> {
        let repo = git2::Repository::open(&self.root_dir)?;
        Ok(f(repo))
    }
    pub fn with_git_oxide_repo<T>(&self, f: impl FnOnce(git::Repository) -> T) -> Result<T, AnyError> {
        let repo = git::open(&self.root_dir)?;
        Ok(f(repo))
    }
    pub fn add_remote(&self, name: impl AsRef<str>, url: impl AsRef<str>) -> Result<(), AnyError> {
        self.with_git2_repo(|mut repo| -> Result<(), AnyError> {
            let _ = repo.remote(name.as_ref(), url.as_ref())?;
            Ok(())
        })
        .and_then(std::convert::identity)
    }
    pub fn add_commit_all(&mut self, message: impl AsRef<str>) {
        self.with_git2_repo(|repo| {
            git2_api::add_and_commit_all(&repo, message)
        });
    }
    pub fn push_to_all_remotes(&self) -> Result<(), Vec<AnyError>> {
        self.with_git2_repo(|repo| {
            git2_api::push_head_to_all_remotes(&repo, self.user_auth.as_ref())
        })
        .map_err(|x| vec![x])
        .and_then(|x| x.map_err(|es| es.into_iter().map(Into::into).collect_vec()))
    }
    pub fn pull_from(&self, remote_name: impl AsRef<str>, remote_branch: impl AsRef<str>) -> Result<(), AnyError> {
        self.with_git2_repo(|repo| {
            git2_api::pull(
                &repo,
                self.user_auth.as_ref(),
                remote_name,
                remote_branch,
            )
            .map_err(Into::into)
        })
        .and_then(std::convert::identity)
    }
}

