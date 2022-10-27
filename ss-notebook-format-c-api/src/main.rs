#![allow(unused)]
use std::borrow::BorrowMut;
use std::cell::RefCell;
use core_graphics::base::CGFloat;
use core_graphics::context::CGContext;
use core_graphics::sys::CGContextRef;

// pub extern crate ss_notebook_format;

pub mod c_helpers;
pub mod canvas_runtime;
pub mod global_runtime;
pub mod toolbar_runtime;
pub mod skia_engine;
pub mod utils;
pub mod data;

fn main() {
    use data::HighCapacityVec;
    let mut alpha: HighCapacityVec<usize> = HighCapacityVec::new(500_000, 100_000);
    let mut beta: Vec<usize> = Vec::with_capacity(500_000);
    for ix in 1..1_000_000 {
        alpha.push(ix);
        beta.push(ix);
        let alpha_len = alpha.len();
        let alpha_cap = alpha.capacity();
        let beta_len = beta.len();
        let beta_cap = beta.capacity();
        if alpha_cap != beta_cap {
            println!("!= {alpha_len} {alpha_cap} :: {beta_len} {beta_cap}");
        } else {
            println!("== {alpha_len} {alpha_cap} :: {beta_len} {beta_cap}");
        }
    }
    // text.push(1);
    // text.push(1);
    // println!("{} {}", text.len(), text.capacity());
    // text.push(1);
    // println!("{} {}", text.len(), text.capacity());
}
