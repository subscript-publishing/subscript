use itertools::Itertools;
use geo::{ConcaveHull, ConvexHull, Scale, BoundingRect, Intersects, Contains, EuclideanLength, Within};
use parry2d::query::PointQuery;

use super::{graphics::*, edit_tool, stroke_style};

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// GEOMETRY PRIMITIVES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Point {
    pub fn new(x: f32, y: f32) -> Self {
        Point { x, y }
    }
    pub fn x(&self) -> f32 {self.x}
    pub fn y(&self) -> f32 {self.y}
    pub fn into_geo_coordinate(self) -> geo::Coordinate {
        geo::Coordinate {x: self.x as f64, y: self.y as f64}
    }
    pub fn into_point2(self) -> parry2d::na::Point2<f32> {
        parry2d::na::Point2::new(self.x, self.y)
    }
    pub fn into_skia_point(self) -> skia_safe::Point {
        skia_safe::Point::new(self.x, self.y)
    }
    pub fn is_finite(self) -> bool {
        self.x.is_finite() && self.y.is_finite()
    }
    pub fn total_cmp(self, other: Self) -> std::cmp::Ordering {
        let x = self.x.total_cmp(&other.x);
        let y = self.y.total_cmp(&other.y);
        x.then(y)
    }
    pub fn apply_linear_scale(&self, scale: LinearScale) -> Self {
        Point { x: scale.map(self.x), y: scale.map(self.y)}
    }
}

impl From<geo::Coordinate> for Point {
    fn from(a: geo::Coordinate) -> Self {Point{x: a.x as f32, y: a.y as f32}}
}
impl From<parry2d::na::Point2<f32>> for Point {
    fn from(a: parry2d::na::Point2<f32>) -> Self {Point{x: a.x, y: a.y}}
}
impl From<skia_safe::Point> for Point {
    fn from(a: skia_safe::Point) -> Self {Point{x: a.x, y: a.y}}
}
impl From<(f32, f32)> for Point {
    fn from((x, y): (f32, f32)) -> Self {Point{x, y}}
}
impl From<[f32; 2]> for Point {
    fn from([x, y]: [f32; 2]) -> Self {Point{x, y}}
}
impl From<(f64, f64)> for Point {
    fn from((x, y): (f64, f64)) -> Self {Point{x: x as f32, y: y as f32}}
}
impl From<SamplePoint> for Point {
    fn from(sample: SamplePoint) -> Self {sample.point}
}
impl std::ops::Mul for Point {
    type Output = Point;
    fn mul(self, rhs: Self) -> Self::Output {Point {x: self.x * rhs.x, y: self.y * rhs.y}}
}
impl std::ops::Mul<f32> for Point {
    type Output = Point;
    fn mul(self, constant: f32) -> Self::Output {Point {x: self.x * constant, y: self.y * constant}}
}

impl Rect {
    pub fn width(&self) -> f32 {
        self.max.x - self.min.x
    }
    pub fn height(&self) -> f32 {
        self.max.y - self.min.y
    }
    pub fn as_skia_rect(&self) -> skia_safe::Rect {
        let width = self.width();
        let height = self.height();
        let min_x = self.min.x;
        let min_y = self.min.y;
        let top_left = skia_safe::Point::new(min_x as f32, min_y as f32);
        let size = skia_safe::Size::new(width as f32, height as f32);
        skia_safe::Rect::from_point_and_size(
            top_left,
            size
        )
    }
    pub fn contains_point(&self, point: impl Into<Point>) -> bool {
        let min = self.min.into_point2();
        let max = self.max.into_point2();
        let point = point.into().into_point2();
        min <= point && point <= max
    }
    pub fn intersects(&self, other: Rect) -> bool {
        let min = self.min.into_point2().coords.sup(&other.min.into_point2().coords);
        let max = self.max.into_point2().coords.inf(&other.max.into_point2().coords);
        if min.x > max.x || min.y > max.y {
            return false;
        }
        true
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// HEAP ALLOCATED GEOMETRY TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl PointVec {
    pub fn from_normal_vec(points: Vec<Point>) -> Self {
        PointVec {points}
    }
    pub fn from_iter<T: Into<Point>>(points: impl IntoIterator<Item=T>) -> Self {
        PointVec { points: points.into_iter().map(|x| x.into()).collect_vec() }
    }
    pub fn into_ref<'a>(&'a self) -> PointVecRef<'a> {
        PointVecRef {points: &self.points}
    }
    pub fn push_points(&mut self, other: PointVec) {
        self.points.extend(other.points);
    }
    pub fn from_nested_iter(xs: impl IntoIterator<Item=PointVec>) -> Self {
        let points = xs
            .into_iter()
            .flat_map(|x| x.points)
            .collect_vec();
        PointVec{points}
    }
    pub fn is_empty(&self) -> bool {
        self.points.is_empty()
    }
    pub fn map_mut(&mut self, f: impl Fn(&mut Point)) {
        self.points
            .iter_mut()
            .for_each(f)
    }
}

pub trait PointVecOps {
    fn points(&self) -> &[Point];
    fn multiply_by(&self, mul: impl Into<f32>) -> PointVec {
        let mul = mul.into();
        let points = self.points().into_iter().map(|a| *a * mul).collect_vec();
        PointVec{points}
    }
    fn apply_linear_scale(&self, scale: LinearScale) -> PointVec {
        let points = self.points()
            .into_iter()
            .map(|a| a.apply_linear_scale(scale))
            .collect_vec();
        PointVec{points}
    }
    fn into_owned(&self) -> PointVec {
        PointVec {points: self.points().to_vec()}
    }
    fn into_geo_coordinates(&self) -> Vec<geo::Coordinate> {
        self.points().into_iter().copied().map(Point::into_geo_coordinate).collect_vec()
    }
    fn into_parry2d_points(&self) -> Vec<parry2d::na::Point2<f32>> {
        self.points().into_iter().copied().map(Point::into_point2).collect_vec()
    }
    fn into_skia_points(&self) -> Vec<skia_safe::Point> {
        self.points().into_iter().copied().map(Point::into_skia_point).collect_vec()
    }
    fn into_parry2d_polyline(&self) -> parry2d::shape::Polyline {
        parry2d::shape::Polyline::new(self.into_parry2d_points(), None)
    }
    fn into_geo_line_string(&self) -> geo::LineString {
        geo::LineString::new(self.into_geo_coordinates())
    }
    fn convex_hull(&self) -> geo::Polygon {
        self.into_geo_line_string().convex_hull()
    }
    fn convex_hull_exterior(&self) -> PointVec {
        let points = self
            .into_geo_line_string();
        let points = points
            .convex_hull();
        let points = points
            .exterior()
            .points()
            .map(|a| Point{x: a.x() as f32, y: a.y() as f32});
        PointVec::from_iter(points)
    }
    fn into_sk_polygon(&self) -> skia_safe::Path {
        let points = self.into_skia_points();
        skia_safe::Path::polygon(&points, true, None, None)
    }
    fn min(&self) -> Option<Point> {
        self.points()
            .iter()
            .copied()
            .filter(|a| a.is_finite())
            .min_by(|a, b| a.total_cmp(*b))
    }
    fn max(&self) -> Option<Point> {
        self.points()
            .into_iter()
            .copied()
            .filter(|a| a.is_finite())
            .max_by(|a, b| a.total_cmp(*b))
    }
    fn min_x(&self) -> Option<f32> {
        self.points()
            .into_iter()
            .map(Point::x)
            .filter(|a| a.is_finite())
            .min_by(|a, b| a.total_cmp(&b))
    }
    fn min_y(&self) -> Option<f32> {
        self.points()
            .into_iter()
            .map(Point::y)
            .filter(|a| a.is_finite())
            .min_by(|a, b| a.total_cmp(&b))
    }
    fn max_x(&self) -> Option<f32> {
        self.points()
            .into_iter()
            .map(Point::x)
            .filter(|a| a.is_finite())
            .max_by(|a, b| a.total_cmp(&b))
    }
    fn max_y(&self) -> Option<f32> {
        self.points()
            .into_iter()
            .map(Point::y)
            .filter(|a| a.is_finite())
            .max_by(|a, b| a.total_cmp(&b))
    }
    fn center_point(&self) -> Point {
        let bounds = self.convex_hull_exterior().into_parry2d_polyline();
        let bounds = bounds.local_aabb();
        bounds.center().to_owned().into()
    }
    fn aabb_any_point_overlap<T: PointVecOps>(&self, other: &T) -> bool {
        let a = self.into_parry2d_polyline();
        let a = a.local_aabb();
        other
            .into_parry2d_points()
            .into_iter()
            .any(|x| {
                a.contains_local_point(&x)
            })
    }
    fn aabb_contains_point(&self, other: Point) -> bool  {
        let bounds = self.convex_hull_exterior().into_parry2d_polyline();
        let bounds = bounds.local_aabb();
        bounds.contains_local_point(&other.into_point2())
    }
    fn intersects<T: PointVecOps>(
        &self,
        other: &T,
    ) -> bool {
        use geo::algorithm::closest_point::ClosestPoint;
        use geo::EuclideanDistance;
        let a = self.convex_hull();
        let b = other.convex_hull();
        let a = a.exterior();
        let b = b.exterior();
        a.intersects(b)
    }
    fn into_rect(&self) -> Option<Rect> {
        let min = self.min()?;
        let max = self.max()?;
        Rect {min, max}.into()
    }
}

impl PointVecOps for PointVec {
    fn points(&self) -> &[Point] {&self.points}
}
impl PointVecOps for PointVecRef<'_> {
    fn points(&self) -> &[Point] {self.points}
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// VISUAL EFFECT PRIMITIVES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Default for CanvasPlacement {
    fn default() -> Self {
        CanvasPlacement::Foreground
    }
}

impl CanvasPlacement {
    pub fn is_valid(&self) -> bool {
        self == &CanvasPlacement::Foreground ||
        self == &CanvasPlacement::Background
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COLOR SCHEME PRIMITIVES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl ColorSchemeType {
    pub fn is_valid(&self) -> bool {
        self == &ColorSchemeType::Dark ||
        self == &ColorSchemeType::Light
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COLOR PRIMITIVES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl RGBA {
    pub fn to_paint(&self) -> skia_safe::Paint {
        let mut paint = skia_safe::Paint::default();
        paint.set_anti_alias(true);
        let color = skia_safe::Color4f::new(
            self.red as f32,
            self.green as f32,
            self.blue as f32,
            self.alpha as f32
        );
        paint.set_color4f(color, None);
        return paint
    }
}

impl DualColors {
    pub fn to_paint(&self, for_color_scheme: ColorSchemeType) -> skia_safe::Paint {
        match for_color_scheme {
            ColorSchemeType::Dark => {
                self.dark_ui.to_paint()
            }
            ColorSchemeType::Light => {
                self.light_ui.to_paint()
            }
        }
    }
    pub fn is_valid(&self) -> bool {
        let result = {
            self.dark_ui.rgba.red.is_finite() &&
            self.dark_ui.rgba.green.is_finite() &&
            self.dark_ui.rgba.blue.is_finite() &&
            self.dark_ui.rgba.alpha.is_finite() &&
            self.dark_ui.hsba.hue.is_finite() &&
            self.dark_ui.hsba.saturation.is_finite() &&
            self.dark_ui.hsba.brightness.is_finite() &&
            self.dark_ui.hsba.alpha.is_finite()
        };
        if !result {
            println!("self.dark_ui.rgba.red.is_finite(): {:?}", self.dark_ui.rgba.red.is_finite());
            println!("self.dark_ui.rgba.green.is_finite(): {:?}", self.dark_ui.rgba.green.is_finite());
            println!("self.dark_ui.rgba.blue.is_finite(): {:?}", self.dark_ui.rgba.blue.is_finite());
            println!("self.dark_ui.rgba.alpha.is_finite(): {:?}", self.dark_ui.rgba.alpha.is_finite());
            println!("self.dark_ui.hsba.hue.is_finite(): {:?}", self.dark_ui.hsba.hue.is_finite());
            println!("self.dark_ui.hsba.saturation.is_finite(): {:?}", self.dark_ui.hsba.saturation.is_finite());
            println!("self.dark_ui.hsba.brightness.is_finite(): {:?}", self.dark_ui.hsba.brightness.is_finite());
            println!("self.dark_ui.hsba.alpha.is_finite(): {:?}", self.dark_ui.hsba.alpha.is_finite());
        }
        result
    }
}

impl RgbaDualColors {
    pub fn to_paint(&self, for_color_scheme: ColorSchemeType) -> skia_safe::Paint {
        match for_color_scheme {
            ColorSchemeType::Dark => {
                self.dark_ui.to_paint()
            }
            ColorSchemeType::Light => {
                self.light_ui.to_paint()
            }
        }
    }
}

impl FatColor {
    pub fn new(hsba: HSBA, rgba: RGBA) -> Self {
        FatColor{hsba, rgba}
    }
    pub fn hsba(&self) -> HSBA {
        self.hsba
    }
    pub fn rgba(&self) -> RGBA {
        self.rgba
    }
    pub fn white() -> Self {
        FatColor {
            hsba: HSBA {hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0},
            rgba: RGBA {red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0}
        }
    }
    pub fn black() -> Self {
        FatColor {
            hsba: HSBA {hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0},
            rgba: RGBA {red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0}
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

impl Default for ColorSchemeType {
    fn default() -> Self {
        ColorSchemeType::Light
    }
}
impl Default for DualColors {
    fn default() -> Self {
        DualColors {
            dark_ui: FatColor::white(),
            light_ui: FatColor::black(),
        }
    }
}

impl stroke_style::Easing {
    pub fn is_valid(&self) -> bool {
        self == &stroke_style::Easing::Linear ||
        self == &stroke_style::Easing::EaseInQuad ||
        self == &stroke_style::Easing::EaseOutQuad ||
        self == &stroke_style::Easing::EaseInOutQuad ||
        self == &stroke_style::Easing::EaseInCubic ||
        self == &stroke_style::Easing::EaseOutCubic ||
        self == &stroke_style::Easing::EaseInOutCubic ||
        self == &stroke_style::Easing::EaseInQuart ||
        self == &stroke_style::Easing::EaseOutQuart ||
        self == &stroke_style::Easing::EaseInOutQuart ||
        self == &stroke_style::Easing::EaseInQuint ||
        self == &stroke_style::Easing::EaseOutQuint ||
        self == &stroke_style::Easing::EaseInOutQuint ||
        self == &stroke_style::Easing::EaseInSine ||
        self == &stroke_style::Easing::EaseOutSine ||
        self == &stroke_style::Easing::EaseInOutSine ||
        self == &stroke_style::Easing::EaseInExpo ||
        self == &stroke_style::Easing::EaseOutExpo
    }
}

impl stroke_style::StrokeCap {
    pub fn is_valid(&self) -> bool {
        (self.cap == true || self.cap == false) &&
        self.easing.is_valid() &&
        self.taper.is_finite()
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TOOL TYPE INFO
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// GEOMETRY + DEVICE INPUT METADATA
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl SamplePoint {
    pub fn force(&self) -> Option<f32> {
        (!self.force.ignore).then(|| self.force.value)
    }
    pub fn is_valid(&self) -> bool {
        self.point.x.is_finite() &&
        self.point.y.is_finite() &&
        self.force.value.is_finite()
    }
}

impl Force {
    pub fn new(value: Option<f32>) -> Self {
        Force{value: value.unwrap_or(0.0), ignore: value.is_none()}
    }
}

impl RecordedStroke {
    pub fn drain_from(sink: &mut RecordedStroke) -> Self {
        RecordedStroke {
            sample_points: sink.sample_points.drain(..).collect_vec()
        }
    }
    pub fn copy_from(sink: &RecordedStroke) -> Self {
        RecordedStroke {
            sample_points: sink.sample_points.clone()
        }
    }
    pub fn into_ref<'a>(&'a self) -> RecordedStrokeRef<'a> {
        RecordedStrokeRef {
            sample_points: &self.sample_points
        }
    }
    pub fn into_points(&self) -> PointVec {
        let points = self.sample_points
            .iter()
            .map(|x| (*x).into())
            .collect_vec();
        PointVec {points}
    }
}

impl<'a> RecordedStrokeRef<'a> {
    pub fn into_points(&'a self) -> PointVec {
        let points = self.sample_points
            .into_iter()
            .map(|x| (*x).into())
            .collect_vec();
        PointVec {points}
    }
}

impl From<Vec<SamplePoint>> for RecordedStroke {
    fn from(sample_points: Vec<SamplePoint>) -> Self {
        RecordedStroke { sample_points }
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// UI RUNTIME STATE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl ViewInfo {
    pub fn get_preferred_color(&self, dual_colors: DualColors) -> FatColor {
        match self.preferred_color_scheme {
            ColorSchemeType::Dark => dual_colors.dark_ui,
            ColorSchemeType::Light => dual_colors.light_ui,
        }
    }
    pub fn get_preferred_color_rgba(&self, dual_colors: RgbaDualColors) -> RGBA {
        match self.preferred_color_scheme {
            ColorSchemeType::Dark => dual_colors.dark_ui,
            ColorSchemeType::Light => dual_colors.light_ui,
        }
    }
    pub fn is_valid(&self) -> bool {
        self.size.width.is_finite() && self.size.width.is_normal() &&
        self.size.height.is_normal() && self.size.height.is_finite() &&
        self.preferred_color_scheme.is_valid()
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TRANSFORMATIONS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl LinearScale {
    pub fn scale(&self, input: f32) -> f32 {
        let min_domain = self.domain.0;
        let max_domain = self.domain.1;
        let min_range = self.range.0;
        let max_range = self.range.1;
        return (max_range - min_range) * (input - min_domain) / (max_domain - min_domain) + min_range
    }
    pub fn map(&self, input: f32) -> f32 {
        self.scale(input)
    }
}

