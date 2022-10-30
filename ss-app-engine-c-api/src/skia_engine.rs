#![allow(unused)]
// use std::borrow::Cow;
use std::ffi::{CString, CStr, c_void};
use std::os::raw::{c_char, c_int};
use libc::{size_t, c_float};
use skia_safe::surface;
use c_ffi_utils::*;
use crate::canvas_runtime::{CanvasRuntimeContext, CanvasRuntimeContextPtr, ViewInfo};


///////////////////////////////////////////////////////////////////////////////
// DATA TYPES
///////////////////////////////////////////////////////////////////////////////

pub struct MetalBackendContext {
    backend: skia_safe::gpu::mtl::BackendContext,
    context: skia_safe::gpu::DirectContext,
    surface: Option<skia_safe::surface::Surface>,
}

impl MetalBackendContext {
    pub fn new(
        device: *mut c_void,
        queue: *mut c_void,
    ) -> Self {
        assert!(!device.is_null());
        assert!(!queue.is_null());
        let backend = unsafe {
            skia_safe::gpu::mtl::BackendContext::new(device, queue, std::ptr::null())
        };
        let mut context = skia_safe::gpu::DirectContext::new_metal(&backend, None).unwrap();
        MetalBackendContext {
            backend,
            context,
            surface: None,
        }
    }
    pub fn get_surface(
        &mut self,
        view: *const c_void,
    ) {
        let surface_props = skia_safe::SurfaceProps::new(
            skia_safe::SurfacePropsFlags::default(),
            skia_safe::PixelGeometry::Unknown,
        );
        let mut surface = unsafe {
            skia_safe::surface::Surface::from_mtk_view(
                &mut self.context,
                view,
                skia_safe::gpu::SurfaceOrigin::TopLeft,
                Some(1),
                skia_safe::ColorType::BGRA8888,
                None,
                Some(&surface_props),
            ).unwrap()
        };
        surface.canvas().clear(skia_safe::colors::TRANSPARENT);
        self.surface = Some(surface);
    }
}




///////////////////////////////////////////////////////////////////////////////
// C API
///////////////////////////////////////////////////////////////////////////////

pub type MetalBackendContextPtr = Pointer<MetalBackendContext>;


#[no_mangle]
pub extern fn ss1_metal_backend_context_init(
    device: *mut c_void,
    queue: *mut c_void,
) -> MetalBackendContextPtr {
    let context = MetalBackendContext::new(device, queue);
    Pointer::new(context)
}


#[no_mangle]
pub extern fn ss1_metal_backend_context_provision_view(
    metal_backend_context_ptr: MetalBackendContextPtr,
    view: *const c_void,
) {
    let f = |metal_backend_context: &mut MetalBackendContext| {
        metal_backend_context.get_surface(view);
    };
    metal_backend_context_ptr.map_mut(f)
}


#[derive(Debug, Clone, PartialEq)]
#[repr(C)]
pub struct MetalTextureInfo {
    width: isize,
    height: isize,
}

#[repr(C)]
#[derive(Debug, PartialEq)]
pub enum DrawResult {
    Success,
    Error,
    NoOp,
}

impl DrawResult {
    pub fn merge(self, other: DrawResult) -> DrawResult {
        match (self, other) {
            (DrawResult::NoOp, DrawResult::NoOp) => DrawResult::NoOp,
            (DrawResult::Success, DrawResult::Success) => DrawResult::Success,
            (DrawResult::NoOp, DrawResult::Success) => DrawResult::Success,
            (DrawResult::Success, DrawResult::NoOp) => DrawResult::Success,
            (DrawResult::Error, _) => DrawResult::Error,
            (_, DrawResult::Error) => DrawResult::Error,
        }
    }
    pub fn is_ok(&self) -> bool {
        match self {
            Self::NoOp => true,
            Self::Success => true,
            _ => false,
        }
    }
}


#[no_mangle]
pub extern fn ss1_metal_view_draw_flush_and_submit(
    metal_backend_context_ptr: MetalBackendContextPtr,
    canvas_runtime_context_ptr: CanvasRuntimeContextPtr,
    view: *const c_void,
    view_info: ViewInfo
) -> DrawResult {
    let f = |metal_backend_context: &mut MetalBackendContext, canvas_runtime_context: &mut CanvasRuntimeContext| {
        let surface = metal_backend_context.surface.as_mut().unwrap();
        let canvas = surface.canvas();
        canvas.clear(skia_safe::colors::TRANSPARENT);
        let result = canvas_runtime_context
            .draw(&view_info, canvas)
            .unwrap_or(DrawResult::NoOp);
        if !result.is_ok() {
            eprintln!("ss1_metal_view_draw_flush_and_submit result: {result:?}");
        }
        surface.flush_and_submit();
        return result
    };
    Pointer::map_mut_pair(metal_backend_context_ptr, canvas_runtime_context_ptr, f)
}


