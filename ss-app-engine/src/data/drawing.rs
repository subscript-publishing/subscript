use std::{fmt::Debug, borrow::{Cow, BorrowMut}};
use itertools::Itertools;
use geo::{ConcaveHull, ConvexHull, Scale, BoundingRect, Intersects, Contains, EuclideanLength, Within};
use uuid::Uuid;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use super::graphics::*;
use super::collections::*;

pub mod perfect_freehand;
pub mod new_perfect_freehand;
pub mod metal_backend;
pub mod skia_backend;
pub mod simplify;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

pub struct DrawContext<'a> {
    pub canvas: &'a mut skia_safe::Canvas,
    pub view_info: ViewInfo,
}

// pub trait Drawable {
//     fn draw(&self, draw_ctx: &mut DrawContext<'_>);
// }


#[derive(Debug, Clone, Copy, PartialEq)]
pub enum DrawStatus {
    OkPresent,
    OkNoOp,
    ErrPresent,
    ErrNoOp,
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// EDIT TOOL TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[repr(C)]
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct EditToolSettings {
    pub selection_type: edit_tool::SelectionType,
    pub selection_layer: edit_tool::SelectionLayer,
    pub strike_through_pen_size: f64,
    pub hit_testing: edit_tool::HitTesting,
}


pub mod edit_tool {
    //! Edit Tool Related Types
    use serde::{Serializer, Deserializer, Serialize, Deserialize};

    #[repr(C)]
    #[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq)]
    pub enum HitTesting {
        BoundingBox,
        ConvexHull,
        Exact,
    }

    #[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
    #[repr(C)]
    pub enum SelectionType {
        Area,
        StrikeThrough,
    }

    #[repr(C)]
    #[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
    pub enum SelectionLayer {
        Both,
        Foreground,
        Background,
    }

    #[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
    #[repr(C)]
    pub enum SelectionCriteria {
        BoundingBox,
        ConvexHull,
        Exact,
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// STROKE TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StrokeObject {
    pub uid: Uuid,
    pub style: StrokeStyle,
    pub input: RecordedStroke,
    pub output: PointVec,
}


#[derive(Debug, Clone)]
pub struct StrokeObjectRef<'a> {
    pub uid: Uuid,
    pub style: StrokeStyle,
    pub input: RecordedStrokeRef<'a>,
    pub output: PointVecRef<'a>,
}


#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[repr(C)]
pub struct StrokeStyle {
    /// All colors in SubScript are parameterized over the environment’s color
    /// scheme preference, and these settings define the color of a given
    /// stroke for a given light or dark color scheme preference.
    pub color: DualColors,
    /// The motivation for this feature is to be able to highlight and underline
    /// strokes and have such strokes render ‘underneath’ foreground strokes, it
    /// just looks nicer. More generally, each stroke can be rendered to the
    /// foreground or background layer depending on the given pen’s ‘Layer’
    /// property. ‘Foreground’ should be the default, when you want to create a
    /// highlighter pen, set this property to ‘Background’.
    pub canvas_placement: CanvasPlacement,
    /// The diameter (i.e. size) of the rendered stroke.
    pub size: f64,
    /// The effect of pressure on the stroke's size. The thinning option takes
    /// a number between ‘-1’ and ‘1’. At ‘0’, pressure will have no effect on
    /// the width of the line. When positive, pressure will have a positive
    /// effect on the width of the line; and when negative, pressure will have
    /// a negative effect on the width of the line.
    pub thinning: f64,
    /// How much to soften the stroke's edges.
    pub smoothing: f64,
    /// How much to streamline the stroke. Often the input points recorded for
    /// a line are 'noisy', or full of irregularities. To fix this, the shaping
    /// algorithm applies a “low pass” filter that moves the points closer to a
    /// perfect curve. We can control the strength of this filter through the
    /// streamline option.
    pub streamline: f64,
    /// An easing function to apply to each point's pressure. For even finer
    /// control over the effect of thinning, we can pass an easing function
    /// that will adjust the pressure along a curve.
    pub easing: stroke_style::Easing,
    /// Whether to simulate pressure based on velocity.
    pub simulate_pressure: bool,
    /// Cap, taper and easing for the start of the line.
    pub start: stroke_style::StrokeCap,
    /// Cap, taper and easing for the end of the line.
    pub end: stroke_style::StrokeCap,
}

pub mod stroke_style {
    use serde::{Serializer, Deserializer, Serialize, Deserialize};

    #[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
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
        fn linear(t: f32) -> f32 {t}
        fn ease_in_quad(t: f32) -> f32 {t * t}
        fn ease_out_quad(t: f32) -> f32 {t * (2. - t)}
        fn ease_in_out_quad(t: f32) -> f32 {
            (if t < 0.5 {2.0 * t * t} else {-1. + (4. - 2. * t) * t})
        }
        fn ease_in_cubic(t: f32) -> f32 {t * t * t}
        fn ease_out_cubic(t: f32) -> f32 {(t - 1.) * t * t + 1.0}
        fn ease_in_out_cubic(t: f32) -> f32 {
            if t < 0.5 {4.0 * t * t * t} else {(t - 1.0) * (2.0 * t - 2.0) * (2.0 * t - 2.0) + 1.0}
        }
        fn ease_in_quart(t: f32) -> f32 {t * t * t * t}
        fn ease_out_quart(t: f32) -> f32 {1.0 - (t - 1.0) * t * t * t}
        fn ease_in_out_quart(t: f32) -> f32 {
            if t < 0.5 {8.0 * t * t * t * t} else {1.0 - 8.0 * (t - 1.0) * t * t * t}
        }
        fn ease_in_quint(t: f32) -> f32 {t * t * t * t * t}
        fn ease_out_quint(t: f32) -> f32 {1.0 + (t - 1.0) * t * t * t * t}
        fn ease_in_out_quint(t: f32) -> f32 {
            if t < 0.5 {16.0 * t * t * t * t * t} else {1.0 + 16.0 * (t - 1.0) * t * t * t * t}
        }
        fn ease_in_sine(t: f32) -> f32 {1.0 - f32::cos((t * std::f32::consts::PI) / 2.0)}
        fn ease_out_sine(t: f32) -> f32 {f32::sin((t * std::f32::consts::PI) / 2.0)}
        fn ease_in_out_sine(t: f32) -> f32 {-(f32::cos(std::f32::consts::PI * t) - 1.0) / 2.0}
        fn ease_in_expo(t: f32) -> f32 {if t <= 0.0 {0.0} else {f32::powf(2.0, 10.0 * t - 10.0)}}
        fn ease_out_expo(t: f32) -> f32 {if t >= 1.0 {1.0} else {1.0 - f32::powf(2.0, -10.0 * t)}}
        pub fn to_function(self) -> fn(f32) -> f32 {
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
    #[derive(Debug, Clone, Copy, Serialize, Deserialize)]
    #[repr(C)]
    pub struct StrokeCap {
        pub cap: bool,
        pub taper: f32,
        pub easing: Easing,
    }
    impl Default for Easing {
        fn default() -> Self {
            Easing::Linear
        }
    }
    impl Default for StrokeCap {
        fn default() -> Self {
            StrokeCap {cap: true, taper: 0.0, easing: Easing::Linear}
        }
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// FILL TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FillObject {
    pub uid: Uuid,
    pub style: FillStyle,
    pub input: RecordedStroke,
}

pub struct FillObjectRef<'a> {
    pub uid: Uuid,
    pub style: FillStyle,
    pub input: RecordedStrokeRef<'a>,
}


#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct FillStyle {
    pub color: DualColors,
    pub canvas_placement: CanvasPlacement,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TOOL TYPE INFO
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Tool {
    Stroke(StrokeStyle),
    Fill(FillStyle),
    Transform(EditToolSettings),
    Erase(EditToolSettings),
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[repr(C)]
pub enum ToolKind {
    Stroke,
    Fill,
    Transform,
    Erase,
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SCENE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Object {
    Stroke(StrokeObject),
    Fill(FillObject),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SceneStack {
    pub objects: HighCapacityVec<Object>
}


#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum LayerIndex {
    Later1,
    Later2,
    Later3,
    Later4,
}

impl LayerIndex {
    pub const fn layer_size() -> usize {1}
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RootScene {
    pub using_layer: LayerIndex,
    pub device: DeviceInputBuffer,
    pub background: [SceneStack; LayerIndex::layer_size()],
    pub foreground: [SceneStack; LayerIndex::layer_size()],
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// DEVICE TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct DeviceInputBuffer {
    pub stroke: RecordedStroke,
}

#[derive(Debug, Clone)]
pub struct DeviceInputRef<'a> {
    pub stroke: RecordedStrokeRef<'a>,
}
