use std::fmt::Debug;
use uuid::Uuid;
use itertools::Itertools;
use serde::{Serializer, Deserializer, Serialize, Deserialize};


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize)]
#[repr(C)]
pub enum Layer {
    Foreground,
    Background,
}

impl Default for Layer {
    fn default() -> Self {
        Layer::Foreground
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COLOR SCHEME TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, PartialEq, Eq)]
#[repr(C)]
pub enum ColorScheme {
    Dark,
    Light,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[repr(C)]
pub struct ColorModes<T> {
    pub dark_ui: T,
    pub light_ui: T,
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COLOR TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


pub type DualColors = ColorModes<Color>;

/// Because I didn’t want to figure out how to convert
/// HSBA to RGB using Apple’s color ranges.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[repr(C)]
#[no_mangle]
pub struct Color {
    hsba: HSBA,
    rgba: RGBA,
}

impl Color {
    /// Because I didn’t want to figure out how to convert
    /// HSBA to RGB using Apple’s color ranges.
    pub fn new_pair(hsba: HSBA, rgba: RGBA) -> Self {
        Color{hsba, rgba}
    }
    pub fn hsba(&self) -> HSBA {
        self.hsba
    }
    pub fn rgba(&self) -> RGBA {
        self.rgba
    }
    pub fn white() -> Self {
        Color {
            hsba: HSBA {
                hue: 0.0,
                saturation: 0.0,
                brightness: 1.0,
                alpha: 1.0,
            },
            rgba: RGBA {
                red: 1.0,
                green: 1.0,
                blue: 1.0,
                alpha: 1.0,
            }
        }
    }
    pub fn black() -> Self {
        Color {
            hsba: HSBA {
                hue: 0.0,
                saturation: 0.0,
                brightness: 1.0,
                alpha: 1.0,
            },
            rgba: RGBA {
                red: 0.0,
                green: 0.0,
                blue: 0.0,
                alpha: 1.0,
            }
        }
    }
}


#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[repr(C)]
pub struct HSBA {
    pub hue: f64,
    pub saturation: f64,
    pub brightness: f64,
    pub alpha: f64,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[repr(C)]
pub struct RGBA {
    pub red: f64,
    pub green: f64,
    pub blue: f64,
    pub alpha: f64,
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// DEVICE INPUT TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize)]
#[repr(C)]
pub struct SamplePoint {
    pub point: [f64; 2],
    pub force: f64,
    pub has_force: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SamplePoints(pub Vec<SamplePoint>);

impl Default for SamplePoints {
    fn default() -> Self {SamplePoints(Default::default())}
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// STD TRAITS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Default for ColorScheme {
    fn default() -> Self {
        ColorScheme::Light
    }
}
impl Default for DualColors {
    fn default() -> Self {
        DualColors {
            dark_ui: Color::white(),
            light_ui: Color::black(),
        }
    }
}
