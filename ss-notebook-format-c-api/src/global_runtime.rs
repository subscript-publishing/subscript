use std::borrow::BorrowMut;
use std::cell::RefCell;
use core_graphics::base::CGFloat;
use core_graphics::context::CGContext;
use core_graphics::sys::CGContextRef;

use ss_notebook_format::drawing::basics::ColorScheme;
use super::c_helpers::*;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// GLOBAL-RUNTIME-CONTEXT
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

pub type GlobalRuntimeContextPtr = Pointer<GlobalRuntimeContext>;

#[derive(Default)]
pub struct GlobalRuntimeContext {
    color_scheme: Option<ColorScheme>,
}

thread_local! {
    pub static GLOBAL_RUNTIME_CONTEXT: RefCell<GlobalRuntimeContext> = RefCell::new(GlobalRuntimeContext {
        color_scheme: Default::default(),
    });
}


#[derive(Debug, Clone)]
pub struct WindowState {
    pub color_scheme: ColorScheme,
}

pub(crate) fn thread_local_get_window_state() -> WindowState {
    GLOBAL_RUNTIME_CONTEXT.with(|ctx| {
        let color_scheme = ctx
            .borrow()
            .color_scheme
            .clone()
            .unwrap_or_default();
        WindowState {
            color_scheme,
        }
    })
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// GLOBAL-RUNTIME-CONTEXT - INIT/FREE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// GLOBAL-RUNTIME-CONTEXT - METHODS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn ss1_global_runtime_context_set_color_scheme(
    ptr: GlobalRuntimeContextPtr,
    color_scheme: ColorScheme,
) {
    GLOBAL_RUNTIME_CONTEXT.with(|ctx| {
        ctx.borrow_mut().color_scheme = Some(color_scheme);
    })
}

