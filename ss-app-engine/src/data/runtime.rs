use std::borrow::BorrowMut;
use std::cell::RefCell;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use super::drawing::Tool;

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
}

 

