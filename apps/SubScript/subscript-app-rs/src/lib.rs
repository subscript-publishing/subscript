#![allow(unused)]
use std::borrow::BorrowMut;
use std::cell::RefCell;
use core_graphics::base::CGFloat;
use core_graphics::context::CGContext;
use core_graphics::sys::CGContextRef;
pub mod canvas;
pub mod utils;
pub(crate) use canvas::Stroke;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// C-API - PRELUDE - SSPointer Wrapper
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[repr(C)]
pub struct SSPointer<T> {
    ptr: *mut T
}

impl<T: Default> Default for SSPointer<T> {
    fn default() -> Self {
        let value = Box::new(T::default());
        let ptr = Box::into_raw(value);
        SSPointer{
            ptr
        }
    }
}

impl<T> SSPointer<T> {
    pub fn with_value<U>(&self, f: impl FnOnce(&mut T) -> U) -> U {
        let mut value: Box<T> = unsafe {
            Box::from_raw(self.ptr)
        };
        let result = f(value.as_mut());
        std::mem::forget(value);
        result
    }
    pub fn get_value(&self) -> &mut T {
        let mut value: Box<T> = unsafe {
            Box::from_raw(self.ptr)
        };
        Box::leak(value)
    }
    pub fn cg_context_with_value<U>(&self, context_ptr: CGContextRef, f: impl FnOnce(&mut CGContext, &mut T) -> U) -> U {
        let mut value: Box<T> = unsafe {Box::from_raw(self.ptr)};
        let mut context = unsafe {CGContext::from_existing_context_ptr(context_ptr)};
        let result = f(&mut context, value.as_mut());
        std::mem::forget(value);
        result
    }
    pub fn free(self) {
        use std::alloc::{dealloc, Layout};
        let ptr = self.ptr;
        unsafe {
            std::ptr::drop_in_place(ptr);
            std::alloc::dealloc(ptr as *mut u8, std::alloc::Layout::new::<SSV1CanvasRuntime>());
        }
        std::mem::drop(self);
    }
}

pub type SSV1CanvasRuntimePtr = SSPointer<SSV1CanvasRuntime>;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// C-API - PRELUDE - VEC
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Default)]
#[repr(C)]
pub struct SSV1Vec<T>(SSPointer<Vec<T>>);

impl<T> SSV1Vec<T> {
    pub fn new() -> SSV1Vec<T> {
        let def: SSPointer<Vec<T>> = SSPointer::default();
        SSV1Vec(def)
    }
    pub fn free(self) {
        self.0.free()
    }
    pub fn into_iter_mut<'a>(&'a mut self) -> std::slice::IterMut<T> {
        let value = self.0.get_value();
        value.iter_mut()
    }
    pub fn into_iter<'a>(&'a self) -> std::slice::Iter<T> {
        let value = self.0.get_value();
        value.iter()
    }
    pub fn get<'a>(&'a self, ix: usize) -> Option<&'a T> {
        let value = self.0.get_value();
        value.get(ix)
    }
    pub fn get_mut<'a>(&'a mut self, ix: usize) -> Option<&'a mut T> {
        let value = self.0.get_value();
        value.get_mut(ix)
    }
    pub fn push(&mut self, new: T) {
        let xs = self.0.get_value();
        xs.push(new)
    }
}


// #[no_mangle]
// pub extern "C" fn ssv1_vec_free(ptr: SSV1Vec) {
//     ptr.free();
// }



//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SSV1 RUNTIME BASICS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Clone, Copy)]
#[no_mangle]
#[repr(C)]
pub enum SSColorScheme {
    SSColorSchemeLight,
    SSColorSchemeDark,
}

impl From<SSColorScheme> for canvas::ColorScheme {
    fn from(value: SSColorScheme) -> Self {
        match value {
            SSColorScheme::SSColorSchemeLight => canvas::ColorScheme::Light,
            SSColorScheme::SSColorSchemeDark => canvas::ColorScheme::Dark,
        }
    }
}

impl Default for SSColorScheme {
    fn default() -> Self {
        SSColorScheme::SSColorSchemeLight
    }
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct SSV1RGBAColor {
    pub red: f64,
    pub green: f64,
    pub blue: f64,
    pub alpha: f64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct SSV1ColorModes {
    pub light: SSV1RGBAColor,
    pub dark: SSV1RGBAColor,
}
impl Default for SSV1ColorModes {
    fn default() -> Self {
        SSV1ColorModes {
            light: SSV1RGBAColor{red: 0.0, blue: 0.0, green: 0.0, alpha: 0.0},
            dark: SSV1RGBAColor{red: 0.0, blue: 0.0, green: 0.0, alpha: 0.0},
        }
    }
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct SSV1Pen {
    pub color: SSV1ColorModes,
}

thread_local! {
    pub static ACTIVE_PEN: RefCell<SSV1Pen> = RefCell::new(SSV1Pen {
        color: SSV1ColorModes::default()
    });
}

#[no_mangle]
pub extern "C" fn ssv1_global_runtime_set_active_pen(new_pen: SSV1Pen) {
    ACTIVE_PEN.with(|cell| {
        let _ = cell.replace(new_pen);
    })
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SSV1-CANVAS-RUNTIME
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
#[derive(Default)]
pub struct SSV1CanvasRuntime {
    color_scheme: Option<SSColorScheme>,
    strokes: Vec<Stroke>,
    active: Stroke,
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SSV1-CANVAS-RUNTIME INIT/FREE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn ssv1_init_canvas_runtime() -> SSV1CanvasRuntimePtr {
    SSPointer::default()
}

#[no_mangle]
pub extern "C" fn ssv1_free_canvas_runtime(ptr: SSV1CanvasRuntimePtr) {
    ptr.free();
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SSV1-CANVAS-RUNTIME METHODS - GESTURE - EVENTS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn ssv1_canvas_runtime_begin_stroke(ptr: SSV1CanvasRuntimePtr) {
    let current_pen = ACTIVE_PEN.with(|cell| {
        cell.borrow().clone()
    });
    ptr.with_value(|canvas_runtime: &mut SSV1CanvasRuntime| {
        canvas_runtime.active.clear();
        canvas_runtime.active.color = canvas::ColorModes::from_c(current_pen.color);
    })
}

#[no_mangle]
pub extern "C" fn ssv1_canvas_runtime_end_stroke(ptr: SSV1CanvasRuntimePtr) {
    ptr.with_value(|canvas_runtime: &mut SSV1CanvasRuntime| {
        let points = canvas_runtime.active.points.drain(..).collect::<Vec<_>>();
        let color = canvas_runtime.active.color.clone();
        let stroke = Stroke {
            points,
            color,
        };
        canvas_runtime.strokes.push(stroke);
    })
}

#[no_mangle]
pub extern "C" fn ssv1_canvas_runtime_record_stroke_point(
    ptr: SSV1CanvasRuntimePtr,
    width: f64,
    height: f64,
    x: f64,
    y: f64,
) {
    ptr.with_value(|canvas_runtime: &mut SSV1CanvasRuntime| {
        canvas_runtime.active.points.push((x, y));
    })
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SSV1-CANVAS-RUNTIME METHODS - UI STATE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn ssv1_canvas_runtime_set_color_scheme(
    ptr: SSV1CanvasRuntimePtr,
    ss_color_scheme: SSColorScheme,
) {
    ptr.with_value(|canvas_runtime: &mut SSV1CanvasRuntime| {
        canvas_runtime.color_scheme = Some(ss_color_scheme);
    })
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SSV1-CANVAS-RUNTIME METHODS - GRAPHICS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[no_mangle]
pub extern "C" fn ssv1_canvas_runtime_draw(
    ptr: SSV1CanvasRuntimePtr,
    width: f64,
    height: f64,
    context: CGContextRef,
) {
    ptr.cg_context_with_value(context, |context: &mut CGContext, canvas_runtime: &mut SSV1CanvasRuntime| {
        let ui_config = canvas::UIConfig {
            color_scheme: canvas_runtime.color_scheme.unwrap_or_default().into(),
            view_frame: canvas::UIFrame{width, height},
        };
        for stroke in canvas_runtime.strokes.iter() {
            stroke.draw(&ui_config, context);
        }
        canvas_runtime.active.draw(&ui_config, context);
    })
}
