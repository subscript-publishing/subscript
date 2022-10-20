use uuid::Uuid;
use itertools::Itertools;
use serde::{Serializer, Deserializer, Serialize, Deserialize};

#[derive(Debug, Clone)]
pub enum ColorScheme {
    Dark,
    Light,
}
#[derive(Debug, Clone)]
pub struct ColorModes<T> {
    pub dark_ui: T,
    pub light_ui: T,
}

