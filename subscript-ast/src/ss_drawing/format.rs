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
            let scale = crate::ss_drawing::utils::new_linear_scale((0.0, 1.0), (0.0, 255.0));
            let red = scale(*red).round();
            let green = scale(*green).round();
            let blue = scale(*blue).round();
            let alpha = scale(*alpha).round();
            format!("rgba({red}, {green}, {blue}, {alpha})")
        }
    }

    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct ColorMap {
        light_ui_mode: Color,
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
    use super::*;

    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct CanvasDataModel {
        pub entries: Vec<DrawingDataModel>
    }

    impl CanvasDataModel {
        // pub fn to_svgs(&self) -> Vec<String> {
        //     self.entries
        //         .iter()
        //         .map(|stroke| {

        //         })
        //         .collect::<Vec<_>>()
        // }
    }

    #[derive(Clone, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct DrawingDataModel {
        pub foreground_strokes: Vec<stroke::Stroke>,
        pub background_strokes: Vec<stroke::Stroke>,
        pub height: f64,
    }

    impl Debug for DrawingDataModel {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> swc_css_codegen::Result {
            f.debug_struct("DrawingDataModel").finish()
        }
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
            if is_valid(min_x) && is_valid(max_x) && is_valid(min_y) && is_valid(min_y) {
                let x_scale = crate::ss_drawing::utils::new_linear_scale(
                    ((min_x, max_x)),
                    ((0.0, 1000.0)),
                );
                let y_scale = crate::ss_drawing::utils::new_linear_scale(
                    ((min_y, max_y)),
                    ((0.0, 1000.0)),
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
            unimplemented!()
        }
        pub fn to_pdf(&self) -> Vec<u8> {
            // let svg = self.to_svg();
            // let pdf = svg2pdf::convert_str(&svg, svg2pdf::Options::default()).unwrap();
            // pdf
            unimplemented!()
        }
        // pub fn to_svg_old(&self) -> String {
        //     let mut xs: Vec<f64> = Vec::new();
        //     let mut ys: Vec<f64> = Vec::new();
        //     let strokes = self.strokes
        //         .clone()
        //         .into_iter()
        //         .map(|mut stroke| {
        //             let points = stroke.to_points();
        //             for (x, y) in points.iter() {
        //                 xs.push(*x);
        //                 ys.push(*y);
        //             }
        //             (stroke, points)
        //         })
        //         .collect_vec();
        //     let min_x = xs.iter().copied().fold(f64::NAN, f64::min);
        //     let max_x = xs.iter().copied().fold(f64::NAN, f64::max);
        //     let min_y = ys.iter().copied().fold(f64::NAN, f64::min);
        //     let max_y = ys.iter().copied().fold(f64::NAN, f64::max);
        //     let x_scale = crate::ss_drawing::utils::new_linear_scale(
        //         ((min_x, max_x)),
        //         ((0.0, 100.0)),
        //     );
        //     let y_scale = crate::ss_drawing::utils::new_linear_scale(
        //         ((min_y, max_y)),
        //         ((0.0, 100.0)),
        //     );
        //     let mut counter = 0;
        //     let strokes = strokes
        //         .into_iter()
        //         .map(|(stroke, points)| {
        //             let points = points
        //                 .into_iter()
        //                 .enumerate()
        //                 .map(|(ix, (x, y))| {
        //                     counter = counter + 1;
        //                     let x = x_scale(x);
        //                     let y = y_scale(y);
        //                     if ix == 0 {
        //                         return format!("M {x} {y}")
        //                     }
        //                     format!("L {x} {y}")
        //                 })
        //                 .collect_vec()
        //                 .join(" ");
        //             let stroke::Color{red, blue, green, alpha} = stroke.options.color;
        //             let scale = crate::ss_drawing::utils::new_linear_scale((0.0, 1.0), (0.0, 255.0));
        //             let red = scale(red).round();
        //             let blue = scale(blue).round();
        //             let green = scale(green).round();
        //             let alpha = scale(alpha).round();
        //             let fill_attr = format!("fill=\"rgba({}, {}, {}, {})\"", red, green, blue, alpha);
        //             format!("<path {fill_attr} d=\"{points}z\"/>")
        //         })
        //         .collect_vec()
        //         .join("\n");
        //     println!("POINTS {counter}");
        //     let view_box_attr = format!("viewBox=\"0 0 100 100\"");
        //     let attrs = format!(
        //         "xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" {view_box_attr}",
        //     );
        //     format!(
        //         "<svg preserveAspectRatio=\"meet\" {attrs}>{strokes}</svg>",
        //     )
        // }
    }
}



pub mod page_data_model {
    use super::*;

    #[derive(Debug, Clone)]
    pub struct PageDataModel {
        page_title: String,
        entries: Vec<PageEntry>,
    }

    #[derive(Debug, Clone)]
    pub struct PageEntry {
        r#type: EntryType,
        title: Title,
        drawing: canvas_data_model::CanvasDataModel,
    }

    #[derive(Debug, Clone)]
    pub enum EntryType {
        Title,
        Drawing,
    }

    #[derive(Debug, Clone)]
    pub struct Title {
        r#type: HeadingType,
        text: String,
    }

    #[derive(Debug, Clone)]
    pub enum HeadingType {
        H1,
        H2,
        H3,
        H4,
        H5,
        H6,
    }
}


// pub fn dev() {
//     let file_path = "/Users/colbyn/Library/Containers/com.colbyn.SubscriptTablet/Data/Documents/data.json";
//     let contents = std::fs::read_to_string(file_path).unwrap();
//     let contents = serde_json::from_str::<CanvasDataModel>(&contents).unwrap();
//     let html = contents.to_html();
//     let html = format!("<!DOCTYPE html><html><head></head><body>{}</body></html>", html);
//     std::fs::write("test.html", html).unwrap();
//     // println!("{:#?}", contents);
//     // let res = serde_json::to_string(&stroke::Easing::Linear);
//     // println!("{:?}", res);
//     // let res = serde_json::from_str::<stroke::Easing>(&res.unwrap());
//     // println!("{:?}", res);
// }
