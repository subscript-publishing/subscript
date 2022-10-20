use core_graphics::context::CGContext;

#[derive(Debug, Clone, Copy)]
pub struct Point {
    x: f64,
    y: f64,
}

pub enum ToolType {
    Pen,
    Eraser,
}

#[derive(Debug, Clone)]
pub enum DrawingOp {
    PenStroke(),
    Transform(),
    EraserStroke(),
}

#[derive(Debug, Clone)]
pub enum ColorScheme {
    Light,
    Dark,
}

impl ColorScheme {
    pub fn is_light_mode(&self) -> bool {
        match self {
            ColorScheme::Light => true,
            _ => false,
        }
    }
    pub fn is_dark_mode(&self) -> bool {
        match self {
            ColorScheme::Dark => true,
            _ => false,
        }
    }
}

#[derive(Debug, Clone)]
pub struct UIFrame {
    pub width: f64,
    pub height: f64,
}

#[derive(Debug, Clone)]
pub struct UIConfig {
    pub color_scheme: ColorScheme,
    pub view_frame: UIFrame,
}

#[derive(Debug, Clone, Default)]
pub struct Color {
    red: f64,
    blue: f64,
    green: f64,
    alpha: f64,
}

impl Color {
    pub fn from_c(value: crate::SSV1RGBAColor) -> Self {
        Color { red: value.red, blue: value.blue, green: value.green, alpha: value.alpha }
    }
    pub fn white() -> Self {
        Color { red: 1.0, blue: 1.0, green: 1.0, alpha: 1.0 }
    }
    pub fn black() -> Self {
        Color { red: 0.0, blue: 0.0, green: 0.0, alpha: 0.0 }
    }
}

#[derive(Debug, Clone)]
pub struct ColorModes {
    light: Color,
    dark: Color,
}

impl ColorModes {
    pub fn from_c(value: crate::SSV1ColorModes) -> Self {
        ColorModes{
            light: Color::from_c(value.light),
            dark: Color::from_c(value.dark),
        }
    }
    pub fn set_cg_context_color(&self, config: &UIConfig, context: &mut CGContext) {
        match config.color_scheme {
            ColorScheme::Dark => {
                context.set_rgb_stroke_color(self.dark.red, self.dark.green, self.dark.blue, self.dark.alpha)
            }
            ColorScheme::Light => {
                context.set_rgb_stroke_color(self.light.red, self.light.green, self.light.blue, self.light.alpha)
            }
        }
    }
}

impl Default for ColorModes {
    fn default() -> Self {
        ColorModes {
            light: Color::black(),
            dark: Color::white(),
        }
    }
}

#[derive(Clone, Debug, Default)]
pub struct Stroke {
    pub points: Vec<(f64, f64)>,
    pub color: ColorModes,
}

impl Stroke {
    pub fn draw(&self, config: &UIConfig, context: &mut CGContext) {
        if self.points.is_empty() {
            return ()
        }
        context.begin_path();
        self.color.set_cg_context_color(config, context);
        for (ix, (x, y)) in self.points.iter().enumerate() {
            if ix == 0 {
                context.move_to_point(*x, *y);
                continue;
            }
            context.add_line_to_point(*x, *y);
        }
        // context.close_path();
        context.stroke_path();
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// CANVAS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

pub struct Canvas {

}