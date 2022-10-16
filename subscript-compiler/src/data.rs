//! Miscellaneous stuff used throughout the compiler.
//! Some of the values here are incomplete.
use std::path::PathBuf;
use std::borrow::Cow;
use std::sync::{Arc, Mutex};
use std::collections::{HashSet, VecDeque, LinkedList};
use std::iter::FromIterator;
use lazy_static::lazy_static;
use serde::{Serialize, Deserialize};

pub static ALLOWED_HTML_TAGS: &[&'static str] = &[
    "address",
    "article",
    "aside",
    "footer",
    "header",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "section",
    "blockquote",
    "dd",
    "dl",
    "dt",
    "figcaption",
    "figure",
    "hr",
    "li",
    "ol",
    "p",
    "pre",
    "ul",
    "a",
    "abbr",
    "b",
    "bdi",
    "bdo",
    "br",
    "cite",
    "code",
    "data",
    "dfn",
    "em",
    "i",
    "kbd",
    "mark",
    "q",
    "s",
    "samp",
    "small",
    "span",
    "strong",
    "sub",
    "sup",
    "time",
    "u",
    "var",
    "wbr",
    "audio",
    "img",
    "map",
    "area",
    "track",
    "video",
    "object",
    "picture",
    "source",
    "del",
    "ins",
    "caption",
    "col",
    "colgroup",
    "table",
    "tbody",
    "td",
    "tfoot",
    "th",
    "thead",
    "tr",
    "details",
    "summary",
];


// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS
// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

pub struct Store<T>(Arc<Mutex<T>>);

unsafe impl<T> Send for Store<T> {}
unsafe impl<T> Sync for Store<T> {}

impl<T: Default> Default for Store<T> {
    fn default() -> Self {
        Store::new(T::default())
    }
}
impl<T> Clone for Store<T> {
    fn clone(&self) -> Self {Store(self.0.clone())}
}


impl<T> std::fmt::Debug for Store<T> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let output_ty_name = std::any::type_name::<T>();
        f.debug_struct(&format!("Store(\"{}\")", output_ty_name)).finish()
    }
}

impl<T> Store<T> {
    pub fn new(x: T) -> Store<T> {
        Store(Arc::new(Mutex::new(x)))
    }
    pub fn map<U>(&self, f: impl Fn(&T)->U) -> U {
        use std::ops::DerefMut;
        let mut lock = self.0.lock().unwrap();
        f(lock.deref_mut())
    }
    pub fn map_mut<U>(&self, mut f: impl FnOnce(&mut T)->U) -> U {
        use std::ops::DerefMut;
        let mut lock = self.0.lock().unwrap();
        f(lock.deref_mut())
    }
    pub fn into_inner(self) -> Arc<Mutex<T>> {
        self.0
    }
    pub fn into_clone(&self) -> T where T: Clone {
        self.map(|x| x.clone())
    }
}


