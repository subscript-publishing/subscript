use std::fmt::Debug;
use uuid::Uuid;
use itertools::Itertools;
use serde::{Serializer, Deserializer, Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Canvas {
    pub id: Uuid,
    // pub foreground_strokes: Vec<graphics::stroke::Stroke>,
    // pub background_strokes: Vec<graphics::stroke::Stroke>,
}


const fn const_true() -> bool {true}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Page {
    pub id: Uuid,
    pub page_title: String,
    pub entries: Vec<PageEntry>,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PageEntry {
    pub id: Uuid,
    pub page_entry_type: PageEntryType,
    pub heading: Heading,
    pub drawing: Canvas,
}
impl PageEntry {
    pub fn is_title(&self) -> bool {
        match self.page_entry_type {
            PageEntryType::Heading => true,
            _ => false
        }
    }
    pub fn is_drawing(&self) -> bool {
        match self.page_entry_type {
            PageEntryType::Drawing => true,
            _ => false
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum PageEntryType {
    Heading,
    Drawing,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Heading {
    pub heading_type: HeadingType,
    pub text: String,
}
impl Heading {
    pub fn new_h1<T: Into<String>>(text: T) -> Self {
        Heading{
            heading_type: HeadingType::H1,
            text: text.into(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum HeadingType {H1, H2, H3, H4, H5, H6}

