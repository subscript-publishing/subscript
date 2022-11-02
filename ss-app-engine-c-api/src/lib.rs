#![allow(unused)]
// pub extern crate ss_notebook_format;
// pub mod canvas_runtime;
// pub mod global_runtime;
// pub mod toolbar_runtime;
// pub mod skia_engine;
// pub mod utils;
// pub mod data;
use std::{ffi::c_void, ptr::null};
use ss_app_engine::data::{drawing::skia_backend::SkiaDrawable, DynamicStrokeStyle, FillStyle, EditToolSettings, Point};

pub use ss_app_engine::data::{RootScene, metal_backend::MetalBackendContext, SamplePoint, ViewInfo};
pub use ss_app_engine::data::c_ffi_utils::{Pointer, ByteArrayPointer};

pub type MetalBackendContextPointer = Pointer<MetalBackendContext>;
pub type RootScenePointer = Pointer<RootScene>;


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// INIT/FREE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn root_scene_new() -> RootScenePointer {
    // println!("root_scene_new: START");
    let result = Pointer::default();
    // println!("root_scene_new: END");
    result
}
#[no_mangle]
pub extern "C" fn root_scene_free(ptr: RootScenePointer) {
    // println!("root_scene_free: START");
    ptr.free();
    // println!("root_scene_free: END");
}



//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// METHODS - GESTURE - EVENTS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn root_scene_begin_stroke(ptr: RootScenePointer, start_point: SamplePoint) {
    // println!("root_scene_begin_stroke: START");
    assert!(start_point.is_valid());
    ptr.map_mut(|ctx| ctx.begin_stroke(start_point));
    // println!("root_scene_begin_stroke: END");
}
#[no_mangle]
pub extern "C" fn root_scene_record_stroke_sample(
    ptr: RootScenePointer,
    sample: SamplePoint,
) {
    assert!(sample.is_valid());
    // println!("root_scene_record_stroke_sample: START");
    ptr.map_mut(|ctx| ctx.record_stroke_sample(sample));
    // println!("root_scene_record_stroke_sample: END");
}
#[no_mangle]
pub extern "C" fn root_scene_end_stroke(ptr: RootScenePointer) {
    // println!("root_scene_end_stroke: START");
    ptr.map_mut(|ctx| ctx.end_stroke());
    // println!("root_scene_end_stroke: END");
}
#[no_mangle]
pub extern "C" fn root_scene_clear_any_highlights(ptr: RootScenePointer) {
    // println!("root_scene_end_stroke: START");
    ptr.map_mut(|ctx| ctx.clear_any_highlights());
    // println!("root_scene_end_stroke: END");
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// METHODS - TOOLBAR
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn toolbar_set_current_tool_to_dynamic_stroke(style: DynamicStrokeStyle) {
    // println!("toolbar_set_current_tool_to_dynamic_stroke: START");
    assert!(style.is_valid());
    ss_app_engine::data::runtime::Toolbar::set_current_tool_to_dynamic_stroke(style);
    // println!("toolbar_set_current_tool_to_dynamic_stroke: END");
}
#[no_mangle]
pub extern "C" fn toolbar_set_current_tool_to_fill(style: FillStyle) {
    // println!("toolbar_set_current_tool_to_fill: START");
    unimplemented!("TODO");
    ss_app_engine::data::runtime::Toolbar::set_current_tool_to_fill(style);
    // println!("toolbar_set_current_tool_to_fill: END");
}
#[no_mangle]
pub extern "C" fn toolbar_set_current_tool_to_transform(settings: EditToolSettings) {
    // println!("toolbar_set_current_tool_to_transform: START");
    assert!(settings.is_valid());
    ss_app_engine::data::runtime::Toolbar::set_current_tool_to_transform(settings);
    // println!("toolbar_set_current_tool_to_transform: END");
}
#[no_mangle]
pub extern "C" fn toolbar_set_current_tool_to_eraser(settings: EditToolSettings) {
    // println!("toolbar_set_current_tool_to_eraser: START");
    assert!(settings.is_valid());
    ss_app_engine::data::runtime::Toolbar::set_current_tool_to_eraser(settings);
    // println!("toolbar_set_current_tool_to_eraser: END");
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// METAL BACKEND
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn metal_backend_context_init(
    device: *mut c_void,
    queue: *mut c_void,
) -> MetalBackendContextPointer {
    assert!(!device.is_null());
    assert!(!queue.is_null());
    // println!("metal_backend_context_init: START");
    let context = MetalBackendContext::new(device, queue);
    let pointer = Pointer::new(context);
    // println!("metal_backend_context_init: END");
    pointer
}


#[no_mangle]
pub extern "C" fn metal_backend_context_reload_view_surface(
    metal_backend_context_ptr: MetalBackendContextPointer,
    view: *const c_void,
) {
    // println!("metal_backend_context_reload_view_surface: START");
    assert!(!view.is_null());
    let f = |metal_backend_context: &mut MetalBackendContext| {
        metal_backend_context.reload_view_surface(view);
    };
    metal_backend_context_ptr.map_mut(f);
    // println!("metal_backend_context_reload_view_surface: END");
}


#[no_mangle]
pub extern "C" fn draw_flush_and_submit_view(
    metal_backend_context_ptr: MetalBackendContextPointer,
    root_scene_ptr: RootScenePointer,
    view: *const c_void,
    view_info: ViewInfo,
) {
    // println!("draw_flush_and_submit_view: START");
    assert!(view_info.is_valid());
    assert!(!view.is_null());
    let f = |metal_ctx: &mut MetalBackendContext, app_model: &mut RootScene| {
        metal_ctx.draw(view_info, app_model);
    };
    let result = Pointer::map_mut_pair(metal_backend_context_ptr, root_scene_ptr, f);
    // println!("draw_flush_and_submit_view: END");
    result
}



//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// METHODS - STATE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――



#[no_mangle]
pub extern "C" fn app_data_model_save_state(byte_array_pointer: ByteArrayPointer) {
    assert!(!byte_array_pointer.is_null());
    let byte_array_pointer = byte_array_pointer.into_vec_copy();
    let reuslt = ss_app_engine::data::notebook::from_serialized_swift_data_model(&byte_array_pointer);
    let mut git_database = ss_app_engine::data::git_db::GitDatabase::new();
    git_database.clone_remote("git@github.com:colbyn/notebook-db-alpha.git", "notebook-db-alpha");
    // println!("reuslt {reuslt:#?}");
}

