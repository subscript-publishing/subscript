use std::fmt::Debug;
use uuid::Uuid;
use itertools::Itertools;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use self::stroke::StrokeSample;

pub struct Datum<'a, T> {
    namespace: String,
    value: &'a T,
}

pub trait ToDatum {
    
}

pub mod stroke {
    use super::*;
    #[derive(Debug, Clone)]
    pub enum Operation {
        Stroke(Stroke),
        Erase(Stroke),
    }
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
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct Stroke {
        pub uid: Uuid,
        pub options: StrokeOptions,
        pub samples: Vec<StrokeSample>
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct OutlinedStroke {
        pub points: Vec<(f64, f64)>,
        pub color: ColorMap,
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct Color {
        pub red: f64,
        pub green: f64,
        pub blue: f64,
        pub alpha: f64,
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct ColorMap {
        #[serde(alias = "lightUIMode")]
        light_ui_mode: Color,
        #[serde(alias = "darkUIMode")]
        dark_ui_mode: Color
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct StrokeOptions {
        pub color: ColorMap,
        /// The base size (diameter) of the stroke.
        pub size: f64,
        /// The effect of pressure on the stroke's size.
        pub thinning: f64,
        /// How much to soften the stroke's edges.
        pub smoothing: f64,
        /// TODO
        pub streamline: f64,
        /// An easing function to apply to each point's pressure.
        pub easing: Easing,
        /// Whether to simulate pressure based on velocity.
        pub simulate_pressure: bool,
        /// Cap, taper and easing for the start of the line.
        pub start: StartCap,
        /// Cap, taper and easing for the end of the line.
        pub end: EndCap,
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct StrokeSample {
        pub point: [f64; 2],
        pub pressure: f64,
    }
    #[derive(Debug, Clone, Copy, Serialize, Deserialize)]
    pub enum Easing {
        Linear,
        EaseInQuad,
        EaseOutQuad,
        EaseInOutQuad,
        EaseInCubic,
        EaseOutCubic,
        EaseInOutCubic,
        EaseInQuart,
        EaseOutQuart,
        EaseInOutQuart,
        EaseInQuint,
        EaseOutQuint,
        EaseInOutQuint,
        EaseInSine,
        EaseOutSine,
        EaseInOutSine,
        EaseInExpo,
        EaseOutExpo,
    }
    impl Easing {
        fn linear(t: f64) -> f64 {t}
        fn ease_in_quad(t: f64) -> f64 {t * t}
        fn ease_out_quad(t: f64) -> f64 {t * (2. - t)}
        fn ease_in_out_quad(t: f64) -> f64 {
            (if t < 0.5 {2.0 * t * t} else {-1. + (4. - 2. * t) * t})
        }
        fn ease_in_cubic(t: f64) -> f64 {t * t * t}
        fn ease_out_cubic(t: f64) -> f64 {(t - 1.) * t * t + 1.0}
        fn ease_in_out_cubic(t: f64) -> f64 {
            if t < 0.5 {4.0 * t * t * t} else {(t - 1.0) * (2.0 * t - 2.0) * (2.0 * t - 2.0) + 1.0}
        }
        fn ease_in_quart(t: f64) -> f64 {t * t * t * t}
        fn ease_out_quart(t: f64) -> f64 {1.0 - (t - 1.0) * t * t * t}
        fn ease_in_out_quart(t: f64) -> f64 {
            if t < 0.5 {8.0 * t * t * t * t} else {1.0 - 8.0 * (t - 1.0) * t * t * t}
        }
        fn ease_in_quint(t: f64) -> f64 {t * t * t * t * t}
        fn ease_out_quint(t: f64) -> f64 {1.0 + (t - 1.0) * t * t * t * t}
        fn ease_in_out_quint(t: f64) -> f64 {
            if t < 0.5 {16.0 * t * t * t * t * t} else {1.0 + 16.0 * (t - 1.0) * t * t * t * t}
        }
        fn ease_in_sine(t: f64) -> f64 {1.0 - f64::cos((t * std::f64::consts::PI) / 2.0)}
        fn ease_out_sine(t: f64) -> f64 {f64::sin((t * std::f64::consts::PI) / 2.0)}
        fn ease_in_out_sine(t: f64) -> f64 {-(f64::cos(std::f64::consts::PI * t) - 1.0) / 2.0}
        fn ease_in_expo(t: f64) -> f64 {if t <= 0.0 {0.0} else {f64::powf(2.0, 10.0 * t - 10.0)}}
        fn ease_out_expo(t: f64) -> f64 {if t >= 1.0 {1.0} else {1.0 - f64::powf(2.0, -10.0 * t)}}
        pub fn to_function(self) -> fn(f64) -> f64 {
            match self {
                Easing::Linear => Easing::linear,
                Easing::EaseInQuad => Easing::ease_in_quad,
                Easing::EaseOutQuad => Easing::ease_out_quad,
                Easing::EaseInOutQuad => Easing::ease_in_out_quad,
                Easing::EaseInCubic => Easing::ease_in_cubic,
                Easing::EaseOutCubic => Easing::ease_out_cubic,
                Easing::EaseInOutCubic => Easing::ease_in_out_cubic,
                Easing::EaseInQuart => Easing::ease_in_quart,
                Easing::EaseOutQuart => Easing::ease_out_quart,
                Easing::EaseInOutQuart => Easing::ease_in_out_quart,
                Easing::EaseInQuint => Easing::ease_in_quint,
                Easing::EaseOutQuint => Easing::ease_out_quint,
                Easing::EaseInOutQuint => Easing::ease_in_out_quint,
                Easing::EaseInSine => Easing::ease_in_sine,
                Easing::EaseOutSine => Easing::ease_out_sine,
                Easing::EaseInOutSine => Easing::ease_in_out_sine,
                Easing::EaseInExpo => Easing::ease_in_expo,
                Easing::EaseOutExpo => Easing::ease_out_expo,
            }
        }
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub enum Layer {
        Foreground,
        Background,
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct StartCap {
        pub cap: bool,
        pub taper: f64,
        pub easing: Easing,
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct EndCap {
        pub cap: bool,
        pub taper: f64,
        pub easing: Easing,
    }
}

use super::*;
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Canvas {
    pub id: String,
    pub entries: Vec<CanvasEntry>
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CanvasEntry {
    pub foreground_strokes: Vec<stroke::Stroke>,
    pub background_strokes: Vec<stroke::Stroke>,
    pub height: f64,
    pub visible: bool,
}
const fn const_true() -> bool {true}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Page {
    pub page_title: String,
    pub entries: Vec<PageEntry>,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PageEntry {
    pub page_entry_type: PageEntryType,
    pub title: Title,
    pub drawing: Canvas,
}
impl PageEntry {
    pub fn is_title(&self) -> bool {
        match self.page_entry_type {
            PageEntryType::Title => true,
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
    Title,
    Drawing,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Title {
    pub heading_type: HeadingType,
    pub text: String,
}
impl Title {
    pub fn new_h1<T: Into<String>>(text: T) -> Self {
        Title{
            heading_type: HeadingType::H1,
            text: text.into(),
        }
    }
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum HeadingType {H1, H2, H3, H4, H5, H6}


pub fn dev() {
    // let file_path = "/Users/colbyn/Library/Containers/com.colbyn.SubscriptTablet/Data/Documents/data.json";
    // let contents = std::fs::read_to_string(file_path).unwrap();
    // let contents = serde_json::from_str::<CanvasDataModel>(&contents).unwrap();
    // let html = contents.to_html();
    // let html = format!("<!DOCTYPE html><html><head></head><body>{}</body></html>", html);
    // std::fs::write("test.html", html).unwrap();
    // println!("{:#?}", contents);
    // let res = serde_json::to_string(&stroke::Easing::Linear);
    // println!("{:?}", res);
    // let res = serde_json::from_str::<stroke::Easing>(&res.unwrap());
    // println!("{:?}", res);
}
