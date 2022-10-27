use std::borrow::BorrowMut;
use std::cell::{RefCell, Cell};
use std::rc::Rc;
use core_graphics::base::CGFloat;
use core_graphics::context::CGContext;
use core_graphics::sys::CGContextRef;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use itertools::Itertools;
use rayon::prelude::*;
use uuid::Uuid;
use geo::{ConcaveHull, Scale, ConvexHull};

use ss_notebook_format::drawing::cmds::FillCmd;
use ss_notebook_format::drawing::basics::{DeviceInput, ColoredShape, SamplePoint, Layer, DualColors, PointsRef};
use ss_notebook_format::drawing::cmds::pen_style::{Easing, StartCap, EndCap};
use ss_notebook_format::drawing::cmds::StrokeCmd;
use ss_notebook_format::drawing::cmds::StrokeStyle;
use ss_notebook_format::drawing::basics::ColorModes;
use ss_notebook_format::drawing::basics::ColorScheme;
use ss_notebook_format::drawing::basics::Color;
use ss_notebook_format::drawing::basics::HSBA;
use ss_notebook_format::drawing::basics::RGBA;
use crate::global_runtime::WindowState;
use crate::toolbar_runtime::{ToolTypeCmd, ToolKind};
use super::c_helpers::*;
use super::toolbar_runtime::GLOBAL_TOOLBAR_CONTEXT;
use crate::utils::new_linear_scale;
use super::skia_engine::DrawResult;
use crate::data::HighCapacityVec;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SKIA HELPERS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
fn get_skia_color(
    view_state: &ViewInfo,
    canvas: &mut skia_safe::Canvas,
    color: &DualColors
) -> skia_safe::Paint {
    let color = match view_state.color_scheme {
        ColorScheme::Dark => {
            color.dark_ui.clone()
        }
        ColorScheme::Light => {
            color.light_ui.clone()
        }
    };
    let rgba = color.rgba();
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

enum EditToolType {
    Eraser,
    Selection
}

fn get_skia_color_for_edit_tool(
    view_state: &ViewInfo,
    style: skia_safe::PaintStyle,
    edit_tool_type: EditToolType,
) -> skia_safe::Paint {
    let (red, green, blue) = match (&view_state.color_scheme, edit_tool_type) {
        (ColorScheme::Dark, EditToolType::Selection) => {
            (0, 255, 247)
        }
        (ColorScheme::Light, EditToolType::Selection) => {
            (0, 98, 255)
        }
        (ColorScheme::Dark, EditToolType::Eraser) => {
            (252, 36, 3)
        }
        (ColorScheme::Light, EditToolType::Eraser) => {
            (252, 36, 3)
        }
    };
    let mut paint = skia_safe::Paint::default();
    paint.set_color(skia_safe::Color::from_rgb(red, green, blue));
    paint.set_style(style);
    paint.set_alpha(200);
    paint.set_anti_alias(true);
    return paint
}
fn get_skia_path(points: impl AsRef<[[f64; 2]]>) -> skia_safe::Path {
    let points = points
        .as_ref()
        .iter()
        .map(|[x, y]| {
            skia_safe::Point{x: *x as f32 * 2.0, y: *y as f32 * 2.0}
        })
        .collect_vec();
    let path = skia_safe::Path::polygon(&points, true, None, None);
    return path
}
fn render_outline_points_for_edit_tool(
    sample_points: impl AsRef<[SamplePoint]>,
    tool_type: EditToolType,
) -> Vec<[f64; 2]> {
    use ss_notebook_format::drawing::cmds::perfect_freehand::vector_outline_points;
    let mut stroke_style = StrokeStyle::default();
    stroke_style.size = 6.0;
    let outline_points = vector_outline_points(
        sample_points,
        &stroke_style,
    );
    outline_points
}
fn draw_convex_hull(
    view_state: &ViewInfo,
    canvas: &mut skia_safe::Canvas,
    polygon: geo::Polygon,
) {
    let exterior = polygon.exterior();
    let mut path = skia_safe::Path::new();
    let points = exterior.0
        .iter()
        // .map(|a| {
        //     geo::algorithm::affine_ops::AffineTransform::scale(1., yfact, origin)
        // })
        .map(|a| a.x_y())
        .map(|(x, y)| [x, y])
        .collect_vec();
    let path = get_skia_path(points);
    let mut paint = get_skia_color_for_edit_tool(view_state, skia_safe::PaintStyle::Stroke, EditToolType::Selection);
    paint.set_style(skia_safe::PaintStyle::Stroke);
    let x = skia_safe::Canvas::draw_path;
    canvas.draw_path(&path, &paint);
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// BASIC TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Debug, Clone)]
pub struct DrawCmd {
    pub op: DrawCmdOp,
    pub highlighted: Rc<RefCell<bool>>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum DrawCmdOp {
    Stroke(StrokeCmd),
    Fill(FillCmd),
}

impl DrawCmd {
    pub fn from_stroke(cmd: StrokeCmd) -> Self {
        DrawCmd::from_draw_cmd_op(DrawCmdOp::Stroke(cmd))
    }
    pub fn from_fill(cmd: FillCmd) -> Self {
        DrawCmd::from_draw_cmd_op(DrawCmdOp::Fill(cmd))
    }
    pub fn from_draw_cmd_op(op: DrawCmdOp) -> Self {
        DrawCmd {
            op,
            highlighted: Default::default(),
        }
    }
    pub fn is_highlighted(&self) -> bool {
        self.highlighted.borrow().to_owned()
    }
    fn id(&self) -> &Uuid {
        match &self.op {
            DrawCmdOp::Stroke(x) => &x.uid,
            DrawCmdOp::Fill(x) => &x.uid,
        }
    }
    fn get_colored_shape(&self) -> Option<&ColoredShape> {
        match &self.op {
            DrawCmdOp::Stroke(x) => Some(&x.computed_outline),
            DrawCmdOp::Fill(x) => Some(&x.outline_points),
        }
    }
    fn get_points_ref(&self) -> PointsRef {
        match &self.op {
            DrawCmdOp::Stroke(x) => x.computed_outline.as_points_ref(),
            DrawCmdOp::Fill(x) => x.outline_points.as_points_ref(),
        }
    }
    fn draw(&mut self, view_state: &ViewInfo, canvas: &mut skia_safe::Canvas) -> DrawResult {
        match &mut self.op {
            DrawCmdOp::Stroke(stroke) => {
                if stroke.computed_outline.points.len() < 2 {
                    return DrawResult::SSMetalDrawResultNoOP
                }
                let paint = get_skia_color(view_state, canvas, &stroke.computed_outline.color);
                let path = get_skia_path(&stroke.computed_outline.points);
                canvas.draw_path(&path, &paint);
                DrawResult::SSMetalDrawResultSuccess
            }
            DrawCmdOp::Fill(fill) => {
                let points = fill.device_input.sample_points
                    .iter()
                    .map(|sample| sample.point)
                    .collect_vec();
                if points.len() < 2 {
                    return DrawResult::SSMetalDrawResultNoOP
                }
                unimplemented!()
            }
        }
    }
    pub fn geo_convex_hull(&self) -> geo::Polygon {
        match &self.op {
            DrawCmdOp::Stroke(stroke) => {
                return stroke.computed_outline.as_points_ref().geo_convex_hull()
            }
            _ => unimplemented!()
        }
    }
}


#[derive(Debug, Clone, PartialEq)]
#[repr(C)]
pub struct ViewInfo {
    width: f64,
    height: f64,
    color_scheme: ColorScheme,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// CANVAS-RUNTIME-CONTEXT - HELPERS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Default)]
pub struct ActiveViewState {
    pub device_input: DeviceInput,
    pub active_tool: ToolTypeCmd,
    pub highlights_toggle_ref: Rc<RefCell<bool>>,
}

impl ActiveViewState {
    pub fn is_background(&self) -> bool {
        self.active_tool.is_background()
    }
    pub fn is_foreground(&self) -> bool {
        self.active_tool.is_foreground()
    }
    pub fn draw(
        &self,
        view_info: &ViewInfo,
        canvas: &mut skia_safe::Canvas
    ) -> DrawResult {
        use ss_notebook_format::drawing::cmds::perfect_freehand::vector_outline_points;
        match &self.active_tool {
            ToolTypeCmd::Stroke(stroke_style) => {
                let outline_points = vector_outline_points(
                    &self.device_input.sample_points,
                    &stroke_style
                );
                if outline_points.len() < 2 {
                    return DrawResult::SSMetalDrawResultNoOP
                }
                let paint = get_skia_color(&view_info, canvas, &stroke_style.color);
                let path = get_skia_path(&outline_points);
                canvas.draw_path(&path, &paint);
                return DrawResult::SSMetalDrawResultSuccess
            },
            ToolTypeCmd::Fill(fill_style) => {
                if self.device_input.sample_points.len() < 2 {
                    return DrawResult::SSMetalDrawResultNoOP
                }
                let points = self.device_input.sample_points.iter().map(|x| x.point).collect_vec();
                unimplemented!();
            },
            ToolTypeCmd::Erase => {
                let outline_points = render_outline_points_for_edit_tool(
                    &self.device_input.sample_points,
                    EditToolType::Eraser,
                );
                if outline_points.len() < 2 {
                    return DrawResult::SSMetalDrawResultNoOP
                }
                let stroke_paint = get_skia_color_for_edit_tool(
                    view_info,
                    skia_safe::PaintStyle::Stroke,
                    EditToolType::Eraser,
                );
                let path = get_skia_path(&outline_points);
                canvas.draw_path(&path, &stroke_paint);
                return DrawResult::SSMetalDrawResultSuccess
            },
            ToolTypeCmd::Transform => {
                let outline_points = render_outline_points_for_edit_tool(
                    &self.device_input.sample_points,
                    EditToolType::Selection,
                );
                if outline_points.len() < 2 {
                    return DrawResult::SSMetalDrawResultNoOP
                }
                let stroke_paint = get_skia_color_for_edit_tool(
                    view_info,
                    skia_safe::PaintStyle::Stroke,
                    EditToolType::Selection,
                );
                let path = get_skia_path(&outline_points);
                canvas.draw_path(&path, &stroke_paint);
                return DrawResult::SSMetalDrawResultSuccess
            },
        }
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// CANVAS-RUNTIME-CONTEXT
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

pub type CanvasRuntimeContextPtr = Pointer<CanvasRuntimeContext>;

pub struct CanvasRuntimeContext {
    pub active: ActiveViewState,
    pub background: HighCapacityVec<DrawCmd>,
    pub foreground: HighCapacityVec<DrawCmd>,
}


const CANVAS_ACTIVE_INPUT_SINK_CAPACITY_SIZE: usize = 10_000;
const CANVAS_BACKGROUND_START_CAPACITY_SIZE: usize = 100_000;
const CANVAS_BACKGROUND_GROW_CAPACITY_SIZE: usize = 10_000;
const CANVAS_FOREGROUND_START_CAPACITY_SIZE: usize = 500_000;
const CANVAS_FOREGROUND_GROW_CAPACITY_SIZE: usize = 100_000;


enum CanvasLayer {
    Foreground,
    Background,
}

impl CanvasRuntimeContext {
    pub fn new() -> Self {
        CanvasRuntimeContext {
            active: ActiveViewState {
                device_input: DeviceInput {
                    sample_points: Vec::with_capacity(CANVAS_ACTIVE_INPUT_SINK_CAPACITY_SIZE),
                },
                active_tool: ToolTypeCmd::default(),
                highlights_toggle_ref: Default::default(),
            },
            background: HighCapacityVec::new(
                CANVAS_BACKGROUND_START_CAPACITY_SIZE,
                CANVAS_BACKGROUND_GROW_CAPACITY_SIZE,
            ),
            foreground: HighCapacityVec::new(
                CANVAS_FOREGROUND_START_CAPACITY_SIZE,
                CANVAS_FOREGROUND_GROW_CAPACITY_SIZE,
            ),
        }
    }
    // pub fn clear_highlights(&mut self) {
    //     self.active.highlights_toggle_ref.replace_with(|_| {
    //         false
    //     });
    // }
    pub fn begin_stroke(&mut self, active_tool: ToolTypeCmd) {
        self.active.highlights_toggle_ref.replace_with(|current| {
            *current = false;
            false
        });
        self.active.device_input.sample_points.clear();
        self.active.active_tool = active_tool;
    }
    pub fn record_stroke_sample(&mut self, sample: SamplePoint) {
        self.active.device_input.sample_points.push(sample);
    }
    pub fn end_stroke(&mut self) {
        let sample_points = self.active.device_input.sample_points.drain(..).collect_vec();
        let device_input = DeviceInput {
            sample_points,
            ..Default::default()
        };
        match &self.active.active_tool {
            ToolTypeCmd::Stroke(stroke_style) => {
                let stroke_cmd = StrokeCmd::new(
                    device_input,
                    stroke_style
                );
                let cmd = DrawCmd::from_stroke(stroke_cmd);
                if stroke_style.is_foreground() {
                    self.foreground.push(cmd);
                } else {
                    self.background.push(cmd);
                }
            }
            ToolTypeCmd::Fill(fill_style) => {
                let fill_cmd = FillCmd::new(device_input, fill_style);
                let cmd = DrawCmd::from_fill(fill_cmd);
                if fill_style.is_foreground() {
                    self.foreground.push(cmd);
                } else {
                    self.background.push(cmd);
                }
            }
            ToolTypeCmd::Erase => {
                let outline_points = render_outline_points_for_edit_tool(
                    &device_input.sample_points,
                    EditToolType::Eraser,
                );
            },
            ToolTypeCmd::Transform => {
                // self.clear_highlights();
                let outline_points = render_outline_points_for_edit_tool(
                    &device_input.sample_points,
                    EditToolType::Selection,
                );
                println!("outline_points {}", outline_points.len());
                let transform = PointsRef::from_iter(outline_points);
                self.active.highlights_toggle_ref.replace_with(|current| {
                    *current = false;
                    true
                });
                for draw_cmd in self.background.iter_mut().chain(self.foreground.iter_mut()) {
                    // assert!(draw_cmd.highlighted.as_ref().borrow().to_owned() == false);
                    let draw_cmd_points = draw_cmd.get_points_ref();
                    let overlaps = {
                        transform.has_overlaps(&draw_cmd_points)
                    };
                    // let overlaps = {
                    //     draw_cmd_points.has_overlaps(&transform) 
                    // };
                    if overlaps {
                        println!("HAS OVERLAPS!!!!!!!!!!!!!!!!!!");
                        draw_cmd.highlighted = self.active.highlights_toggle_ref.clone();
                        // assert!(draw_cmd.highlighted.as_ref().borrow().to_owned() == true);
                    }
                }
            },
        }
    }
    pub fn draw(&mut self, view_info: &ViewInfo, canvas: &mut skia_safe::Canvas) -> Option<DrawResult> {
        let mut results: Vec<DrawResult> = Vec::with_capacity(
            1 +  self.background.len() + self.foreground.len()
        );
        let mut highlights: Vec<geo::Coordinate> = Vec::new();
        for cmd in self.background.iter_mut() {
            results.push(cmd.draw(view_info, canvas));
            if cmd.is_highlighted() {
                highlights.extend(
                    cmd.get_points_ref().as_geo_coords()
                );
            }
        }
        if self.active.active_tool.is_background() {
            results.push(self.active.draw(view_info, canvas));
        }
        for cmd in self.foreground.iter_mut() {
            results.push(cmd.draw(view_info, canvas));
            if cmd.is_highlighted() {
                highlights.extend(
                    cmd.get_points_ref().as_geo_coords()
                );
            }
        }
        if self.active.active_tool.is_foreground() {
            results.push(self.active.draw(view_info, canvas));
        }
        if !highlights.is_empty() {
            let convext_hull = geo::LineString::new(highlights).convex_hull();
            draw_convex_hull(view_info, canvas, convext_hull);
        }
        results.into_iter().reduce(DrawResult::merge)
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// CANVAS-RUNTIME-CONTEXT - INIT/FREE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn ss1_canvas_runtime_context_new() -> CanvasRuntimeContextPtr {
    Pointer::new(CanvasRuntimeContext::new())
}
#[no_mangle]
pub extern "C" fn ss1_canvas_runtime_context_free(ptr: CanvasRuntimeContextPtr) {
    ptr.free();
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// CANVAS-RUNTIME-CONTEXT - METHODS - GESTURE - EVENTS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn ss1_canvas_runtime_context_begin_stroke(ptr: CanvasRuntimeContextPtr) {
    let active_tool = crate::toolbar_runtime::thread_local_get_active_tool();
    ptr.map_mut(|ctx| ctx.begin_stroke(active_tool))
}
#[no_mangle]
pub extern "C" fn ss1_canvas_runtime_context_record_stroke_sample(
    ptr: CanvasRuntimeContextPtr,
    sample: SamplePoint,
) {
    ptr.map_mut(|ctx| ctx.record_stroke_sample(sample))
}
#[no_mangle]
pub extern "C" fn ss1_canvas_runtime_context_end_stroke(ptr: CanvasRuntimeContextPtr) {
    ptr.map_mut(|ctx| ctx.end_stroke())
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// CANVAS-RUNTIME-CONTEXT - METHODS - GRAPHICS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――




