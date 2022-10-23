use std::borrow::BorrowMut;
use std::cell::{RefCell, Cell};
use core_graphics::base::CGFloat;
use core_graphics::context::CGContext;
use core_graphics::sys::CGContextRef;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use itertools::Itertools;
use rayon::prelude::*;
use uuid::Uuid;

use ss_notebook_format::graphics::tools::FillCmd;
use ss_notebook_format::graphics::basics::{SamplePoints, SamplePoint, Layer, DualColors};
use ss_notebook_format::graphics::tools::pen_style::{Easing, StartCap, EndCap};
use ss_notebook_format::graphics::tools::ComputedPenOutline;
use ss_notebook_format::graphics::tools::StrokeCmd;
use ss_notebook_format::graphics::tools::StrokeStyle;
use ss_notebook_format::graphics::basics::ColorModes;
use ss_notebook_format::graphics::basics::ColorScheme;
use ss_notebook_format::graphics::basics::Color;
use ss_notebook_format::graphics::basics::HSBA;
use ss_notebook_format::graphics::basics::RGBA;
use crate::global_runtime::WindowState;
use crate::toolbar_runtime::{ToolTypeCmd, ToolKind};
use super::c_helpers::*;
use super::toolbar_runtime::GLOBAL_TOOLBAR_CONTEXT;
use crate::utils::new_linear_scale;


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SKIA HELPERS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
fn get_skia_color(
    view_state: &ViewState,
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
    let color_scale = new_linear_scale(
        (0.0, 1.0),
        (0.0, 255.0),
    );
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
fn get_skia_color_for_edit_tool(
    view_state: &ViewState,
    canvas: &mut skia_safe::Canvas,
) -> skia_safe::Paint {
    let (red, green, blue) = match view_state.color_scheme {
        ColorScheme::Dark => {
            (0, 255, 247)
        }
        ColorScheme::Light => {
            (0, 98, 255)
        }
    };
    let mut paint = skia_safe::Paint::default();
    paint.set_color(skia_safe::Color::from_rgb(red, green, blue));
    paint.set_alpha(200);
    paint.set_anti_alias(true);
    return paint
}
fn get_skia_path(view_state: &ViewState, canvas: &mut skia_safe::Canvas, points: &[[f64; 2]]) -> skia_safe::Path {
    let points = points
        .into_iter()
        .map(|[x, y]| {
            skia_safe::Point{x: *x as f32 * 2.0, y: *y as f32 * 2.0}
        })
        .collect_vec();
    let path = skia_safe::Path::polygon(&points, true, None, None);
    return path
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// BASIC TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DrawCmd {
    pub op: DrawCmdOp,
    pub drawn: RefCell<bool>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum DrawCmdOp {
    Stroke(StrokeCmd),
    Fill(FillCmd),
}

impl DrawCmd {
    fn skia_draw(&mut self, view_state: &ViewState, canvas: &mut skia_safe::Canvas) {
        match &mut self.op {
            DrawCmdOp::Stroke(stroke) => {
                stroke.compute_outline_if_missing();
                let outline = stroke.computed_outline.as_ref().unwrap();
                if outline.points.len() < 2 {
                    return ()
                }
                let paint = get_skia_color(view_state, canvas, &outline.color);
                let path = get_skia_path(view_state, canvas, &outline.points);
                canvas.draw_path(&path, &paint);
            }
            DrawCmdOp::Fill(fill) => {
                let points = fill.device_input.0
                    .iter()
                    .map(|sample| sample.point)
                    .collect_vec();
                if points.len() < 2 {
                    return ()
                }
                unimplemented!()
            }
        }
    }
}


#[derive(Debug, Clone, PartialEq)]
#[repr(C)]
pub struct ViewState {
    width: f64,
    height: f64,
    color_scheme: ColorScheme,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// CANVAS-RUNTIME-CONTEXT - HELPERS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Default)]
struct ActiveViewState {
    device_input: SamplePoints,
    active_tool: ToolTypeCmd,
    view_state: Option<ViewState>,
    redraw_all: RefCell<bool>,
}

impl ActiveViewState {
    pub fn draw_via_skia(&self, view_state: &ViewState, canvas: &mut skia_safe::Canvas) {
        use ss_notebook_format::graphics::tools::perfect_freehand::vector_outline_points;
        match &self.active_tool {
            ToolTypeCmd::Stroke(stroke_style) => {
                let outline_points = vector_outline_points(
                    &self.device_input,
                    &stroke_style
                );
                if outline_points.len() < 2 {
                    return
                }
                let paint = get_skia_color(view_state, canvas, &stroke_style.color);
                let path = get_skia_path(view_state, canvas, &outline_points);
                canvas.draw_path(&path, &paint);
            },
            ToolTypeCmd::Fill(fill_style) => {
                if self.device_input.0.len() < 2 {
                    return
                }
                let points = self.device_input.0.iter().map(|x| x.point).collect_vec();
                unimplemented!();
            },
            ToolTypeCmd::Erase => {
                let mut stroke_style = StrokeStyle::default();
                stroke_style.size = 5.0;
                let outline_points = vector_outline_points(
                    &self.device_input,
                    &stroke_style
                );
                if outline_points.len() < 2 {
                    return
                }
                let paint = get_skia_color_for_edit_tool(view_state, canvas);
                let path = get_skia_path(view_state, canvas, &outline_points);
                canvas.draw_path(&path, &paint);
            },
            ToolTypeCmd::Transform => unimplemented!(),
        }
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// CANVAS-RUNTIME-CONTEXT
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

pub type CanvasRuntimeContextPtr = Pointer<CanvasRuntimeContext>;

#[derive(Default)]
pub struct CanvasRuntimeContext {
    active: ActiveViewState,
    foreground: Vec<DrawCmd>,
    background: Vec<DrawCmd>,
}

impl CanvasRuntimeContext {
    pub fn begin_stroke(&mut self, active_tool: ToolTypeCmd) {
        let kind = active_tool.kind();
        let is_background = active_tool.is_background();
        self.active.device_input.0.clear();
        self.active.active_tool = active_tool;
        match kind {
            ToolKind::Erase | ToolKind::Transform => {
                self.redraw_all()
            }
            ToolKind::Fill | ToolKind::Stroke if is_background => {
                self.redraw_all()
            }
            ToolKind::Fill | ToolKind::Stroke => {}
        }
    }
    pub fn redraw_all(&self) {
        self.active.redraw_all.replace(true);
    }
    pub fn record_stroke_sample(&mut self, sample: SamplePoint) {
        self.active.device_input.0.push(sample);
    }
    pub fn update_view_state(&mut self, new_state: ViewState) {
        if Some(&new_state) != self.active.view_state.as_ref() {
            self.active.view_state = Some(new_state);
            self.redraw_all();
        }
    }
    pub fn end_stroke(&mut self) {
        let device_input = self.active.device_input.0.drain(..).collect_vec();
        let device_input = SamplePoints(device_input);
        match self.active.active_tool.clone() {
            ToolTypeCmd::Stroke(stroke_style) => {
                let is_foreground = stroke_style.is_foreground();
                let op = DrawCmdOp::Stroke(StrokeCmd{
                    uid: Uuid::new_v4(),
                    stroke_style,
                    device_input,
                    computed_outline: None,
                });
                let cmd = DrawCmd {op, drawn: RefCell::new(false)};
                if is_foreground {
                    self.foreground.push(cmd);
                } else {
                    self.background.push(cmd);
                }
            }
            ToolTypeCmd::Fill(fill_style) => {
                let is_foreground = fill_style.is_foreground();
                let op = DrawCmdOp::Fill(FillCmd{
                    uid: Uuid::new_v4(),
                    fill_style,
                    device_input,
                });
                let cmd = DrawCmd {op, drawn: RefCell::new(false)};
                if is_foreground {
                    self.foreground.push(cmd);
                } else {
                    self.background.push(cmd);
                }
            }
            ToolTypeCmd::Erase => {
                self.active.device_input.0.clear();
            },
            ToolTypeCmd::Transform => unimplemented!(),
        }
    }
    pub fn skia_draw(&mut self, canvas: &mut skia_safe::Canvas) -> Option<()> {
        let view_state = self.active.view_state.as_ref()?;
        for cmd in self.background.iter_mut() {
            cmd.skia_draw(&view_state, canvas);
        }
        if self.active.active_tool.is_background() {
            self.active.draw_via_skia(view_state, canvas);
        }
        for cmd in self.foreground.iter_mut() {
            cmd.skia_draw(&view_state, canvas);
        }
        if self.active.active_tool.is_foreground() {
            self.active.draw_via_skia(view_state, canvas);
        }
        Some(())
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// CANVAS-RUNTIME-CONTEXT - INIT/FREE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn ss1_canvas_runtime_context_new() -> CanvasRuntimeContextPtr {
    Pointer::default()
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

#[no_mangle]
pub extern "C" fn ss1_canvas_runtime_context_set_view_state(
    ptr: CanvasRuntimeContextPtr,
    view_state: ViewState,
) {
    ptr.map_mut(|ctx| {
        ctx.update_view_state(view_state);
    })
}


