#![allow(unused)]
// use std::borrow::Cow;
use std::ffi::{CString, CStr, c_void};
use std::os::raw::{c_char, c_int};
use libc::{size_t, c_float};
use crate::canvas_runtime::{CanvasRuntimeContext, CanvasRuntimeContextPtr};
use super::c_helpers::Pointer;

///////////////////////////////////////////////////////////////////////////////
// SKIA
///////////////////////////////////////////////////////////////////////////////

pub struct MetalViewContext {
    backend: skia_safe::gpu::mtl::BackendContext,
    context: skia_safe::gpu::DirectContext,
    surface: Option<skia_safe::surface::Surface>,
}

pub type MetalViewContextPtr = Pointer<MetalViewContext>;

#[no_mangle]
pub extern fn init_metal_view_context(
    view: *const c_void,
    device: *mut c_void,
    queue: *mut c_void,
) -> MetalViewContextPtr {
    assert!(!device.is_null());
    assert!(!queue.is_null());
    let backend = unsafe {
        skia_safe::gpu::mtl::BackendContext::new(device, queue, std::ptr::null())
    };
    let mut context = skia_safe::gpu::DirectContext::new_metal(&backend, None).unwrap();
    let surface_props = skia_safe::SurfaceProps::new(
        skia_safe::SurfacePropsFlags::default(),
        skia_safe::PixelGeometry::Unknown,
    );
    let context = MetalViewContext {
        backend,
        context,
        surface: None,
    };
    MetalViewContextPtr::new(context)
}

#[no_mangle]
pub extern fn init_metal_view_surface(
    view: *const c_void,
    context_ptr: MetalViewContextPtr
) {
    assert!(!view.is_null());
    context_ptr.map_mut(|context| {
        let surface_props = skia_safe::SurfaceProps::new(
            skia_safe::SurfacePropsFlags::default(),
            skia_safe::PixelGeometry::Unknown,
        );
        let mut surface = unsafe {
            skia_safe::surface::Surface::from_mtk_view(
                &mut context.context,
                view,
                skia_safe::gpu::SurfaceOrigin::TopLeft,
                Some(1),
                skia_safe::ColorType::BGRA8888,
                None,
                Some(&surface_props),
            ).unwrap()
        };
        surface.canvas().clear(skia_safe::colors::TRANSPARENT);
        let mut paint = skia_safe::Paint::default();
        paint.set_color(skia_safe::Color::from_rgb(255, 0, 0));
        surface.canvas().draw_line((0.0, 0.0), (1000.0, 1000.0), &paint);
        context.surface = Some(surface);
    });
}


#[no_mangle]
pub extern fn metal_canvas_view_draw_flush_and_submit(
    metal_view_context_ptr: MetalViewContextPtr,
    canvas_runtime_context_ptr: CanvasRuntimeContextPtr,
) {
    let f = |metal_view_ctx: &mut MetalViewContext, canvas_ctx: &mut CanvasRuntimeContext| {
        let canvas = metal_view_ctx.surface.as_mut().unwrap().canvas();
        canvas.clear(skia_safe::colors::TRANSPARENT);
        canvas_ctx.skia_draw(canvas);
        metal_view_ctx.surface.as_mut().unwrap().flush_and_submit();
    };
    Pointer::map_mut_pair(metal_view_context_ptr, canvas_runtime_context_ptr, f);
}

