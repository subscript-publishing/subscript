use std::path::{PathBuf, Path};



// For some reason I’m unable to parse into a FileDataModel directly, but it
// works if I parse the binary PList file into the corresponding Value type
// (from the plist lib) and then use e.g. serde json to parse it…
pub fn parse_file<P: AsRef<Path>>(file_path: P) -> Result<crate::ss_drawing::format::FileDataModel, String> {
    let value: serde_json::Value = plist::from_file(file_path.as_ref())
        .map_err(|x| format!("{:?}", x))?;
    let model = serde_json::from_value::<crate::ss_drawing::format::FileDataModel>(value)
        .map_err(|x| format!("{:?}", x))?;
    Ok(model)
}

/// Compiles into a vec of SVG(s).
pub fn compile<P: AsRef<Path>>(file_path: P) -> Result<Vec<String>, String> {
    parse_file(file_path).map(|x| x.canvas.to_svgs())
}
