#![allow(unused)]
use poem::{handler, listener::TcpListener, post, get, web::Json, Route, Server, web::Path};
use serde::{Serialize, Deserialize};
use wax::{Glob, Pattern};
use std::{collections::{HashSet, BTreeSet, BTreeMap, VecDeque}, path::PathBuf, fmt::format, str::FromStr};


#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
enum File {
    Folder{
        name: String,
        path: PathBuf,
    },
    File{
        name: String,
        path: PathBuf,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
enum ListResult {
    Success {files: Vec<File>},
    Error,
}

#[handler]
async fn topics_root() -> Json<serde_json::Value> {
    let topics_path = "example-project/topics";
    let files = std::fs::read_dir(topics_path)
        .unwrap()
        .filter_map(Result::ok)
        .map(|x| { x.path()})
        .map(|x| {
            let name = x.file_name().unwrap().to_str().unwrap().to_owned();
            let path = x.strip_prefix(topics_path).unwrap().to_owned();
            if x.is_dir() {
                File::Folder {name, path}
            } else {
                File::File {name, path}
            }
        })
        .collect::<Vec<_>>();
    Json(serde_json::json!(ListResult::Success { files: files }))
}

#[handler]
async fn topics_ls(path: Path<String>) -> Json<serde_json::Value> {
    let topics_path = "example-project/topics";
    let folder_path = format!("{}/{}", topics_path, path.as_str());
    if let Ok(files) = std::fs::read_dir(&folder_path) {
        let files = files
            .filter_map(Result::ok)
            .map(|x| { x.path()})
            .map(|x| {
                let name = x.file_name().unwrap().to_str().unwrap().to_owned();
                let path = x.strip_prefix(&topics_path).unwrap().to_owned();
                if x.is_dir() {
                    File::Folder {name, path}
                } else {
                    File::File {name, path}
                }
            })
            .collect::<Vec<_>>();
        Json(serde_json::json!(ListResult::Success { files: files }))
    } else {
        Json(serde_json::json!(ListResult::Error))
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
enum SaveFileResult {
    Success,
    Error,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
#[serde(rename_all = "camelCase")]
struct SaveDrawingRequest {
    path: String,
    canvas: subscript_project::freehand::format::CanvasDataModel,
}

#[handler]
async fn save_drawing(req: Json<SaveDrawingRequest>) -> Json<serde_json::Value> {
    let mut resource_path = PathBuf::from_str("example-project/topics").unwrap();
    let mut origional = PathBuf::from_str("example-project/topics").unwrap();
    resource_path.push(req.path.clone());
    if resource_path == origional {
        return Json(serde_json::json!(SaveFileResult::Error))
    }
    println!("PATH: {:?}", resource_path);
    if let Some(parent) =  resource_path.parent() {
        std::fs::create_dir_all(parent);
    }
    let file_data = rmp_serde::encode::to_vec(&req.canvas).unwrap();
    std::fs::write(&resource_path, file_data).unwrap();

    Json(serde_json::json!(SaveFileResult::Success))
}


#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
#[serde(rename_all = "camelCase")]
enum ReadFileResult {
    Success {canvas: subscript_project::freehand::format::CanvasDataModel},
    Error,
}

#[handler]
async fn open_drawing(path: Path<String>) -> Json<serde_json::Value> {
    use subscript_project::freehand::format::CanvasDataModel;
    let topics_path = "example-project/topics";
    let file_path = format!("{}/{}", topics_path, path.as_str());
    if !file_path.ends_with("ss-drawing") {
        return Json(serde_json::json!(ReadFileResult::Error))
    }
    if let Ok(file) = std::fs::read(&file_path) {
        let contents = rmp_serde::decode::from_slice::<CanvasDataModel>(&file).unwrap();
        Json(serde_json::json!(ReadFileResult::Success{canvas: contents}))
    } else {
        Json(serde_json::json!(ReadFileResult::Error))
    }
}


pub async fn run_server() -> Result<(), std::io::Error> {
    let debug = true;
    if std::env::var_os("RUST_LOG").is_none() || debug {
        std::env::set_var("RUST_LOG", "poem=debug");
    }
    tracing_subscriber::fmt::init();
    let app = Route::new()
        .at("/ls/topics", get(topics_root))
        .at("/ls/topics/*path", get(topics_ls))
        .at("/save/topics", post(save_drawing))
        .at("/open/topics/*path", get(open_drawing));
    Server::new(TcpListener::bind("10.16.230.144:3030"))
        .run(app)
        .await
}

#[tokio::main]
pub async fn main() -> Result<(), std::io::Error> {
    run_server().await
}