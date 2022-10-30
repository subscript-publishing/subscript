use std::ffi::c_void;
use c_ffi_utils::Pointer;
use crate::data::ViewInfo;

use super::skia_backend::SkiaDrawable;

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
    pub fn reload_view_surface(
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
        println!("MetalBackendContext::refresh_view")
    }
    pub fn draw<T: SkiaDrawable>(&mut self, view_info: ViewInfo, drawable: &T) {
        let surface = self.surface.as_mut().unwrap();
        let mut canvas = surface.canvas();
        canvas.clear(skia_safe::colors::TRANSPARENT);
        drawable.draw(view_info, &mut canvas);
        surface.flush_and_submit();
    }
}



