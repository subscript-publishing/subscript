use std::io::Write;
use itertools::Itertools;
use std::path::Path;
use super::UserAuth;


// pub fn get_name(remote: &git2::Remote) -> &str {
//     remote.name().unwrap()
// }
// pub fn get_url(remote: &git2::Remote) -> &str {
//     remote.url().unwrap()
// }
// pub fn get_push_url(remote: &git2::Remote) -> Option<&str> {
//     remote.pushurl()
// }
pub fn get_default_branch(remote: &git2::Remote) -> Option<String> {
    remote
        .default_branch()
        .as_ref()
        .ok()
        .and_then(|x| x.as_str())
        .map(String::from)
}
// pub fn get_metadata(remote: &git2::Remote) -> RemoteMetadata {
//     let name = remote.name().unwrap().to_string();
//     let url = remote.url().unwrap().to_string();
//     let push_url = remote.pushurl().map(|x| x.to_owned());
//     let default_branch = remote
//         .default_branch()
//         .as_ref()
//         .ok()
//         .and_then(|x| x.as_str())
//         .map(String::from);
//     RemoteMetadata{name, url, push_url, default_branch}
// }
pub fn map_reference_advertisement_list<T>(remote: &mut git2::Remote, f: impl Fn(&git2::RemoteHead) -> T) -> Vec<T> {
    remote.connect(git2::Direction::Fetch).unwrap();
    let xs = remote.list().unwrap();
    let results = xs
        .into_iter()
        .map(f)
        .collect_vec();
    remote.disconnect().unwrap();
    results
}
pub fn push<T: AsRef<str>>(
    user_auth: Option<&UserAuth>,
    remote: &mut git2::Remote,
    ref_list: &[T]
) -> Result<(), git2::Error> {
    let mut push_options = git2::PushOptions::new();
    let mut remote_callbacks = user_auth
        .as_ref()
        .map(|user_auth| user_auth.provision_new_remote_callbacks())
        .unwrap_or_else(|| git2::RemoteCallbacks::new());
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
    remote.push::<&str>(&ref_list, Some(&mut push_options))
}
pub fn fetch_download<T: AsRef<str>>(
    user_auth: Option<&UserAuth>,
    remote: &mut git2::Remote,
    ref_list: &[T]
) -> Result<(), git2::Error> {
    let init_remote_callbacks = || {
        let mut remote_callbacks = user_auth
            .as_ref()
            .map(|user_auth| user_auth.provision_new_remote_callbacks())
            .unwrap_or_else(|| git2::RemoteCallbacks::new());
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
    // let fetch_connection = remote.connect_auth(git2::Direction::Fetch, Some(remote_callbacks), None).unwrap();
    // let list = fetch_connection.list()
    let ref_list = ref_list
        .into_iter()
        .map(|x| x.as_ref())
        .collect_vec();
    remote.download(&ref_list, Some(&mut fetch_options))?;
    // If there are local objects (we got a thin pack), then tell the user
    // how many objects we saved from having to cross the network.
    let stats = remote.stats();
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
    remote.disconnect()?;
    // Update the references in the remote's namespace to point to the right
    // commits. This may be needed even if there was no packfile to download,
    // which can happen e.g. when the branches have been changed but all the
    // needed objects are available locally.
    let mut remote_callbacks = init_remote_callbacks();
    remote.update_tips(Some(&mut remote_callbacks), true, git2::AutotagOption::Unspecified, None)?;
    Ok(())
}
pub fn fetch<T: AsRef<str>>(
    user_auth: Option<&UserAuth>,
    remote: &mut git2::Remote,
    ref_list: &[T],
) -> Result<(), git2::Error> {
    let mut remote_callbacks = user_auth
            .as_ref()
            .map(|user_auth| user_auth.provision_new_remote_callbacks())
            .unwrap_or_else(|| git2::RemoteCallbacks::new());
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
    println!("Fetching {} for repo", remote.name().unwrap());
    let ref_list = ref_list
        .into_iter()
        .map(|x| x.as_ref())
        .collect_vec();
    remote.fetch(&ref_list, Some(&mut fetch_options), None)?;
    // If there are local objects (we got a thin pack), then tell the user
    // how many objects we saved from having to cross the network.
    let stats = remote.stats();
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


