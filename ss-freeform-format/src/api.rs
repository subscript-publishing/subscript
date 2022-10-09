use std::path::{PathBuf, Path};
pub use crate::format::*;
pub use crate::format::{canvas_data_model::CanvasDataModel, canvas_data_model::DrawingDataModel};
pub use crate::format::page_data_model::{PageDataModel, PageEntry, PageEntryType, Title, HeadingType};

#[derive(Debug, Clone)]
pub enum SS1FreeformSuite {
    /// File ending with a `.ss1-drawing` extension.
    Ss1Drawing(CanvasDataModel),
    /// File ending with a `.ss1-composition` extension.
    Ss1Composition(PageDataModel),
}

impl SS1FreeformSuite {
    pub fn is_ss1_drawing_file<T: AsRef<Path>>(file_path: T) -> bool {
        file_path
            .as_ref()
            .extension()
            .map(|x| {
                x == "ss1-drawing"
            })
            .unwrap_or(false)
    }
    pub fn is_ss1_composition_file<T: AsRef<Path>>(file_path: T) -> bool {
        file_path
            .as_ref()
            .extension()
            .map(|x| {
                x == "ss1-composition"
            })
            .unwrap_or(false)
    }
    pub fn parse_ss1_drawing_file<T: AsRef<Path>>(file_path: T) -> Result<Self, SS1FreeformSuiteError> {
        if !SS1FreeformSuite::is_ss1_drawing_file(file_path.as_ref()) {
            return Err(SS1FreeformSuiteError::ExpectedSs1DrawingFileFormat {
                file_path: file_path.as_ref().to_path_buf()
            })
        }
        let payload = std::fs::read(file_path.as_ref())
            .map_err(|_| {
                SS1FreeformSuiteError::FailedToOpenFile {file_path: file_path.as_ref().to_path_buf()}
            })?;
        // For some reason I’m unable to this into a `CanvasDataModel` directly, 
        // but it works if I parse this as a `serde_json::Value` type and then use
        // `serde_json` to parse into a `CanvasDataModel`.
        let payload = plist::from_bytes::<serde_json::Value>(&payload)
            .map_err(|_| {
                SS1FreeformSuiteError::FailedToParseFileFormat {file_path: file_path.as_ref().to_path_buf()}
            })?;
        let payload = serde_json::from_value::<CanvasDataModel>(payload)
            .map_err(|e| {
                println!("ERROR {e:#?}");
                SS1FreeformSuiteError::FailedToParseFileFormat {file_path: file_path.as_ref().to_path_buf()}
            })?;
        Ok(SS1FreeformSuite::Ss1Drawing(payload))
    }
    pub fn parse_ss1_composition_file<T: AsRef<Path>>(file_path: T) -> Result<Self, SS1FreeformSuiteError> {
        if !SS1FreeformSuite::is_ss1_composition_file(file_path.as_ref()) {
            return Err(SS1FreeformSuiteError::ExpectedSs1CompositionFileFormat {
                file_path: file_path.as_ref().to_path_buf()
            })
        }
        let payload = std::fs::read(file_path.as_ref())
            .map_err(|_| {
                SS1FreeformSuiteError::FailedToOpenFile {file_path: file_path.as_ref().to_path_buf()}
            })?;
        // For some reason I’m unable to this into a `PageDataModel` directly, 
        // but it works if I parse this as a `serde_json::Value` type and then use
        // `serde_json` to parse into a `PageDataModel`.
        let payload = plist::from_bytes::<serde_json::Value>(&payload)
            .map_err(|_| {
                SS1FreeformSuiteError::FailedToParseFileFormat {file_path: file_path.as_ref().to_path_buf()}
            })?;
        let payload = serde_json::from_value::<PageDataModel>(payload)
            .map_err(|e| {
                println!("ERROR {e:#?}");
                SS1FreeformSuiteError::FailedToParseFileFormat {file_path: file_path.as_ref().to_path_buf()}
            })?;
        Ok(SS1FreeformSuite::Ss1Composition(payload))
    }
}


#[derive(Debug, Clone, PartialEq)]
pub enum SS1FreeformSuiteError {
    ExpectedSs1DrawingFileFormat {file_path: PathBuf},
    ExpectedSs1CompositionFileFormat {file_path: PathBuf},
    FailedToOpenFile {file_path: PathBuf},
    FailedToParseFileFormat {file_path: PathBuf},
}

impl std::fmt::Display for SS1FreeformSuiteError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SS1FreeformSuiteError::ExpectedSs1DrawingFileFormat {file_path} => {
                write!(f, "Expected SS1 Drawing File Format {file_path:?}")
            }
            SS1FreeformSuiteError::ExpectedSs1CompositionFileFormat {file_path} => {
                write!(f, "Expected SS1 Composition File Format {file_path:?}")
            }
            SS1FreeformSuiteError::FailedToOpenFile { file_path } => {
                write!(f, "Failed to open file {file_path:?}")
            }
            SS1FreeformSuiteError::FailedToParseFileFormat { file_path } => {
                write!(f, "Failed to parse file format for {file_path:?}")
            }
        }
    }
}

// pub fn parse_file<P: AsRef<Path>>(file_path: P) {

// }

// /// Compiles into a vec of SVG(s).
// pub fn compile<P: AsRef<Path>>(file_path: P) -> Result<Vec<String>, String> {
//     // parse_file(file_path).map(|x| x.canvas.to_svgs())
//     unimplemented!()
// }

pub fn dev() {
    // let result = SS1FreeformSuite::parse_ss1_drawing_file("test/Untitled.ss1-drawing");
    let result = SS1FreeformSuite::parse_ss1_composition_file("test/Untitled.ss1-composition");
    println!("{result:#?}");
}
