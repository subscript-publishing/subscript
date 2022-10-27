use std::{fmt::Debug, borrow::{Cow, BorrowMut}};
use geo::{ConcaveHull, ConvexHull, Scale, BoundingRect, Intersects, Contains, EuclideanLength, Within};
use parry2d::simba::scalar::SupersetOf;
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

impl ColorModes<Color> {
    pub fn to_paint(&self, for_color_scheme: &ColorScheme) -> skia_safe::Paint {
        match for_color_scheme {
            ColorScheme::Dark => {
                self.dark_ui.to_paint()
            }
            ColorScheme::Light => {
                self.light_ui.to_paint()
            }
        }
    }
}

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
    pub fn to_paint(&self) -> skia_safe::Paint {
        let rgba = self.rgba();
        let mut paint = skia_safe::Paint::default();
        paint.set_anti_alias(true);
        let color = skia_safe::Color4f::new(
            rgba.red as f32,
            rgba.green as f32,
            rgba.blue as f32,
            rgba.alpha as f32
        );
        paint.set_color4f(color, None);
        return paint
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


#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct DeviceInput {
    pub sample_points: Vec<SamplePoint>,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// OUTLINE POLYGON
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ColoredShape {
    pub color: DualColors,
    pub points: Vec<[f64; 2]>,
}

impl ColoredShape {
    pub fn new(color: DualColors, points: impl IntoIterator<Item=[f64; 2]>) -> Self {
        let points = Vec::from_iter(points);
        ColoredShape{color, points}
    }
    pub fn as_points_ref<'a>(&'a self) -> PointsRef<'a> {
        let points = Cow::Borrowed(self.points.as_ref());
        PointsRef {points}
    }
}

#[derive(Debug, Clone)]
pub struct PointsRef<'a> {
    points: Cow<'a, [[f64; 2]]>
}


impl<'a> PointsRef<'a> {
    pub fn new() -> Self {
        PointsRef {
            points: Cow::Owned(Vec::new())
        }
    }
    pub fn from_iter<T: Into<f64>, U: Into<[T; 2]>>(points: impl IntoIterator<Item=U>) -> PointsRef<'a> {
        let points = points
            .into_iter()
            .map(|a| {
                let [x, y] = a.into();
                [x.into(), y.into()]
            })
            .collect_vec();
        let points = Cow::Owned(points);
        PointsRef{points}
    }
    pub fn as_parry2d_polyline(&self) -> parry2d::shape::Polyline {
        let points = self.points
            .iter()
            .map(|[x, y]| {
                parry2d::na::Point2::new(*x as f32, *y as f32)
            })
            .collect_vec();
        parry2d::shape::Polyline::new(points, None)
    }
    pub fn as_geo_coords(&self) -> Vec<geo::Coordinate> {
        self.points
            .iter()
            .copied()
            .map(geo::Coordinate::from)
            .collect_vec()
    }
    pub fn as_geo_line_string(&self) -> geo::LineString {
        geo::LineString::new(self.as_geo_coords())
    }
    pub fn geo_convex_hull(&self) -> geo::Polygon {
        let line_str = self.as_geo_line_string();
        line_str.convex_hull()
    }
    pub fn get_skia_path(&self) -> skia_safe::Path {
        let points = self.points
            .iter()
            .map(|[x, y]| {
                skia_safe::Point{x: *x as f32 * 2.0, y: *y as f32 * 2.0}
            })
            .collect_vec();
        let path = skia_safe::Path::polygon(&points, true, None, None);
        return path
    }
    // pub fn overlaps(&self, other: &PointsRef) -> Option<geo::LineString> {
    //     let a = self.as_geo_line_string();
    //     let b = other.as_geo_line_string();
    //     println!("a.intersects(&b): FALSE");
    //     None
    // }
    pub fn has_overlaps(&self, other: &PointsRef) -> bool {
        if self.points.as_ref().len() < 2 {
            return false
        }
        if other.points.as_ref().len() < 2 {
            return false
        }
        use geo::algorithm::closest_point::ClosestPoint;
        use geo::EuclideanDistance;
        let a = self.geo_convex_hull();
        let b = other.geo_convex_hull();
        let a = a.exterior();
        let b = b.exterior();
        println!("euclidean_distance: {:?}", b.euclidean_distance(a));
        false
    }
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
