use std::borrow::BorrowMut;
use std::cell::RefCell;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use super::{drawing::Tool, DynamicStrokeStyle, FillStyle, EditToolSettings};

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TOOLBAR RUNTIME STATE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[repr(C)]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Toolbar {
    current_tool: Tool,
}

thread_local! {
    static GLOBAL_TOOLBAR_DATA: RefCell<Toolbar> = RefCell::new(Toolbar {
        current_tool: Tool::default(),
    });
}

impl Toolbar {
    pub fn current_tool() -> Tool {
        GLOBAL_TOOLBAR_DATA.with(|ctx| {
            ctx.borrow().current_tool.clone()
        })
    }
    pub fn edit_settings() -> Option<EditToolSettings> {
        match Toolbar::current_tool() {
            Tool::Erase(settings) => Some(settings.clone()),
            Tool::Transform(settings) => Some(settings.clone()),
            _ => None
        }
    }
    pub fn set_current_tool_to_dynamic_stroke(stroke: DynamicStrokeStyle) {
        GLOBAL_TOOLBAR_DATA.with(|ctx| {
            ctx.borrow_mut().current_tool = Tool::DynamicStroke(stroke);
        })
    }
    pub fn set_current_tool_to_fill(fill: FillStyle) {
        GLOBAL_TOOLBAR_DATA.with(|ctx| {
            ctx.borrow_mut().current_tool = Tool::Fill(fill);
        })
    }
    pub fn set_current_tool_to_transform(settings: EditToolSettings) {
        GLOBAL_TOOLBAR_DATA.with(|ctx| {
            ctx.borrow_mut().current_tool = Tool::Transform(settings);
        })
    }
    pub fn set_current_tool_to_eraser(settings: EditToolSettings) {
        GLOBAL_TOOLBAR_DATA.with(|ctx| {
            ctx.borrow_mut().current_tool = Tool::Erase(settings);
        })
    }
}

 

