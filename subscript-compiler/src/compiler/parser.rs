//! The parser herein is supposed to meet the following criteria:
//! * real-time parsing (suitable for IDE syntax highlighting).
//! * zero-copy parsing (only copying pointers).
//! * fault tolerant parsing; again, so it can be used in IDE/text editors.
//! Eventually I’d like to support incremental parsing as well. 
use std::rc::Rc;
use std::borrow::Cow;
use std::collections::{HashSet, VecDeque, LinkedList};
use std::iter::FromIterator;
use std::vec;
use serde::de::value;
use unicode_segmentation::UnicodeSegmentation;

use crate::compiler::data::*;
use crate::compiler::ast::*;



///////////////////////////////////////////////////////////////////////////////
// INTERNAL PARSER TYPES
///////////////////////////////////////////////////////////////////////////////

#[derive(Debug)]
struct Zipper<T> {
    left: Option<T>,
    current: T,
    right: Option<T>,
}

enum ZipperConsumed {
    Current,
    Right,
}

#[derive(Debug, Clone)]
pub enum Mode {
    BeginEnclosure {
        kind: String,
    },
    EndEnclosure {
        kind: String,
    },
    OpenOrCloseEnclosureQuote,
    Ident(String),
    Symbol(String),
    NoOP,
}

// type BeginEnclosureStack<'a> = VecDeque<(&'a str, CharIndex, LinkedList<Node>)>;

#[derive(Debug, Clone, PartialEq)]
pub enum OpenTokenType {
    CurlyBrace,
    SquareParen,
    Parens,
    Quote,
}

impl OpenTokenType {
    pub fn as_str(&self) -> &'static str {
        match self {
            OpenTokenType::CurlyBrace => "{",
            OpenTokenType::SquareParen => "[",
            OpenTokenType::Parens => "(",
            OpenTokenType::Quote => "\""
        }
    }
    pub fn new(token: String) -> Option<OpenTokenType> {
        match (token.as_str()) {
            ("{") => Some(OpenTokenType::CurlyBrace),
            ("[") => Some(OpenTokenType::SquareParen),
            ("(") => Some(OpenTokenType::Parens),
            (_) => None,
        }
    }
    pub fn is_quote(&self) -> bool {
        self == &OpenTokenType::Quote
    }
}

#[derive(Debug, Clone)]
struct PartialBlock {
    open_type: Ann<OpenTokenType>,
    open: Ann<String>,
    children: LinkedList<Node>,
}

#[derive(Debug, Clone)]
enum Branch {
    PartialBlock(PartialBlock),
    Node(Node),
}

#[derive(Debug, Default)]
pub struct ParseTree {
    scopes: VecDeque<PartialBlock>,
    finalized: LinkedList<Node>,
}

///////////////////////////////////////////////////////////////////////////////
// PARSE-TREE UTILS
///////////////////////////////////////////////////////////////////////////////

impl ParseTree {
    fn add_child_node(&mut self, new_node: Node) {
        match self.scopes.back_mut() {
            Some(scope) => {
                scope.children.push_back(new_node);
            }
            None => {
                self.finalized.push_back(new_node);
            }
        }
    }
    fn open_new_enclosure(&mut self, new_enclosure: PartialBlock) {
        self.scopes.push_back(new_enclosure);
    }
    fn close_last_enclosure<'a>(&mut self, close_word: &Word<'a>) {
        match self.scopes.pop_back() {
            Some(scope) => {
                let open = scope.open.clone();
                let close = Ann::new(close_word.range, close_word.word.to_owned());
                let new_node = Enclosure {
                    // kind: EnclosureKind::new(
                    //     Text(Cow::Borrowed(scope.open_token.data.as_str())),
                    //     Text(Cow::Borrowed(close_word.word)),
                    // ),
                    open: Some(open),
                    close: Some(close),
                    children: scope.children.into_iter().collect()
                };
                let range = {
                    let start = scope.open.start();
                    let end = close_word.range.end;
                    CharRange::join(start, Some(end))
                };
                self.add_child_node(Node::Enclosure(Ann::join(range, new_node)));
            }
            None => {
                let new_node = Node::InvalidToken(Ann::new(
                    close_word.range,
                    close_word.word.to_owned(),
                ));
                self.add_child_node(new_node);
            }
        }
    }
    pub fn finalize_all(self) -> Vec<Node> {
        let ParseTree { mut scopes, mut finalized } = self;
        let scopes = scopes.drain(..);
        let xs = scopes
            .map(|scope| {
                let enclosure = Enclosure{
                    // kind: EnclosureKind::Error{
                    //     open: Text(Cow::Borrowed(scope.open_token.data.as_str())),
                    //     close: None
                    // },
                    open: Some(scope.open.clone()),
                    close: None,
                    children: scope.children.into_iter().collect()
                };
                Node::Enclosure(Ann::join(
                    scope.open.range(),
                    enclosure,
                ))
            });
        finalized.extend(xs);
        finalized.into_iter().collect()
    }
}

///////////////////////////////////////////////////////////////////////////////
// CORE PARSER ENGINE
///////////////////////////////////////////////////////////////////////////////


impl ParseTree {
    pub fn parse_words<'a>(words: Vec<Word<'a>>) -> Vec<Node> {
        let mut parse_tree = ParseTree::default();
        let mut skip_to: Option<usize> = None;
        for pos in 0..words.len() {
            if let Some(start_from) = skip_to {
                if pos <= start_from {
                    continue;
                } else {
                    skip_to = None;
                }
            }
            let forward = |by: usize| {
                words
                    .get(pos + by)
                    .filter(|w| !w.is_whitespace())
                    .map(|w| (by, w))
            };
            let current = &words[pos];
            let next = {
                let mut entry = None::<(usize, &Word)>;
                let words_left = words.len() - pos;
                for offset in 1..words_left {
                    assert!(entry.is_none());
                    entry = forward(offset);
                    if entry.is_some() {break}
                }
                entry
            };
            let (mode, consumed) = match_word(
                current.word,
                next.map(|(_, x)| x.word)
            );
            match mode {
                Mode::BeginEnclosure {kind} => {
                    let start_pos = current.range.start;
                    let new_stack = PartialBlock {
                        open: Ann::new(
                            current.range,
                            kind.to_owned()
                        ),
                        open_type: Ann::new(
                            current.range,
                            OpenTokenType::new(kind.into()).unwrap()
                        ),
                        children: Default::default(),
                    };
                    parse_tree.open_new_enclosure(new_stack);
                }
                Mode::EndEnclosure {kind: close_token} => {
                    parse_tree.close_last_enclosure(current);
                }
                Mode::OpenOrCloseEnclosureQuote => {
                    enum OpenOrCloseOp {
                        Close,
                        Open,
                    }
                    let operation = parse_tree.scopes.back().map(|block| {
                        if block.open_type.data.is_quote() {
                            OpenOrCloseOp::Close
                        } else {
                            OpenOrCloseOp::Open
                        }
                    }).unwrap_or(OpenOrCloseOp::Open);
                    match operation {
                        OpenOrCloseOp::Open => {
                            let start_pos = current.range.start;
                            let new_stack = PartialBlock {
                                open_type: Ann::new(
                                    current.range,
                                    OpenTokenType::Quote
                                ),
                                open: Ann::new(current.range, current.word.into()),
                                children: Default::default(),
                            };
                            parse_tree.open_new_enclosure(new_stack);
                        }
                        OpenOrCloseOp::Close => {
                            parse_tree.close_last_enclosure(current);
                        }
                    }
                }
                Mode::Ident(ident) => {
                    let start = current.range.start;
                    let end = next
                        .map(|x| x.1.range.end)
                        .unwrap_or(current.range.end);
                    let new_node = Node::Ident(Ann::new(
                        CharRange::new(
                            start,
                            end,
                        ),
                        ident.into()
                    ));
                    parse_tree.add_child_node(new_node);
                }
                Mode::Symbol(sym) => {
                    let start = current.range.start;
                    let end = next
                        .map(|x| x.1.range.end)
                        .unwrap_or(current.range.end);
                    let new_node = Node::Text(Ann::new(
                        CharRange::new(
                            start,
                            end,
                        ),
                        sym.into()
                    ));
                    parse_tree.add_child_node(new_node);
                }
                Mode::NoOP => {
                    let new_node = Node::Text(Ann::new(
                        current.range,
                        current.word.into()
                    ));
                    parse_tree.add_child_node(new_node);
                }
            }
            // FINALIZE
            match consumed {
                ZipperConsumed::Current => (),
                ZipperConsumed::Right => {
                    assert!(next.is_some());
                    let offset = next.unwrap().0;
                    skip_to = Some(pos + offset);
                }
            }
        }
        parse_tree.finalize_all()
    }
}



///////////////////////////////////////////////////////////////////////////////
// PARSER ENTRYPOINT
///////////////////////////////////////////////////////////////////////////////


// MAIN ENTRYPOINT FOR STRING TO PARSER AST 
pub fn parse_source<'a>(source: &'a str) -> Vec<Node> {
    let words = init_words(source, init_characters(source));
    ParseTree::parse_words(words)
}


///////////////////////////////////////////////////////////////////////////////
// DEV
///////////////////////////////////////////////////////////////////////////////

// fn process_word<'a>(values: Vec<(CharIndex, &'a str)>) -> Vec<Vec<(CharIndex, &'a str)>> {
//     use itertools::Itertools;
//     values
//         .into_iter()
//         .group_by(|(_, char)| {
//             let char: &str = char;
//             match char {
//                 "\\" => true,
//                 "{" => true,
//                 "}" => true,
//                 "[" => true,
//                 "]" => true,
//                 "(" => true,
//                 ")" => true,
//                 "=" => true,
//                 ">" => true,
//                 "_" => true,
//                 "^" => true,
//                 "," => true,
//                 _ => false
//             }
//         })
//         .into_iter()
//         .flat_map(|(key, group)| -> Vec<Vec<(CharIndex, &str)>> {
//             if key == true {
//                 group
//                     .into_iter()
//                     .map(|(ix, ch)| {
//                         vec![(ix, ch)]
//                     })
//                     .collect::<Vec<_>>()
//             } else {
//                 vec![group.into_iter().collect::<Vec<_>>()]
//             }
//         })
//         .collect_vec()
// }



#[derive(Debug, Clone)]
pub struct Character<'a> {
    range: CharRange,
    char: &'a str,
}

impl<'a> Character<'a> {
    pub fn is_whitespace(&self) -> bool {
        self.char.chars().any(|x| x.is_whitespace())
    }
}

pub fn init_characters<'a>(source: &'a str) -> Vec<Character<'a>> {
    use itertools::Itertools;
    let ending_byte_size = source.len();
    let words = source
        .grapheme_indices(true)
        .enumerate()
        .map(|(cix, (bix, x))| {
            let index = CharIndex {
                byte_index: bix,
                char_index: cix,
            };
            (index, x)
        })
        .collect_vec();
    let mut output = Vec::new();
    for pos in 0..words.len() {
        let (start, current) = words[pos];
        let end = words
            .get(pos + 1)
            .map(|(pos, _)| *pos)
            .unwrap_or_else(|| {
                CharIndex {
                    byte_index: ending_byte_size,
                    char_index: pos + 1
                }
            });
        output.push(Character{
            range: CharRange{ start, end},
            char: current
        });
    }
    output
}

#[derive(Debug, Clone)]
pub struct Word<'a> {
    range: CharRange,
    word: &'a str,
}

impl<'a> Word<'a> {
    pub fn is_whitespace(&self) -> bool {
        self.word.trim().is_empty()
    }
}

pub fn init_words<'a>(source: &'a str, chars: Vec<Character<'a>>) -> Vec<Word<'a>> {
    use itertools::Itertools;
    // let mut output = Vec::new();
    let mut current_word_start = 0usize;
    chars
        .into_iter()
        .group_by(|char| {
            if char.is_whitespace() {
                return true
            }
            match char.char {
                "\\" => true,
                "{" => true,
                "}" => true,
                "[" => true,
                "]" => true,
                "(" => true,
                ")" => true,
                "=" => true,
                ">" => true,
                "_" => true,
                "." => true,
                "^" => true,
                "," => true,
                "\"" => true,
                _ => false
            }
        })
        .into_iter()
        .flat_map(|(key, chars)| {
            let chars = chars.into_iter().collect_vec();
            if key || chars.len() < 2 {
                let chars = chars
                    .into_iter()
                    .map(|char| {
                        Word {
                            range: char.range,
                            word: char.char,
                        }
                    })
                    .collect_vec();
                return chars;
            }
            let start = {
                (&chars[0]).range.start
            };
            let end = {
                (&chars[chars.len() - 1]).range.end
            };
            let word = &source[start.byte_index..end.byte_index];
            let word = Word {
                range: CharRange{start, end},
                word,
            };
            vec![word]
        })
        .collect::<Vec<_>>()
}

fn match_word(current: &str, next: Option<&str>) -> (Mode, ZipperConsumed) {
    match (current, next) {
        ("\\", Some(next)) if next == "{"  => (
            Mode::Ident(INLINE_MATH_TAG.to_owned()),
            ZipperConsumed::Current,
        ),
        ("\\", Some(ident)) if !is_token(ident) && ident != " " => (
            Mode::Ident(ident.to_owned()),
            ZipperConsumed::Right
        ),
        ("=", Some(">")) => (
            Mode::Symbol("=>".to_owned()),
            ZipperConsumed::Right
        ),
        (tk @ "{", _) => (
            Mode::BeginEnclosure{kind: tk.to_owned()},
            ZipperConsumed::Current
        ),
        (tk @ "[", _) => (
            Mode::BeginEnclosure{kind: tk.to_owned()},
            ZipperConsumed::Current
        ),
        (tk @ "(", _) => (
            Mode::BeginEnclosure{kind: tk.to_owned()},
            ZipperConsumed::Current
        ),
        (tk @ "\"", _) => (
            Mode::OpenOrCloseEnclosureQuote,
            ZipperConsumed::Current
        ),
        (tk @ "}", _) => (
            Mode::EndEnclosure{kind: tk.to_owned()},
            ZipperConsumed::Current
        ),
        (tk @ "]", _) => (
            Mode::EndEnclosure{kind: tk.to_owned()},
            ZipperConsumed::Current
        ),
        (tk @ ")", _) => (
            Mode::EndEnclosure{kind: tk.to_owned()},
            ZipperConsumed::Current
        ),
        _ => (Mode::NoOP, ZipperConsumed::Current),
    }
}




