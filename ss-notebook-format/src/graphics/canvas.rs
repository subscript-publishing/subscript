use std::fmt::Debug;
use uuid::Uuid;
use itertools::Itertools;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use super::{basics::*, tools};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Cmd {
    Stroke(SamplePoints),
    Fill(SamplePoints),
    Transform(SamplePoints),
    Erase(SamplePoints),
}


