use itertools::Itertools;

use super::collections::HighCapacityVec;
use super::drawing::*;
use super::graphics::*;
use super::graphics_impl::PointVecOps;


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


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// STROKE TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


impl StrokeObject {
    pub fn into_ref<'a>(&'a self) -> StrokeObjectRef<'a> {
        StrokeObjectRef {
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

impl Default for StrokeStyle {
    fn default() -> Self {
        StrokeStyle {
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

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// FILL TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TOOL TYPE INFO
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Default for Tool {
    fn default() -> Self {
        Tool::Stroke(StrokeStyle::default())
    }
}

impl Tool {
    pub fn kind(&self) -> ToolKind {
        match self {
            Tool::Stroke(_) => ToolKind::Stroke,
            Tool::Fill(_) => ToolKind::Fill,
            Tool::Transform(_) => ToolKind::Transform,
            Tool::Erase(_) => ToolKind::Erase,
        }
    }
    pub fn canvas_placement(&self) -> CanvasPlacement {
        match self {
            Tool::Stroke(x) => x.canvas_placement,
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

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SCENE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Object {
    pub fn is_stroke(&self) -> bool {
        match self {
            Object::Stroke(_) => true,
            _ => false,
        }
    }
    pub fn is_fill(&self) -> bool {
        match self {
            Object::Fill(_) => true,
            _ => false,
        }
    }
    pub fn new_stroke(input: impl Into<RecordedStroke>, style: StrokeStyle) -> Option<Self> {
        let input: RecordedStroke = input.into();
        let output: PointVec = input.vector_outline_points_new(style)?;
        let stroke_object = StrokeObject {
            uid: uuid::Uuid::new_v4(),
            style,
            input: input.into(),
            output
        };
        Some(stroke_object.into())
    }
    pub fn draw(&self, view_info: ViewInfo, canvas: &mut skia_safe::Canvas) -> Option<DrawStatus> {
        match self {
            Object::Stroke(strke) => strke.draw(view_info, canvas),
            Object::Fill(strke) => unimplemented!(),
        }
    }
}

impl From<StrokeObject> for Object {
    fn from(x: StrokeObject) -> Self {Object::Stroke(x)}
}
impl From<FillObject> for Object {
    fn from(x: FillObject) -> Self {Object::Fill(x)}
}

impl SceneStack {
    pub fn new(
        initial_capacity: usize,
        reallocation_capacity_chunk_size: usize,
    ) -> Self {
        SceneStack {objects: HighCapacityVec::new(initial_capacity, reallocation_capacity_chunk_size)}
    }
    pub fn push(&mut self, object: impl Into<Object>) {
        self.objects.push(object.into());
    }
    pub fn draw(&self, view_info: ViewInfo, canvas: &mut skia_safe::Canvas) -> Option<DrawStatus> {
        let results = self.objects.iter().filter_map(|object| object.draw(view_info, canvas));
        DrawStatus::from_iter(results)
    }
}


impl RootScene {
    pub fn push(&mut self, placement: CanvasPlacement, object: impl Into<Object>) {
        use LayerIndex::*;
        use CanvasPlacement::*;
        match (self.using_layer, placement) {
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
    pub fn flush_device_input_buffer(&mut self) {
        let current_tool = super::runtime::Toolbar::current_tool();
        let recorded_stroke = RecordedStroke::drain_from(&mut self.device.stroke);
        match current_tool {
            Tool::Stroke(style) => {
                Object::new_stroke(recorded_stroke, style).map(|object| {
                    self.push(style.canvas_placement, object);
                });
            }
            Tool::Fill(style) => {
                unimplemented!()
            }
            Tool::Erase(style) => {
                unimplemented!()
            }
            Tool::Transform(style) => {
                unimplemented!()
            }
        }
    }
    pub fn begin_stroke(&mut self) {
        self.device.stroke.sample_points.clear();
    }
    pub fn record_stroke_sample(&mut self, sample_point: SamplePoint) {
        self.device.stroke.sample_points.push(sample_point);
    }
    pub fn end_stroke(&mut self) {
        self.flush_device_input_buffer()
    }
}

impl skia_backend::SkiaDrawable for RootScene {
    fn draw(&self, view_info: ViewInfo, canvas: &mut skia_safe::Canvas) -> Option<DrawStatus> {
        let current_tool = super::runtime::Toolbar::current_tool();
        let background = self.background.iter().filter_map(|x| x.draw(view_info, canvas)).collect_vec();
        let mut device_status: Vec<DrawStatus> = Vec::new();
        if current_tool.is_background() {
            self.device.draw(view_info, canvas).map(|status| device_status.push(status));
        }
        let foreground = self.foreground.iter().filter_map(|x| x.draw(view_info, canvas)).collect_vec();
        if current_tool.is_foreground() {
            self.device.draw(view_info, canvas).map(|status| device_status.push(status));
        }
        DrawStatus::from_iter([background, foreground, device_status].concat())
    }
}


impl Default for LayerIndex {
    fn default() -> Self {
        LayerIndex::Later1
    }
}
impl Default for SceneStack {
    fn default() -> Self {
        SceneStack {
            objects: HighCapacityVec::new(500_000, 100_000)
        }
    }
}
impl Default for RootScene {
    fn default() -> Self {
        RootScene {
            using_layer: LayerIndex::default(),
            device: DeviceInputBuffer::default(),
            background: [
                SceneStack::new(500_000, 100_000),
            ],
            foreground: [
                SceneStack::new(500_000, 100_000),
            ],
        }
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// DEVICE TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl DeviceInputBuffer {
    pub fn into_ref<'a>(&'a self) -> DeviceInputRef<'a> {
        DeviceInputRef {
            stroke: self.stroke.into_ref()
        }
    }
    pub fn draw(&self, view_info: ViewInfo, canvas: &mut skia_safe::Canvas) -> Option<DrawStatus> {
        let current_tool = super::runtime::Toolbar::current_tool();
        match current_tool {
            Tool::Stroke(stroke) => {
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
            Tool::Erase(erase) => {
                unimplemented!()
            },
            Tool::Transform(erase) => {
                unimplemented!()
            },
        }
    }
}

impl<'a> DeviceInputRef<'a> {
    
}

