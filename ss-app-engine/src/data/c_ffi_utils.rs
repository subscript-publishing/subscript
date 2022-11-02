use std::borrow::BorrowMut;
use std::cell::RefCell;
use std::io::Read;
use std::marker::PhantomData;
use std::ptr::{null, null_mut};
use std::ffi::c_void;
use std::string::FromUtf8Error;
use rand::AsByteSliceMut;
use uuid::Uuid;
use rayon::prelude::*;
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use serde::ser::SerializeStruct;
use serde::de::{self, Visitor, DeserializeOwned, SeqAccess, MapAccess};


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// POINTER WRAPPER
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


/// A simple pain-free pointer to wrap your types in for FFI export.
#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub struct Pointer<T> {
    ptr: *mut T
}

impl<T> Serialize for Pointer<T> {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error> where S: Serializer {
        // 3 is the number of fields in the struct.
        let mut state = serializer.serialize_struct("Pointer", 1)?;
        state.serialize_field("ptr", &(self.ptr as usize))?;
        state.end()
    }
}

impl<'de, T> Deserialize<'de> for Pointer<T> {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error> where D: Deserializer<'de> {
        enum Field { Ptr }
        impl<'de> Deserialize<'de> for Field {
            fn deserialize<D>(deserializer: D) -> Result<Field, D::Error> where D: Deserializer<'de> {
                struct FieldVisitor;
                impl<'de> Visitor<'de> for FieldVisitor {
                    type Value = Field;
                    fn expecting(&self, formatter: &mut std::fmt::Formatter) -> std::fmt::Result {
                        formatter.write_str("`ptr`")
                    }
                    fn visit_str<E>(self, value: &str) -> Result<Field, E> where E: de::Error {
                        match value {
                            "ptr" => Ok(Field::Ptr),
                            _ => Err(de::Error::unknown_field(value, FIELDS)),
                        }
                    }
                }
                deserializer.deserialize_identifier(FieldVisitor)
            }
        }

        struct PointerVisitor<T>(PhantomData<T>);

        impl<'de, T> Visitor<'de> for PointerVisitor<T> {
            type Value = Pointer<T>;

            fn expecting(&self, formatter: &mut std::fmt::Formatter) -> std::fmt::Result {
                formatter.write_str("struct Pointer")
            }

            fn visit_seq<V>(self, mut seq: V) -> Result<Pointer<T>, V::Error> where V: SeqAccess<'de> {
                let ptr: usize = seq.next_element()?.ok_or_else(|| de::Error::invalid_length(0, &self))?;
                Ok(Pointer {ptr: ptr as *mut T})
            }

            fn visit_map<V>(self, mut map: V) -> Result<Pointer<T>, V::Error> where V: MapAccess<'de> {
                let mut ptr: Option<usize> = None;
                while let Some(key) = map.next_key()? {
                    match key {
                        Field::Ptr => {
                            if ptr.is_some() {
                                return Err(de::Error::duplicate_field("ptr"));
                            }
                            ptr = Some(map.next_value()?);
                        }
                    }
                }
                let ptr = ptr.ok_or_else(|| de::Error::missing_field("ptr"))?;
                Ok(Pointer {ptr: ptr as *mut T})
            }
        }

        const FIELDS: &'static [&'static str] = &["ptr"];
        deserializer.deserialize_struct("Pointer", FIELDS, PointerVisitor(PhantomData))
    }
}

impl<T: Default> Default for Pointer<T> {
    fn default() -> Self {
        let value = Box::new(T::default());
        let ptr = Box::into_raw(value);
        Pointer{ptr}
    }
}

impl<T> Pointer<T> {
    fn from_raw(ptr: usize) -> Pointer<T> {
        let ptr = ptr as *mut T;
        Pointer{ptr: ptr}
    }
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
    pub fn map<U>(&self, f: impl FnOnce(&T) -> U) -> U {
        assert!(!self.ptr.is_null());
        let mut value: Box<T> = unsafe {
            Box::from_raw(self.ptr)
        };
        let result = f(value.as_ref());
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
    pub fn into_cloned(&self) -> T where T: Clone {
        self.map(|x| x.clone())
    }
    pub fn free(self) {
        use std::alloc::{dealloc, Layout};
        assert!(!self.ptr.is_null());
        let ptr = self.ptr;
        unsafe {
            std::ptr::drop_in_place(ptr);
            std::alloc::dealloc(ptr as *mut u8, std::alloc::Layout::new::<T>());
        }
        // self.ptr = null_mut();
        std::mem::drop(self);
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// VEC POINTER WRAPPER
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[repr(C)]
pub struct VecPointer<T>(Pointer<Vec<T>>);

impl<T> VecPointer<T> {
    pub fn new() -> VecPointer<T> {
        let def: Pointer<Vec<T>> = Pointer::default();
        VecPointer(def)
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

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// C ARRAY HELPERS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[repr(C)]
pub struct ByteArrayPointer {
    pub head: *const u8,
    pub len: usize,
}

impl ByteArrayPointer {
    /// This function completely copes the input bytes into dynamic C array VIA `calloc`.
    pub fn from_str(value: &str) -> Self {
        let value = value.as_bytes();
        let array_len = value.len();
        let item_size = std::mem::size_of::<u8>();
        let array = unsafe {
            ::libc::calloc(array_len, item_size)
        };
        let array = array as *mut u8;
        for (ix, byte) in value.iter().enumerate() {
            unsafe {
                let ptr = array.offset(ix as isize);
                *ptr = (*byte as u8);
            }
        }
        ByteArrayPointer {head: array, len: array_len}
    }
    pub fn is_null(&self) -> bool {
        self.head.is_null()
    }
    /// Returns a copy of the underlying value as a string.
    pub fn into_vec_copy(&self) -> Vec<u8> {
        let mut bytes: Vec<u8> = Vec::with_capacity(self.len);
        for ix in 0..self.len {
            unsafe {
                let ptr = self.head.offset(ix as isize);
                bytes.push(*ptr);
            }
        }
        bytes
    }
    /// Returns a copy of the underlying value as a string.
    pub fn into_string_copy(&self) -> Result<String, FromUtf8Error> {
        String::from_utf8(self.into_vec_copy())
    }
    /// Frees the allocated bytes. 
    pub unsafe fn free(self) {
        libc::free(self.head as *mut c_void);
    }
}

// impl<T> ByteArrayPointer<T> {
//     /// This function completely copes the input bytes into dynamic C array VIA `calloc`.
//     pub fn new(value: &T) -> Self {
//         let value = value.as_bytes();
//         let len = value.len();
//         let size = std::mem::size_of::<u8>();
//         let array = unsafe {
//             ::libc::calloc(len, size)
//         };
//         let array = array as *mut u8;
//         for (ix, byte) in value.iter().enumerate() {
//             unsafe {
//                 let ptr = array.offset(ix as isize);
//                 *ptr = (*byte as u8);
//             }
//         }
//         let type_marker: PhantomData<T> = PhantomData;
//         ByteArrayPointer {head: array, len, type_marker}
//     }
//     pub fn free(self) {
//         unsafe {
//             // libc::free(self.head as *mut c_void);
//         }
//     }
// }


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// String Helpers
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

pub type UTF8StringPointer = ByteArrayPointer;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// EXPERIMENTAL
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

struct DeserializeFromPointerVisitor<T>(PhantomData<T>);


#[derive(Debug)]
pub struct FromPointer<T>(T);

impl<'de, T> Visitor<'de> for DeserializeFromPointerVisitor<T> where T: Clone {
    type Value = T;

    fn expecting(&self, formatter: &mut std::fmt::Formatter) -> std::fmt::Result {
        formatter.write_str("TODO")
    }

    fn visit_u64<E>(self, pointer: u64) -> Result<Self::Value, E> where E: de::Error {
        use std::usize;
        assert!(format!("{pointer}") == format!("{}", pointer as usize));
        let pointer: Pointer<T> = Pointer::from_raw(pointer as usize);
        let value: T = pointer.map(|x| x.clone());
        Ok(value)
    }
}

impl<'de, T: Clone + Deserialize<'de>> Deserialize<'de> for FromPointer<T> {
    fn deserialize<D>(deserializer: D) -> Result<FromPointer<T>, D::Error> where D: Deserializer<'de> {
        let visitor: DeserializeFromPointerVisitor<T> = DeserializeFromPointerVisitor(PhantomData);
        let result = deserializer.deserialize_u64(visitor)?;
        Ok(FromPointer(result))
    }
}


pub fn dev() {
    let test: Pointer<usize> = Pointer::new(100);
    let value = test.ptr as usize;
    let value = format!("{value}");
    let result = serde_json::from_str::<FromPointer<usize>>(&value);
    println!("result: {:#?}", result);

}

