//! For those who like to critique things, maybe in the future I’ll reorganize
//! the following modules: 
//! 
//! - `drawing.rs`
//! - `drawing_utils.rs`
//! - `drawing_traits.rs`
//! - `geometry.rs`
//! - `geometry_utils.rs`
//! - `geometry_traits.rs`
//! - …
//! 
//! Into nested folders:
//! - `drawing.rs`
//! - `drawing.rs/utils.rs`
//! - `drawing/traits.rs`
//! - `geometry.rs`
//! - `geometry/utils.rs`
//! - `geometry/traits.rs`
//! - …
//! 
//! But part of me actually kinda has a preference to only nest modules no
//! more than a couple layers deep, it’s just faster to move around in
//! my text editor. 
//! 
//! Coming from the Haskell world, it’s not uncommon to see modules nested
//! under several layers of folders (and now it just seems like a pain),
//! which I used to follow until I got into rust where the community seems
//! to be more conservative (relatively speaking) about nested module depth.

pub mod collections;
pub mod runtime;
pub mod notebook;
pub mod c_ffi_utils;
pub mod archive;

pub mod drawing;
pub mod drawing_impl;

pub mod graphics;
pub mod graphics_impl;

pub use drawing::*;
pub use drawing_impl::*;

pub use graphics::*;
pub use graphics_impl::*;
