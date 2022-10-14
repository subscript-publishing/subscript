use std::path::{PathBuf, Path};

pub mod format;

pub fn random_str_id() -> String {
    use rand::Rng;
    let mut rng = rand::thread_rng();
    let number: usize = rng.gen();
    return format!("ID{}", number)
}

pub fn file_path_union<T, U>(
    path1: T,
    path2: U,
) -> Option<PathBuf> where T: AsRef<Path>, U: AsRef<Path> {
    for path in [path1.as_ref(), path2.as_ref()] {
        if !path.exists() {
            let _: () = path
                .parent()
                .and_then(|parent| {
                    std::fs::create_dir_all(parent).ok()
                })?;
            std::fs::write(&path, []);
        }
    }
    let normalized_src_file = path1.as_ref().canonicalize().ok()?;
    let normalized_out_file = path2.as_ref().canonicalize().ok()?;
    let union_path = normalized_src_file
        .components()
        .zip(normalized_out_file.components())
        .take_while(|(l, r)| l == r)
        .map(|(l, r)| {
            assert!(l == r);
            l
        })
        .collect::<PathBuf>();;
    Some(union_path)
}