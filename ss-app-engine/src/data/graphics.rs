use std::borrow::Cow;

use serde::{Serializer, Deserializer, Serialize, Deserialize};


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// GEOMETRY PRIMITIVES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[repr(C)]
pub struct Point {
    pub x: f32,
    pub y: f32,
}

#[derive(Debug, Clone, Copy)]
#[repr(C)]
pub struct Rect {
    pub min: Point,
    pub max: Point,
}

#[derive(Debug, Clone, Copy, PartialEq)]
#[repr(C)]
pub struct FrameSize {
    pub width: f32,
    pub height: f32,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// HEAP ALLOCATED GEOMETRY TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PointVec {
    pub(super) points: Vec<Point>,
}

#[derive(Debug, Clone)]
pub struct PointVecRef<'a> {
    pub(super) points: &'a [Point],
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// VISUAL EFFECT PRIMITIVES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
#[repr(C)]
pub enum CanvasPlacement {
    Foreground,
    Background,
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COLOR SCHEME PRIMITIVES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
#[repr(C)]
pub enum ColorSchemeType {
    Dark,
    Light,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[repr(C)]
/// All colors in SubScript are parameterized over the environment’s color scheme
/// preference, and these settings define the color of a given object for a given
/// light or dark color scheme preference.
pub struct DualColors {
    pub dark_ui: FatColor,
    pub light_ui: FatColor,
}


#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[repr(C)]
pub struct RgbaDualColors {
    pub dark_ui: RGBA,
    pub light_ui: RGBA,
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COLOR PRIMITIVES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

/// Ultimately, I’m aware that we redundantly record the same color twice (in
/// two different formats), perhaps over time I’ll move to only using one of
/// the two, and convert the other on-the-spot when it’s needed, but for now
/// this is easier (and I suppose this entails less runtime computation during
/// rendering). 
///
/// Anyway, **HSL(A) should be the default**:
/// - It’s much easier to use from the perspective of **generating light/dark UI
/// color variants**, because you can keep the hue the same and only tweak
/// brightness and saturation. 
///    * At the time of this writing, on IOS the default SwiftUI color picker
/// doesn’t support HSL(A), but theres a WIP hand made alternative, and over
/// time I’d like to support a high quality HSLA color pickers since as
/// previously mentioned, it’s much easier to use for creating light/dark
/// color variants. 
/// - We also record RGB(A) values as well which we use for places that only
/// support RGB(A) input. Also, maybe I’m just being paranoid here, but it
/// seems best if the RGB(A) values are always be derived from the original
/// HSL(A) color, not the other way around (unless we know that the algorithm
/// is lossless or where the loss is insignificant when compounded a multitude of times). 
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[repr(C)]
#[no_mangle]
pub struct FatColor {
    pub(super) hsba: HSBA,
    pub(super) rgba: RGBA,
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
// GEOMETRY + DEVICE INPUT METADATA
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[repr(C)]
pub struct SamplePoint {
    pub point: Point,
    pub force: Force,
}


#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[repr(C)]
pub struct Force {
    pub value: f32,
    pub ignore: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct RecordedStroke {
    pub sample_points: Vec<SamplePoint>,
}

#[derive(Debug, Clone)]
pub struct RecordedStrokeRef<'a> {
    pub sample_points: &'a [SamplePoint],
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// UI RUNTIME STATE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Copy)]
#[repr(C)]
pub struct ViewInfo {
    pub size: FrameSize,
    pub preferred_color_scheme: ColorSchemeType,
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TRANSFORMATIONS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Copy)]
pub struct LinearScale {
    pub domain: (f32, f32),
    pub range: (f32, f32),
}
