use std::borrow::BorrowMut;
use std::cell::RefCell;
use core_graphics::base::CGFloat;
use core_graphics::context::CGContext;
use core_graphics::sys::CGContextRef;



//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// C-API - PRELUDE - Pointer Wrapper
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[repr(C)]
pub struct Pointer<T> {
    ptr: *mut T
}

impl<T: Default> Default for Pointer<T> {
    fn default() -> Self {
        let value = Box::new(T::default());
        let ptr = Box::into_raw(value);
        Pointer{ptr}
    }
}

impl<T> Pointer<T> {
    pub fn new(value: T) -> Self {
        let value = Box::new(value);
        let ptr = Box::into_raw(value);
        Pointer{ptr}
    }
    pub fn map_mut_pair<U, V>(
        first: Pointer<T>,
        second: Pointer<U>,
        f: impl FnOnce(&mut T, &mut U) -> V
    ) -> V {
        assert!(!first.ptr.is_null());
        assert!(!second.ptr.is_null());
        let mut first_value: Box<T> = unsafe {
            Box::from_raw(first.ptr)
        };
        let mut second_value: Box<U> = unsafe {
            Box::from_raw(second.ptr)
        };
        let result = f(first_value.as_mut(), second_value.as_mut());
        std::mem::forget(first_value);
        std::mem::forget(second_value);
        result
    }
    pub fn map_mut<U>(&self, f: impl FnOnce(&mut T) -> U) -> U {
        assert!(!self.ptr.is_null());
        let mut value: Box<T> = unsafe {
            Box::from_raw(self.ptr)
        };
        let result = f(value.as_mut());
        std::mem::forget(value);
        result
    }
    pub fn get_value(&self) -> &mut T {
        assert!(!self.ptr.is_null());
        let mut value: Box<T> = unsafe {
            Box::from_raw(self.ptr)
        };
        Box::leak(value)
    }
    pub fn free(self) {
        use std::alloc::{dealloc, Layout};
        assert!(!self.ptr.is_null());
        let ptr = self.ptr;
        unsafe {
            std::ptr::drop_in_place(ptr);
            std::alloc::dealloc(ptr as *mut u8, std::alloc::Layout::new::<T>());
        }
        std::mem::drop(self);
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// C-API - PRELUDE - VEC
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Default)]
#[repr(C)]
pub struct SSV1Vec<T>(Pointer<Vec<T>>);

impl<T> SSV1Vec<T> {
    pub fn new() -> SSV1Vec<T> {
        let def: Pointer<Vec<T>> = Pointer::default();
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
