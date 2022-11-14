use std::fmt::Display;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// USER-AUTH
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone)]
pub struct UserAuth {
    pub username: String,
    pub token: String,
}

impl UserAuth {
    pub fn load_dev() -> Self {
        let dev_token = include_str!("./resources/token").trim();
        UserAuth {
            username: String::from("colbyn-git-bot1"),
            token: String::from(dev_token),
        }
    }
}

#[derive(Debug, Clone)]
pub struct UserSignature {
    pub name: String,
    pub email: String,
}

impl UserSignature {
    pub fn new(name: impl Into<String>, email: impl Into<String>) -> Self {
        UserSignature {
            name: name.into(),
            email: email.into(),
        }
    }
    pub fn load_dev() -> Self {
        UserSignature {
            name: String::from("colbyn-git-bot1"),
            email: String::from("colbyn-git-bot1@colbyn.com"),
        }
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// ERRORS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug)]
pub enum AnyError {
    Git2(git2::Error),
    GitOxError(GitOxError)
}

#[derive(Debug)]
pub enum GitOxError {
    Open(git_repository::open::Error),
    Init(git_repository::init::Error),
}

impl From<git2::Error> for AnyError {
    fn from(x: git2::Error) -> Self {AnyError::Git2(x)}
}
impl From<git_repository::open::Error> for AnyError {
    fn from(x: git_repository::open::Error) -> Self {AnyError::GitOxError(GitOxError::Open(x))}
}
impl From<git_repository::init::Error> for AnyError {
    fn from(x: git_repository::init::Error) -> Self {AnyError::GitOxError(GitOxError::Init(x))}
}
impl From<git_repository::open::Error> for GitOxError {
    fn from(x: git_repository::open::Error) -> Self {GitOxError::Open(x)}
}
impl From<git_repository::init::Error> for GitOxError {
    fn from(x: git_repository::init::Error) -> Self {GitOxError::Init(x)}
}
impl Display for AnyError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AnyError::Git2(e) => e.fmt(f),
            AnyError::GitOxError(e) => e.fmt(f),
        }
    }
}
impl Display for GitOxError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            GitOxError::Init(e) => e.fmt(f),
            GitOxError::Open(e) => e.fmt(f),
        }
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Debug, Clone)]
pub struct FileTree {
    
}

