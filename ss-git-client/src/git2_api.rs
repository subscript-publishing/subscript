use std::path::Path;
pub mod git2_remote;
use crate::data::UserAuth;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// USER-AUTH
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


impl UserAuth {
    /// Currying seems to fix lifetime issues. 
    fn get_credential_setter(&self) -> impl FnOnce(&mut git2::RemoteCallbacks) -> () {
        let git_config = git2::Config::open_default().unwrap();
        let user = self.clone();
        move |callbacks| {
            let user = user.clone();
            callbacks.credentials(move |_url, username_from_url, _allowed_types| {
                println!("_allowed_types {:?}", _allowed_types);
                let cred = git2::Cred::userpass_plaintext(
                    user.username.as_str(),
                    user.token.as_str(),
                );
                assert!(cred.is_ok());
                cred
            });
        }
    }
    /// Returns an object that was provisioned with the stored user credentials.
    fn provision_new_remote_callbacks(&self) -> git2::RemoteCallbacks {;
        let mut callbacks = git2::RemoteCallbacks::new();
        self.get_credential_setter()(&mut callbacks);
        callbacks
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// GIT REPOSITORY
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


use git2::{Repository, Remote, Error};
use itertools::Itertools;

pub fn open_repo(path: impl AsRef<Path>) -> Result<Repository, git2::Error> {
    git2::Repository::open(path.as_ref())
}
pub fn init_repo(path: impl AsRef<Path>) -> Result<Repository, git2::Error> {
    git2::Repository::init(path.as_ref())
}
pub fn clone_repo(
    user_auth: Option<UserAuth>,
    url: impl AsRef<str>,
    target: impl AsRef<Path>,
) -> Result<Repository, git2::Error> {
    // Prepare callbacks.
    let mut callbacks = user_auth
        .as_ref()
        .map(|user_auth| user_auth.provision_new_remote_callbacks())
        .unwrap_or_else(|| git2::RemoteCallbacks::new());
    // Prepare fetch options.
    let mut fetch_options = git2::FetchOptions::new();
    fetch_options.remote_callbacks(callbacks);
    // Prepare builder.
    let mut builder = git2::build::RepoBuilder::new();
    builder.fetch_options(fetch_options);
    // Clone the project.
    builder.clone(url.as_ref(), target.as_ref())
}
pub fn add_and_commit_all(repo: &Repository, message: impl AsRef<str>) {
    add_and_commit(repo, message, |index| {
        index.add_all(["*"].iter(), git2::IndexAddOption::DEFAULT, None).unwrap();
    })
}
pub fn add_and_commit(repo: &Repository, message: impl AsRef<str>, indexer: impl FnOnce(&mut git2::Index)) {
    let sig = repo.signature().unwrap();
    let mut index = repo.index().unwrap();
    indexer(&mut index);
    assert!(!index.has_conflicts());
    index.write().unwrap();
    let tree_oid = index.write_tree().unwrap();
    let tree = repo.find_tree(tree_oid).unwrap();
    let parent_commit = match repo.revparse_single("HEAD") {
        Ok(obj) => Some(obj.into_commit().unwrap()),
        // FIRST COMMIT SO NO PARENT COMMIT
        Err(e) if e.code() == git2::ErrorCode::NotFound => None,
        e => panic!("ERROR {e:?}"),
    };
    let mut parents = Vec::new();
    if parent_commit.is_some() {
        parents.push(parent_commit.as_ref().unwrap());
    }
    let signature = repo.signature().unwrap();
    let commit_oid = repo.commit(
        Some("HEAD"),
        &signature,
        &signature,
        message.as_ref(),
        &tree,
        &parents[..],
    ).unwrap();
    let _ = repo.find_commit(commit_oid).unwrap();
}
pub fn add_remote(
    repo: &Repository,
    name: impl AsRef<str>,
    url: impl AsRef<str>,
) -> Result<git2::Remote<'_>, git2::Error> {
    repo.remote(name.as_ref(), url.as_ref())
}
pub fn for_all_remotes<T>(repo: &Repository, f: impl Fn(git2::Remote) -> T) -> Vec<T> {
    repo
        .remotes()
        .as_mut()
        .unwrap()
        .into_iter()
        .flat_map(std::convert::identity)
        .filter_map(|name| repo.find_remote(name.as_ref()).ok())
        .map(|remote| {
            f(remote)
        })
        .collect_vec()
}
pub fn try_for_all_remotes<T>(
    repo: &Repository,
    f: impl Fn(git2::Remote) -> Result<T, git2::Error>,
) -> (Vec<T>, Vec<git2::Error>) {
    for_all_remotes(repo, f)
        .into_iter()
        .partition_result::<Vec<_>, Vec<_>, _, git2::Error>()
}
pub fn push_head_to_all_remotes(
    repo: &Repository,
    user_auth: Option<&UserAuth>,
) -> Result<(), Vec<git2::Error>> {
    let rev = repo.revparse_ext("HEAD").map_err(|x| vec![x])?;
    let rev_name = rev.1.as_ref().unwrap().name().unwrap();
    push_to_all_remotes(repo, user_auth, &[rev_name])
}
pub fn pull(
    repo: &Repository,
    user_auth: Option<&UserAuth>,
    remote_name: impl AsRef<str>,
    remote_branch: impl AsRef<str>,
) -> Result<(), git2::Error> {
    let mut remote = repo.find_remote(remote_name.as_ref())?;
    // let _ = remote.fetch(&[remote_branch.as_ref()])?;
    let _ = git2_remote::fetch(user_auth, &mut remote, &[remote_branch.as_ref()]);
    std::mem::drop(remote);
    let fetch_head: git2::Reference = repo.find_reference("FETCH_HEAD")?;
    println!("fetch_head: {:?}", fetch_head.name());
    let fetch_commit = repo.reference_to_annotated_commit(&fetch_head)?;
    std::mem::drop(fetch_head);
    let _ = merge(repo, remote_branch, fetch_commit)?;
    Ok(())
}
fn fast_forward(
    repo: &Repository,
    lb: &mut git2::Reference,
    rc: &git2::AnnotatedCommit,
) -> Result<(), git2::Error> {
    let name = match lb.name() {
        Some(s) => s.to_string(),
        None => String::from_utf8_lossy(lb.name_bytes()).to_string(),
    };
    let msg = format!("Fast-Forward: Setting {} to id: {}", name, rc.id());
    println!("{}", msg);
    lb.set_target(rc.id(), &msg)?;
    repo.set_head(&name)?;
    repo.checkout_head(Some(
        git2::build::CheckoutBuilder::default()
            // For some reason the force is required to make the working directory actually get updated
            // I suspect we should be adding some logic to handle dirty working directory states
            // but this is just an example so maybe not.
            .force(),
    ))?;
    Ok(())
}
fn normal_merge(
    repo: &Repository,
    local: &git2::AnnotatedCommit,
    remote: &git2::AnnotatedCommit,
) -> Result<(), git2::Error> {
    let local_tree = repo.find_commit(local.id())?.tree()?;
    let remote_tree = repo.find_commit(remote.id())?.tree()?;
    let ancestor = repo
        .find_commit(repo.merge_base(local.id(), remote.id())?)?
        .tree()?;
    let mut idx = repo.merge_trees(&ancestor, &local_tree, &remote_tree, None)?;
    if idx.has_conflicts() {
        println!("Merge conficts detected...");
        repo.checkout_index(Some(&mut idx), None)?;
        return Ok(());
    }
    let result_tree = repo.find_tree(idx.write_tree_to(&repo)?)?;
    // now create the merge commit
    let msg = format!("Merge: {} into {}", remote.id(), local.id());
    let sig = repo.signature()?;
    let local_commit = repo.find_commit(local.id())?;
    let remote_commit = repo.find_commit(remote.id())?;
    // Do our merge commit and set current branch head to that commit.
    let _merge_commit = repo.commit(
        Some("HEAD"),
        &sig,
        &sig,
        &msg,
        &result_tree,
        &[&local_commit, &remote_commit],
    )?;
    // Set working tree to match head.
    repo.checkout_head(None)?;
    Ok(())
}
pub fn merge(
    repo: &Repository,
    remote_branch: impl AsRef<str>,
    fetch_commit: git2::AnnotatedCommit
) -> Result<(), git2::Error> {
    // 1. DO A MERGE ANALYSIS
    let merge_analysis = get_basic_merge_analysis(repo, &fetch_commit)?;
    println!("merge_analysis: {:?}", merge_analysis);
    // 2. DO THE APPOPRIATE MERGE
    match merge_analysis {
        // The branch doesn't exist so just set the reference to the
        // commit directly. Usually this is because you are pulling
        // into an empty repository.
        BasicMergeAnalysis::IsFastForward => {
            // DO A FAST FORWARD
            let refname = format!("refs/heads/{}", remote_branch.as_ref());
            match repo.find_reference(&refname) {
                Ok(mut r) => {
                    fast_forward(repo, &mut r, &fetch_commit)?;
                }
                Err(_) => {
                    repo.reference(
                        &refname,
                        fetch_commit.id(),
                        true,
                        &format!("Setting {} to {}", remote_branch.as_ref(), fetch_commit.id()),
                    )?;
                    repo.set_head(&refname)?;
                    repo.checkout_head(Some(
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
            let head_commit = repo.reference_to_annotated_commit(&repo.head()?)?;
            normal_merge(repo, &head_commit, &fetch_commit)?;
        }
        BasicMergeAnalysis::IsNone | BasicMergeAnalysis::IsUpToDate | BasicMergeAnalysis::IsUnborn => {
            println!("Nothing to do...");
        }
    }
    Ok(())
}
pub fn push_to_all_remotes<T: AsRef<str>>(
    repo: &Repository,
    user_auth: Option<&UserAuth>,
    rev_list: &[T],
) -> Result<(), Vec<git2::Error>> {
    let (xs, es) = try_for_all_remotes(repo, |mut remote| {
        let ref_list = rev_list
            .into_iter()
            .map(|x| x.as_ref())
            .collect_vec();
        git2_remote::push(user_auth, &mut remote, &ref_list)
    });
    if es.is_empty() {
        return Ok(())
    }
    Err(es)
}
// // pub fn fetch_from_all_remotes<T: AsRef<str>>(&mut self, rev_list: &[T]) {
// //     self.for_all_remote_managers(|mut remote| {
// //         let rev_list = rev_list
// //             .into_iter()
// //             .map(|x| x.as_ref())
// //             .collect_vec();
// //         let _ = remote.fetch(&rev_list).unwrap();
// //         let fetch_head = repo.find_reference("FETCH_HEAD").unwrap();
// //         let annotated_commit = repo.reference_to_annotated_commit(&fetch_head).unwrap();
// //     });
// // }
pub fn download_from_all_remotes<T: AsRef<str>>(
    repo: &Repository,
    user_auth: Option<&UserAuth>,
    ref_list: &[T],
) -> Result<(), Vec<git2::Error>> {
    let (xs, es) = try_for_all_remotes(repo, |mut remote| {
        let ref_list = ref_list
            .into_iter()
            .map(|x| x.as_ref())
            .collect_vec();
        git2_remote::fetch_download(user_auth, &mut remote, &ref_list)
    });
    if es.is_empty() {
        return Ok(())
    }
    Err(es)
}
/// Lookup the branch that HEAD points to
pub fn head_branch_shorthand(repo: &Repository) -> Option<String> {
    repo
        .head()
        .ok()?
        .resolve()
        .ok()?
        .shorthand()
        .map(String::from)
}
// pub fn head(repo: &Repository) {
//     let rev = repo.revparse_ext("HEAD").unwrap();
//     let rev_name = rev.1.as_ref().unwrap().name().unwrap();
// }
pub fn head_branch_reference_name(repo: &Repository) -> Option<String> {
    repo
        .head()
        .ok()?
        .resolve()
        .ok()?
        .name()
        .map(String::from)
}
/// Lookup the commit ID for `HEAD`
pub fn head_id(repo: &Repository) -> Option<git2::Oid> {
    repo.head().ok()?.resolve().ok()?.target()
}
pub fn is_dirty(repo: &Repository) -> bool {
    if repo.state() != git2::RepositoryState::Clean {
        println!("Repository status is unclean: {:?}", repo.state());
        return true;
    }
    let status = repo
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
pub fn references(repo: &Repository) -> Vec<git2::Reference> {
    repo
        .references()
        .unwrap()
        .map(|x| x.unwrap())
        .map(|x| x)
        .collect_vec()
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MERGE-ANALYSIS
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

pub fn get_basic_merge_analysis(
    repo: &git2::Repository,
    fetch_commit: &git2::AnnotatedCommit,
) -> Result<BasicMergeAnalysis, git2::Error> {
    let (merge_analysis, _) = repo.merge_analysis(&[&fetch_commit])?;
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




