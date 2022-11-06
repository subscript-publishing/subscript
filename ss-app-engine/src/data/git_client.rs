use std::io::Write;
use std::collections::HashMap;
use std::path::PathBuf;
use std::path::Path;
use itertools::Itertools;
use git2::ErrorCode;
use git2::IndexAddOption;
use git2::{Cred, Error};
use git2::build::{CheckoutBuilder, RepoBuilder};
use git2::{FetchOptions, Progress, RemoteCallbacks};

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
        let dev_token = include_str!("./git_db/token").trim();
        UserAuth {
            username: String::from("colbyn-git-bot1"),
            token: String::from(dev_token),
        }
    }
    /// Currying seems to fix lifetime issues. 
    pub fn get_credential_setter(&self) -> impl FnOnce(&mut RemoteCallbacks) -> () {
        let git_config = git2::Config::open_default().unwrap();
        let user = self.clone();
        move |callbacks| {
            let user = user.clone();
            callbacks.credentials(move |_url, username_from_url, _allowed_types| {
                println!("_allowed_types {:?}", _allowed_types);
                let cred = Cred::userpass_plaintext(
                    user.username.as_str(),
                    user.token.as_str(),
                );
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

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// ERROR STUFF
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug)]
pub enum GitErr {
    Git(git2::Error),
    Other(String),
}

impl GitErr {
    fn other(msg: impl AsRef<str>) -> Self {GitErr::Other(msg.as_ref().to_string())}
}

impl From<git2::Error> for GitErr {
    fn from(err: git2::Error) -> Self {
        GitErr::Git(err)
    }
}

impl std::fmt::Display for GitErr {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            GitErr::Git(err) => write!(f, "{}", err),
            GitErr::Other(str) => write!(f, "{}", str),
        }
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// REMOTE-MANAGER
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone)]
pub struct RemoteTarget {
    pub name: String,
    pub url: String,
}

#[derive(Debug, Clone)]
pub struct RemoteMetadata {
    pub name: String,
    pub url: String,
    pub push_url: Option<String>,
    pub default_branch: Option<String>,
}

pub struct RemoteManager<'a> {
    settings: Settings,
    remote: git2::Remote<'a>,
}

impl<'a> RemoteManager<'a> {
    pub fn get_name(&self) -> &str {
        self.remote.name().unwrap()
    }
    pub fn get_url(&self) -> &str {
        self.remote.url().unwrap()
    }
    pub fn get_push_url(&self) -> Option<&str> {
        self.remote.pushurl()
    }
    pub fn get_default_branch(&self) -> Option<String> {
        self.remote
            .default_branch()
            .as_ref()
            .ok()
            .and_then(|x| x.as_str())
            .map(String::from)
    }
    pub fn get_metadata(&self) -> RemoteMetadata {
        let name = self.remote.name().unwrap().to_string();
        let url = self.remote.url().unwrap().to_string();
        let push_url = self.remote.pushurl().map(|x| x.to_owned());
        let default_branch = self.remote
            .default_branch()
            .as_ref()
            .ok()
            .and_then(|x| x.as_str())
            .map(String::from);
        RemoteMetadata{name, url, push_url, default_branch}
    }
    pub fn map_reference_advertisement_list<T>(&mut self, f: impl Fn(&git2::RemoteHead) -> T) -> Vec<T> {
        self.remote.connect(git2::Direction::Fetch).unwrap();
        let xs = self.remote.list().unwrap();
        let results = xs
            .into_iter()
            .map(f)
            .collect_vec();
        self.remote.disconnect().unwrap();
        results
    }
    pub fn push<T: AsRef<str>>(&mut self, ref_list: &[T]) {
        let mut push_options = git2::PushOptions::new();
        let mut remote_callbacks = self.settings.user_auth
            .as_ref()
            .map(|user_auth| user_auth.provision_new_remote_callbacks())
            .unwrap_or_else(|| RemoteCallbacks::new());
        remote_callbacks.push_update_reference(|reference_name, server_status_message| {
            println!("ENTRY: {reference_name} {server_status_message:?}");
            Ok(())
        });
        remote_callbacks.update_tips(|refname, a, b| {
            if a.is_zero() {
                println!("[PUSH: NEW]     {:20} {}", b, refname);
            } else {
                println!("[PUSH: UPDATED] {:10}..{:10} {}", a, b, refname);
            }
            true
        });
        push_options.remote_callbacks(remote_callbacks);
        // let rev = self.repository.revparse_ext("HEAD").unwrap();
        // let rev_name = rev.1.as_ref().unwrap().name().unwrap();
        let ref_list = ref_list
            .into_iter()
            .map(|x| x.as_ref())
            .collect_vec();
        self.remote.push::<&str>(&ref_list, Some(&mut push_options)).unwrap();
    }
    pub fn fetch_download<T: AsRef<str>>(&mut self, ref_list: &[T]) -> Result<(), GitErr> {
        let init_remote_callbacks = || {
            let mut remote_callbacks = self.settings.user_auth
                .as_ref()
                .map(|user_auth| user_auth.provision_new_remote_callbacks())
                .unwrap_or_else(|| RemoteCallbacks::new());
            remote_callbacks.transfer_progress(|stats| {
                if stats.received_objects() == stats.total_objects() {
                    print!(
                        "Resolving deltas {}/{}\r",
                        stats.indexed_deltas(),
                        stats.total_deltas()
                    );
                } else if stats.total_objects() > 0 {
                    print!(
                        "Received {}/{} objects ({}) in {} bytes\r",
                        stats.received_objects(),
                        stats.total_objects(),
                        stats.indexed_objects(),
                        stats.received_bytes()
                    );
                }
                std::io::stdout().flush().unwrap();
                true
            });
            remote_callbacks.update_tips(|refname, a, b| {
                if a.is_zero() {
                    println!("[FETCH: NEW]     {:20} {}", b, refname);
                } else {
                    println!("[FETCH: UPDATED] {:10}..{:10} {}", a, b, refname);
                }
                true
            });
            remote_callbacks.push_update_reference(|reference_name, server_status_message| {
                println!("ENTRY: {reference_name} {server_status_message:?}");
                Ok(())
            });
            remote_callbacks
        };
        let mut fetch_options = git2::FetchOptions::new();
        fetch_options.remote_callbacks(init_remote_callbacks());
        // let fetch_connection = self.remote.connect_auth(git2::Direction::Fetch, Some(remote_callbacks), None).unwrap();
        // let list = fetch_connection.list()
        let ref_list = ref_list
            .into_iter()
            .map(|x| x.as_ref())
            .collect_vec();
        self.remote.download(&ref_list, Some(&mut fetch_options))?;
        // If there are local objects (we got a thin pack), then tell the user
        // how many objects we saved from having to cross the network.
        let stats = self.remote.stats();
        if stats.local_objects() > 0 {
            println!(
                "\rReceived {}/{} objects in {} bytes (used {} local objects)",
                stats.indexed_objects(),
                stats.total_objects(),
                stats.received_bytes(),
                stats.local_objects()
            );
        } else {
            println!(
                "\rReceived {}/{} objects in {} bytes",
                stats.indexed_objects(),
                stats.total_objects(),
                stats.received_bytes()
            );
        }
        std::mem::drop(stats);
        // Disconnect the underlying connection to prevent from idling.
        self.remote.disconnect()?;
        // Update the references in the remote's namespace to point to the right
        // commits. This may be needed even if there was no packfile to download,
        // which can happen e.g. when the branches have been changed but all the
        // needed objects are available locally.
        let mut remote_callbacks = init_remote_callbacks();
        self.remote.update_tips(Some(&mut remote_callbacks), true, git2::AutotagOption::Unspecified, None)?;
        Ok(())
    }
    pub fn fetch<T: AsRef<str>>(&mut self, ref_list: &[T]) -> Result<(), GitErr> {
        let mut remote_callbacks = self.settings.user_auth
                .as_ref()
                .map(|user_auth| user_auth.provision_new_remote_callbacks())
                .unwrap_or_else(|| RemoteCallbacks::new());
        // PRINT OUT OUR TRANSFER PROGRESS
        remote_callbacks.transfer_progress(|stats| {
            if stats.received_objects() == stats.total_objects() {
                print!(
                    "Resolving deltas {}/{}\r",
                    stats.indexed_deltas(),
                    stats.total_deltas()
                );
            } else if stats.total_objects() > 0 {
                print!(
                    "Received {}/{} objects ({}) in {} bytes\r",
                    stats.received_objects(),
                    stats.total_objects(),
                    stats.indexed_objects(),
                    stats.received_bytes()
                );
            }
            std::io::stdout().flush().unwrap();
            true
        });

        let mut fetch_options = git2::FetchOptions::new();
        fetch_options.remote_callbacks(remote_callbacks);
        // ALWAYS FETCH ALL TAGS
        // Perform a download and also update tips
        fetch_options.download_tags(git2::AutotagOption::All);
        println!("Fetching {} for repo", self.remote.name().unwrap());
        let ref_list = ref_list
            .into_iter()
            .map(|x| x.as_ref())
            .collect_vec();
        self.remote.fetch(&ref_list, Some(&mut fetch_options), None)?;
        // If there are local objects (we got a thin pack), then tell the user
        // how many objects we saved from having to cross the network.
        let stats = self.remote.stats();
        if stats.local_objects() > 0 {
            println!(
                "\rReceived {}/{} objects in {} bytes (used {} local objects)",
                stats.indexed_objects(),
                stats.total_objects(),
                stats.received_bytes(),
                stats.local_objects()
            );
        } else {
            println!(
                "\rReceived {}/{} objects in {} bytes",
                stats.indexed_objects(),
                stats.total_objects(),
                stats.received_bytes()
            );
        }
        Ok(())
    }
}


/// E.g.
/// - src: `Some("refs/heads/*")`
/// - dst: `Some("refs/remotes/origin/*")`
#[derive(Debug, Clone)]
pub struct OwnRefSpec {
    direction: git2::Direction,
    /// 
    /// E.g.
    /// - dst: `Some("refs/remotes/origin/*")`
    dst: Option<String>,
    /// E.g.
    /// - src: `Some("refs/heads/*")`
    src: Option<String>,
    is_force: bool,
    str: Option<String>,
}

impl OwnRefSpec {
    pub fn from(refspec: git2::Refspec) -> Self {
        OwnRefSpec::from_ref(&refspec)
    }
    pub fn from_ref(refspec: &git2::Refspec) -> Self {
        OwnRefSpec {
            direction: refspec.direction(),
            dst: refspec.dst().map(String::from),
            src: refspec.src().map(String::from),
            is_force: refspec.is_force(),
            str: refspec.str().map(String::from),
        }
    }
}

impl<'a> RemoteManager<'a> {
    pub fn map_refspecs<T>(&mut self, f: impl Fn(git2::Refspec) -> T) -> Vec<T> {
        self.remote.connect(git2::Direction::Fetch).unwrap();
        let xs = self.remote
            .refspecs()
            .into_iter()
            .map(|x| f(x))
            .collect_vec();
        self.remote.disconnect().unwrap();
        xs
    }
    /// E.g.
    /// - src: `Some("refs/heads/*")`
    /// - dst: `Some("refs/remotes/origin/*")`
    pub fn get_specs(&mut self) -> Vec<OwnRefSpec> {
        self.map_refspecs(OwnRefSpec::from)
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// GIT-MANAGER
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Debug, Clone, Default)]
pub struct Settings {
    user_auth: Option<UserAuth>,
}

pub struct GitManager {
    settings: Settings,
    repository: git2::Repository,
}

impl GitManager {
    pub fn open_repo(path: impl AsRef<Path>) -> Result<Self, git2::Error> {
        let repository = git2::Repository::open(path.as_ref())?;
        Ok(GitManager{repository, settings: Settings::default()})
    }
    pub fn init_repo(path: impl AsRef<Path>) -> Result<Self, git2::Error> {
        let repository = git2::Repository::init(path.as_ref())?;
        Ok(GitManager{repository, settings: Settings::default()})
    }
    pub fn clone_repo(
        user_auth: Option<UserAuth>,
        url: impl AsRef<str>,
        target: impl AsRef<Path>,
    ) -> Result<Self, git2::Error> {
        // Prepare callbacks.
        let mut callbacks = user_auth
            .as_ref()
            .map(|user_auth| user_auth.provision_new_remote_callbacks())
            .unwrap_or_else(|| RemoteCallbacks::new());
        // Prepare fetch options.
        let mut fo = git2::FetchOptions::new();
        fo.remote_callbacks(callbacks);
        // Prepare builder.
        let mut builder = git2::build::RepoBuilder::new();
        builder.fetch_options(fo);
        // Clone the project.
        let _ = builder.clone(url.as_ref(), target.as_ref()).unwrap();
        Ok(GitManager::open_repo(target.as_ref()).unwrap())
    }
    pub fn set_user_auth(&mut self, user: UserAuth) {
        self.settings.user_auth = Some(user);
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
            // FIRST COMMIT SO NO PARENT COMMIT
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
        let _ = self.repository.find_commit(commit_oid).unwrap();
    }
    pub fn add_remote(
        &mut self,
        name: impl AsRef<str>,
        url: impl AsRef<str>,
    ) {
        self.repository.remote(name.as_ref(), url.as_ref()).unwrap();
    }
    pub fn with_remote_manager<T>(
        &self,
        name: impl AsRef<str>,
        f: impl FnOnce(RemoteManager) -> T,
    ) -> Result<T, git2::Error> {
        self.repository
            .find_remote(name.as_ref())
            .map(|remote| {
                let settings = self.settings.clone();
                f(RemoteManager{remote, settings})
            })
    }
    pub fn map_remote_managers<T>(
        &self,
        f: impl Fn(RemoteManager) -> Result<T, git2::Error>,
    ) -> (Vec<T>, Vec<git2::Error>) {
        let remote = match self.repository.remotes() {
            Ok(x) => x,
            Err(e) => return (Default::default(), vec![e])
        };
        remote
            .into_iter()
            .flat_map(std::convert::identity)
            .map(|name| self.get_remote(name).unwrap())
            .map(|remote| {
                f(remote)
            })
            .partition_result()
    }
    pub fn for_all_remote_managers(&self, f: impl Fn(RemoteManager)) {
        self.repository
            .remotes()
            .as_mut()
            .unwrap()
            .into_iter()
            .flat_map(std::convert::identity)
            .map(|name| self.get_remote(name).unwrap())
            .for_each(|remote| {
                f(remote)
            });
    }
    pub fn get_remote_metadata(&self, name: impl AsRef<str>) -> Option<RemoteMetadata> {
        self.with_remote_manager(name, |x| x.get_metadata()).ok()
    }
    pub fn get_remote(&self, name: impl AsRef<str>) -> Result<RemoteManager, git2::Error> {
        let remote = self.repository.find_remote(name.as_ref())?;
        Ok(RemoteManager { settings: self.settings.clone(), remote })
    }
    pub fn push_head_to_all_remotes<T: AsRef<str>>(&self, rev_list: &[T]) -> Result<(), GitErr> {
        let rev = self.repository.revparse_ext("HEAD")?;
        let rev_name = rev.1.as_ref().unwrap().name().unwrap();
        self.push_to_all_remotes(&[rev_name]);
        Ok(())
    }
    pub fn pull(
        &mut self,
        remote_name: impl AsRef<str>,
        remote_branch: impl AsRef<str>,
    ) -> Result<(), GitErr> {
        let mut remote = self.get_remote(remote_name)?;
        let _ = remote.fetch(&[remote_branch.as_ref()])?;
        std::mem::drop(remote);
        let fetch_head: git2::Reference = self.repository.find_reference("FETCH_HEAD")?;
        println!("fetch_head: {:?}", fetch_head.name());
        let fetch_commit = self.repository.reference_to_annotated_commit(&fetch_head)?;
        std::mem::drop(fetch_head);
        let _ = self.merge(remote_branch, fetch_commit)?;
        Ok(())
    }
    fn fast_forward(
        &self,
        lb: &mut git2::Reference,
        rc: &git2::AnnotatedCommit,
    ) -> Result<(), GitErr> {
        let name = match lb.name() {
            Some(s) => s.to_string(),
            None => String::from_utf8_lossy(lb.name_bytes()).to_string(),
        };
        let msg = format!("Fast-Forward: Setting {} to id: {}", name, rc.id());
        println!("{}", msg);
        lb.set_target(rc.id(), &msg)?;
        self.repository.set_head(&name)?;
        self.repository.checkout_head(Some(
            git2::build::CheckoutBuilder::default()
                // For some reason the force is required to make the working directory actually get updated
                // I suspect we should be adding some logic to handle dirty working directory states
                // but this is just an example so maybe not.
                .force(),
        ))?;
        Ok(())
    }
    fn normal_merge(
        &self,
        local: &git2::AnnotatedCommit,
        remote: &git2::AnnotatedCommit,
    ) -> Result<(), GitErr> {
        let local_tree = self.repository.find_commit(local.id())?.tree()?;
        let remote_tree = self.repository.find_commit(remote.id())?.tree()?;
        let ancestor = self.repository
            .find_commit(self.repository.merge_base(local.id(), remote.id())?)?
            .tree()?;
        let mut idx = self.repository.merge_trees(&ancestor, &local_tree, &remote_tree, None)?;

        if idx.has_conflicts() {
            println!("Merge conficts detected...");
            self.repository.checkout_index(Some(&mut idx), None)?;
            return Ok(());
        }
        let result_tree = self.repository.find_tree(idx.write_tree_to(&self.repository)?)?;
        // now create the merge commit
        let msg = format!("Merge: {} into {}", remote.id(), local.id());
        let sig = self.repository.signature()?;
        let local_commit = self.repository.find_commit(local.id())?;
        let remote_commit = self.repository.find_commit(remote.id())?;
        // Do our merge commit and set current branch head to that commit.
        let _merge_commit = self.repository.commit(
            Some("HEAD"),
            &sig,
            &sig,
            &msg,
            &result_tree,
            &[&local_commit, &remote_commit],
        )?;
        // Set working tree to match head.
        self.repository.checkout_head(None)?;
        Ok(())
    }
    pub fn merge(&self, remote_branch: impl AsRef<str>, fetch_commit: git2::AnnotatedCommit) -> Result<(), GitErr> {
        // 1. DO A MERGE ANALYSIS
        let merge_analysis = self.get_basic_merge_analysis(&fetch_commit)?;
        println!("merge_analysis: {:?}", merge_analysis);
        // 2. DO THE APPOPRIATE MERGE
        match merge_analysis {
            // The branch doesn't exist so just set the reference to the
            // commit directly. Usually this is because you are pulling
            // into an empty repository.
            BasicMergeAnalysis::IsFastForward => {
                // DO A FAST FORWARD
                let refname = format!("refs/heads/{}", remote_branch.as_ref());
                match self.repository.find_reference(&refname) {
                    Ok(mut r) => {
                        self.fast_forward(&mut r, &fetch_commit)?;
                    }
                    Err(_) => {
                        self.repository.reference(
                            &refname,
                            fetch_commit.id(),
                            true,
                            &format!("Setting {} to {}", remote_branch.as_ref(), fetch_commit.id()),
                        )?;
                        self.repository.set_head(&refname)?;
                        self.repository.checkout_head(Some(
                            git2::build::CheckoutBuilder::default()
                                .allow_conflicts(true)
                                .conflict_style_merge(true)
                                .force(),
                        ))?;
                    }
                }   
            }
            BasicMergeAnalysis::IsNormal => {
                // DO A NORMAL MERGE
                let head_commit = self.repository.reference_to_annotated_commit(&self.repository.head()?)?;
                self.normal_merge(&head_commit, &fetch_commit)?;
            }
            BasicMergeAnalysis::IsNone | BasicMergeAnalysis::IsUpToDate | BasicMergeAnalysis::IsUnborn => {
                println!("Nothing to do...");
            }
        }
        Ok(())
    }
    pub fn push_to_all_remotes<T: AsRef<str>>(&self, rev_list: &[T]) {
        self.for_all_remote_managers(|mut remote| {
            let rev_list = rev_list
                .into_iter()
                .map(|x| x.as_ref())
                .collect_vec();
            remote.push(&rev_list);
        });
    }
    // pub fn fetch_from_all_remotes<T: AsRef<str>>(&mut self, rev_list: &[T]) {
    //     self.for_all_remote_managers(|mut remote| {
    //         let rev_list = rev_list
    //             .into_iter()
    //             .map(|x| x.as_ref())
    //             .collect_vec();
    //         let _ = remote.fetch(&rev_list).unwrap();
    //         let fetch_head = self.repository.find_reference("FETCH_HEAD").unwrap();
    //         let annotated_commit = self.repository.reference_to_annotated_commit(&fetch_head).unwrap();
    //     });
    // }
    pub fn download_from_all_remotes<T: AsRef<str>>(&mut self, rev_list: &[T]) {
        self.for_all_remote_managers(|mut remote| {
            let rev_list = rev_list
                .into_iter()
                .map(|x| x.as_ref())
                .collect_vec();
            let _ = remote.fetch_download(&rev_list).unwrap();
        });
    }
    /// Lookup the branch that HEAD points to
    pub fn head_branch_shorthand(&self) -> Option<String> {
        self.repository
            .head()
            .ok()?
            .resolve()
            .ok()?
            .shorthand()
            .map(String::from)
    }
    // pub fn head(&self) {
    //     let rev = self.repository.revparse_ext("HEAD").unwrap();
    //     let rev_name = rev.1.as_ref().unwrap().name().unwrap();
    // }
    pub fn head_branch_reference_name(&self) -> Option<String> {
        self.repository
            .head()
            .ok()?
            .resolve()
            .ok()?
            .name()
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
    pub fn references(&self) -> Vec<git2::Reference> {
        self.repository
            .references()
            .unwrap()
            .map(|x| x.unwrap())
            .map(|x| x)
            .collect_vec()
    }
}


fn traverse_object(
    level: usize,
    value: git2::Object,
) {
    let l1 = "\t".repeat(level);
    let l2 = "\t".repeat(level + 1);
    let l3 = "\t".repeat(level + 2);
    let key = "object";
    println!("{l1}id: {:?}", value.id());
    println!("{l1}short_id: {:?}", value.short_id().map(|x| x.as_str().map(String::from)));
    println!("{l1}kind: {:?}", value.kind());
}
fn traverse_tree(
    level: usize,
    value: git2::Tree,
) {
    let l1 = "\t".repeat(level);
    let l2 = "\t".repeat(level + 1);
    let l3 = "\t".repeat(level + 2);
    let key = "tree";
    println!("{l1}{key}.id: {}", value.id());
    let object = value.as_object();
    println!("{l2}object.id: {:?}", object.id());
    println!("{l2}object.short_id: {:?}", object.short_id().map(|x| x.as_str().map(String::from)));
    println!("{l2}object.kind: {:?}", object.kind());
    for (ix, entry) in value.iter().enumerate() {
        println!("{l1}tree.iter: {}", ix);
        println!("{l2}id: {}", entry.id());
        println!("{l2}name: {:?}", entry.name());
        println!("{l2}kind: {:?}", entry.kind());
        println!("{l2}filemode: {}", entry.filemode());
    }
}
fn traverse_reference(
    level: usize,
    value: git2::Reference,
) {
    let name = value.name();
    let shorthand = value.shorthand();
    println!("{level}:");
    let l1 = "\t".repeat(level);
    let l2 = "\t".repeat(level + 1);
    let l3 = "\t".repeat(level + 2);
    let key = "reference";
    println!("{l1}{key}.name: {:?}", name);
    println!("{l1}{key}.shorthand: {:?}", shorthand);
    println!("{l1}{key}.symbolic_target: {:?}", value.symbolic_target());
    println!("{l1}{key}.kind: {:?}", value.kind());
    println!("{l1}{key}.is_branch: {:?}", value.is_branch());
    println!("{l1}{key}.is_note: {:?}", value.is_note());
    println!("{l1}{key}.is_remote: {:?}", value.is_remote());
    println!("{l1}{key}.is_tag: {:?}", value.is_tag());
    match value.resolve() {
        Ok(value) => {
            println!("{l1}[resolved] {key}.name: {:?}", value.name());
            println!("{l1}[resolved] {key}.shorthand: {:?}", value.shorthand());
            println!("{l1}[resolved] {key}.symbolic_target: {:?}", value.symbolic_target());
        }
        Err(err) => {
            println!("{l1}[ERROR] {key}.resolve: {err}")
        }
    }
    if let Some(name) = name.as_ref() {
        println!(
            "{l1}{key}.shorthand [NORMAL]: {:?}",
            git2::Reference::normalize_name(name, git2::ReferenceFormat::NORMAL),
        );
        println!(
            "{l1}{key}.shorthand [ALLOW_ONELEVEL]: {:?}",
            git2::Reference::normalize_name(name, git2::ReferenceFormat::ALLOW_ONELEVEL),
        );
        println!(
            "{l1}{key}.shorthand [REFSPEC_PATTERN]: {:?}",
            git2::Reference::normalize_name(name, git2::ReferenceFormat::REFSPEC_PATTERN),
        );
        println!(
            "{l1}{key}.shorthand [REFSPEC_SHORTHAND]: {:?}",
            git2::Reference::normalize_name(name, git2::ReferenceFormat::REFSPEC_SHORTHAND),
        );
    }
    if let Ok(value) = value.peel_to_blob() {
        println!("{l1}{key}.peel_to_blob:");
        println!("{l2}blob.id: {}", value.id());
        let object = value.as_object();
        println!("{l3}object.id: {:?}", object.id());
        println!("{l3}object.short_id: {:?}", object.short_id().map(|x| x.as_str().map(String::from)));
        println!("{l3}object.kind: {:?}", object.kind());
    }
    if let Ok(value) = value.peel_to_commit() {
        println!("{l1}{key}.peel_to_commit:");
        println!("{l2}commit.id: {}", value.id());
        println!("{l2}commit.message: {:?}", value.message());
        println!("{l2}commit.summary: {:?}", value.summary());
        println!("{l2}commit.time: {:?}", value.time());
        let author = value.author();
        let committer = value.committer();
        println!("{l2}commit.author.name: {:?}", author.name());
        println!("{l2}commit.author.email: {:?}", author.email());
        println!("{l2}commit.committer.name: {:?}", committer.name());
        println!("{l2}commit.committer.email: {:?}", committer.email());
        let object = value.as_object();
        println!("{l3}object.id: {:?}", object.id());
        println!("{l3}object.short_id: {:?}", object.short_id().map(|x| x.as_str().map(String::from)));
        println!("{l3}object.kind: {:?}", object.kind());
    }
    if let Ok(value) = value.peel_to_tree() {
        println!("{l1}{key}.peel_to_tree:");
        println!("{l2}tree.id: {}", value.id());
        let object = value.as_object();
        println!("{l3}object.id: {:?}", object.id());
        println!("{l3}object.short_id: {:?}", object.short_id().map(|x| x.as_str().map(String::from)));
        println!("{l3}object.kind: {:?}", object.kind());
        println!("{l2}tree.iter:");
        for (ix, entry) in value.iter().enumerate() {
            println!("{l3}id: {}", entry.id());
            println!("{l3}name: {:?}", entry.name());
            println!("{l3}kind: {:?}", entry.kind());
            println!("{l3}filemode: {}", entry.filemode());
        }
        println!("{l2}tree.walk:");
        value.walk(git2::TreeWalkMode::PreOrder, |str, entry| {
            println!("{l3}arg1: {str:?}");
            println!("{l3}id: {}", entry.id());
            println!("{l3}name: {:?}", entry.name());
            println!("{l3}kind: {:?}", entry.kind());
            println!("{l3}filemode: {}", entry.filemode());
            git2::TreeWalkResult::Ok
        });
    }
    if let Ok(value) = value.peel_to_tag() {
        println!("{l1}{key}.peel_to_tag:");
        println!("{l2}tag.id: {}", value.id());
        let object = value.as_object();
        println!("{l3}object.id: {:?}", object.id());
        println!("{l3}object.short_id: {:?}", object.short_id().map(|x| x.as_str().map(String::from)));
        println!("{l3}object.kind: {:?}", object.kind());

    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// GIT-MANAGER - MERGE-ANALYSIS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum BasicMergeAnalysis {
    /// No merge is possible.
    IsNone,
    /// A "normal" merge; both HEAD and the given merge input have diverged
    /// from their common ancestor. The divergent commits must be merged.
    IsNormal,
    /// All given merge inputs are reachable from HEAD, meaning the
    /// repository is up-to-date and no merge needs to be performed.
    IsUpToDate,
    /// The given merge input is a fast-forward from HEAD and no merge
    /// needs to be performed.  Instead, the client can check out the
    /// given merge input.
    IsFastForward,
    /// The HEAD of the current repository is "unborn" and does not point to
    /// a valid commit.  No merge can be performed, but the caller may wish
    /// to simply set HEAD to the target commit(s).
    IsUnborn,
}

impl BasicMergeAnalysis {
    pub fn is_none(&self) -> bool {*self == BasicMergeAnalysis::IsNone}
    pub fn is_normal(&self) -> bool {*self == BasicMergeAnalysis::IsNormal}
    pub fn is_up_to_date(&self) -> bool {*self == BasicMergeAnalysis::IsUpToDate}
    pub fn is_fast_forward(&self) -> bool {*self == BasicMergeAnalysis::IsFastForward}
    pub fn is_unborn(&self) -> bool {*self == BasicMergeAnalysis::IsUnborn}
}

impl GitManager {
    pub fn get_basic_merge_analysis(
        &self,
        fetch_commit: &git2::AnnotatedCommit,
    ) -> Result<BasicMergeAnalysis, GitErr> {
        let (merge_analysis, _) = self.repository.merge_analysis(&[&fetch_commit])?;
        if merge_analysis.is_none() {
            return Ok(BasicMergeAnalysis::IsNone)
        }
        if merge_analysis.is_normal() {
            return Ok(BasicMergeAnalysis::IsNormal)
        }
        if merge_analysis.is_up_to_date() {
            return Ok(BasicMergeAnalysis::IsUpToDate)
        }
        if merge_analysis.is_fast_forward() {
            return Ok(BasicMergeAnalysis::IsFastForward)
        }
        if merge_analysis.is_unborn() {
            return Ok(BasicMergeAnalysis::IsUnborn)
        }
        panic!("Not possible!")
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// GIT-MANAGER - FILE-STATUS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum FileStatus {
    IsIndexNew,
    IsIndexModified,
    IsIndexDeleted,
    IsIndexRenamed,
    IsIndexTypechange,
    IsWtNew,
    IsWtModified,
    IsWtDeleted,
    IsWtTypechange,
    IsWtRenamed,
    IsIgnored,
    IsConflicted,
}

impl FileStatus {
    pub fn is_index_new(&self) -> bool {*self == FileStatus::IsIndexNew}
    pub fn is_index_modified(&self) -> bool {*self == FileStatus::IsIndexModified}
    pub fn is_index_deleted(&self) -> bool {*self == FileStatus::IsIndexDeleted}
    pub fn is_index_renamed(&self) -> bool {*self == FileStatus::IsIndexRenamed}
    pub fn is_index_typechange(&self) -> bool {*self == FileStatus::IsIndexTypechange}
    pub fn is_wt_new(&self) -> bool {*self == FileStatus::IsWtNew}
    pub fn is_wt_modified(&self) -> bool {*self == FileStatus::IsWtModified}
    pub fn is_wt_deleted(&self) -> bool {*self == FileStatus::IsWtDeleted}
    pub fn is_wt_typechange(&self) -> bool {*self == FileStatus::IsWtTypechange}
    pub fn is_wt_renamed(&self) -> bool {*self == FileStatus::IsWtRenamed}
    pub fn is_ignored(&self) -> bool {*self == FileStatus::IsIgnored}
    pub fn is_conflicted(&self) -> bool {*self == FileStatus::IsConflicted}
}

// impl GitManager {
//     pub fn file_status(&self, name: impl AsRef<str>) {}
// }


#[derive(Debug, Clone)]
pub enum Tree {
    
}

impl GitManager {
    // pub fn remote_list(&self) {
    //     self.for_all_remote_managers(|mut manager| {
    //         println!("fetch_refspecs");
    //         for (ix, spec) in manager.remote.fetch_refspecs().unwrap().into_iter().enumerate() {
    //             println!("{ix}");
    //             println!("\tspec: {:?}", spec);
    //         }
    //         println!("push_refspecs");
    //         for (ix, spec) in manager.remote.push_refspecs().unwrap().into_iter().enumerate() {
    //             println!("{ix}");
    //             println!("\tspec: {:?}", spec);
    //         }
    //         println!("refspecs");
    //         manager.remote.connect(git2::Direction::Fetch).unwrap();
    //         let xs = manager.remote.refspecs();
    //         println!("for_all_remote_managers {}", xs.len());
    //         for (ix, x) in xs.enumerate() {
    //             println!("{ix}");
    //             println!("\tdst: {:?}", x.dst());
    //             println!("\tsrc: {:?}", x.src());
    //             println!("\tis_force: {:?}", x.is_force());
    //             println!("\tstr: {:?}", x.str());
    //             // println!("name: {:?}", x.name());
    //             // println!("\tsymref_target: {:?}", x.symref_target());
    //         }
    //         manager.remote.disconnect().unwrap();
    //     });
    // }
    pub fn get_all_files(&self) {
        let (xs, errs) = self.map_remote_managers(|mut manager| {
            // manager.fetch_download(ref_list)
            println!("remote:");
            println!("\tname: {:?}", manager.remote.name());
            println!("\turl: {:?}", manager.remote.url());
            println!("\tpushurl: {:?}", manager.remote.pushurl());
            if let Some(name) = manager.remote.name() {
                println!("\tis_valid_name: {:?}", git2::Remote::is_valid_name(name));
            }
            manager.remote.connect(git2::Direction::Fetch).unwrap();
            for refspec in manager.remote.refspecs() {
                let own = OwnRefSpec::from_ref(&refspec);
                println!("{own:#?}");
                println!("RESULT {:?}", refspec.transform(own.src.as_ref().unwrap()).unwrap().as_str());
                println!("RESULT {:?}", refspec.rtransform(own.dst.as_ref().unwrap()).unwrap().as_str());
            }
            for x in manager.remote.list().unwrap() {
                println!("name: {:?}", x.name());
                println!("symref_target: {:?}", x.symref_target());
                println!("");
            }
            // let results = manager.map_reference_advertisement_list(|remote_head| {
            //     for refspec in manager.remote.refspecs() {
            //         let res1 = refspec.src_matches(remote_head.name());
            //         println!("res1: {res1:?}");
            //     }
            // });
            // manager.remote.disconnect().unwrap();
            // for (ix, spec) in manager.remote.fetch_refspecs().unwrap().into_iter().enumerate() {
            //     println!("{ix}");
            //     println!("\tspec: {:?}", spec);
            // }
            Ok(())
        });
        assert!(errs.is_empty());
    }
}



//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// FILE-TREE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone)]
pub enum FileTree {
    File(File),
    Folder(Folder),
}

#[derive(Debug, Clone)]
pub struct File {
    path: ProjectPath,
    name: String,
}

#[derive(Debug, Clone)]
pub struct Folder {
    path: ProjectPath,
    name: String,
    children: Vec<FileTree>,
}

#[derive(Debug, Clone)]
pub struct ProjectPath {
    project_root: PathBuf,
    local_path: PathBuf,
}

impl ProjectPath {
    pub fn absolute_path(&self) -> PathBuf {
        let mut abs_path = self.project_root.clone();
        abs_path.push(&self.local_path);
        abs_path
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// DEV
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

// impl ProjectPath {
//     pub fn from(val: impl AsRef<Path>) -> Self {
//         ProjectPath()
//     }
// }

pub fn dev() {
    // let git_repo_path = "/Users/colbyn/Developer/tmp/libgit2";
    // let git_repo_path = "/Users/colbyn/Developer/tmp/simplegit-progit";
    // let git_repo_path = "/Users/colbyn/Developer/tmp/testrepo2";
    // let git_repo_path = "/Users/colbyn/Developer/tmp/empty-repo";
    let git_repo_path = "/Users/colbyn/Developer/tmp/git-sample-repo1";
    // let git_repo_path = "/Users/colbyn/Developer/tmp/sample.ss1-notebook";
    // let mut git_manager = GitManager::init_repo(git_repo_path).unwrap();
    let mut git_manager = GitManager::open_repo(git_repo_path).unwrap();
    let user_auth = UserAuth::load_dev();
    git_manager.set_user_auth(user_auth);
    println!("OPENED");
    // git_manager.push_to_all_remotes::<&str>(&[]);
    // git_manager.add_and_commit_all("Add some more delta sub-dirs.");
    // println!("HEAD {:?}", git_manager.head_branch_reference_name());
    // git_manager.add_remote("origin", "https://github.com/colbyn-git-bot1/ss-notebook-db-genesis.git");
    // println!("HEAD {:?}", git_manager.head_branch_reference_name());
    // println!("references.count: {}", git_manager.references().len());
    // for reference in git_manager.references() {
    //     traverse_reference(1, reference);
    // }
    // println!("{}", "-".repeat(80));
    // git_manager.download_from_all_remotes::<String>(&[]);
    // println!("HEAD {:?}", git_manager.head_branch_reference_name());
    // println!("{}", "-".repeat(80));
    // git_manager.pull("origin", "master");
    // println!("references.count: {}", git_manager.references().len());
    // for (ix, reference) in git_manager.references().into_iter().enumerate() {
    //     traverse_reference(1, reference);
    // }
    // let resolved_reference = git_manager.repository.resolve_reference_from_short_name("master").unwrap();
    // println!("resolved_reference.name: {:?}", resolved_reference.name());
    // println!("resolved_reference.shorthand: {:?}", resolved_reference.shorthand());
    
    // let head = git_manager.repository.head().unwrap();
    // println!("head.name: {:?}", head.name());
    // println!("head.shorthand: {:?}", head.shorthand());

    // println!("state: {:?}", git_manager.repository.state());
    // println!("namespace: {:?}", git_manager.repository.namespace());
    // println!("message: {:?}", git_manager.repository.message());
    for reference in git_manager.references() {
        traverse_reference(1, reference);
        // let reference = reference.unwrap();
        // println!("reference.name: {:?}", reference.name());
        // println!("reference.shorthand: {:?}", reference.shorthand());
    }
    // git_manager.remote_list();
    println!("{}", "-".repeat(80));
    git_manager.get_all_files();
    // let mut git_manager = GitManager::open_repo("/Users/colbyn/Developer/tmp/empty-repo").unwrap();
    // println!("OPENED");
    // let resolved_reference = git_manager.repository.resolve_reference_from_short_name("master").unwrap();
    // println!("resolved_reference.name: {:?}", resolved_reference.name());
    // println!("resolved_reference.shorthand: {:?}", resolved_reference.shorthand());
    // let head_ref = git_manager.head_branch_reference_name().unwrap();
    // git_manager.fetch_from_all_remotes::<&str>(&[]);
    // git_manager.pull("origin", "master").unwrap();
}

