use super::{ViewInfo, DrawStatus};

pub trait SkiaDrawable {
    fn draw(&self, view_info: ViewInfo, canvas: &mut skia_safe::Canvas) -> Option<DrawStatus>;
}

