#![allow(unused)]
// pub extern crate ss_notebook_format;
// pub mod canvas_runtime;
// pub mod global_runtime;
// pub mod toolbar_runtime;
// pub mod skia_engine;
// pub mod utils;
// pub mod data;
use std::ffi::c_void;
use ss_app_engine::data::drawing::skia_backend::SkiaDrawable;

pub use ss_app_engine::data::{RootScene, metal_backend::MetalBackendContext, SamplePoint, ViewInfo};
pub use c_ffi_utils::Pointer;

pub type MetalBackendContextPointer = Pointer<MetalBackendContext>;
pub type RootScenePointer = Pointer<RootScene>;


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// INIT/FREE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn root_scene_new() -> RootScenePointer {
    Pointer::default()
}
#[no_mangle]
pub extern "C" fn root_scene_free(ptr: RootScenePointer) {
    ptr.free();
}



//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// METHODS - GESTURE - EVENTS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn root_scene_begin_stroke(ptr: RootScenePointer) {
    ptr.map_mut(|ctx| ctx.begin_stroke())
}
#[no_mangle]
pub extern "C" fn root_scene_record_stroke_sample(
    ptr: RootScenePointer,
    sample: SamplePoint,
) {
    ptr.map_mut(|ctx| ctx.record_stroke_sample(sample))
}
#[no_mangle]
pub extern "C" fn root_scene_end_stroke(ptr: RootScenePointer) {
    ptr.map_mut(|ctx| ctx.end_stroke())
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// METAL BACKEND
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern fn metal_backend_context_init(
    device: *mut c_void,
    queue: *mut c_void,
) -> MetalBackendContextPointer {
    let context = MetalBackendContext::new(device, queue);
    Pointer::new(context)
}


#[no_mangle]
pub extern fn metal_backend_context_reload_view_surface(
    metal_backend_context_ptr: MetalBackendContextPointer,
    view: *const c_void,
) {
    let f = |metal_backend_context: &mut MetalBackendContext| {
        metal_backend_context.reload_view_surface(view);
    };
    metal_backend_context_ptr.map_mut(f)
}


#[no_mangle]
pub extern fn draw_flush_and_submit_background(
    metal_backend_context_ptr: MetalBackendContextPointer,
    root_scene_ptr: RootScenePointer,
    view: *const c_void,
    view_info: ViewInfo,
) {
    let f = |metal_ctx: &mut MetalBackendContext, app_model: &mut RootScene| {
        metal_ctx.draw(view_info, app_model);
    };
    Pointer::map_mut_pair(metal_backend_context_ptr, root_scene_ptr, f)
}


