use super::data::*;


pub struct DrawContext<'a> {
    canvas: &'a mut skia_safe::Canvas,
    view_info: ViewInfo,
}

pub trait Drawable {
    fn draw(&self, draw_ctx: DrawContext<'_>);
}


