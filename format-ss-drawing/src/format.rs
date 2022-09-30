use serde::{Serializer, Deserializer, Serialize, Deserialize};
use super::stroke_points::vector_outline_points;

pub mod stroke {
    use super::*;

    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct Color {
        pub red: f64,
        pub green: f64,
        pub blue: f64,
        pub alpha: f64,
    }

    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct Stroke {
        pub uid: String,
        pub options: StrokeOptions,
        pub samples: Vec<StrokeSample>
    }

    impl Stroke {
        pub fn to_svg_path(&self) -> String {
            let path_points = vector_outline_points(self.clone())
                .into_iter()
                .enumerate()
                .map(|(ix, [x, y])| {
                    let x = x.round();
                    let y = y.round();
                    if ix == 0 {
                        format!("M {} {}", x, y)
                    } else {
                        format!("L {} {}", x, y)
                    }
                })
                .collect::<Vec<_>>()
                .join(" ");
            let Color{red, blue, green, alpha} = self.options.color;
            let scale = crate::utils::new_linear_scale((0.0, 1.0), (0.0, 255.0));
            let red = scale(red).round();
            let blue = scale(blue).round();
            let green = scale(green).round();
            let alpha = scale(alpha).round();
            let fill_attr = format!("fill=\"rgba({}, {}, {}, {})\"", red, green, blue, alpha);
            let path_attr = format!("d=\"{}\"", path_points);
            format!("<path {} {} />", fill_attr, path_attr)
        }
    }
    
    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct StrokeOptions {
        pub color: Color,
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


#[derive(Debug, Clone, Serialize, Deserialize)]
// #[serde(rename_all = "PascalCase")]
#[serde(rename_all = "camelCase")]

pub struct FileDataModel {
    pub canvas: CanvasDataModel,
}


#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CanvasDataModel {
    pub entries: Vec<DrawingDataModel>
}

impl CanvasDataModel {
    pub fn to_svgs(&self) -> Vec<String> {
        self.entries
            .iter()
            .map(DrawingDataModel::to_svg)
            .collect::<Vec<_>>()
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct DrawingDataModel {
    pub strokes: Vec<stroke::Stroke>,
    pub height: f64,
}

impl DrawingDataModel {
    pub fn to_svg(&self) -> String {
        let mut xs: Vec<f64> = Vec::new();
        let mut ys: Vec<f64> = Vec::new();
        let stroke_paths = self.strokes
            .iter()
            .map(|stroke| {
                for sample in stroke.samples.iter() {
                    xs.push(sample.point[0]);
                    ys.push(sample.point[1]);
                }
                stroke
            })
            .map(stroke::Stroke::to_svg_path)
            .collect::<String>();
        let min_x = xs.iter().copied().fold(f64::NAN, f64::min).round();
        let max_x = xs.iter().copied().fold(f64::NAN, f64::max).round();
        let min_y = ys.iter().copied().fold(f64::NAN, f64::min).round();
        let max_y = ys.iter().copied().fold(f64::NAN, f64::max).round();
        let style_attr = format!("style=\"max-width: {}px;\"", max_x);
        let view_box_attr = format!(
            "viewBox=\"{} {} {} {}\"",
            min_x,
            min_y,
            max_x,
            max_y,
        );
        let attrs = format!(
            "xmlns=\"http://www.w3.org/2000/svg\" {} {}",
            style_attr,
            view_box_attr
        );
        format!(
            "<svg {}>{}</svg>",
            attrs,
            stroke_paths
        )
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
