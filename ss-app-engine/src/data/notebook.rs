use uuid::Uuid;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use serde::de::{self, Visitor};
use crate::data::RootScene;
use crate::data::c_ffi_utils::Pointer;

use super::RootSceneArchive;

mod swift_data_model;


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Page {
    pub id: Uuid,
    pub entries: Vec<PageEntry>,
}

impl Page {
    pub fn new_sample() -> Self {
        let id = Uuid::new_v4();
        let entries = vec![
            PageEntry::new_h1("Top-Level Title"),
            PageEntry::new_h2("Subtitle"),
            PageEntry::new_h3("Hello Drawing"),
            PageEntry::new_drawing(),
        ];
        Page {id, entries}
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PageEntry {
    pub id: Uuid,
    pub payload: PageEntryPayload,
}

impl PageEntry {
    pub fn new_h1(title: impl AsRef<str>) -> Self {
        PageEntry::new_heading(HeadingLevel::H1, title)
    }
    pub fn new_h2(title: impl AsRef<str>) -> Self {
        PageEntry::new_heading(HeadingLevel::H2, title)
    }
    pub fn new_h3(title: impl AsRef<str>) -> Self {
        PageEntry::new_heading(HeadingLevel::H3, title)
    }
    pub fn new_h4(title: impl AsRef<str>) -> Self {
        PageEntry::new_heading(HeadingLevel::H4, title)
    }
    pub fn new_h5(title: impl AsRef<str>) -> Self {
        PageEntry::new_heading(HeadingLevel::H5, title)
    }
    pub fn new_h6(title: impl AsRef<str>) -> Self {
        PageEntry::new_heading(HeadingLevel::H6, title)
    }
    pub fn new_heading(level: HeadingLevel, title: impl AsRef<str>) -> Self {
        PageEntry{
            id: Uuid::new_v4(),
            payload: PageEntryPayload::Heading(Heading {
                level,
                text: title.as_ref().to_string(),
            })
        }
    }
    pub fn new_drawing() -> Self {
        PageEntry{
            id: Uuid::new_v4(),
            payload: PageEntryPayload::Freeform(vec![
                FreeformCanvas {
                    id: Uuid::new_v4(),
                    height: 400.0,
                    visible: true,
                    scene: RootSceneArchive::default(),
                }
            ])
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum PageEntryPayload {
    Heading(Heading),
    Freeform(Vec<FreeformCanvas>),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum PageEntryPayloadKind {
    Heading,
    Drawing,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Heading {
    pub level: HeadingLevel,
    pub text: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum HeadingLevel {H1, H2, H3, H4, H5, H6}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FreeformCanvas {
    pub id: Uuid,
    pub height: f32,
    pub visible: bool,
    pub scene: RootSceneArchive,
}

pub fn from_serialized_swift_data_model(bytes: &[u8]) -> serde_json::Result<Page> {
    swift_data_model::from_serialized_swift_data_model(bytes)
}



