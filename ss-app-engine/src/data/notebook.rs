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

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PageEntry {
    pub id: Uuid,
    pub payload: PageEntryPayload,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum PageEntryPayload {
    Heading(Heading),
    Drawings(Vec<Drawing>),
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
pub struct Drawing {
    pub id: Uuid,
    pub height: f32,
    pub visible: bool,
    pub scene: RootSceneArchive,
}

pub fn from_serialized_swift_data_model(bytes: &[u8]) -> serde_json::Result<Page> {
    swift_data_model::from_serialized_swift_data_model(bytes)
}



