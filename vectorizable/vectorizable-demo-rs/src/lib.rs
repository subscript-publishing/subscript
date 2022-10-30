#![allow(unused)]
use std::borrow::BorrowMut;
use std::cell::{RefCell, Cell};
use std::rc::Rc;
use core_graphics::base::CGFloat;
use core_graphics::context::CGContext;
use core_graphics::sys::CGContextRef;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use itertools::Itertools;
use rayon::prelude::*;
use uuid::Uuid;
use geo::{ConcaveHull, Scale, ConvexHull};
use std::ffi::c_void;

pub use c_ffi_utils::Pointer;
use c_ffi_utils::*;
// use vectorizable::data::RGBA;
// pub use vectorizable::data::Point;
// pub use vectorizable::metal_backend::MetalBackendContext;


impl SceneObject {
    pub(crate) fn skia_draw(&self, canvas: &mut skia_safe::Canvas) {
        // if self.points.len() < 2 { return () }
        // let points = self.points
        //     .iter()
        //     .map(|point| {
        //         let x = point.x;
        //         let y = point.y;
        //         skia_safe::Point{x: x * 2.0, y: y * 2.0}
        //     })
        //     .collect_vec();
        // let path = skia_safe::Path::polygon(&points, true, None, None);
        // let line = skia_safe::Pol
        let mut paint = skia_safe::Paint::default();
        let color = skia_safe::Color4f::new(
            self.color.red as f32,
            self.color.blue as f32,
            self.color.green as f32,
            self.color.alpha as f32,
        );
        paint.set_color4f(&color, None);
        paint.set_anti_alias(true);
        paint.set_style(skia_safe::PaintStyle::Stroke);
        paint.set_stroke_width(20.0);
        paint.set_alpha(150);
        let mut path = skia_safe::Path::new();
        for (ix, point) in self.points.iter().enumerate() {
            let x = point.x;
            let y = point.y;
            let point = skia_safe::Point{x: x * 2.0, y: y * 2.0};
            if ix == 0 {
                path.move_to(point);
                continue;
            }
            path.line_to(point);
        }
        canvas.draw_path(&path, &paint);
    }
}

impl SceneApi {
    pub(crate) fn skia_draw(&self, canvas: &mut skia_safe::Canvas) {
        for path in self.objects.iter() {
            path.skia_draw(canvas);
        }
    }
}

#[repr(transparent)]
pub struct PointSlice([Point]);


#[derive(Debug, Clone)]
pub struct SceneObject {
    pub id: Uuid,
    pub points: Vec<Point>,
    pub color: RGBA,
}

pub trait PathRenderable {
    fn id(&self) -> Uuid;
    fn points(&self) -> &[Point];
    fn color(&self) -> RGBA;
}


pub struct SceneApi {
    pub(crate) objects: Vec<SceneObject>,
}

impl SceneApi {
    pub(crate) fn new() -> Self {
        SceneApi {
            objects: Default::default(),
        }
    }
    pub fn register_path<T: PathRenderable>(&mut self, renderable: &T) {
        let object = SceneObject {
            id: renderable.id(),
            points: renderable.points().to_vec(),
            color: renderable.color(),
        };
        self.objects.push(object);
    }
}


pub trait Scene {
    fn init_scene(&self, api: &mut SceneApi);
}

pub trait IncrementalScene: Scene {
    fn needs_refresh(&self) -> bool;
    fn post_refresh_flush(&mut self);
    fn incremental_update(&self, api: &mut SceneApi);
    fn post_update_flush(&mut self);
}


pub struct MetalBackendContext {
    backend: skia_safe::gpu::mtl::BackendContext,
    context: skia_safe::gpu::DirectContext,
    surface: Option<skia_safe::surface::Surface>,
    new_surface: bool,
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
            new_surface: true,
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
        self.new_surface = true;
        println!("MetalBackendContext::refresh_view")
    }
    pub fn draw<T: Scene>(&mut self, scene_object: &T) {
        let surface = self.surface.as_mut().unwrap();
        let mut canvas = surface.canvas();
        canvas.clear(skia_safe::colors::TRANSPARENT);
        let mut scene_api = SceneApi::new();
        scene_object.init_scene(&mut scene_api);
        scene_api.skia_draw(&mut canvas);
        surface.flush_and_submit();
    }
    pub fn incremental_draw<T: IncrementalScene>(&mut self, scene_object: &mut T) {
        let surface = self.surface.as_mut().unwrap();
        let mut canvas = surface.canvas();
        let mut scene_api = SceneApi::new();
        canvas.clear(skia_safe::colors::TRANSPARENT);
        if scene_object.needs_refresh() || self.new_surface {
            scene_object.init_scene(&mut scene_api);
            scene_object.post_refresh_flush();
            self.new_surface = false;
        } else {
            scene_object.incremental_update(&mut scene_api);
            scene_object.post_update_flush();
        }
        scene_api.skia_draw(&mut canvas);
        surface.flush_and_submit();
    }
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[repr(C)]
pub struct Point {
    pub x: f32,
    pub y: f32,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[repr(C)]
pub struct RGBA {
    pub red: f64,
    pub green: f64,
    pub blue: f64,
    pub alpha: f64,
}

impl Default for RGBA {
    fn default() -> Self {
        RGBA::red()
    }
}

impl RGBA {
    pub fn white() -> Self {
        RGBA {red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0}
    }
    pub fn black() -> Self {
        RGBA {red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0}
    }
    pub fn red() -> Self {
        RGBA {red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0}
    }
    pub fn green() -> Self {
        RGBA {red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0}
    }
    pub fn blue() -> Self {
        RGBA {red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0}
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// APP-MODEL
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

pub type AppModelPtr = Pointer<AppModel>;

#[derive(Debug, Clone, Default)]
struct Stroke {
    id: Uuid,
    points: Vec<Point>,
    color: RGBA,
}

impl Stroke {
    fn new(points: impl IntoIterator<Item=Point>) -> Self {
        let points = points.into_iter().collect_vec();
        Stroke {id: Uuid::new_v4(), points, color: RGBA::red()}
    }
    pub fn copy_from(stroke: &Self) -> Self {
        let points = stroke.points.iter().cloned().collect_vec();
        let mut new_stroke = Stroke::new(points);
        new_stroke.color = stroke.color;
        new_stroke
    }
    pub fn drain_from(stroke: &mut Self) -> Self {
        let mut new_stroke = Stroke::new(stroke.points.drain(..));
        new_stroke.color = stroke.color;
        new_stroke
    }
}

impl PathRenderable for Stroke {
    fn id(&self) -> Uuid {
        self.id
    }
    fn points(&self) -> &[Point] {
        &self.points
    }
    fn color(&self) -> RGBA {
        self.color
    }
}

// impl RgbaColorable for Stroke {
//     fn dark_ui_color(&self) -> RGBA {
//         RGBA::white()
//     }
//     fn light_ui_color(&self) -> RGBA {
//         RGBA::black()
//     }
// }



#[derive(Debug, Clone, Copy, PartialEq)]
enum LayerType {
    Foreground,
    Background,
}

impl Default for LayerType {
    fn default() -> Self {
        LayerType::Foreground
    }
}

#[derive(Debug, Clone, Default)]
pub struct Layer {
    drawn_strokes: Vec<Stroke>,
    new_strokes: Vec<Stroke>,
    needs_refresh: bool,
}

impl Scene for Layer {
    fn init_scene(&self, api: &mut SceneApi) {
        for stroke in self.drawn_strokes.iter().chain(self.new_strokes.iter()) {
            api.register_path(stroke);
        }
    }
}

impl IncrementalScene for Layer {
    fn needs_refresh(&self) -> bool {
        self.needs_refresh
    }
    fn post_refresh_flush(&mut self) {
        self.needs_refresh = false;
        self.post_update_flush();
    }
    fn incremental_update(&self, api: &mut SceneApi) {
        for stroke in self.new_strokes.iter() {
            api.register_path(stroke);
        }
    }
    fn post_update_flush(&mut self) {
        self.drawn_strokes.append(&mut self.new_strokes);
    }
}

#[derive(Debug, Clone, Default)]
struct ActiveLayer {
    active_stack: Vec<Stroke>,
    active_stroke: Stroke,
}

impl ActiveLayer {
    fn finalize_active_stroke(&mut self) {
        if !self.active_stroke.points.is_empty() {
            let new_stroke = Stroke::drain_from(&mut self.active_stroke);
            self.active_stack.push(new_stroke);
        }
    }
}

impl Scene for ActiveLayer {
    fn init_scene(&self, api: &mut SceneApi) {
        for stroke in self.active_stack.iter() {
            api.register_path(stroke);
        }
        if !self.active_stroke.points.is_empty() {
            api.register_path(&self.active_stroke);
        }
    }
}

thread_local! {
    static CURRENT_LAYER: RefCell<LayerType> = RefCell::new(LayerType::default());
}

#[no_mangle]
pub extern "C" fn toolbar_set_current_layer_to_foreground() {
    CURRENT_LAYER.with(|cell| {
        *cell.borrow_mut() = LayerType::Foreground;
        assert!(*cell.borrow() == LayerType::Foreground);
    })
}

#[no_mangle]
pub extern "C" fn toolbar_set_current_layer_to_background() {
    CURRENT_LAYER.with(|cell| {
        *cell.borrow_mut() = LayerType::Background;
        assert!(*cell.borrow() == LayerType::Background);
    })
}

fn get_current_layer() -> LayerType {
    CURRENT_LAYER.with(|toolbar| toolbar.borrow().clone())
}

#[derive(Debug, Clone)]
pub struct AppModel {
    background: Layer,
    background_active: ActiveLayer,
    foreground: Layer,
    foreground_active: ActiveLayer,
    currently_drawing: bool,
}

impl Default for AppModel {
    fn default() -> Self {
        let mut app_model = AppModel {
            background: Default::default(),
            background_active: Default::default(),
            foreground: Default::default(),
            foreground_active: Default::default(),
            currently_drawing: false,
        };
        app_model.background_active.active_stroke.color = RGBA::blue();
        app_model.foreground_active.active_stroke.color = RGBA::green();
        app_model
    }
}

impl AppModel {
    fn try_flush(&mut self) {
        if !self.currently_drawing {
            self.force_flush();
        }
    }
    fn force_flush(&mut self) {
        assert!(!self.currently_drawing);
        assert!(self.background_active.active_stroke.points.is_empty());
        assert!(self.foreground_active.active_stroke.points.is_empty());
        self.background.new_strokes.append(&mut self.background_active.active_stack);
        self.foreground.new_strokes.append(&mut self.foreground_active.active_stack);
    }
    fn begin_stroke(&mut self) {
        self.background_active.finalize_active_stroke();
        self.foreground_active.finalize_active_stroke();
        assert!(self.background_active.active_stroke.points.is_empty());
        assert!(self.foreground_active.active_stroke.points.is_empty());
        self.currently_drawing = true;
    }
    fn record_stroke_point(&mut self, point: Point) {
        let current_layer = get_current_layer();
        match current_layer {
            LayerType::Background => {
                self.background_active.active_stroke.points.push(point);
            }
            LayerType::Foreground => {
                self.foreground_active.active_stroke.points.push(point);
            }
        }
    }
    fn end_stroke(&mut self) {
        self.currently_drawing = false;
        self.background_active.finalize_active_stroke();
        self.foreground_active.finalize_active_stroke();
    }
    fn draw_background(&mut self, metal_ctx: &mut MetalBackendContext) {
        metal_ctx.draw(&self.background);
    }
    fn draw_background_active(&mut self, metal_ctx: &mut MetalBackendContext) {
        metal_ctx.draw(&self.background_active);
    }
    fn draw_foreground(&mut self, metal_ctx: &mut MetalBackendContext) {
        metal_ctx.incremental_draw(&mut self.foreground);
    }
    fn draw_foreground_active(&mut self, metal_ctx: &mut MetalBackendContext) {
        metal_ctx.draw(&self.foreground_active);
    }
}



//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// APP-MODEL - INIT/FREE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn app_model_new() -> AppModelPtr {
    Pointer::default()
}
#[no_mangle]
pub extern "C" fn app_model_free(ptr: AppModelPtr) {
    ptr.free();
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// APP-MODEL - METHODS - GESTURE - EVENTS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn app_model_begin_stroke(ptr: AppModelPtr) {
    ptr.map_mut(|model| model.begin_stroke())
}
#[no_mangle]
pub extern "C" fn app_model_record_stroke_sample(
    ptr: AppModelPtr,
    point: Point,
) {
    ptr.map_mut(|model| model.record_stroke_point(point))
}
#[no_mangle]
pub extern "C" fn app_model_end_stroke(ptr: AppModelPtr) {
    ptr.map_mut(|model| model.end_stroke())
}
#[no_mangle]
pub extern "C" fn app_model_try_flush(ptr: AppModelPtr) {
    ptr.map_mut(|model| model.try_flush())
}
#[no_mangle]
pub extern "C" fn app_model_force_flush(ptr: AppModelPtr) {
    ptr.map_mut(|model| model.force_flush())
}


// #[no_mangle]
// pub extern "C" fn app_model_set_active_layer_to_foreground(ptr: AppModelPtr) {
//     ptr.map_mut(|model| {
//         model.set_active_layer(LayerType::Foreground)
//     })
// }
// #[no_mangle]
// pub extern "C" fn app_model_set_active_layer_to_background(ptr: AppModelPtr) {
//     ptr.map_mut(|model| {
//         model.set_active_layer(LayerType::Foreground)
//     })
// }

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// METAL BACKEND
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


pub type MetalBackendContextPtr = Pointer<MetalBackendContext>;

#[no_mangle]
pub extern fn vectorizable_metal_backend_context_init(
    device: *mut c_void,
    queue: *mut c_void,
) -> MetalBackendContextPtr {
    let context = MetalBackendContext::new(device, queue);
    Pointer::new(context)
}


#[no_mangle]
pub extern fn vectorizable_metal_backend_context_reload_view_surface(
    metal_backend_context_ptr: MetalBackendContextPtr,
    view: *const c_void,
) {
    let f = |metal_backend_context: &mut MetalBackendContext| {
        metal_backend_context.reload_view_surface(view);
    };
    metal_backend_context_ptr.map_mut(f)
}

#[repr(C)]
pub enum DrawResult {
    Success,
    Error
}


#[no_mangle]
pub extern fn vectorizable_draw_flush_and_submit_background(
    metal_backend_context_ptr: MetalBackendContextPtr,
    app_model_ptr: AppModelPtr,
    view: *const c_void,
) {
    let f = |metal_ctx: &mut MetalBackendContext, app_model: &mut AppModel| {
        app_model.draw_background(metal_ctx);
    };
    Pointer::map_mut_pair(metal_backend_context_ptr, app_model_ptr, f)
}


#[no_mangle]
pub extern fn vectorizable_draw_flush_and_submit_background_active(
    metal_backend_context_ptr: MetalBackendContextPtr,
    app_model_ptr: AppModelPtr,
    view: *const c_void,
) {
    let f = |metal_ctx: &mut MetalBackendContext, app_model: &mut AppModel| {
        app_model.draw_background_active(metal_ctx);
    };
    Pointer::map_mut_pair(metal_backend_context_ptr, app_model_ptr, f)
}


#[no_mangle]
pub extern fn vectorizable_draw_flush_and_submit_foreground(
    metal_backend_context_ptr: MetalBackendContextPtr,
    app_model_ptr: AppModelPtr,
    view: *const c_void,
) {
    let f = |metal_ctx: &mut MetalBackendContext, app_model: &mut AppModel| {
        app_model.draw_foreground(metal_ctx);
    };
    Pointer::map_mut_pair(metal_backend_context_ptr, app_model_ptr, f)
}


#[no_mangle]
pub extern fn vectorizable_draw_flush_and_submit_foreground_active(
    metal_backend_context_ptr: MetalBackendContextPtr,
    app_model_ptr: AppModelPtr,
    view: *const c_void,
) {
    let f = |metal_ctx: &mut MetalBackendContext, app_model: &mut AppModel| {
        app_model.draw_foreground_active(metal_ctx);
    };
    Pointer::map_mut_pair(metal_backend_context_ptr, app_model_ptr, f)
}



