use std::{fmt::Debug, cell::RefCell};
use uuid::Uuid;
use itertools::Itertools;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use super::basics::*;

pub mod perfect_freehand;


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// STROKE COMMAND
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StrokeCmd {
    pub uid: Uuid,
    pub stroke_style: StrokeStyle,
    pub device_input: SamplePoints,
    pub computed_outline: Option<ComputedPenOutline>,
}

impl StrokeCmd {
    pub fn compute_outline_if_missing(&mut self) {
        if self.computed_outline.is_none() {
            let points = perfect_freehand::vector_outline_points_for_stroke(self);
            self.computed_outline = Some(ComputedPenOutline {
                color: self.stroke_style.color.clone(),
                points,
            })
        }
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// STROKE COMMAND
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FillCmd {
    pub uid: Uuid,
    pub fill_style: FillStyle,
    pub device_input: SamplePoints,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[repr(C)]
pub struct FillStyle {
    pub color: DualColors,
    pub layer: Layer,
}

impl FillStyle {
    pub fn is_foreground(&self) -> bool {
        match self.layer {
            Layer::Foreground => true,
            _ => false,
        }
    }
    pub fn is_background(&self) -> bool {
        match self.layer {
            Layer::Background => true,
            _ => false,
        }
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COMPUTED PEN OUTLINE POINTS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ComputedPenOutline {
    pub color: DualColors,
    pub points: Vec<[f64; 2]>,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// PEN SETTINGS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize)]
#[repr(C)]
pub struct StrokeStyle {
    pub color: DualColors,
    pub layer: Layer,
    /// The base size (diameter) of the stroke.
    pub size: f64,
    /// The effect of pressure on the stroke's size.
    pub thinning: f64,
    /// How much to soften the stroke's edges.
    pub smoothing: f64,
    /// TODO
    pub streamline: f64,
    /// An easing function to apply to each point's pressure.
    pub easing: pen_style::Easing,
    /// Whether to simulate pressure based on velocity.
    pub simulate_pressure: bool,
    /// Cap, taper and easing for the start of the line.
    pub start: pen_style::StartCap,
    /// Cap, taper and easing for the end of the line.
    pub end: pen_style::EndCap,
}

impl StrokeStyle {
    pub fn is_foreground(&self) -> bool {
        match self.layer {
            Layer::Foreground => true,
            _ => false,
        }
    }
    pub fn is_background(&self) -> bool {
        match self.layer {
            Layer::Background => true,
            _ => false,
        }
    }
}

pub mod pen_style {
    use serde::{Serializer, Deserializer, Serialize, Deserialize};

    #[derive(Debug, Clone, Copy, Serialize, Deserialize)]
    #[repr(C)]
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
    #[repr(C)]
    pub struct StartCap {
        pub cap: bool,
        pub taper: f64,
        pub easing: Easing,
    }
    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[repr(C)]
    pub struct EndCap {
        pub cap: bool,
        pub taper: f64,
        pub easing: Easing,
    }
    impl Default for Easing {
        fn default() -> Self {
            Easing::Linear
        }
    }
    impl Default for StartCap {
        fn default() -> Self {
            StartCap {cap: true, taper: 0.0, easing: Easing::Linear}
        }
    }
    impl Default for EndCap {
        fn default() -> Self {
            EndCap {cap: true, taper: 0.0, easing: Easing::Linear}
        }
    }
}



impl Default for StrokeStyle {
    fn default() -> Self {
        StrokeStyle{
            color: DualColors::default(),
            layer: Layer::default(),
            size: 5.0,
            thinning: 0.5,
            smoothing: 0.5,
            streamline: 0.5,
            easing: pen_style::Easing::default(),
            simulate_pressure: true,
            start: pen_style::StartCap::default(),
            end: pen_style::EndCap::default(),
        }
    }
}