use std::cell::{RefCell, Cell};
use std::fmt::Debug;
use std::rc::Rc;
use std::collections::VecDeque;
use wasm_bindgen::prelude::*;
use wasm_bindgen::JsCast;
use web_sys::{HtmlCanvasElement, CanvasRenderingContext2d, HtmlElement, SvgsvgElement, SvgPathElement, MouseEvent};

// ////////////////////////////////////////////////////////////////////////////
// MISCELLANEOUS
// ////////////////////////////////////////////////////////////////////////////


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
                    events_queue.borrow_mut().push_back(x);
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
        self.events.borrow_mut().drain(..).collect::<Vec<_>>()
    }
    pub fn drain_for_each(&self, f: impl FnMut(T)) {
        self.events
            .borrow_mut()
            .drain(..)
            .for_each(f)
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


#[derive(Debug, Clone)]
pub struct StrokePath {
    pub dom_ref: SvgPathElement,
    pub samples: Vec<(i32, i32)>,
}

impl StrokePath {
    pub fn new(svg: &SvgsvgElement) -> Self {
        let document = document();
        let path = document.create_element_ns(Some("http://www.w3.org/2000/svg"), "path").unwrap();
        let dom_ref = SvgPathElement::from(JsValue::from(&path));
        svg.append_child(&path);
        StrokePath {
            dom_ref,
            samples: Default::default()
        }
    }
    pub fn tick(&mut self) {
        // use cavalier_contours::pline_closed;
        // use cavalier_contours::{pline_closed};
        use cavalier_contours::polyline::PlineVertex;
        use cavalier_contours::polyline::Polyline;
        use cavalier_contours::polyline::PlineSource;
        use cavalier_contours::polyline::PlineOffsetOptions;
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
            is_closed: true,
        };
        let mut opt = PlineOffsetOptions::new();
        opt.handle_self_intersects = true;
        let results = pline.parallel_offset_opt(1.0, &opt);
        for poly_line in results {
            
        }

        // let mut polyline = 
        // let points = self.samples
        //     .iter()
        //     .map(|(x, y)| (*x as f64, *y as f64, 0.0))
        //     .collect::<Vec<_>>();
        // let points = pline_closed!(points);
    }
}

#[derive(Clone, Debug)]
pub struct CanvasElement {
    pub parent: HtmlElement,
    pub dom_ref: SvgsvgElement,
    pub active: StrokePath,
    pub record_inputs: Rc<Cell<bool>>,
    pub input_points: Rc<RefCell<VecDeque<RawInput>>>,
    pub begin_recording_callbacks: [SimpleCallback; 2],
    pub process_input_callbacks: [SimpleCallback; 2],
    pub end_recording_callbacks: [SimpleCallback; 3],
}

#[derive(Clone, Debug)]
pub struct RawInput {
    point: (i32, i32)
}


impl CanvasElement {
    pub fn new_global_canvas() -> Self {
        let window = web_sys::window().expect("no global `window` exists");
        let document = window.document().expect("should have a document on window");
        let body = document.body().expect("document should have a body");
        let svg = document.create_element_ns(Some("http://www.w3.org/2000/svg"), "svg").unwrap();
        let dom_ref = SvgsvgElement::from(JsValue::from(&svg));
        body.append_child(&dom_ref).unwrap();
        let record_inputs: Rc<Cell<bool>> = Rc::new(Cell::new(false));
        let input_points = Rc::new(RefCell::new(VecDeque::new()));
        fn process_input(
            event_name: &str,
            event: JsValue,
            input_points: &mut VecDeque<RawInput>
        ) {
            web_sys::console::log_2(
                &event_name.into(),
                &event
            );
            let mouse_event = MouseEvent::from(event);
            let x = mouse_event.page_x();
            let y = mouse_event.page_y();
            input_points.push_back(RawInput{
                point: (x, y)
            });
        }
        let begin_recording_callbacks = [
            SimpleCallback::new(
                &svg,
                "touchstart",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let record_inputs = record_inputs.clone();
                    let input_points = input_points.clone();
                    move |event| {
                        record_inputs.set(true);
                        process_input("touchstart", event, &mut input_points.borrow_mut());
                    }
                }
            ),
            SimpleCallback::new(
                &svg,
                "mousedown",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let record_inputs = record_inputs.clone();
                    let input_points = input_points.clone();
                    move |event| {
                        record_inputs.set(true);
                        process_input("mousedown", event, &mut input_points.borrow_mut());
                    }
                },
            ),
        ];
        let process_input_callbacks = [
            SimpleCallback::new(
                &svg,
                "touchmove",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let record_inputs = record_inputs.clone();
                    let input_points = input_points.clone();
                    move |event| {
                        if record_inputs.get() {
                            process_input("touchmove", event, &mut input_points.borrow_mut());
                        }
                    }
                }
            ),
            SimpleCallback::new(
                &svg,
                "mousemove",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let record_inputs = record_inputs.clone();
                    let input_points = input_points.clone();
                    move |event| {
                        if record_inputs.get() {
                            process_input("mousemove", event, &mut input_points.borrow_mut());
                        }
                    }
                },
            ),
        ];
        let end_recording_callbacks = [
            SimpleCallback::new(
                &svg,
                "touchend",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let record_inputs = record_inputs.clone();
                    let input_points = input_points.clone();
                    move |event| {
                        record_inputs.set(false);
                        process_input("touchend", event, &mut input_points.borrow_mut());
                    }
                }
            ),
            SimpleCallback::new(
                &svg,
                "touchleave",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let record_inputs = record_inputs.clone();
                    let input_points = input_points.clone();
                    move |event| {
                        record_inputs.set(false);
                        process_input("touchleave", event, &mut input_points.borrow_mut());
                    }
                },
            ),
            SimpleCallback::new(
                &svg,
                "mouseup",
                CallbackSettings {stop_propagation: true, prevent_default: true}, {
                    let record_inputs = record_inputs.clone();
                    let input_points = input_points.clone();
                    move |event| {
                        record_inputs.set(false);
                        process_input("mouseup", event, &mut input_points.borrow_mut());
                    }
                },
            ),
        ];
        CanvasElement{
            active: StrokePath::new(&dom_ref),
            parent: body,
            dom_ref,
            record_inputs,
            input_points,
            begin_recording_callbacks,
            process_input_callbacks,
            end_recording_callbacks,
        }
    }
    pub fn tick(&mut self) {
        // log!("1");
        // let (width, height) = {
        //     let rect = self.parent.get_bounding_client_rect();
        //     let width = rect.width();
        //     let height = rect.height();
        //     (width, height)
        // };
        // self.dom_ref.set_width(width.round() as u32);
        // self.dom_ref.set_height(height.round() as u32);
        self.active.samples.extend(
            self.input_points
                .borrow_mut()
                .drain(..)
                .map(|x| x.point)
        );

    }
}


// ////////////////////////////////////////////////////////////////////////////
// ENTRYPOINT
// ////////////////////////////////////////////////////////////////////////////

pub fn run() {
    // let window = web_sys::window().expect("no global `window` exists");
    // let document = window.document().expect("should have a document on window");
    // let body = document.body().expect("document should have a body");
    let f = Rc::new(RefCell::new(None));
    let g = f.clone();
    let mut canvas = CanvasElement::new_global_canvas();
    canvas.tick();
    *g.borrow_mut() = Some(Closure::new(move || {
        canvas.tick();
        request_animation_frame(f.borrow().as_ref().unwrap());
    }));
    request_animation_frame(g.borrow().as_ref().unwrap());
}
