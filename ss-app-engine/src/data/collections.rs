//! Data utilities 
use serde::{Serializer, Deserializer, Serialize, Deserialize};
use std::ops::RangeBounds;
use std::slice::{Iter, IterMut};
use std::vec::IntoIter;
use rayon::prelude::*;


/// This data structure is a wrapper around `Vec` that preallocates memory in
/// chunks VIA the chunk size field. Which interesting, I’ve since discovered
/// that this is already the default behavior of `Vec` if it’s been initialized
/// with the `Vec::with_capacity` method. 
/// 
/// **Although**, I’m not sure if this is a platform specific optimization for
/// environments with relatively high memory capacity (such as my desktop),
/// specially, I’m not sure if this also applies to mobile devices. I could
/// test this but at the moment it seems easier to just use this wrapper which
/// will ensure consistent behavior and find out later if this data structure
/// is redundant. 
/// 
/// One benefit of keeping this around is that I may want to alter the
/// behavior at some point, such as e.g. starting with a given initial
/// capacity, and thereafter grow the vec using a different value.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HighCapacityVec<T> {
    data: Vec<T>,
    initial_capacity: usize,
    reallocation_capacity_chunk_size: usize,
}

impl<T> HighCapacityVec<T> {
    pub fn new(
        initial_capacity: usize,
        reallocation_capacity_chunk_size: usize,
    ) -> Self {
        let vec = Vec::with_capacity(initial_capacity);
        HighCapacityVec {data: vec, initial_capacity, reallocation_capacity_chunk_size}
    }
    pub fn capacity(&self) -> usize {
        self.data.capacity()
    }
    pub fn len(&self) -> usize {
        self.data.len()
    }
    pub fn iter(&self) -> Iter<T> {
        self.data.iter()
    }
    pub fn iter_mut(&mut self) -> IterMut<T> {
        self.data.iter_mut()
    }
    pub fn into_iter(self) -> IntoIter<T> {
        self.data.into_iter()
    }
    pub fn get(&self, index: usize) -> Option<&T> {
        self.data.get(index)
    }
    pub fn get_mut(&mut self, index: usize) -> Option<&mut T> {
        self.data.get_mut(index)
    }
    pub fn drain(&mut self, range: impl RangeBounds<usize>) -> std::vec::Drain<T> {
        self.data.drain(range)
    }
    pub fn clear(&mut self) {
        self.data.clear()
    }
    /// Instead of calling `Vec::reserve_exact`, we instead call `vec::reserve`
    /// which may speculatively over-allocate, which may be problematic with
    /// very high initial capacity values on more memory constrained devices
    /// (I’m not sure if the defaults are different on such platforms). 
    pub fn push(&mut self, value: T) {
        let len = self.data.len();
        let capacity = self.data.capacity();
        if len == capacity {
            //
            self.data.reserve(self.reallocation_capacity_chunk_size);
        }
        self.data.push(value);
    }
}
impl<T> AsRef<[T]> for HighCapacityVec<T> {
    fn as_ref(&self) -> &[T] {
        self.data.as_ref()
    }
}
impl<T> HighCapacityVec<T> where T: Send {
    pub fn par_iter_mut(&mut self) -> rayon::slice::IterMut<T> {
        self.data.par_iter_mut()
    }
    pub fn into_par_iter(self) -> rayon::vec::IntoIter<T> {
        self.data.into_par_iter()
    }
}
