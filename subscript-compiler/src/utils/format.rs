use std::fmt::Display;

use itertools::Itertools;


// #[derive(Debug, Clone, Default)]
// pub struct Enclose {
//     pub open: String,
//     pub sep: String,
//     pub close: String,
//     pub body: Vec<(String, String)>,
// }

// impl Enclose {
//     pub fn new(
//         open: impl Into<String>,
//         sep: impl Into<String>,
//         close: impl Into<String>,
//     ) -> Self {
//         Enclose {
//             open: open.into(),
//             sep: sep.into(),
//             close: close.into(),
//             ..Default::default()
//         }
//     }
//     pub fn body<K: Display, V: Display>(
//         mut self,
//         xs: impl IntoIterator<Item=(K, V)>,
//     ) -> Self {
//         let xs = xs
//             .into_iter()
//             .map(|(k, v)|{
//                 (format!("{k}"), format!("{v}"))
//             });
//         self.body.extend(xs);
//         self
//     }
// }

// pub fn object<T>(
//     open: impl Into<String>,
//     close: impl Into<String>,
//     xs: impl IntoIterator<Item=T>
// ) {

// }