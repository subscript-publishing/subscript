use std::borrow::BorrowMut;
use std::cell::{RefCell, Cell, RefMut, Ref};
use std::fmt::Debug;
use std::rc::Rc;
use std::collections::VecDeque;
use wasm_bindgen::prelude::*;
use wasm_bindgen::JsCast;
use web_sys::{HtmlCanvasElement, CanvasRenderingContext2d, HtmlElement, SvgsvgElement, SvgPathElement, MouseEvent};

// ////////////////////////////////////////////////////////////////////////////
// MISCELLANEOUS
// ////////////////////////////////////////////////////////////////////////////

pub fn new_linear_scale(
    domain: (f64, f64),
    range: (f64, f64)
) -> impl Fn(f64) -> f64 {
    move |value: f64| {
        let min_domain = domain.0;
        let max_domain = domain.1;
        let min_range = range.0;
        let max_range = range.1;
        return (max_range - min_range) * (value - min_domain) / (max_domain - min_domain) + min_range
    }
}

#[derive(Default, Debug)]
pub struct Memory<T>(Rc<RefCell<T>>);

impl<T> Clone for Memory<T> {
    fn clone(&self) -> Self {
        Memory(self.0.clone())
    }
}

impl<T> Memory<T> {
    pub fn new(x: T) -> Self {
        Memory(Rc::new(RefCell::new(x)))
    }
    pub fn borrow_mut<'a>(&'a self) -> RefMut<T> {
        let x = self.0.as_ref();
        let y = x.borrow_mut();
        y
    }
    pub fn borrow<'a>(&'a self) -> Ref<T> {
        self.0.borrow()
    }
    pub fn into_clone(&self) -> T where T: Clone {
        self.0.borrow()
            .clone()
    }
}



// ////////////////////////////////////////////////////////////////////////////
// DOM & JAVASCRIPT HELPERS
// ////////////////////////////////////////////////////////////////////////////

fn window() -> web_sys::Window {
    web_sys::window().expect("no global `window` exists")
}
fn document() -> web_sys::Document {
    window()
        .document()
        .expect("should have a document on window")
}

fn body() -> web_sys::HtmlElement {
    document().body().expect("document should have a body")
}


fn request_animation_frame(f: &Closure<dyn FnMut()>) {
    window()
        .request_animation_frame(f.as_ref().unchecked_ref())
        .expect("should register `requestAnimationFrame` OK");
}

macro_rules! log {
    ( $( $t:tt )* ) => {
        web_sys::console::log_1(&format!( $( $t )* ).into());
    }
}


// ////////////////////////////////////////////////////////////////////////////
// DOM & JAVASCRIPT HELPERS - CALLBACKS
// ////////////////////////////////////////////////////////////////////////////

#[derive(Clone)]
pub struct CallbackSettings {
    pub stop_propagation: bool,
    pub prevent_default: bool,
}

impl CallbackSettings {
    fn callback_settings_handler(&self, value: &JsValue) {
        let event: web_sys::Event = From::from(value.clone());
        if self.prevent_default {
            event.prevent_default();
        }
        if self.stop_propagation {
            event.stop_propagation();
        }
    }
}


#[derive(Clone)]
pub struct QueueCallback<T> {
    settings: CallbackSettings,
    bindgen_closure: Rc<Closure<dyn Fn(JsValue)>>,
    events: Rc<RefCell<VecDeque<T>>>,
}

impl<T: 'static> QueueCallback<T> {
    pub fn new(
        dom_ref: web_sys::Element,
        event_type: &str,
        settings: CallbackSettings,
        parser: impl Fn(&JsValue) -> Option<T> + 'static,
    ) -> Self {
        let events_queue: Rc<RefCell<VecDeque<T>>> = Rc::new(RefCell::new(VecDeque::new()));
        let bindgen_closure: Closure<dyn Fn(JsValue)> = Closure::wrap(Box::new({
            let events_queue = events_queue.clone();
            let settings = settings.clone();
            move |value: JsValue| {
                settings.callback_settings_handler(&value);
                if let Some(x) = parser(&value) {
                    // events_queue
                    //     .borrow_mut()
                    //     .push_back(x);
                    unimplemented!()
                }
            }
        }));
        let js_function: &js_sys::Function = bindgen_closure.as_ref().unchecked_ref();
        dom_ref.add_event_listener_with_callback(event_type, js_function);
        QueueCallback {
            settings: settings.clone(),
            bindgen_closure: Rc::new(bindgen_closure),
            events: events_queue
        }
    }
    pub fn drain(&self) -> Vec<T> {
        // self.events.borrow_mut().drain(..).collect::<Vec<_>>()
        unimplemented!()
    }
    pub fn drain_for_each(&self, f: impl FnMut(T)) {
        // self.events
        //     .borrow_mut()
        //     .drain(..)
        //     .for_each(f)
        unimplemented!()
    }
}
impl<T: Debug> std::fmt::Debug for QueueCallback<T> {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "QueueCallback")
    }
}


#[derive(Clone)]
pub struct SimpleCallback {
    settings: CallbackSettings,
    callback: Option<Rc<dyn Fn(JsValue)>>,
    bindgen_closure: Rc<Closure<dyn Fn(JsValue)>>,
}
impl SimpleCallback {
    pub fn new(
        dom_ref: &web_sys::Element,
        event_type: &str,
        settings: CallbackSettings,
        callback: impl Fn(JsValue) + 'static
    ) -> Self {
        let callback = Rc::new(callback);
        let bindgen_closure: Closure<dyn Fn(JsValue)> = Closure::wrap(Box::new({
            let callback = callback.clone();
            let settings = settings.clone();
            move |value: JsValue| {
                settings.callback_settings_handler(&value);
                callback(value);
            }
        }));
        let js_function: &js_sys::Function = bindgen_closure.as_ref().unchecked_ref();
        dom_ref.add_event_listener_with_callback(event_type, js_function);
        SimpleCallback {settings, callback: Some(callback), bindgen_closure: Rc::new(bindgen_closure)}
    }
}
impl std::fmt::Debug for SimpleCallback {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "SimpleCallback")
    }
}


// ////////////////////////////////////////////////////////////////////////////
// DATA TYPES
// ////////////////////////////////////////////////////////////////////////////


#[derive(Debug, Clone, Default)]
pub struct StrokePath {
    pub samples: Vec<(f64, f64)>,
}

impl StrokePath {
    pub fn new() -> Self {
        StrokePath {
            samples: Default::default()
        }
    }
    pub fn tick(&mut self, ctx: &CanvasRenderingContext2d, (width, height, dpi): (f64, f64, f64)) {
        // use cavalier_contours::pline_closed;
        // use cavalier_contours::{pline_closed};
        use cavalier_contours::polyline::PlineVertex;
        use cavalier_contours::polyline::Polyline;
        use cavalier_contours::polyline::PlineSource;
        use cavalier_contours::polyline::PlineOffsetOptions;
        if self.samples.len() < 2 {
            return
        }
        let vertex_data = self.samples
            .iter()
            .map(|(x, y)| {
                PlineVertex{
                    x: *x as f64,
                    y: *y as f64,
                    bulge: 0.0 as f64,
                }
            })
            .collect::<Vec<_>>();
        let mut pline = Polyline{
            vertex_data,
            is_closed: false,
        };
        let mut opt = PlineOffsetOptions::new();
        opt.handle_self_intersects = true;
        let for_each_line = |pline: &Polyline, heads: &mut Vec<(f64, f64)>, last: &mut Option<(f64, f64)>| {
            for (ix, vertex) in pline.vertex_data.iter().enumerate() {
                let x = vertex.x;
                let y = vertex.y;

                if let Some(last) = heads.last() {
                    ctx.line_to(x, y);
                } else {
                    if ix == 0 {
                        ctx.move_to(x, y);
                    } else {
                        ctx.line_to(x, y);
                    }
                }
                if ix == 0 {
                    heads.push((x, y));
                }
                *last = Some((x, y));
            }
        };
        // let results = (
        //     pline.parallel_offset_opt(10.0, &opt).and_then(|x| {
        //         if x.is_empty() {
        //             return None
        //         }
        //         if x.len() != 1 {
        //             log!("LEN != 1: {}", x.len());
        //         }
        //         x.first().map(Clone::clone)
        //     }),
        //     pline.parallel_offset_opt(-10.0, &opt).and_then(|x| {
        //         if x.is_empty() {
        //             return None
        //         }
        //         if x.len() != 1 {
        //             log!("LEN != 1: {}", x.len());
        //         }
        //         x.first().map(Clone::clone)
        //     }),
        // );
        let results = [
            pline.parallel_offset_opt(10.0, &opt).map(|x| {
                if x.len() > 1 {
                    log!("x.len > 1: {}", x.len());
                }
                x
            }),
            // pline.parallel_offset_opt(-10.0, &opt).map(|x| {
            //     if x.len() > 1 {
            //         log!("x.len > 1: {}", x.len());
            //     }
            //     x
            // }),
        ];
        // for pline in results.concat() {
        //     for_each_line(pline);
        // }
        // let results = vec![
        //     pline.parallel_offset_opt(4.0, &opt),
        //     pline.parallel_offset_opt(-4.0, &opt),
        // ];
        // match (results) {
        //     (Some(mut front), Some(mut back)) => {
        //         ctx.begin_path();
        //         for_each_line(front);
        //         for_each_line(front);
        //         // for (ix, vertex) in front.vertex_data.iter().chain(back.vertex_data.iter().rev()).enumerate() {
        //         //     let x = vertex.x;
        //         //     let y = vertex.y;
        //         //     if ix == 0 {
        //         //         ctx.move_to(x, y);
        //         //     } else {
        //         //         ctx.line_to(x, y);
        //         //     }
        //         // }
                
        //         // ctx.close_path();
        //         ctx.fill();
        //     }
        //     _ => ()
        // }
        let mut flip = false;
        let mut last: Option<(f64, f64)> = None;
        let mut heads: Vec<(f64, f64)> = Vec::new();
        // ctx.begin_path();
        for mut pline in results.iter().flat_map(|x| x).flat_map(|x| x.clone()) {
            if pline.is_closed() {
                ctx.begin_path();
                for (ix, vertex) in pline.vertex_data.iter().enumerate() {
                    if ix == 0 {
                        ctx.move_to(vertex.x, vertex.y);
                    } else {
                        ctx.line_to(vertex.x, vertex.y);
                    }
                }
                ctx.close_path();
                ctx.fill();
                continue;
            }
            ctx.begin_path();
            assert!(pline.area() == 0.0);
            for_each_line(&pline, &mut heads, &mut last);
            ctx.stroke();
        }
        // if let Some((x, y)) = heads.first() {
        //     ctx.line_to(*x, *y);
        // }
        // ctx.close_path();
        // ctx.fill();
    }
}

#[derive(Clone, Debug)]
pub struct CanvasElement {
    pub parent: HtmlElement,
    pub dom_ref: HtmlCanvasElement,
    // pub ctx: CanvasRenderingContext2d,
    // pub strokes: Vec<StrokePath>,
    pub active: Memory<StrokePath>,
    pub strokes: Memory<Vec<StrokePath>>,
    pub record_inputs: Rc<Cell<bool>>,
    // pub input_points: Memory<VecDeque<RawInput<f64>>>,
    pub begin_recording_callbacks: Option<[SimpleCallback; 2]>,
    pub process_input_callbacks: Option<[SimpleCallback; 2]>,
    pub end_recording_callbacks: Option<[SimpleCallback; 3]>,
}

#[derive(Clone, Debug)]
pub struct RawInput<T> {
    point: (T, T)
}


impl CanvasElement {
    pub fn new_global_canvas() -> Self {
        let window = web_sys::window().expect("no global `window` exists");
        let document = window.document().expect("should have a document on window");
        let body = document.body().expect("document should have a body");
        let svg = document.create_element("canvas").unwrap();
        let dom_ref = HtmlCanvasElement::from(JsValue::from(&svg));
        body.append_child(&dom_ref).unwrap();
        let record_inputs: Rc<Cell<bool>> = Rc::new(Cell::new(false));
        // let input_points = Default::default();
        CanvasElement{
            active: Default::default(),
            strokes: Default::default(),
            // ctx,
            parent: body,
            dom_ref,
            record_inputs,
            // input_points,
            begin_recording_callbacks: None,
            process_input_callbacks: None,
            end_recording_callbacks: None,
        }
    }
    pub fn init_callbacks(&mut self, dim: (f64, f64, f64)) {
        fn process_input(
            event_name: &str,
            event: JsValue,
            (width, height, dpr): (f64, f64, f64),
            active: &Memory<StrokePath>,
        ) {
            // web_sys::console::log_2(
            //     &event_name.into(),
            //     &event
            // );
            let mouse_event = MouseEvent::from(event);
            let x = mouse_event.page_x() as f64;
            let y = mouse_event.page_y() as f64;
            active.borrow_mut().samples.push((x, y));
        }
        fn begin_recording(
            event_name: &str,
            event: JsValue,
            dim: (f64, f64, f64),
            record_inputs: &Rc<Cell<bool>>,
            active: &Memory<StrokePath>,
        ) {
            // active.borrow_mut().samples.clear();
            // input_points.borrow_mut().clear();
            record_inputs.set(true);
            // process_input(event_name, event, dim, active);
        }
        fn process_event(
            event_name: &str,
            event: JsValue,
            dim: (f64, f64, f64),
            record_inputs: &Rc<Cell<bool>>,
            active: &Memory<StrokePath>,
        ) {
            if record_inputs.get() {
                process_input(event_name, event, dim, active);
            }
        }
        fn end_recording(
            event_name: &str,
            event: JsValue,
            dim: (f64, f64, f64),
            record_inputs: &Rc<Cell<bool>>,
            active: &Memory<StrokePath>,
            strokes: &Memory<Vec<StrokePath>>,
        ) {
            // process_input(event_name, event, dim, active);
            if !active.borrow().samples.is_empty() {
                log!("NEW STROKE");
                strokes.borrow_mut().push(active.into_clone());
            }
            record_inputs.set(false);
            active.borrow_mut().samples.clear();
        }
        let begin_recording_callbacks = [
            SimpleCallback::new(
                &self.dom_ref,
                "touchstart",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let event_name = "touchstart";
                    let record_inputs = self.record_inputs.clone();
                    let active = self.active.clone();
                    move |event| {
                        begin_recording(event_name, event, dim, &record_inputs, &active)
                    }
                }
            ),
            SimpleCallback::new(
                &self.dom_ref,
                "mousedown",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let event_name = "mousedown";
                    let record_inputs = self.record_inputs.clone();
                    let active = self.active.clone();
                    move |event| {
                        begin_recording(event_name, event, dim, &record_inputs, &active)
                    }
                },
            ),
        ];
        let process_input_callbacks = [
            SimpleCallback::new(
                &self.dom_ref,
                "touchmove",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let event_name = "touchmove";
                    let record_inputs = self.record_inputs.clone();
                    let active = self.active.clone();
                    move |event| {
                        process_event(event_name, event, dim, &record_inputs, &active);
                    }
                }
            ),
            SimpleCallback::new(
                &self.dom_ref,
                "mousemove",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let event_name = "mousemove";
                    let record_inputs = self.record_inputs.clone();
                    let active = self.active.clone();
                    move |event| {
                        process_event(event_name, event, dim, &record_inputs, &active);
                    }
                },
            ),
        ];
        let end_recording_callbacks = [
            SimpleCallback::new(
                &self.dom_ref,
                "touchend",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let event_name = "touchend";
                    let record_inputs = self.record_inputs.clone();
                    let active = self.active.clone();
                    let strokes = self.strokes.clone();
                    move |event| {
                        end_recording(
                            event_name,
                            event, dim,
                            &record_inputs,
                            &active,
                            &strokes
                        )
                    }
                }
            ),
            SimpleCallback::new(
                &self.dom_ref,
                "touchleave",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let event_name = "touchleave";
                    let record_inputs = self.record_inputs.clone();
                    let active = self.active.clone();
                    let strokes = self.strokes.clone();
                    move |event| {
                        end_recording(
                            event_name,
                            event, dim,
                            &record_inputs,
                            &active,
                            &strokes
                        )
                    }
                },
            ),
            SimpleCallback::new(
                &self.dom_ref,
                "mouseup",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let event_name = "mouseup";
                    let record_inputs = self.record_inputs.clone();
                    let active = self.active.clone();
                    let strokes = self.strokes.clone();
                    move |event| {
                        end_recording(
                            event_name,
                            event, dim,
                            &record_inputs,
                            &active,
                            &strokes
                        )
                    }
                },
            ),
        ];
        assert!(self.begin_recording_callbacks.is_none());
        assert!(self.process_input_callbacks.is_none());
        assert!(self.end_recording_callbacks.is_none());
        self.begin_recording_callbacks = Some(begin_recording_callbacks);
        self.process_input_callbacks = Some(process_input_callbacks);
        self.end_recording_callbacks = Some(end_recording_callbacks);
        // std::mem::forget(begin_recording_callbacks);
        // std::mem::forget(process_input_callbacks);
        // std::mem::forget(end_recording_callbacks);
    }
    pub fn init(&mut self) -> (f64, f64, f64) {
        let (width, height, dpr) = {
            let dpr = window().device_pixel_ratio();
            let rect = self.parent.get_bounding_client_rect();
            let width = rect.width();
            let height = rect.height();
            (width, height, dpr)
        };
        let client_width = width;
        let client_height = height;
        self.dom_ref.set_width((width * dpr) as u32);
        self.dom_ref.set_height((height * dpr) as u32);
        let ctx = self.get_context();
        ctx.scale(dpr, dpr).unwrap();
        (width, height, dpr)
    }
    pub fn get_context(&self) -> CanvasRenderingContext2d {
        CanvasRenderingContext2d::from(JsValue::from(self.dom_ref.get_context("2d").unwrap()))
    }
    pub fn tick(&self, dim @ (width, height, _): (f64, f64, f64)) {
        let mut active = self.active.borrow_mut();
        let ctx = self.get_context();
        ctx.clear_rect(0.0, 0.0, width, height);
        for stroke in self.strokes.borrow_mut().iter_mut() {
            stroke.tick(&ctx, dim);
        }
        active.tick(&ctx, dim);
    }
}


// ////////////////////////////////////////////////////////////////////////////
// ENTRYPOINT
// ////////////////////////////////////////////////////////////////////////////

pub fn run() {
    let window = web_sys::window().expect("no global `window` exists");
    let document = window.document().expect("should have a document on window");
    let body = document.body().expect("document should have a body");
    let f: Memory<Option<Closure<dyn FnMut()>>> = Memory::new(None);
    let mut g = f.clone();
    let mut canvas = CanvasElement::new_global_canvas();
    let dim = canvas.init();
    canvas.init_callbacks(dim);
    canvas.tick(dim);
    *g.borrow_mut() = Some(Closure::new(move || {
        canvas.tick(dim);
        request_animation_frame(f.borrow().as_ref().unwrap());
    }));
    request_animation_frame(g.borrow().as_ref().unwrap());
    std::mem::forget(g);
    // std::mem::forget(canvas);
}
