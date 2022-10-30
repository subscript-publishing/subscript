use itertools::Itertools;
use geo::{ConcaveHull, ConvexHull, Scale, BoundingRect, Intersects, Contains, EuclideanLength, Within};
use super::data::*;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// GEOMETRY PRIMITIVES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

// impl Point {
//     pub fn into_geo_coordinate(self) -> geo::Coordinate {
//         geo::Coordinate {x: self.x as f64, y: self.y as f64}
//     }
//     pub fn into_point2(self) -> parry2d::na::Point2<f32> {
//         parry2d::na::Point2::new(self.x, self.y)
//     }
//     pub fn into_skia_point(self) -> skia_safe::Point {
//         skia_safe::Point::new(self.x, self.y)
//     }
// }

// impl From<geo::Coordinate> for Point {
//     fn from(a: geo::Coordinate) -> Self {Point{x: a.x as f32, y: a.y as f32}}
// }
// impl From<parry2d::na::Point2<f32>> for Point {
//     fn from(a: parry2d::na::Point2<f32>) -> Self {Point{x: a.x, y: a.y}}
// }
// impl From<skia_safe::Point> for Point {
//     fn from(a: skia_safe::Point) -> Self {Point{x: a.x, y: a.y}}
// }
// impl From<(f32, f32)> for Point {
//     fn from((x, y): (f32, f32)) -> Self {Point{x, y}}
// }
// impl From<(f64, f64)> for Point {
//     fn from((x, y): (f64, f64)) -> Self {Point{x: x as f32, y: y as f32}}
// }
// impl From<SamplePoint> for Point {
//     fn from(sample: SamplePoint) -> Self {sample.point}
// }

// impl Rect {
//     pub fn width(&self) -> f32 {
//         self.max.x - self.min.x
//     }
//     pub fn height(&self) -> f32 {
//         self.max.y - self.min.y
//     }
//     pub fn as_skia_rect(&self) -> skia_safe::Rect {
//         let width = self.width();
//         let height = self.height();
//         let min_x = self.min.x;
//         let min_y = self.min.y;
//         let top_left = skia_safe::Point::new(min_x as f32, min_y as f32);
//         let size = skia_safe::Size::new(width as f32, height as f32);
//         skia_safe::Rect::from_point_and_size(
//             top_left,
//             size
//         )
//     }
// }

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// HEAP ALLOCATED GEOMETRY TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

// impl PointVec {
//     pub fn into_ref<'a>(&'a self) -> PointVecRef<'a> {
//         PointVecRef {points: &self.points}
//     }
//     pub fn from_iter<T: Into<Point>>(points: impl IntoIterator<Item=T>) -> Self {
//         PointVec { points: points.into_iter().map(|x| x.into()).collect_vec() }
//     }
//     pub fn push_points(&mut self, other: PointVec) {
//         self.points.extend(other.points);
//     }
// }
// impl<'a> PointVecRef<'a> {
//     pub fn into_owned(&'a self) -> PointVec {
//         PointVec {points: self.points.to_vec()}
//     }
//     pub fn into_geo_coordinates(&self) -> Vec<geo::Coordinate> {
//         self.points.iter().copied().map(Point::into_geo_coordinate).collect_vec()
//     }
//     pub fn into_parry2d_points(&self) -> Vec<parry2d::na::Point2<f32>> {
//         self.points.iter().copied().map(Point::into_point2).collect_vec()
//     }
//     pub fn into_skia_points(&self) -> Vec<skia_safe::Point> {
//         self.points.iter().copied().map(Point::into_skia_point).collect_vec()
//     }
//     pub fn into_parry2d_polyline(&self) -> parry2d::shape::Polyline {
//         parry2d::shape::Polyline::new(self.into_parry2d_points(), None)
//     }
//     pub fn into_geo_line_string(&self) -> geo::LineString {
//         geo::LineString::new(self.into_geo_coordinates())
//     }
//     pub fn convex_hull(&self) -> geo::Polygon {
//         self.into_geo_line_string().convex_hull()
//     }
//     pub fn into_sk_polygon(&self) -> skia_safe::Path {
//         let points = self.into_skia_points();
//         skia_safe::Path::polygon(&points, true, None, None)
//     }
//     pub fn overlaps(&self, other: &PointVecRef<'_>) -> bool {
//         if self.points.as_ref().len() < 2 {
//             return false
//         }
//         if other.points.as_ref().len() < 2 {
//             return false
//         }
//         let a = self.into_parry2d_polyline();
//         let a = a.local_aabb();
//         other
//             .into_parry2d_points()
//             .into_iter()
//             .any(|x| {
//                 a.contains_local_point(&x)
//             })
//     }
//     pub fn intersects(&self, other: &PointVecRef<'_>) -> bool {
//         if self.points.as_ref().len() < 2 {
//             return false
//         }
//         if other.points.as_ref().len() < 2 {
//             return false
//         }
//         use geo::algorithm::closest_point::ClosestPoint;
//         use geo::EuclideanDistance;
//         let a = self.convex_hull();
//         let b = other.convex_hull();
//         let a = a.exterior();
//         let b = b.exterior();
//         a.intersects(b)
//     }
//     pub fn into_rect(&self) -> Option<Rect> {
//         let bounding_box = self.into_geo_line_string().bounding_rect()?;
//         let mut path = skia_safe::Path::new();
//         let min = bounding_box.min().x_y();
//         let max = bounding_box.max().x_y();
//         Some(Rect { min: min.into(), max: max.into() })
//     }
// }


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// VISUAL EFFECT PRIMITIVES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

// impl Default for CanvasPlacement {
//     fn default() -> Self {
//         CanvasPlacement::Foreground
//     }
// }

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COLOR SCHEME PRIMITIVES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COLOR PRIMITIVES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

// impl DualColors {
//     pub fn to_paint(&self, for_color_scheme: ColorSchemeType) -> skia_safe::Paint {
//         match for_color_scheme {
//             ColorSchemeType::Dark => {
//                 self.dark_ui.to_paint()
//             }
//             ColorSchemeType::Light => {
//                 self.light_ui.to_paint()
//             }
//         }
//     }
// }

// impl FatColor {
//     pub fn new(hsba: HSBA, rgba: RGBA) -> Self {
//         FatColor{hsba, rgba}
//     }
//     pub fn hsba(&self) -> HSBA {
//         self.hsba
//     }
//     pub fn rgba(&self) -> RGBA {
//         self.rgba
//     }
//     pub fn white() -> Self {
//         FatColor {
//             hsba: HSBA {hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0},
//             rgba: RGBA {red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0}
//         }
//     }
//     pub fn black() -> Self {
//         FatColor {
//             hsba: HSBA {hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0},
//             rgba: RGBA {red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0}
//         }
//     }
//     pub fn to_paint(&self) -> skia_safe::Paint {
//         let rgba = self.rgba();
//         let mut paint = skia_safe::Paint::default();
//         paint.set_anti_alias(true);
//         let color = skia_safe::Color4f::new(
//             rgba.red as f32,
//             rgba.green as f32,
//             rgba.blue as f32,
//             rgba.alpha as f32
//         );
//         paint.set_color4f(color, None);
//         return paint
//     }
// }

// impl Default for ColorSchemeType {
//     fn default() -> Self {
//         ColorSchemeType::Light
//     }
// }
// impl Default for DualColors {
//     fn default() -> Self {
//         DualColors {
//             dark_ui: FatColor::white(),
//             light_ui: FatColor::black(),
//         }
//     }
// }

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TOOL TYPE INFO
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// GEOMETRY + DEVICE INPUT METADATA
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


// impl RecordedStroke {
//     pub fn drain_from(sink: &mut RecordedStroke) -> Self {
//         RecordedStroke {
//             sample_points: sink.sample_points.drain(..).collect_vec()
//         }
//     }
//     pub fn into_ref<'a>(&'a self) -> RecordedStrokeRef<'a> {
//         RecordedStrokeRef {
//             sample_points: &self.sample_points
//         }
//     }
// }

// impl<'a> RecordedStrokeRef<'a> {
//     pub fn into_points(&'a self) -> PointVec {
//         let points = self.sample_points
//             .into_iter()
//             .map(|x| (*x).into())
//             .collect_vec();
//         PointVec {points}
//     }
// }

// impl From<Vec<SamplePoint>> for RecordedStroke {
//     fn from(sample_points: Vec<SamplePoint>) -> Self {
//         RecordedStroke { sample_points }
//     }
// }
