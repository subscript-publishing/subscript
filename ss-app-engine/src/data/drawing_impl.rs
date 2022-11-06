use std::sync::atomic::AtomicBool;
use itertools::Itertools;
use rayon::prelude::*;

use super::collections::HighCapacityVec;
use super::drawing::*;
use super::graphics::*;
use super::graphics_impl::PointVecOps;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// HELPERS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

fn highlight_color(
    view_info: ViewInfo,
    edit_tool: edit_tool::EditToolKind,
    style: skia_safe::PaintStyle,
) -> skia_safe::Paint {
    let dark_color: (u8, u8, u8) = match edit_tool {
        edit_tool::EditToolKind::Eraser => (255, 112, 105),
        edit_tool::EditToolKind::Lasso => (3, 211, 252),
    };
    let light_color: (u8, u8, u8) = match edit_tool {
        edit_tool::EditToolKind::Eraser => (255, 29, 18),
        edit_tool::EditToolKind::Lasso => (3, 53, 252),
    };
    let color = RgbaDualColors {
        dark_ui: RGBA {
            red: (dark_color.0 as f64) / 255.0,
            green: (dark_color.1 as f64) / 255.0,
            blue: (dark_color.2 as f64) / 255.0,
            alpha: 1.0
        },
        light_ui: RGBA {
            red: (light_color.0 as f64) / 255.0,
            green: (light_color.1 as f64) / 255.0,
            blue: (light_color.2 as f64) / 255.0,
            alpha: 1.0
        }
    };
    let mut paint = view_info.get_preferred_color_rgba(color).to_paint();
    match style {
        skia_safe::PaintStyle::Stroke => {
            paint.set_alpha(200);
        }
        skia_safe::PaintStyle::Fill => {
            paint.set_alpha(25);
        }
        skia_safe::PaintStyle::StrokeAndFill => {
            paint.set_alpha(50);
        }
    }
    paint.set_style(style);
    paint
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


impl DrawStatus {
    pub fn merge(self, other: DrawStatus) -> DrawStatus {
        use DrawStatus::*;
        match (self, other) {
            (OkPresent, OkPresent) => OkPresent,
            (OkNoOp, OkNoOp) => OkNoOp,
            (ErrPresent, ErrPresent) => ErrPresent,
            (ErrNoOp, ErrNoOp) => ErrNoOp,

            (OkPresent, OkNoOp) => OkPresent,
            (OkPresent, ErrPresent) => ErrPresent,
            (OkPresent, ErrNoOp) => ErrPresent,

            (OkNoOp, OkPresent) => OkPresent,
            (OkNoOp, ErrPresent) => ErrPresent,
            (OkNoOp, ErrNoOp) => ErrNoOp,

            (ErrPresent, OkPresent) => ErrPresent,
            (ErrPresent, OkNoOp) => ErrPresent,
            (ErrPresent, ErrNoOp) => ErrPresent,

            (ErrNoOp, OkPresent) => ErrPresent,
            (ErrNoOp, OkNoOp) => ErrNoOp,
            (ErrNoOp, ErrPresent) => ErrPresent,
        }
    }
    pub fn merge_all(xs: &[DrawStatus]) -> Option<DrawStatus> {
        xs.into_iter().copied().reduce(|x, y| x.merge(y))
    }
    pub fn from_iter(xs: impl IntoIterator<Item=DrawStatus>) -> Option<DrawStatus> {
        xs.into_iter().reduce(|x, y| x.merge(y))
    }
}

impl Default for DrawStatus {
    fn default() -> Self {
        DrawStatus::OkNoOp
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// EDIT TOOL TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl EditToolSettings {
    pub fn any_selection_layer(&self) -> bool {
        match self.selection_layer {
            edit_tool::SelectionLayer::Both => true,
            _ => false,
        }
    }
    pub fn for_foreground(&self) -> bool {
        match self.selection_layer {
            edit_tool::SelectionLayer::Foreground => true,
            _ => false,
        }
    }
    pub fn for_background(&self) -> bool {
        match self.selection_layer {
            edit_tool::SelectionLayer::Background => true,
            _ => false,
        }
    }
    pub fn is_valid(&self) -> bool {
        self.selection_layer == edit_tool::SelectionLayer::Background ||
        self.selection_layer == edit_tool::SelectionLayer::Foreground ||
        self.selection_layer == edit_tool::SelectionLayer::Both
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// STROKE TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


impl DynamicStrokeObject {
    pub fn into_ref<'a>(&'a self) -> DynamicStrokeObjectRef<'a> {
        DynamicStrokeObjectRef {
            uid: self.uid,
            style: self.style,
            input: self.input.into_ref(),
            output: self.output.into_ref(),
        }
    }
    pub fn draw(&self, view_info: ViewInfo, canvas: &mut skia_safe::Canvas) -> Option<DrawStatus> {
        let path = self.output
            .multiply_by(2.0)
            .into_ref()
            .into_sk_polygon();
        let paint = view_info.get_preferred_color(self.style.color).to_paint();
        canvas.draw_path(&path, &paint);
        Some(DrawStatus::OkPresent)
    }
}

impl Default for DynamicStrokeStyle {
    fn default() -> Self {
        DynamicStrokeStyle {
            color: DualColors::default(),
            canvas_placement: CanvasPlacement::default(),
            size: 10.0,
            thinning: 0.5,
            smoothing: 0.5,
            streamline: 0.5,
            easing: stroke_style::Easing::default(),
            simulate_pressure: true,
            start: stroke_style::StrokeCap::default(),
            end: stroke_style::StrokeCap::default(),
        }
    }
}

impl DynamicStrokeStyle {
    pub fn is_valid(&self) -> bool {
        let result = {
            self.color.is_valid() &&
            self.canvas_placement.is_valid() &&
            self.size.is_finite() && self.size.is_normal() &&
            self.thinning.is_finite() &&
            self.smoothing.is_finite() && self.smoothing.is_normal() &&
            self.streamline.is_finite() && self.streamline.is_normal() &&
            self.easing.is_valid() &&
            (self.simulate_pressure == true || self.simulate_pressure == false) &&
            self.start.is_valid() &&
            self.end.is_valid()
        };
        if !result {
            println!("self.color.is_valid() {:?}", self.color.is_valid());
            println!("self.canvas_placement.is_valid() {:?}", self.canvas_placement.is_valid());
            println!("self.size.is_finite() && self.size.is_normal() {:?}", self.size.is_finite() && self.size.is_normal());
            println!("self.thinning.is_finite() {:?}", self.thinning.is_finite());
            println!("self.smoothing.is_finite() && self.smoothing.is_normal() {:?}", self.smoothing.is_finite() && self.smoothing.is_normal());
            println!("self.streamline.is_finite() && self.streamline.is_normal() {:?}", self.streamline.is_finite() && self.streamline.is_normal());
            println!("self.easing.is_valid() {:?}", self.easing.is_valid());
            println!("(self.simulate_pressure == true || self.simulate_pressure == false) {:?}", (self.simulate_pressure == true || self.simulate_pressure == false));
            println!("self.start.is_valid() {:?}", self.start.is_valid());
            println!("self.end.is_valid() {:?}", self.end.is_valid());
        }
        result
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// FILL TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TOOL TYPE INFO
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Default for Tool {
    fn default() -> Self {
        Tool::DynamicStroke(DynamicStrokeStyle::default())
    }
}

impl Tool {
    pub fn kind(&self) -> ToolKind {
        match self {
            Tool::DynamicStroke(_) => ToolKind::DynamicStroke,
            Tool::Fill(_) => ToolKind::Fill,
            Tool::Transform(_) => ToolKind::Transform,
            Tool::Erase(_) => ToolKind::Erase,
        }
    }
    pub fn canvas_placement(&self) -> CanvasPlacement {
        match self {
            Tool::DynamicStroke(x) => x.canvas_placement,
            Tool::Fill(x) => x.canvas_placement,
            Tool::Transform(_) => CanvasPlacement::Foreground,
            Tool::Erase(_) => CanvasPlacement::Foreground,
        }
    }
    pub fn is_foreground(&self) -> bool {
        self.canvas_placement() == CanvasPlacement::Foreground
    }
    pub fn is_background(&self) -> bool {
        self.canvas_placement() == CanvasPlacement::Background
    }
}

impl ToolKind {
    pub fn as_edit_tool_kind(&self) -> Option<edit_tool::EditToolKind> {
        match self {
            ToolKind::Erase => Some(edit_tool::EditToolKind::Eraser),
            ToolKind::Transform => Some(edit_tool::EditToolKind::Lasso),
            _ => None,
        }
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SCENE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl SceneObject {
    pub fn is_stroke(&self) -> bool {
        self.payload.is_stroke()
    }
    pub fn is_fill(&self) -> bool {
        self.payload.is_fill()
    }
    pub fn new_stroke(input: impl Into<RecordedStroke>, style: DynamicStrokeStyle) -> Option<Self> {
        Some(SceneObject{
            payload: ObjectPayload::new_stroke_payload(input, style)?,
            is_highlighted: false
        })
    }
    pub fn draw(&self, view_info: ViewInfo, canvas: &mut skia_safe::Canvas) -> Option<DrawStatus> {
        let status = self.payload.draw(view_info, canvas);
        status
    }
    pub fn output_points(&self) -> PointVecRef<'_> {
        match &self.payload {
            ObjectPayload::Stroke(object) => object.output.into_ref(),
            ObjectPayload::Fill(object) => object.output.into_ref(),
        }
    }
    pub fn map_mut_output_points(&mut self, f: impl Fn(&mut Point)) {
        match &mut self.payload {
            ObjectPayload::Stroke(object) => {
                object.output.map_mut(f);
            },
            ObjectPayload::Fill(object) => unimplemented!(),
        }
    }
    pub fn into_scene_object_archive(self) -> SceneObjectArchive {
        SceneObjectArchive {payload: self.payload}
    }
}

impl ObjectPayload {
    pub fn is_stroke(&self) -> bool {
        match self {
            ObjectPayload::Stroke(_) => true,
            _ => false,
        }
    }
    pub fn is_fill(&self) -> bool {
        match self {
            ObjectPayload::Fill(_) => true,
            _ => false,
        }
    }
    pub fn new_stroke_payload(input: impl Into<RecordedStroke>, style: DynamicStrokeStyle) -> Option<Self> {
        let input: RecordedStroke = input.into();
        let output: PointVec = input.vector_outline_points_new(style)?;
        let stroke_object = DynamicStrokeObject {
            uid: uuid::Uuid::new_v4(),
            style,
            input: input.into(),
            output
        };
        Some(stroke_object.into())
    }
    pub fn draw(&self, view_info: ViewInfo, canvas: &mut skia_safe::Canvas) -> Option<DrawStatus> {
        match self {
            ObjectPayload::Stroke(object) => object.draw(view_info, canvas),
            ObjectPayload::Fill(object) => unimplemented!(),
        }
    }
    pub fn context_hull(&self) -> PointVec {
        match self {
            ObjectPayload::Stroke(object) => object.output.convex_hull_exterior(),
            ObjectPayload::Fill(object) => unimplemented!(),
        }
    }
    pub fn outline_points(&self) -> &PointVec {
        match self {
            ObjectPayload::Stroke(object) => &object.output,
            ObjectPayload::Fill(object) => unimplemented!(),
        }
    }
}

impl From<DynamicStrokeObject> for ObjectPayload {
    fn from(x: DynamicStrokeObject) -> Self {ObjectPayload::Stroke(x)}
}
impl From<FillObject> for ObjectPayload {
    fn from(x: FillObject) -> Self {ObjectPayload::Fill(x)}
}

impl ObjectStack {
    pub fn new(
        initial_capacity: usize,
        reallocation_capacity_chunk_size: usize,
    ) -> Self {
        ObjectStack {objects: HighCapacityVec::new(initial_capacity, reallocation_capacity_chunk_size)}
    }
    pub fn push(&mut self, object: impl Into<ObjectPayload>) {
        self.objects.push(SceneObject {
            payload: object.into(),
            is_highlighted: false,
        });
    }
    pub fn draw(
        &self,
        view_info: ViewInfo,
        canvas: &mut skia_safe::Canvas,
        highlights: &mut Vec<PointVec>,
    ) -> Option<DrawStatus> {
        let results = self.objects
            .iter()
            .filter_map(|object| {
                if object.is_highlighted {
                    highlights.push(object.payload.outline_points().clone());
                }
                object.draw(view_info, canvas)
            });
        DrawStatus::from_iter(results)
    }
    pub fn into_scene_stack_archive(self) -> ObjectStackArchive {
        let objects = self.objects
            .into_iter()
            .map(SceneObject::into_scene_object_archive)
            .collect_vec();
        ObjectStackArchive {objects}
    }
}


impl RootScene {
    pub fn push(&mut self, placement: CanvasPlacement, object: impl Into<ObjectPayload>) {
        use LayerIndex::*;
        use CanvasPlacement::*;
        match (self.metadata.using_layer, placement) {
            (Later1, Foreground) => self.foreground[0].push(object),
            (Later2, Foreground) => self.foreground[1].push(object),
            (Later3, Foreground) => self.foreground[2].push(object),
            (Later4, Foreground) => self.foreground[3].push(object),
            (Later1, Background) => self.background[0].push(object),
            (Later2, Background) => self.background[1].push(object),
            (Later3, Background) => self.background[2].push(object),
            (Later4, Background) => self.background[3].push(object),
        }
    }
    pub fn flush_device_input_buffer(&mut self) -> Option<()> {
        let current_tool = super::runtime::Toolbar::current_tool();
        let recorded_stroke = RecordedStroke::drain_from(&mut self.device.stroke);
        match current_tool {
            Tool::DynamicStroke(style) => {
                ObjectPayload::new_stroke_payload(recorded_stroke, style).map(|object| {
                    self.push(style.canvas_placement, object);
                });
                Some(())
            }
            Tool::Fill(style) => {
                unimplemented!();
                Some(())
            }
            Tool::Erase(settings) => {
                self.device.stroke.sample_points.clear();
                Some(())
            }
            Tool::Transform(settings) => {
                self.device.stroke.sample_points.clear();
                Some(())
            }
        }
    }
    pub fn begin_stroke(&mut self, start_point: SamplePoint) {
        self.device.stroke.sample_points.clear();
        self.device.drag_pan_mode = self
            .get_highlighted_region()
            .map(|points_cloud| {
                points_cloud.aabb_contains_point(start_point.point)
            })
            .unwrap_or(false);
        if !self.device.drag_pan_mode {
            self.clear_highlights();
        }
        self.record_stroke_sample(start_point);
    }
    pub fn record_stroke_sample(&mut self, sample_point: SamplePoint) {
        self.device.stroke.sample_points.push(sample_point);
        match self.device.stroke_input_mode() {
            StrokeInputMode::Default => {}
            StrokeInputMode::LassoObjects(settings) => {
                let recorded_stroke = RecordedStroke::copy_from(&mut self.device.stroke);
                self.mark_highlights(settings, &recorded_stroke);
            }
            StrokeInputMode::DeleteObjects(settings) => {
                let recorded_stroke = RecordedStroke::copy_from(&mut self.device.stroke);
                self.delete_highlights(settings, &recorded_stroke);
            }
            StrokeInputMode::PanObjects => {
                let highlighted_points = self.get_highlighted_region().unwrap();
                let highlighted_points_center = highlighted_points.center_point();
                let delta = Point {
                    x: highlighted_points_center.x - sample_point.point.x,
                    y: highlighted_points_center.y - sample_point.point.y,
                };
                self.for_each_highlighted_object(|entry| {
                    entry.map_mut_output_points(|point| {
                        point.x = (point.x - (delta.x / 10.0));
                        point.y = (point.y - (delta.y / 10.0));
                    });
                });
            }
        }
    }
    pub fn end_stroke(&mut self) {
        let _ = self.flush_device_input_buffer();
    }
    pub fn clear_any_highlights(&mut self) {
        self.clear_highlights()
    }
    pub fn for_each_highlighted_object<F: Fn(&mut SceneObject) -> ()>(&mut self, f: F) where F: Send + Sync {
        if self.metadata.has_highlights {
            self.background
                .par_iter_mut()
                .chain(self.foreground.par_iter_mut())
                .flat_map(|stack| stack.objects.par_iter_mut())
                .filter(|x| x.is_highlighted)
                .for_each(f);
        }
    }
    pub fn for_each_object_matching_placement<F: Fn(&mut SceneObject) -> ()>(
        &mut self,
        selection_layer: edit_tool::SelectionLayer,
        f: F
    ) where F: Send + Sync {
        match selection_layer {
            edit_tool::SelectionLayer::Background => {
                self.background
                    .par_iter_mut()
                    .flat_map(|stack| stack.objects.par_iter_mut())
                    .for_each(f);
            }
            edit_tool::SelectionLayer::Foreground => {
                self.foreground
                    .par_iter_mut()
                    .flat_map(|stack| stack.objects.par_iter_mut())
                    .for_each(f);
            }
            edit_tool::SelectionLayer::Both => {
                self.background
                    .par_iter_mut()
                    .chain(self.foreground.par_iter_mut())
                    .flat_map(|stack| stack.objects.par_iter_mut())
                    .for_each(f);
            }
        }
    }
    pub fn filter_objects_matching_placement(
        &mut self,
        selection_layer: edit_tool::SelectionLayer,
        ref f: impl Fn(&SceneObject) -> bool + Send + Sync
    ) {
        match selection_layer {
            edit_tool::SelectionLayer::Background => {
                self.background
                    .par_iter_mut()
                    .for_each(|stack| {
                        stack.objects.par_filter(f);
                    });
            }
            edit_tool::SelectionLayer::Foreground => {
                self.foreground
                    .par_iter_mut()
                    .for_each(|stack| {
                        stack.objects.par_filter(f);
                    });
            }
            edit_tool::SelectionLayer::Both => {
                self.background
                    .par_iter_mut()
                    .for_each(|stack| {
                        stack.objects.par_filter(f);
                    });
                self.foreground
                    .par_iter_mut()
                    .for_each(|stack| {
                        stack.objects.par_filter(f);
                    });
            }
        }
    }
    pub fn get_highlighted_region(&self) -> Option<PointVec> {
        if !self.metadata.has_highlights {
            return None
        }
        let points = self.background
            .par_iter()
            .chain(self.foreground.par_iter())
            .flat_map(|stack| stack.objects.par_iter())
            .flat_map(|entry| {
                if entry.is_highlighted {
                    let xs = entry.output_points().points.to_vec();
                    xs
                } else {
                    Vec::new()
                }
            })
            .collect::<Vec<_>>();
        if points.is_empty() {
            None
        } else {
            Some(PointVec::from_normal_vec(points))
        }
    }
    pub fn mark_highlights(&mut self, settings: EditToolSettings, selection_stroke: &RecordedStroke) {
        let selection_outline_shape = selection_stroke
            .into_ref()
            .into_points()
            .convex_hull_exterior();
        let has_highlights = AtomicBool::new(false);
        fn set_has_highlights(has_highlights: &AtomicBool) {
            has_highlights.store(true,  std::sync::atomic::Ordering::Relaxed);
        }
        self.for_each_object_matching_placement(settings.selection_layer, |entry: &mut SceneObject| {
            if entry.is_highlighted {
                set_has_highlights(&has_highlights);
                return ()
            }
            let entry_outline = entry.output_points().convex_hull_exterior();
            entry.is_highlighted = selection_outline_shape.intersects(&entry_outline);
            if entry.is_highlighted {
                set_has_highlights(&has_highlights);
            }
        });
        self.metadata.has_highlights = has_highlights.load(std::sync::atomic::Ordering::Acquire);
    }
    pub fn delete_highlights(&mut self, settings: EditToolSettings, selection_stroke: &RecordedStroke) {
        if self.metadata.has_highlights {
            let selection_outline_shape = selection_stroke
                .into_ref()
                .into_points()
                .convex_hull_exterior();
            self.filter_objects_matching_placement(settings.selection_layer, |entry: &SceneObject| {
                let entry_outline = entry.output_points().convex_hull_exterior();
                let is_highlighted = selection_outline_shape.intersects(&entry_outline);
                !is_highlighted
            });
        }
    }
    pub fn clear_highlights(&mut self) {
        if self.metadata.has_highlights {
            self.for_each_object_matching_placement(edit_tool::SelectionLayer::Both, |entry: &mut SceneObject| {
                entry.is_highlighted = false;
            });
        }
        self.metadata.has_highlights = false;
    }
    pub fn into_root_scene_archive(self) -> RootSceneArchive {
        let foreground = self.foreground
            .into_iter()
            .map(ObjectStack::into_scene_stack_archive)
            .collect_vec();
        let background = self.background
            .into_iter()
            .map(ObjectStack::into_scene_stack_archive)
            .collect_vec();
        RootSceneArchive {foreground, background}
    }
}

impl skia_backend::SkiaDrawable for RootScene {
    fn draw(&self, view_info: ViewInfo, canvas: &mut skia_safe::Canvas) -> Option<DrawStatus> {
        let current_tool = super::runtime::Toolbar::current_tool();
        let mut highlights: Vec<PointVec> = Vec::with_capacity(10);
        let background = self.background
            .iter()
            .filter_map(|stack| {
                stack.draw(view_info, canvas, &mut highlights)
            })
            .collect_vec();
        let mut device_status: Vec<DrawStatus> = Vec::new();
        if current_tool.is_background() {
            self.device.draw(view_info, canvas).map(|status| device_status.push(status));
        }
        let foreground = self.foreground
            .iter()
            .filter_map(|stack| {
                stack.draw(view_info, canvas, &mut highlights)
            })
            .collect_vec();
        if current_tool.is_foreground() {
            self.device.draw(view_info, canvas).map(|status| device_status.push(status));
        }
        let highlights = PointVec::from_nested_iter(highlights);
        if !highlights.is_empty() {
            let edit_tool_type = current_tool.kind().as_edit_tool_kind()?;
            let polygon = highlights
                .convex_hull_exterior()
                .multiply_by(2.0)
                .into_sk_polygon();
            let paint = highlight_color(view_info, edit_tool_type, skia_safe::PaintStyle::Stroke);
            canvas.draw_path(&polygon, &paint);
            let paint = highlight_color(view_info, edit_tool_type, skia_safe::PaintStyle::Fill);
            canvas.draw_path(&polygon, &paint);
        }
        DrawStatus::from_iter([background, foreground, device_status].concat())
    }
}


impl Default for LayerIndex {
    fn default() -> Self {
        LayerIndex::Later1
    }
}
impl Default for ObjectStack {
    fn default() -> Self {
        ObjectStack {
            objects: HighCapacityVec::new(500_000, 100_000)
        }
    }
}
impl Default for RootScene {
    fn default() -> Self {
        RootScene {
            device: DeviceInputBuffer::default(),
            metadata: RootSceneRuntimeMetadata {
                using_layer: LayerIndex::default(),
                has_highlights: false,
            },
            background: [
                ObjectStack::new(500_000, 100_000),
            ],
            foreground: [
                ObjectStack::new(500_000, 100_000),
            ],
        }
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// DEVICE TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

enum StrokeInputMode {
    Default,
    LassoObjects(EditToolSettings),
    DeleteObjects(EditToolSettings),
    PanObjects,
}

impl StrokeInputMode {
    pub fn pan_objects(&self) -> bool {
        match self {
            StrokeInputMode::PanObjects => true,
            _ => false,
        }
    }
}

impl DeviceInputBuffer {
    pub fn into_ref<'a>(&'a self) -> DeviceInputRef<'a> {
        DeviceInputRef {
            stroke: self.stroke.into_ref()
        }
    }
    fn stroke_input_mode(&self) -> StrokeInputMode {
        if self.drag_pan_mode {
            return StrokeInputMode::PanObjects;
        }
        match super::runtime::Toolbar::current_tool() {
            Tool::Erase(settings) => {
                return StrokeInputMode::DeleteObjects(settings)
            },
            Tool::Transform(settings) => {
                return StrokeInputMode::LassoObjects(settings)
            },
            Tool::DynamicStroke(_) => (),
            Tool::Fill(_) => (),
        }
        StrokeInputMode::Default
    }
    pub fn draw_highligh_region(
        &self,
        view_info: ViewInfo,
        canvas: &mut skia_safe::Canvas,
        settings: EditToolSettings,
        edit_tool_kind: edit_tool::EditToolKind,
    ) -> Option<()> {
        let stroke_style = DynamicStrokeStyle {
            size: 5.0,
            ..Default::default()
        };
        let outline_shape = self.stroke
            .into_points()
            .multiply_by(2.0)
            .convex_hull_exterior()
            .into_sk_polygon();
        let strke_path = self.stroke
            .vector_outline_points(stroke_style)?
            .multiply_by(2.0)
            .into_sk_polygon();
        
        let stroke_paint = highlight_color(view_info, edit_tool_kind, skia_safe::PaintStyle::Stroke);
        let fill_paint = highlight_color(view_info, edit_tool_kind, skia_safe::PaintStyle::Fill);
        canvas.draw_path(&outline_shape, &stroke_paint);
        canvas.draw_path(&outline_shape, &fill_paint);
        canvas.draw_path(&strke_path, &stroke_paint);
        Some(())
    }
    pub fn draw(&self, view_info: ViewInfo, canvas: &mut skia_safe::Canvas) -> Option<DrawStatus> {
        let current_tool = super::runtime::Toolbar::current_tool();
        match current_tool {
            Tool::DynamicStroke(stroke) => {
                let path = self.stroke
                    .vector_outline_points_new(stroke)?
                    .multiply_by(2.0)
                    .into_sk_polygon();
                let paint = view_info.get_preferred_color(stroke.color).to_paint();
                canvas.draw_path(&path, &paint);
                Some(DrawStatus::OkPresent)
            },
            Tool::Fill(fill) => {
                unimplemented!()
            },
            Tool::Erase(settings) => {
                self.draw_highligh_region(view_info, canvas, settings, edit_tool::EditToolKind::Eraser);
                Some(DrawStatus::OkPresent)
            },
            Tool::Transform(_) if self.stroke_input_mode().pan_objects() => {
                Some(DrawStatus::OkNoOp)
            }
            Tool::Transform(settings) => {
                self.draw_highligh_region(view_info, canvas, settings, edit_tool::EditToolKind::Lasso);
                Some(DrawStatus::OkPresent)
            },
        }
    }
}


