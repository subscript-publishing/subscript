use std::borrow::BorrowMut;
use std::cell::RefCell;
use core_graphics::base::CGFloat;
use core_graphics::context::CGContext;
use core_graphics::sys::CGContextRef;
use serde::{Serialize, Deserialize};

use c_ffi_utils::*;
use ss_notebook_format::drawing::basics::DualColors;
use ss_notebook_format::drawing::cmds::FillStyle;
use ss_notebook_format::drawing::basics::{SamplePoint, Layer};
use ss_notebook_format::drawing::cmds::pen_style::{Easing, StartCap, EndCap};
use ss_notebook_format::drawing::cmds::StrokeCmd;
use ss_notebook_format::drawing::cmds::StrokeStyle;
use ss_notebook_format::drawing::basics::ColorModes;
use ss_notebook_format::drawing::basics::ColorScheme;
use ss_notebook_format::drawing::basics::Color;
use ss_notebook_format::drawing::basics::HSBA;
use ss_notebook_format::drawing::basics::RGBA;


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// BASIC TYPES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Debug, Clone, Serialize, Deserialize)]
#[repr(C)]
pub enum ToolKind {
    Stroke,
    Fill,
    Transform,
    Erase,
}

impl Default for ToolKind {
    fn default() -> Self {
        ToolKind::Stroke
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ToolTypeCmd {
    Stroke(StrokeStyle),
    Fill(FillStyle),
    Transform(EditToolSettings),
    Erase(EditToolSettings),
}

impl ToolTypeCmd {
    pub fn kind(&self) -> ToolKind {
        match self {
            ToolTypeCmd::Stroke(_) => ToolKind::Stroke,
            ToolTypeCmd::Fill(_) => ToolKind::Fill,
            ToolTypeCmd::Erase(_) => ToolKind::Erase,
            ToolTypeCmd::Transform(_) => ToolKind::Transform,
        }
    }
    pub fn is_foreground(&self) -> bool {
        match self {
            ToolTypeCmd::Stroke(x) => x.is_foreground(),
            ToolTypeCmd::Fill(x) => x.is_foreground(),
            ToolTypeCmd::Erase(_) => true,
            ToolTypeCmd::Transform(_) => true,
        }
    }
    pub fn is_background(&self) -> bool {
        match self {
            ToolTypeCmd::Stroke(x) => x.is_background(),
            ToolTypeCmd::Fill(x) => x.is_background(),
            ToolTypeCmd::Erase(_) => false,
            ToolTypeCmd::Transform(_) => false,
        }
    }
}

impl Default for ToolTypeCmd {
    fn default() -> Self {
        ToolTypeCmd::Stroke(StrokeStyle::default())
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TOOLBAR-RUNTIME
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[repr(C)]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GlobalToolbarContext {
    pub active_tool: ToolTypeCmd,
}

thread_local! {
    pub static GLOBAL_TOOLBAR_CONTEXT: RefCell<GlobalToolbarContext> = RefCell::new(GlobalToolbarContext {
        active_tool: ToolTypeCmd::default(),
    });
}

#[no_mangle]
pub extern "C" fn ss1_toolbar_runtime_set_active_tool_to_stroke(stroke_cmd_style: StrokeStyle) {
    GLOBAL_TOOLBAR_CONTEXT.with(|cell| {
        cell.borrow_mut().active_tool = ToolTypeCmd::Stroke(stroke_cmd_style);
    })
}
#[no_mangle]
pub extern "C" fn ss1_toolbar_runtime_set_active_tool_to_fill(fill_cmd_style: FillStyle) {
    GLOBAL_TOOLBAR_CONTEXT.with(|cell| {
        cell.borrow_mut().active_tool = ToolTypeCmd::Fill(fill_cmd_style);
    })
}
#[no_mangle]
pub extern "C" fn ss1_toolbar_runtime_set_active_tool_to_transform(
    edit_tool_settings: EditToolSettings,
) {
    GLOBAL_TOOLBAR_CONTEXT.with(|cell| {
        cell.borrow_mut().active_tool = ToolTypeCmd::Transform(edit_tool_settings);
    })
}
#[no_mangle]
pub extern "C" fn ss1_toolbar_runtime_set_active_tool_to_eraser(
    edit_tool_settings: EditToolSettings,
) {
    GLOBAL_TOOLBAR_CONTEXT.with(|cell| {
        cell.borrow_mut().active_tool = ToolTypeCmd::Erase(edit_tool_settings);
    })
}

pub(crate) fn thread_local_get_active_tool() -> ToolTypeCmd {
    GLOBAL_TOOLBAR_CONTEXT.with(|toolbar| toolbar.borrow().active_tool.clone())
}


#[repr(C)]
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum SelectionLayer {
    Both,
    Foreground,
    Background,
}
#[repr(C)]
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum SelectionType {
    StrikeThrough,
    Area,
}
#[repr(C)]
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum HitTesting {
    BoundingBox,
    ConvexHull,
    Exact,
}
#[repr(C)]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EditToolSettings {
    pub selection_type: SelectionType,
    pub selection_layer: SelectionLayer,
    pub strike_through_pen_size: f64,
    pub hit_testing: HitTesting,
}


impl SelectionType {
    pub fn is_strike_through(&self) -> bool {
        use SelectionType::*;
        match self {
            StrikeThrough => true,
            _ => false,
        }
    }
    pub fn is_area(&self) -> bool {
        use SelectionType::*;
        match self {
            Area => true,
            _ => false,
        }
    }
    pub fn paint_style(&self) -> skia_safe::PaintStyle {
        use SelectionType::*;
        match self {
            StrikeThrough => {
                skia_safe::PaintStyle::Stroke
            },
            Area => {
                skia_safe::PaintStyle::Fill
            },
        }
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TOOLBAR-RUNTIME - INIT/FREE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――



//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TOOLBAR-RUNTIME - METHODS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

// #[no_mangle]
// pub extern "C" fn global_runtime_context_set_color_scheme(
//     ptr: GlobalRuntimeContextPtr,
//     ss_color_scheme: ColorScheme,
// ) {
//     ptr.with_value(|ctx: &mut GlobalRuntimeContext| {
//         ctx.color_scheme = Some(ss_color_scheme);
//     })
// }

