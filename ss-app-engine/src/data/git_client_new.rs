use std::path::Path;
use git_repository as git;



pub struct GitManager {
    repository: git::Repository
}

impl GitManager {
    pub fn open_repo(path: impl AsRef<Path>) -> Result<Self, git::open::Error> {
        let repository = git::open(path.as_ref().to_path_buf())?;
        Ok(GitManager {repository})
    }
    pub fn init_repo(path: impl AsRef<Path>) -> Result<Self, git::init::Error> {
        let repository = git::init(path.as_ref().to_path_buf())?;
        Ok(GitManager {repository})
    }
    pub fn init_config(&mut self) {
        let mut config = self.repository.config_snapshot_mut();
        config.set_raw_value("author", None, "name", "ss-git-bot").unwrap();
        config.set_raw_value("author", None, "email", "ss-git-bot@example.com").unwrap();
    }
    fn with_repository_mut<T>(&mut self, f: impl FnOnce(&mut git::Repository) -> T) -> T {
        f(&mut self.repository)
    }
}


pub fn dev() {
    // let git_repo_path = "/Users/colbyn/Developer/tmp/libgit2";
    // let git_repo_path = "/Users/colbyn/Developer/tmp/simplegit-progit";
    // let git_repo_path = "/Users/colbyn/Developer/tmp/testrepo2";
    // let git_repo_path = "/Users/colbyn/Developer/tmp/empty-repo";
    let git_repo_path = "/Users/colbyn/Developer/tmp/git-sample-repo1";
    // let git_repo_path = "/Users/colbyn/Developer/tmp/sample.ss1-notebook";
    // let mut git_manager = GitManager::init_repo(git_repo_path).unwrap();
    let mut git_manager = GitManager::open_repo(git_repo_path).unwrap();
    println!("OPENED");
    git_manager.with_repository_mut(|repo| {
        for name in repo.branch_names() {
            println!("branch_name: {name}");
        }
        for name in repo.remote_names() {
            println!("remote_name: {name}");
        }
        // for x in repo.subsection_names_of("main") {
        //     println!("x: {x}");
        // }
    });
    // let user_auth = UserAuth::load_dev();
    // git_manager.set_user_auth(user_auth);
    // git_manager.repository.
}

