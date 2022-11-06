use itertools::Itertools;
use uuid::Uuid;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use serde::de::{self, Visitor};
use crate::data::c_ffi_utils::Pointer;

#[derive(Debug, Clone, Serialize, Deserialize)]
struct PageModel {
    id: Uuid,
    entries: Vec<PageEntryModel>,
}

impl PageModel {
    fn to_rust_data_model(self) -> super::Page {
        let entries = self.entries
            .into_iter()
            .map(PageEntryModel::to_rust_data_model)
            .collect_vec();
        super::Page {id: self.id, entries}
    }
}


#[derive(Debug, Clone, Serialize, Deserialize)]
struct PageEntryModel {
    id: Uuid,
    r#type: EntryType,
    heading: Heading,
    drawings: Vec<CanvasModel>,
}

impl PageEntryModel {
    fn to_rust_data_model(self) -> super::PageEntry {
        let payload = match self.r#type {
            EntryType::Heading => super::PageEntryPayload::Heading(self.heading.to_rust_data_model()),
            EntryType::Drawing => {
                let drawings = self.drawings
                    .into_iter()
                    .map(CanvasModel::to_rust_data_model)
                    .collect_vec();
                super::PageEntryPayload::Freeform(drawings)
            },
        };
        super::PageEntry {id: self.id, payload}
    }
}


#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
enum EntryType {
    Heading,
    Drawing,
}

impl EntryType {
    fn to_rust_data_model(self) -> super::PageEntryPayloadKind {
        match self {
            EntryType::Heading => super::PageEntryPayloadKind::Heading,
            EntryType::Drawing => super::PageEntryPayloadKind::Drawing,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Heading {
    r#type: HeadingType,
    text: String,
}

impl Heading {
    fn to_rust_data_model(self) -> super::Heading {
        super::Heading {level: self.r#type.to_rust_data_model(), text: self.text}
    }
}


#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
enum HeadingType {H1, H2, H3, H4, H5, H6}

impl HeadingType {
    fn to_rust_data_model(self) -> super::HeadingLevel {
        match self {
            HeadingType::H1 => super::HeadingLevel::H1,
            HeadingType::H2 => super::HeadingLevel::H2,
            HeadingType::H3 => super::HeadingLevel::H3,
            HeadingType::H4 => super::HeadingLevel::H4,
            HeadingType::H5 => super::HeadingLevel::H5,
            HeadingType::H6 => super::HeadingLevel::H6,
        }
    }
}

type RootScenePointer = Pointer<crate::data::drawing::RootScene>;

#[derive(Debug, Clone, Serialize, Deserialize)]
struct CanvasModel {
    id: Uuid,
    height: f32,
    visible: bool,
    pointer: RootScenePointer,
}

impl CanvasModel {
    fn to_rust_data_model(self) -> super::FreeformCanvas {
        super::FreeformCanvas {
            id: self.id,
            height: self.height,
            visible: self.visible,
            scene: self.pointer.into_cloned().into_root_scene_archive(),
        }
    }
}

pub(super) fn from_serialized_swift_data_model(bytes: &[u8]) -> serde_json::Result<super::Page> {
    serde_json::from_slice::<PageModel>(bytes).map(PageModel::to_rust_data_model)
}




