use std::fmt::Debug;

use itertools::Itertools;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use self::stroke::StrokeSample;

use super::stroke_points::vector_outline_points;

#[derive(Debug, Clone)]
pub enum ColorScheme {
    Dark,
    Light,
}

#[derive(Debug, Clone)]
pub struct ColorModes<T> {
    dark_ui: T,
    light_ui: T,
}

pub mod stroke {
    use super::*;

    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct Stroke {
        pub uid: String,
        pub options: StrokeOptions,
        pub samples: Vec<StrokeSample>
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct OutlinedStroke {
        pub points: Vec<(f64, f64)>,
        pub color: ColorMap,
    }
    impl OutlinedStroke {
        pub fn to_svg_path(self, for_color_scheme: &ColorScheme) -> String {
            let path_points = self.points
                .into_iter()
                .enumerate()
                .map(|(ix, (x, y))| {
                    if ix == 0 {
                        format!("M {} {}", x, y)
                    } else {
                        format!("L {} {}", x, y)
                    }
                })
                .collect_vec()
                .join(" ");
            let rgba_css_color = {
                match for_color_scheme {
                    ColorScheme::Dark => {
                        self.color.dark_ui_mode.to_svg_rgba_color()
                    }
                    ColorScheme::Light => {
                        self.color.light_ui_mode.to_svg_rgba_color()
                    }
                }
            };
            let fill_attr = format!("fill=\"{rgba_css_color}\"");
            let path_attr = format!("d=\"{}Z\"", path_points);
            format!("<path {fill_attr} {path_attr} />")
        }
    }
    impl Stroke {
        pub fn to_points(&self) -> Vec<(f64, f64)> {
            vector_outline_points(self.clone())
                .into_iter()
                .map(|[x, y]| (x, y))
                .collect_vec()
        }
        pub fn to_outlined_stroke(&self) -> OutlinedStroke {
            let points = vector_outline_points(self.clone())
                .into_iter()
                .map(|[x, y]| (x, y))
                .collect_vec();
            OutlinedStroke{
                points,
                color: self.options.color.clone(),
            }
        }
        pub fn to_svg_path(
            &self,
            for_color_scheme: &ColorScheme,
            mut f: impl FnMut(f64, f64) -> ()
        ) -> String {
            let path_points = vector_outline_points(self.clone())
                .into_iter()
                .enumerate()
                .map(|(ix, [x, y])| {
                    let x = x;
                    let y = y;
                    f(x, y);
                    if ix == 0 {
                        format!("M {} {}", x, y)
                    } else {
                        format!("L {} {}", x, y)
                    }
                })
                .collect_vec()
                .join(" ");
            let rgba_css_color = {
                match for_color_scheme {
                    ColorScheme::Dark => {
                        self.options.color.dark_ui_mode.to_svg_rgba_color()
                    }
                    ColorScheme::Light => {
                        self.options.color.light_ui_mode.to_svg_rgba_color()
                    }
                }
            };
            let fill_attr = format!("fill=\"{rgba_css_color}\"");
            let path_attr = format!("d=\"{}Z\"", path_points);
            format!("<path {fill_attr} {path_attr} />")
        }
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct Color {
        pub red: f64,
        pub green: f64,
        pub blue: f64,
        pub alpha: f64,
    }
    impl Color {
        fn to_svg_rgba_color(&self) -> String {
            let Color{red, blue, green, alpha} = self;
            let scale = crate::utils::new_linear_scale((0.0, 1.0), (0.0, 255.0));
            let red = scale(*red).round();
            let green = scale(*green).round();
            let blue = scale(*blue).round();
            let alpha = scale(*alpha).round();
            format!("rgba({red}, {green}, {blue}, {alpha})")
        }
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct ColorMap {
        #[serde(alias = "lightUIMode")]
        light_ui_mode: Color,
        #[serde(alias = "darkUIMode")]
        dark_ui_mode: Color
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
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
    #[serde(rename_all = "camelCase")]
    pub struct StrokeSample {
        pub point: [f64; 2],
        pub pressure: f64,
    }
    #[derive(Debug, Clone, Copy, Serialize, Deserialize)]
    pub enum Easing {
        #[serde(rename = "linear")]
        Linear,
        #[serde(rename = "easeInQuad")]
        EaseInQuad,
        #[serde(rename = "easeOutQuad")]
        EaseOutQuad,
        #[serde(rename = "easeInOutQuad")]
        EaseInOutQuad,
        #[serde(rename = "easeInCubic")]
        EaseInCubic,
        #[serde(rename = "easeOutCubic")]
        EaseOutCubic,
        #[serde(rename = "easeInOutCubic")]
        EaseInOutCubic,
        #[serde(rename = "easeInQuart")]
        EaseInQuart,
        #[serde(rename = "easeOutQuart")]
        EaseOutQuart,
        #[serde(rename = "easeInOutQuart")]
        EaseInOutQuart,
        #[serde(rename = "easeInQuint")]
        EaseInQuint,
        #[serde(rename = "easeOutQuint")]
        EaseOutQuint,
        #[serde(rename = "easeInOutQuint")]
        EaseInOutQuint,
        #[serde(rename = "easeInSine")]
        EaseInSine,
        #[serde(rename = "easeOutSine")]
        EaseOutSine,
        #[serde(rename = "easeInOutSine")]
        EaseInOutSine,
        #[serde(rename = "easeInExpo")]
        EaseInExpo,
        #[serde(rename = "easeOutExpo")]
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
        #[serde(rename = "foreground")]
        Foreground,
        #[serde(rename = "background")]
        Background,
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct StartCap {
        pub cap: bool,
        pub taper: f64,
        pub easing: Easing,
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct EndCap {
        pub cap: bool,
        pub taper: f64,
        pub easing: Easing,
    }
}


pub mod canvas_data_model {
    use std::path::Path;

    use super::*;
    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct CanvasDataModel {
        pub entries: Vec<DrawingDataModel>
    }
    impl CanvasDataModel {
        pub fn parse_file<T: AsRef<Path>>(file_path: T) -> Result<Self, crate::api::SS1FreeformSuiteError> {
            if !crate::api::SS1FreeformSuite::is_ss1_drawing_file(file_path.as_ref()) {
                return Err(crate::api::SS1FreeformSuiteError::ExpectedSs1DrawingFileFormat {
                    file_path: file_path.as_ref().to_path_buf()
                })
            }
            let payload = std::fs::read(file_path.as_ref())
                .map_err(|_| {
                    crate::api::SS1FreeformSuiteError::FailedToOpenFile {
                        file_path: file_path.as_ref().to_path_buf()
                    }
                })?;
            // For some reason I’m unable to this into a `CanvasDataModel` directly, 
            // but it works if I parse this as a `serde_json::Value` type and then use
            // `serde_json` to parse into a `CanvasDataModel`.
            let payload = plist::from_bytes::<serde_json::Value>(&payload)
                .map_err(|_| {
                    crate::api::SS1FreeformSuiteError::FailedToParseFileFormat {
                        file_path: file_path.as_ref().to_path_buf()
                    }
                })?;
            let payload = serde_json::from_value::<CanvasDataModel>(payload)
                .map_err(|e| {
                    crate::api::SS1FreeformSuiteError::FailedToParseFileFormat {
                        file_path: file_path.as_ref().to_path_buf()
                    }
                })?;
            Ok(payload)
        }
    }
    #[derive(Clone, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct DrawingDataModel {
        pub foreground_strokes: Vec<stroke::Stroke>,
        pub background_strokes: Vec<stroke::Stroke>,
        pub height: f64,
    }
    impl DrawingDataModel {
        pub fn to_svg(&self, for_color_scheme: &ColorScheme) -> String {
            let mut xs: Vec<f64> = Vec::new();
            let mut ys: Vec<f64> = Vec::new();
            let mut outlines_foreground_strokes = self.foreground_strokes
                .iter()
                .map(stroke::Stroke::to_outlined_stroke)
                .collect_vec();
            let mut outlines_background_strokes = self.background_strokes
                .iter()
                .map(stroke::Stroke::to_outlined_stroke)
                .collect_vec();
            for stroke in outlines_foreground_strokes.iter().chain(outlines_background_strokes.iter()) {
                xs.extend(stroke.points.iter().map(|(x,_)| *x));
                ys.extend(stroke.points.iter().map(|(_,y)| *y));
            }
            let min_x = xs.iter().copied().fold(f64::NAN, f64::min);
            let max_x = xs.iter().copied().fold(f64::NAN, f64::max);
            let min_y = ys.iter().copied().fold(f64::NAN, f64::min);
            let max_y = ys.iter().copied().fold(f64::NAN, f64::max);
            let is_valid = |x: f64| {x.is_normal() && x > 0.0};
            let max_point_range = 1000.0;
            if is_valid(min_x) && is_valid(max_x) && is_valid(min_y) && is_valid(min_y) {
                let x_scale = crate::utils::new_linear_scale(
                    ((min_x, max_x)),
                    ((0.0, max_point_range)),
                );
                let y_scale = crate::utils::new_linear_scale(
                    ((min_y, max_y)),
                    ((0.0, max_point_range)),
                );
                let for_each = |mut outline_stroke: stroke::OutlinedStroke| {
                    outline_stroke.points = outline_stroke.points
                        .into_iter()
                        .map(|(x, y)| {
                            (x_scale(x), y_scale(y))
                        })
                        .collect_vec();
                    outline_stroke
                };
                outlines_foreground_strokes = outlines_foreground_strokes
                    .into_iter()
                    .map(for_each)
                    .collect_vec();
                outlines_background_strokes = outlines_background_strokes
                    .into_iter()
                    .map(for_each)
                    .collect_vec();
            }
            let mut paths = outlines_background_strokes
                .into_iter()
                .chain(outlines_foreground_strokes.into_iter())
                .map(|outline_stroke| {
                    outline_stroke.to_svg_path(for_color_scheme)
                })
                .collect::<String>();
            let attrs: Vec<(String, String)> = vec![
                (String::from("viewBox"), format!("0 0 {max_point_range} {max_point_range}")),
                (String::from("xmlns"), String::from("http://www.w3.org/2000/svg")),
                (String::from("xmlns:xlink"), String::from("http://www.w3.org/1999/xlink")),
                (String::from("preserveAspectRatio"), String::from("meet")),
                // For CSS selectors that toggle the display of a an SVG in
                // accordance with the browsers color scheme preference. 
                (String::from("data-svg-color-scheme"), match for_color_scheme {
                    ColorScheme::Dark => format!("dark-mode"),
                    ColorScheme::Light => format!("light-mode"),
                }),
            ];
            let attrs = attrs
                .into_iter()
                .map(|(k, v)| format!("{k}=\"{v}\""))
                .collect_vec()
                .join(" ");
            format!(
                "<svg {attrs}>{paths}</svg>",
            )
        }
        pub fn to_pdf(&self, for_color_scheme: &ColorScheme) -> Vec<u8> {
            let svg = self.to_svg(for_color_scheme);
            let pdf = svg2pdf::convert_str(&svg, svg2pdf::Options::default()).unwrap();
            pdf
        }
    }
    impl Debug for DrawingDataModel {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            write!(f, "DrawingDataModel(…)")
        }
    }
}



pub mod page_data_model {
    use std::path::Path;

    use super::*;
    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct PageDataModel {
        page_title: String,
        entries: Vec<PageEntry>,
    }
    impl PageDataModel {
        pub fn parse_file<T: AsRef<Path>>(file_path: T) -> Result<Self, crate::api::SS1FreeformSuiteError> {
            if !crate::api::SS1FreeformSuite::is_ss1_drawing_file(file_path.as_ref()) {
                return Err(crate::api::SS1FreeformSuiteError::ExpectedSs1DrawingFileFormat {
                    file_path: file_path.as_ref().to_path_buf()
                })
            }
            let payload = std::fs::read(file_path.as_ref())
                .map_err(|_| {
                    crate::api::SS1FreeformSuiteError::FailedToOpenFile {
                        file_path: file_path.as_ref().to_path_buf()
                    }
                })?;
            // For some reason I’m unable to this into a `PageDataModel` directly, 
            // but it works if I parse this as a `serde_json::Value` type and then use
            // `serde_json` to parse into a `PageDataModel`.
            let payload = plist::from_bytes::<serde_json::Value>(&payload)
                .map_err(|_| {
                    crate::api::SS1FreeformSuiteError::FailedToParseFileFormat {
                        file_path: file_path.as_ref().to_path_buf()
                    }
                })?;
            let payload = serde_json::from_value::<PageDataModel>(payload)
                .map_err(|e| {
                    crate::api::SS1FreeformSuiteError::FailedToParseFileFormat {
                        file_path: file_path.as_ref().to_path_buf()
                    }
                })?;
            Ok(payload)
        }
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct PageEntry {
        r#type: PageEntryType,
        title: Title,
        drawing: canvas_data_model::CanvasDataModel,
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub enum PageEntryType {
        #[serde(alias = "title")]
        Title,
        #[serde(alias = "drawing")]
        Drawing,
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct Title {
        r#type: HeadingType,
        text: String,
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub enum HeadingType {
        #[serde(alias = "h1")]
        H1,
        #[serde(alias = "h2")]
        H2,
        #[serde(alias = "h3")]
        H3,
        #[serde(alias = "h4")]
        H4,
        #[serde(alias = "h5")]
        H5,
        #[serde(alias = "h6")]
        H6,
    }
}


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
