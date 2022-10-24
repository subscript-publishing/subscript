#![allow(unused)]
// use std::borrow::Cow;
use std::ffi::{CString, CStr, c_void};
use std::os::raw::{c_char, c_int};
use libc::{size_t, c_float};
use skia_safe::surface;
use crate::canvas_runtime::{CanvasRuntimeContext, CanvasRuntimeContextPtr, ViewInfo};
use super::c_helpers::Pointer;

///////////////////////////////////////////////////////////////////////////////
// DATA TYPES
///////////////////////////////////////////////////////////////////////////////

pub struct MetalBackendContext {
    backend: skia_safe::gpu::mtl::BackendContext,
    context: skia_safe::gpu::DirectContext,
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
        let surface_props = skia_safe::SurfaceProps::new(
            skia_safe::SurfacePropsFlags::default(),
            skia_safe::PixelGeometry::Unknown,
        );
        MetalBackendContext {
            backend,
            context,
        }
    }
}

#[derive(Default)]
pub struct MetalViewLayers {
    background: Option<skia_safe::surface::Surface>,
    background_active: Option<skia_safe::surface::Surface>,
    foreground: Option<skia_safe::surface::Surface>,
    foreground_active: Option<skia_safe::surface::Surface>,
}

impl MetalViewLayers {
    pub fn need_provision(&self) -> bool {
        self.background.is_none() ||
        self.background_active.is_none() ||
        self.foreground.is_none() ||
        self.foreground_active.is_none()
    }
    pub fn provision(
        &mut self,
        metal_backend_context: &mut MetalBackendContext,
        background_view: *const c_void,
        background_active_view: *const c_void,
        foreground_view: *const c_void,
        foreground_active_view: *const c_void,
    ) {
        // if !self.need_provision() {
        //     return ()
        // }
        let mut new = move |view: *const c_void| {
            let surface_props = skia_safe::SurfaceProps::new(
                skia_safe::SurfacePropsFlags::default(),
                skia_safe::PixelGeometry::Unknown,
            );
            let mut surface = unsafe {
                skia_safe::surface::Surface::from_mtk_view(
                    &mut metal_backend_context.context,
                    view,
                    skia_safe::gpu::SurfaceOrigin::TopLeft,
                    Some(1),
                    skia_safe::ColorType::BGRA8888,
                    None,
                    Some(&surface_props),
                ).unwrap()
            };
            surface.canvas().clear(skia_safe::colors::TRANSPARENT);
            surface
        };
        self.background = Some(new(background_view));
        self.background_active = Some(new(background_active_view));
        self.foreground = Some(new(foreground_view));
        self.foreground_active = Some(new(foreground_active_view));
    }
    pub fn provision_for(
        &mut self,
        metal_backend_context: &mut MetalBackendContext,
        layer_view: *const c_void,
        layer_type: MetalViewLayerType,
    ) {
        let surface_props = skia_safe::SurfaceProps::new(
            skia_safe::SurfacePropsFlags::default(),
            skia_safe::PixelGeometry::Unknown,
        );
        let mut surface = unsafe {
            skia_safe::surface::Surface::from_mtk_view(
                &mut metal_backend_context.context,
                layer_view,
                skia_safe::gpu::SurfaceOrigin::TopLeft,
                Some(1),
                skia_safe::ColorType::BGRA8888,
                None,
                Some(&surface_props),
            ).unwrap()
        };
        // surface.canvas().clear(skia_safe::colors::TRANSPARENT);
        match layer_type {
            MetalViewLayerType::MetalViewIsBackground => {
                self.background = Some(surface);
            }
            MetalViewLayerType::MetalViewIsBackgroundActive => {
                self.background_active = Some(surface);
            }
            MetalViewLayerType::MetalViewIsForeground => {
                self.foreground = Some(surface);
            }
            MetalViewLayerType::MetalViewIsForegroundActive => {
                self.foreground_active = Some(surface);
            }
        }
    }
    pub fn flush_and_submit(&mut self) {
        // self.background.as_mut().unwrap().flush_and_submit();
        // self.background_active.as_mut().unwrap().flush_and_submit();
        self.foreground.as_mut().unwrap().flush_and_submit();
        // self.foreground_active.as_mut().unwrap().flush_and_submit();
    }
}


pub struct CanvasDrawLayers<'a> {
    pub background: &'a mut skia_safe::Canvas,
    pub background_active: &'a mut skia_safe::Canvas,
    pub foreground: &'a mut skia_safe::Canvas,
    pub foreground_active: &'a mut skia_safe::Canvas,
}

impl<'a> CanvasDrawLayers<'a> {
    pub fn get(metal_view_layers: &'a mut MetalViewLayers) -> Self {
        CanvasDrawLayers {
            background: metal_view_layers.background.as_mut().unwrap().canvas(),
            background_active: metal_view_layers.background_active.as_mut().unwrap().canvas(),
            foreground: metal_view_layers.foreground.as_mut().unwrap().canvas(),
            foreground_active: metal_view_layers.foreground_active.as_mut().unwrap().canvas(),
        }
    }
    pub fn clear_all(&mut self) {
        let clear_color = skia_safe::colors::TRANSPARENT;
        self.background.clear(clear_color);
        self.background_active.clear(clear_color);
        self.foreground.clear(clear_color);
        self.foreground_active.clear(clear_color);
    }
}


///////////////////////////////////////////////////////////////////////////////
// C API
///////////////////////////////////////////////////////////////////////////////

pub type MetalBackendContextPtr = Pointer<MetalBackendContext>;
pub type MetalViewLayersPtr = Pointer<MetalViewLayers>;


#[no_mangle]
pub extern fn ss1_metal_backend_context_init(
    device: *mut c_void,
    queue: *mut c_void,
) -> MetalBackendContextPtr {
    let context = MetalBackendContext::new(device, queue);
    Pointer::new(context)
}

#[no_mangle]
pub extern fn ss1_metal_view_layers_init() -> MetalViewLayersPtr {
    Pointer::default()
}

#[no_mangle]
pub extern fn ss1_metal_view_layers_provision(
    metal_backend_context_ptr: MetalBackendContextPtr,
    metal_view_layers_ptr: MetalViewLayersPtr,
    background_view: *const c_void,
    background_active_view: *const c_void,
    foreground_view: *const c_void,
    foreground_active_view: *const c_void,
) {
    let f = |metal_backend_context: &mut MetalBackendContext, metal_view_layers: &mut MetalViewLayers| {
        metal_view_layers.provision(
            metal_backend_context,
            background_view,
            background_active_view,
            foreground_view,
            foreground_active_view
        )
    };
    Pointer::map_mut_pair(metal_backend_context_ptr, metal_view_layers_ptr, f);
}

#[repr(C)]
pub enum MetalViewLayerType {
    MetalViewIsBackground,
    MetalViewIsBackgroundActive,
    MetalViewIsForeground,
    MetalViewIsForegroundActive,
}

#[no_mangle]
pub extern fn ss1_metal_view_layers_provision_for_layer(
    metal_backend_context_ptr: MetalBackendContextPtr,
    metal_view_layers_ptr: MetalViewLayersPtr,
    layer_view: *const c_void,
    layer_type: MetalViewLayerType,
) {
    let f = |metal_backend_context: &mut MetalBackendContext, metal_view_layers: &mut MetalViewLayers| {
        metal_view_layers.provision_for(
            metal_backend_context,
            layer_view,
            layer_type,
        )
    };
    Pointer::map_mut_pair(metal_backend_context_ptr, metal_view_layers_ptr, f);
}

// #[repr(C)]
// pub struct LayerHeights {
//     pub background: f64,
//     pub background_active: f64,
//     pub foreground: f64,
//     pub foreground_active: f64,
// }

// impl LayerHeights {
//     pub fn valid_background(&self, layer: &MetalViewLayers) -> Option<bool> {
//         layer.background.as_ref().map(|x| {
//             let normalized = self.background;
//             normalized >= x.height() as f64
//         })
//     }
//     pub fn valid_background_active(&self, layer: &MetalViewLayers) -> Option<bool> {
//         layer.background_active.as_ref().map(|x| {
//             let normalized = self.background_active;
//             normalized >= x.height() as f64
//         })
//     }
//     pub fn valid_foreground(&self, layer: &MetalViewLayers) -> Option<bool> {
//         layer.foreground.as_ref().map(|x| {
//             let normalized = self.foreground;
//             normalized >= x.height() as f64
//         })
//     }
//     pub fn valid_foreground_active(&self, layer: &MetalViewLayers) -> Option<bool> {
//         layer.foreground_active.as_ref().map(|x| {
//             let normalized = self.foreground_active;
//             normalized >= x.height() as f64
//         })
//     }
//     pub fn all_valid(&self, layers: &MetalViewLayers) -> Option<bool> {
//         let valid_background = self.valid_background(layers)?;
//         let valid_background_active = self.valid_background_active(layers)?;
//         let valid_foreground = self.valid_foreground(layers)?;
//         let valid_foreground_active = self.valid_foreground_active(layers)?;
//         let result = valid_background && valid_background_active && valid_foreground && valid_foreground_active;
//         if !result {
//             eprintln!("RESULT: {valid_background} && {valid_background_active} && {valid_foreground} && {valid_foreground_active}");
//         }
//         Some(result)
//     }
// }

// #[no_mangle]
// pub extern fn ss1_metal_view_layers_flush_and_submit(
//     metal_backend_context_ptr: MetalBackendContextPtr,
//     metal_view_layers_ptr: MetalViewLayersPtr,
//     canvas_runtime_context_ptr: CanvasRuntimeContextPtr,

// ) {
//     let f = |metal_backend_context: &mut MetalBackendContext, metal_view_layers: &mut MetalViewLayers| {
//         canvas_runtime_context_ptr.map_mut(|canvas_runtime_context| {
//             let all_valid = heights.valid_foreground(&metal_view_layers).unwrap_or(false);
//             // let all_valid = heights.valid_foreground(&metal_view_layers).unwrap_or(false);
//             let foreground_surface = metal_view_layers.foreground.as_mut().unwrap();
//             println!("[heights.foreground] {} >= {}", heights.foreground, foreground_surface.height());
//             if all_valid {
//                 // let canvas_draw_layers = CanvasDrawLayers::get(metal_backend_context, metal_view_layers);
//                 let canvas = foreground_surface.canvas();
//                 canvas_runtime_context.skia_draw(
//                     canvas
//                 );
//                 metal_view_layers.foreground.as_mut().unwrap().flush_and_submit();
//             } else {
//                 eprintln!("Invalid heights: skipping")
//             }
//         });
//         // let canvas_draw_layers = CanvasDrawLayers{};
//         // let canvas = metal_view_ctx.surface.as_mut().unwrap().canvas();
//         // canvas.clear(skia_safe::colors::TRANSPARENT);
//         // canvas_ctx.skia_draw(canvas_draw_layers.foreground);
//         // metal_view_ctx.surface.as_mut().unwrap().flush_and_submit();
//         // metal_view_layers.flush_and_submit();
//     };
//     Pointer::map_mut_pair(metal_backend_context_ptr, metal_view_layers_ptr, f);
// }

#[derive(Debug, Clone, PartialEq)]
#[repr(C)]
pub struct MetalTextureInfo {
    width: isize,
    height: isize,
}

impl MetalTextureInfo {
    pub fn valid_for(&self, surface: &skia_safe::Surface) -> bool {
        let valid_width = self.width >= surface.width() as isize;
        let valid_height = self.height >= surface.height() as isize;
        valid_height
    }
}

#[repr(C)]
pub enum DrawResult {
    SSMetalDrawResultSuccess,
    SSMetalDrawResultErr,
    SSMetalDrawResultNoOP,
}


#[no_mangle]
pub extern fn ss1_metal_view_layers_flush_and_submit_for_layer(
    metal_backend_context_ptr: MetalBackendContextPtr,
    metal_view_layers_ptr: MetalViewLayersPtr,
    canvas_runtime_context_ptr: CanvasRuntimeContextPtr,
    layer_type: MetalViewLayerType,
    layer_view: *const c_void,
    view_info: ViewInfo,
    texture_info: MetalTextureInfo,
) -> DrawResult {
    let f = |metal_backend_context: &mut MetalBackendContext, metal_view_layers: &mut MetalViewLayers| {
        use MetalViewLayerType::MetalViewIsBackground;
        use MetalViewLayerType::MetalViewIsBackgroundActive;
        use MetalViewLayerType::MetalViewIsForeground;
        use MetalViewLayerType::MetalViewIsForegroundActive;
        canvas_runtime_context_ptr.map_mut(|canvas_runtime_context| {
            match layer_type {
                MetalViewIsBackground => {
                    let mut surface = metal_view_layers.background.as_mut().unwrap();
                    let texture_valid = texture_info.valid_for(&surface);
                    let canvas = surface.canvas();
                    canvas_runtime_context.background_view_state = Some(view_info);
                    let result = canvas_runtime_context.skia_draw_background(canvas);
                    if result.is_none() {
                        eprintln!("Failed to draw background; perhaps you didn't set ViewState?");
                    }
                    surface.flush_and_submit();
                    return result.unwrap_or(DrawResult::SSMetalDrawResultErr)
                }
                MetalViewIsBackgroundActive => {
                    let mut surface = metal_view_layers.background_active.as_mut().unwrap();
                    let texture_valid = texture_info.valid_for(&surface);
                    let canvas = surface.canvas();
                    if !canvas_runtime_context.active.device_input.0.is_empty() {
                        canvas_runtime_context.active.view_state = Some(view_info.clone());
                        let result = canvas_runtime_context.skia_draw_background_active(canvas);
                        if result.is_none() {
                            eprintln!("Failed to draw backgroundActive; perhaps you didn't set ViewState?");
                        }
                        surface.flush_and_submit();
                        return result.unwrap_or(DrawResult::SSMetalDrawResultErr)
                    }
                    DrawResult::SSMetalDrawResultNoOP
                }
                MetalViewIsForeground => {
                    let mut surface = metal_view_layers.foreground.as_mut().unwrap();
                    let texture_valid = texture_info.valid_for(&surface);
                    let canvas = surface.canvas();
                    canvas_runtime_context.foreground_view_state = Some(view_info);
                    let result = canvas_runtime_context.skia_draw_foreground(canvas);
                    if result.is_none() {
                        eprintln!("Failed to draw foreground; perhaps you didn't set ViewState?");
                    }
                    surface.flush_and_submit();
                    return result.unwrap_or(DrawResult::SSMetalDrawResultErr)
                }
                MetalViewIsForegroundActive if canvas_runtime_context.active.is_foreground() => {
                    let mut surface = metal_view_layers.foreground_active.as_mut().unwrap();
                    let texture_valid = texture_info.valid_for(&surface);
                    let canvas = surface.canvas();
                    canvas.clear(skia_safe::colors::TRANSPARENT);
                    if !canvas_runtime_context.active.device_input.0.len() > 2 {
                        canvas_runtime_context.active.view_state = Some(view_info.clone());
                        let result = canvas_runtime_context.skia_draw_foreground_active(canvas);
                        if result.is_none() {
                            eprintln!("Failed to draw foregroundActive; perhaps you didn't set ViewState?");
                        }
                        surface.flush_and_submit();
                        return result.unwrap_or(DrawResult::SSMetalDrawResultErr)
                    }
                    DrawResult::SSMetalDrawResultNoOP
                }
                MetalViewIsForegroundActive => {
                    DrawResult::SSMetalDrawResultNoOP
                }
            }
        })
    };
    Pointer::map_mut_pair(metal_backend_context_ptr, metal_view_layers_ptr, f)
}


// #[no_mangle]
// pub extern fn init_metal_view_context(
//     device: *mut c_void,
//     queue: *mut c_void,
// ) -> MetalViewContextPtr {
//     assert!(!device.is_null());
//     assert!(!queue.is_null());
//     let backend = unsafe {
//         skia_safe::gpu::mtl::BackendContext::new(device, queue, std::ptr::null())
//     };
//     let mut context = skia_safe::gpu::DirectContext::new_metal(&backend, None).unwrap();
//     let surface_props = skia_safe::SurfaceProps::new(
//         skia_safe::SurfacePropsFlags::default(),
//         skia_safe::PixelGeometry::Unknown,
//     );
//     let context = MetalViewLayer {
//         backend,
//         context,
//         surface: None,
//     };
//     MetalViewContextPtr::new(context)
// }

// #[no_mangle]
// pub extern fn init_metal_view_surface(
//     view: *const c_void,
//     context_ptr: MetalViewContextPtr
// ) {
//     assert!(!view.is_null());
//     context_ptr.map_mut(|context| {
//         let surface_props = skia_safe::SurfaceProps::new(
//             skia_safe::SurfacePropsFlags::default(),
//             skia_safe::PixelGeometry::Unknown,
//         );
//         let mut surface = unsafe {
//             skia_safe::surface::Surface::from_mtk_view(
//                 &mut context.context,
//                 view,
//                 skia_safe::gpu::SurfaceOrigin::TopLeft,
//                 Some(1),
//                 skia_safe::ColorType::BGRA8888,
//                 None,
//                 Some(&surface_props),
//             ).unwrap()
//         };
//         surface.canvas().clear(skia_safe::colors::TRANSPARENT);
//         let mut paint = skia_safe::Paint::default();
//         paint.set_color(skia_safe::Color::from_rgb(255, 0, 0));
//         surface.canvas().draw_line((0.0, 0.0), (1000.0, 1000.0), &paint);
//         context.surface = Some(surface);
//     });
// }


// #[no_mangle]
// pub extern fn metal_canvas_view_draw_flush_and_submit(
//     metal_view_context_ptr: MetalViewContextPtr,
//     canvas_runtime_context_ptr: CanvasRuntimeContextPtr,
// ) {
//     let f = |metal_view_ctx: &mut MetalViewLayer, canvas_ctx: &mut CanvasRuntimeContext| {
//         let canvas = metal_view_ctx.surface.as_mut().unwrap().canvas();
//         canvas.clear(skia_safe::colors::TRANSPARENT);
//         canvas_ctx.skia_draw(canvas);
//         metal_view_ctx.surface.as_mut().unwrap().flush_and_submit();
//     };
//     Pointer::map_mut_pair(metal_view_context_ptr, canvas_runtime_context_ptr, f);
// }

