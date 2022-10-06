use std::cell::RefCell;
use std::fmt::Display;
use std::path::PathBuf;
use std::rc::Rc;
use std::borrow::{Borrow, Cow};
use std::collections::{HashSet, VecDeque, LinkedList, HashMap};
use std::iter::FromIterator;
use std::{vec, panic};
use itertools::Itertools;
use serde::{Serialize, Deserialize};
use unicode_segmentation::UnicodeSegmentation;
use crate::cmds::data::CompilerEnv;


// ////////////////////////////////////////////////////////////////////////////
// IDENTIFIERS
// ////////////////////////////////////////////////////////////////////////////


/// Unlike old implementations, the new SubScript parser doesn’t remove `\`
/// from identifiers. Which has been changed (removing it leads to subtle errors
/// such as calculating byte offsets that use e.g. `String::len` and forgetting
/// to insert a byte for the missing slash). This behavior has since changed,
/// but then I frequently ran into new issues where i’d define a rewrite rule
/// for all identifiers/commands with a given name and forget to add a
/// slash `\` (and so such wouldn’t match and I’d wonder why the AST rewrite
/// isn’t working). Therefore to address this problem I’m using this `Ident`
/// type to help prevent such issues. To create a new identifier, you have to
/// use of the construction methods, such as `Ident::from(“\\name”)`, which
/// will return a Result type, usually I just immediately unwrap this so if I
/// forget to add the slash prefix I’ll know where the issue occurred. 
/// 
/// E.g.
/// ```
/// use subscript_data::subscript::parser::Ident;
/// assert!(Ident::from("name").is_none());
/// assert!(Ident::from("\\name").is_some());
/// ```
#[derive(Debug, Clone, PartialEq, Hash, Eq)]
pub struct Ident(String);

impl Ident {
    /// For consistency, all identifiers must start with `\`, otherwise `None` is returned.
    /// ```
    /// use subscript_data::subscript::parser::Ident;
    /// assert!(Ident::from("name").is_none());
    /// assert!(Ident::from("\\name").is_some());
    /// ```
    /// When I initially wrote this in swift, I repeatedly found myself
    /// forgetting to prefix identifiers with `\` and would run into bugs
    /// where things didn’t match as expected. Usually I just immediately
    /// unwrap this result so if I forgot I’ll know where the issue occurred.
    /// 
    /// 
    /// NOTE:
    /// * this type implements PartialEq<T> where T can be any
    ///   `AsRef<str>`, and for convenience, can match against prefixed and
    ///   un-prefixed values.  Which may lead to it’s own problems, idk, having
    ///   to use the constructor API for matching would make a lot of patterning
    ///   matching branches quite verbose… 
    /// * This may get removed, and so this may be out-of-date, idk… 
    pub fn from<T: Into<String>>(str: T) -> Result<Self, IdentInitError> {
        let str = str.into();
        if str.starts_with("\\") {
            return Ok(Ident(str))
        }
        Err(IdentInitError::MissingPrefix)
    }
    /// If the identifier is e.g. `\p`, then `html_wrap(&[...])` will produce `<p>...<p>`
    pub fn to_html_tag(&self, children: impl Display) -> String {
        let tag = self.0.strip_prefix("\\").unwrap();
        format!("<{tag}>{children}</{tag}>")
    }
    /// Simply returns the identifier. E.g. `\p` -> `\p`. 
    pub fn to_tex_ident(&self) -> &str {
        self.0.as_str()
    }
    pub fn unwrap_remove_slash(&self) -> &str {
        self.0.strip_prefix("\\").unwrap()
    }
    pub fn as_str(&self) -> &str {
        self.0.as_str()
    }
}

#[derive(Debug, Clone, PartialEq)]
pub enum IdentInitError {
    /// You're missing the `\` prefix. 
    MissingPrefix
}

impl Display for IdentInitError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> Result<(), std::fmt::Error> {
        match self {
            IdentInitError::MissingPrefix => write!(f, "missing prefix (\\)")
        }
    }
}

impl PartialEq<str> for Ident{
    fn eq(&self, other: &str) -> bool {
        if !other.starts_with("\\") {
            let left = self.0.strip_prefix("\\").unwrap();
            return left == other
        }
        self.0 == other
    }
}

impl<T> PartialEq<T> for Ident where T: AsRef<str> {
    fn eq(&self, other: &T) -> bool {
        let other = other.as_ref();
        if !other.starts_with("\\") {
            let left = self.0.strip_prefix("\\").unwrap();
            return left == other
        }
        self.0 == other
    }
}

// ////////////////////////////////////////////////////////////////////////////
// COMMON AST RELATED DATA TYPES
// ////////////////////////////////////////////////////////////////////////////


#[derive(Debug, Clone, PartialEq)]
pub enum BracketKind {
    CurlyBrace,
    SquareParen,
    Parens,
    Error,
}

// pub type Text<'a> = Ann<Cow<'a, str>>;

#[derive(Debug, Clone)]
struct Bracket {
    pub open: Option<Ann<String>>,
    pub close: Option<Ann<String>>,
    pub children: Vec<ParserAst>,
}


#[derive(Debug, Clone)]
struct Quotation {
    pub open: Option<Ann<String>>,
    pub close: Option<Ann<String>>,
    pub children: Vec<ParserAst>,
}

// ////////////////////////////////////////////////////////////////////////////
// INDEXING DATA TYPES
// ////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone, Copy, PartialEq, Hash, Serialize, Deserialize)]
pub struct CharIndex {
    pub byte_index: usize,
    pub char_index: usize,
}

impl CharIndex {
    pub fn zero() -> Self {
        CharIndex{
            byte_index: 0,
            char_index: 0,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Hash, Serialize, Deserialize)]
pub struct CharRange {
    pub start: CharIndex,
    pub end: CharIndex,
}

impl CharRange {
    pub fn join(start: Option<CharIndex>, end: Option<CharIndex>) -> Option<Self> {
        if let Some(start) = start {
            if let Some(end) = end {
                return Some(CharRange{start, end})
            }
        }
        None
    }
    pub fn new(start: CharIndex, end: CharIndex) -> Self {
        CharRange{start, end}
    }
    pub fn substrng<'a>(&self, source: &'a str) -> &'a str {
        return &source[self.start.byte_index..self.end.byte_index];
    }
    pub fn into_annotated_tree<T>(self, data: T) -> Ann<T> {
        Ann {
            range: Some(self),
            value: data,
        }
    }
}

#[derive(Debug, Clone)]
pub struct Ann<T> {
    pub range: Option<CharRange>,
    pub value: T,
}

impl<T: std::cmp::PartialEq> std::cmp::PartialEq for Ann<T> {
    fn eq(&self, other: &Self) -> bool {
        self.value == other.value
    }
}

impl Ann<String> {
    pub fn equal_to(&self, value: &str) -> bool {
        &self.value == value
    }
}

impl<T> Ann<T> {
    pub fn unannotated(data: T) -> Self {
        let range = None;
        Ann {range, value: data}
    }
    pub fn new(range: CharRange, data: T) -> Self {
        Ann {range: Some(range), value: data}
    }
    pub fn join(range: Option<CharRange>, data: T) -> Self {
        Ann {range, value: data}
    }
    pub fn range(&self) -> Option<CharRange> {
        self.range
    }
    pub fn start(&self) -> Option<CharIndex> {
        if let Some(range) = self.range {
            return Some(range.start)
        }
        None
    }
    pub fn end(&self) -> Option<CharIndex> {
        if let Some(range) = self.range {
            return Some(range.end)
        }
        None
    }
    pub fn map<U>(self, f: impl Fn(T) -> U) -> Ann<U> {
        Ann {
            range: self.range,
            value: f(self.value),
        }
    }
    pub fn consume(self) -> T {
        self.value
    }
}

impl Ann<String> {
    pub fn to_ident(self) -> Result<Ann<Ident>, IdentInitError> {
        let ident = Ident::from(self.value)?;
        Ok(Ann { range: self.range, value: ident})
    }
}


impl From<String> for Ann<String> {
    fn from(value: String) -> Self {Ann::unannotated(value)}
}
// impl From<Cow<'a, str>> for Ann<String> {
//     fn from(value: Cow<'a, str>) -> Self {Ann::unannotated(Text(value))}
// }
impl From<&str> for Ann<String> {
    fn from(value: &str) -> Self {Ann::unannotated(value.to_string())}
}
impl From<&String> for Ann<String> {
    fn from(value: &String) -> Self {Ann::unannotated(value.to_string())}
}
impl From<Ann<&str>> for Ann<String> {
    fn from(value: Ann<&str>) -> Self {
        value.map(|x| x.to_owned())
    }
}

#[derive(Debug, Clone)]
enum ParserAst {
    Text(Ann<String>),
    Ident(Ann<Ident>),
    Symbol(Ann<String>),
    Bracket(Bracket),
    Quotation(Quotation),
    InvalidToken(Ann<String>),
    Comment(Ann<String>),
}

impl ParserAst {
    fn to_node(self) -> crate::subscript::ast::Node {
        use crate::subscript::ast;
        match self {
            ParserAst::Text(node) => {
                ast::Node::Text(node)
            }
            ParserAst::Ident(node) => {
                ast::Node::Ident(node)
            }
            ParserAst::Symbol(node) => {
                ast::Node::Symbol(node)
            }
            ParserAst::Bracket(node) => {
                let children = node.children
                    .into_iter()
                    .map(ParserAst::to_node)
                    .collect_vec();
                ast::Node::Bracket(Ann::unannotated(ast::Bracket{
                    open: node.open,
                    close: node.close,
                    children,
                }))
            }
            ParserAst::Quotation(node) => {
                let children = node.children
                    .into_iter()
                    .map(ParserAst::to_node)
                    .collect_vec();
                ast::Node::Quotation(Ann::unannotated(ast::Quotation{
                    open: node.open,
                    close: node.close,
                    children,
                }))
            }
            ParserAst::InvalidToken(tk) => ast::Node::InvalidToken(tk),
            ParserAst::Comment(text) => ast::Node::Fragment(vec![]),
        }
    }
}

fn init_words<'a>(source: &'a str) -> VecDeque<Word> {
    use itertools::Itertools;
    #[derive(Debug, Clone)]
    enum Key {
        Ident,
        /// E.g. `\!where`; 
        /// NOTE:
        /// * Due to how PartialEq works this **will not** show up in the resulting word list.
        /// * Instead it will be `Ident`.
        /// * This is just an intermediate state.
        ModifierIdent,
        Text,
        Symbol,
        OpenBracket,
        CloseBracket,
        Quotation,
        Comment,
    }
    impl PartialEq for Key {
        fn eq(&self, other: &Self) -> bool {
            match (self, other) {
                (Key::Ident, Key::Ident) => true,
                (Key::Comment, Key::Comment) => true,
                // WE EXPLICITLY WANT THIS TO MATCH AS TRUE
                (Key::Ident, Key::ModifierIdent) => true,
                (Key::ModifierIdent, Key::ModifierIdent) => true,
                (Key::Text, Key::Text) => true,
                // WE EXPLICITLY WANT THIS TO MATCH AS FALSE
                (Key::Symbol, Key::Symbol) => false,
                // WE EXPLICITLY WANT THIS TO MATCH AS FALSE
                (Key::OpenBracket, Key::OpenBracket) => false,
                // WE EXPLICITLY WANT THIS TO MATCH AS FALSE
                (Key::CloseBracket, Key::CloseBracket) => false,
                // WE EXPLICITLY WANT THIS TO MATCH AS FALSE
                (Key::Quotation, Key::Quotation) => false,
                // NOT EQUAL
                _ => false,
            }
        }
    }
    struct Comment {
        first_slash: bool,
        second_slash: bool,
        third_slash: bool,
    }
    impl Comment {
        fn new(first: bool, second: bool, third: bool) -> Self {
            Comment { first_slash: first, second_slash: second, third_slash: third }
        }
    }
    fn match_str(in_comment_mode: &mut Comment, last_key: Option<Key>, ix: &CharIndex, str: &str) -> Key {
        let mut process_is_comment = |ix: &CharIndex, str: &str| -> bool {
            assert!(str.chars().count() == 1);
            let first = in_comment_mode.first_slash;
            let second = in_comment_mode.second_slash;
            let third = in_comment_mode.third_slash;
            match (first, second, third) {
                (false, false, false) if str == "/" => {
                    *in_comment_mode = Comment::new(true, false, false);
                    true
                }
                (true, false, false) if str == "/" => {
                    *in_comment_mode = Comment::new(true, true, false);
                    true
                }
                (true, true, false) if str == "/" => {
                    *in_comment_mode = Comment::new(true, true, true);
                    true
                }
                (true, true, true) if str == "\n" => {
                    *in_comment_mode = Comment { first_slash: false, second_slash: false, third_slash: false };
                    false
                }
                (true, true, true) => {
                    true
                }
                (_, _, _) => {
                    *in_comment_mode = Comment { first_slash: false, second_slash: false, third_slash: false };
                    false
                }
            }
        };
        let str_char_length = str.chars().count();
        let is_empty = str_char_length == 0;
        assert!(!is_empty);
        if process_is_comment(ix, str) {
            return Key::Comment
        }
        if last_key == Some(Key::ModifierIdent) && str.chars().all(char::is_alphanumeric) {
            return Key::ModifierIdent
        }
        if last_key == Some(Key::Ident) && str == "!" {
            return Key::ModifierIdent
        }
        if last_key == Some(Key::Ident) && str.chars().all(|x| {
            x.is_alphanumeric() || x == ':' || x == '_' || x == '-'
        }) {
            return Key::Ident
        }
        if last_key == Some(Key::ModifierIdent) && str.chars().enumerate().all(|(ix, x)| {
            if ix == (str_char_length - 1) {
                return x == '!'
            }
            x.is_alphanumeric() || x == ':' || x == '_' || x == '-'
        }) {
            return Key::ModifierIdent
        }
        if str == "\\" {
            return Key::Ident
        }
        if str == "{" || str == "[" || str == "(" {
            return Key::OpenBracket
        }
        if str == "}" || str == "]" || str == ")" {
            return Key::CloseBracket
        }
        if str == "\"" {
            return Key::Quotation
        }
        if str == "'" {
            return Key::Quotation
        }
        if str.chars().all(|x| x.is_ascii_punctuation()) {
            return Key::Symbol
        }
        if str.chars().all(|x| x.is_ascii_punctuation()) {
            return Key::Symbol
        }
        Key::Text
    }
    let ending_byte_size = source.len();
    let mut in_comment_mode: Comment = Comment { first_slash: false, second_slash: false, third_slash: false };
    let mut last_key: Option<Key> = None;
    let words = source
        .grapheme_indices(true)
        .enumerate()
        .map(|(cix, (bix, x))| -> (CharIndex, &str) {
            let index = CharIndex {byte_index: bix, char_index: cix};
            (index, x)
        })
        .into_iter()
        .group_by(|(ix, str)| -> Key {
            let key = match_str(&mut in_comment_mode, last_key.clone(), ix, str);
            last_key = Some(key.clone());
            key
        })
        .into_iter()
        .filter_map(|(key, group)| -> Option<(Key, CharRange, String)> {
            let mut start: Option<CharIndex> = None;
            let mut last: Option<CharIndex> = None;
            let mut str = String::new();
            for (ix, x) in group {
                str.push_str(x);
                if start.is_none() {
                    start = Some(ix);
                    continue;
                }
                last = Some(ix);
            }
            if let Some(start) = start {
                let end = CharIndex{
                    char_index: start.char_index + str.clone().chars().count(),
                    byte_index: start.byte_index + str.len(),
                };
                return Some((key, CharRange{start, end}, str));
            }
            unimplemented!("What to do?")
        })
        .map(|(k, r, s)| {
            Word {
                ty: match k {
                    Key::Ident => WordType::Ident,
                    Key::ModifierIdent => panic!("Not possible?"),
                    Key::Text => WordType::Text,
                    Key::Symbol => WordType::Symbol,
                    // It may seem redundant to return a `&'a str`
                    // as opposed to an owned `String`. BUT, it makes
                    // pattern matching much easier... So yeah...
                    Key::OpenBracket => WordType::OpenBracket({
                        let str_ref = r.substrng(source);
                        assert!(str_ref == s);
                        str_ref
                    }),
                    Key::CloseBracket => WordType::CloseBracket({
                        let str_ref = r.substrng(source);
                        assert!(str_ref == s);
                        str_ref
                    }),
                    Key::Quotation => WordType::Quotation({
                        let str_ref = r.substrng(source);
                        assert!(str_ref == s);
                        str_ref
                    }),
                    Key::Comment => WordType::Comment
                },
                range: r.clone(),
                str: Ann::new(r, s),
            }
        })
        .collect::<VecDeque<_>>();
    let debug = false;
    if debug {
        words
            .iter()
            .for_each(|word| {
                let sub_str = word.range.substrng(source);
                assert!(sub_str == word.str.value);
            })
    }
    let mut result: VecDeque<Word> = VecDeque::with_capacity(words.len());
    for word in words {
        if let Some(last) = result.pop_back() {
            if last.str.value == "=" && word.str.value == ">" {
                let range = CharRange {
                    start: last.range.start,
                    end: CharIndex{
                        char_index: last.range.start.char_index + "=?".clone().chars().count(),
                        byte_index: last.range.start.byte_index + "=>".len(),
                    }
                };
                result.push_back(Word {
                    ty: WordType::Symbol,
                    str: Ann::new(range, String::from("=>")),
                    range,
                });
                continue;
            }
            if last.str.value.chars().count() > 0 {
                if last.str.value.chars().all(|x| x == '.') && word.str.value == "." {
                    let str = last.str.value + ".";
                    let range = CharRange {
                        start: last.range.start,
                        end: CharIndex{
                            char_index: last.range.start.char_index + 1,
                            // Maybe it's 1 byte? Idk unicode made me paranoid...
                            byte_index: last.range.start.byte_index + ".".len(),
                        }
                    };
                    result.push_back(Word {
                        ty: WordType::Symbol,
                        str: Ann::new(range, str),
                        range,
                    });
                    continue;
                }
            }
            result.push_back(last);
            result.push_back(word);
            continue;
        }
        result.push_back(word);
    }
    result
}


#[derive(Debug, Clone, PartialEq)]
enum OpenType<'a> {
    Bracket(&'a str),
    Quotation(&'a str),
}
#[derive(Debug, Clone, PartialEq)]
enum CloseType<'a> {
    Bracket(&'a str),
    Quotation(&'a str),
}
impl<'a> OpenType<'a> {
    fn is_match_close_type(&'a self, close: &'a CloseType) -> bool {
        match (self, close) {
            (OpenType::Bracket("{"), CloseType::Bracket("}")) => true,
            (OpenType::Bracket("["), CloseType::Bracket("]")) => true,
            (OpenType::Bracket("("), CloseType::Bracket(")")) => true,
            (OpenType::Quotation("\""), CloseType::Quotation("\"")) => true,
            (OpenType::Quotation("'"), CloseType::Quotation("'")) => true,
            _ => false,
        }
    }
    fn is_bracket(&self) -> bool {
        match self {
            OpenType::Bracket(_) => true,
            _ => false,
        }
    }
    fn is_quotation(&self, ty: &'static str) -> bool {
        match self {
            OpenType::Quotation(x) if *x == ty => true,
            _ => false,
        }
    }
}
impl<'a> CloseType<'a> {
    fn is_bracket(&self) -> bool {
        match self {
            CloseType::Bracket(_) => true,
            _ => false,
        }
    }
    fn is_quotation(&self, ty: &'static str) -> bool {
        match self {
            CloseType::Quotation(x) if *x == ty => true,
            _ => false,
        }
    }
}
#[derive(Debug, Clone)]
struct Level<'a> {
    open: OpenType<'a>,
    children: ParserAst,
}

#[derive(Debug, Clone)]
pub struct Word<'a> {
    ty: WordType<'a>,
    range: CharRange,
    str: Ann<String>,
}

impl<'a> Word<'a> {
    fn to_close_type(&self) -> Option<CloseType<'a>> {
        match self.ty {
            WordType::CloseBracket(x) => Some(CloseType::Bracket(x)),
            WordType::Quotation(x) => Some(CloseType::Quotation(x)),
            _ => None,
        }
    }
    fn to_open_type(&self) -> Option<OpenType<'a>> {
        match self.ty {
            WordType::OpenBracket(x) => Some(OpenType::Bracket(x)),
            WordType::Quotation(x) => Some(OpenType::Quotation(x)),
            _ => None,
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
pub enum WordType<'a> {
    Ident,
    Text,
    Symbol,
    OpenBracket(&'a str),
    CloseBracket(&'a str),
    Quotation(&'a str),
    Comment,
}

impl<'a> WordType<'a> {
    fn is_close_bracket(&self) -> bool {
        match self {
            WordType::CloseBracket(_) => true,
            _ => false,
        }
    }
    fn is_quotation(&self, ty: &'static str) -> bool {
        match self {
            WordType::Quotation(x) if *x == ty => true,
            _ => false,
        }
    }
    fn is_open_bracket(&self) -> bool {
        match self {
            WordType::OpenBracket(_) => true,
            _ => false
        }
    }
}

type CloseWord<'a> = Word<'a>;
type OpenWord<'a> = Word<'a>;

#[derive(Debug, Clone)]
pub enum ParserError {
    
}

fn parse_words<'a>(
    env: &CompilerEnv,
    words: &mut VecDeque<Word<'a>>,
    parent: Option<(OpenWord<'a>)>,
) -> (Vec<ParserAst>, Option<CloseWord<'a>>) {
    fn to_node<'a>(word: Word<'a>) -> Option<ParserAst> {
        match word.ty {
            WordType::Ident => {
                Some(ParserAst::Ident(word.str.to_ident().unwrap()))
            }
            WordType::Text => {
                Some(ParserAst::Text(word.str))
            }
            WordType::Symbol => {
                Some(ParserAst::Symbol(word.str))
            }
            WordType::OpenBracket(_) | WordType::CloseBracket(_) | WordType::Quotation(_) => {
                None
            }
            WordType::Comment => {
                Some(ParserAst::Comment(word.str))
            }
        }
    }
    let mut nodes: Vec<ParserAst> = Vec::new();
    while let Some(current) = words.pop_front() {
        match (parent.as_ref().map(|x| &x.ty), current.ty.clone()) {
            (Some(WordType::OpenBracket("{")), WordType::CloseBracket("}")) => {
                return (nodes, Some(current))
            }
            (Some(WordType::OpenBracket("[")), WordType::CloseBracket("]")) => {
                return (nodes, Some(current))
            }
            (Some(WordType::OpenBracket("(")), WordType::CloseBracket(")")) => {
                return (nodes, Some(current))
            }
            (Some(WordType::Quotation("\"")), WordType::Quotation("\"")) => {
                return (nodes, Some(current))
            }
            (Some(WordType::Quotation("'")), WordType::Quotation("'")) => {
                return (nodes, Some(current))
            }
            (Some(WordType::Quotation("\"")), _) => {
                nodes.push(to_node(current).unwrap())
            }
            (Some(WordType::Quotation("'")), ty) => {
                match to_node(current.clone()) {
                    Some(x) => nodes.push(x),
                    None => {
                        nodes.push(ParserAst::Symbol(current.str));
                    },
                }
            }
            (_, WordType::OpenBracket("{")) => {
                let open_ty = current.to_open_type().unwrap();
                let (children, close) = parse_words(env, words, Some(current.clone()));
                let close_ty = close.clone().and_then(|close| close.to_close_type());
                match ((open_ty, close_ty)) {
                    (OpenType::Bracket("{"), Some(CloseType::Bracket("}"))) => {
                        let result = ParserAst::Bracket(Bracket{
                            children,
                            open: Some(current.str),
                            close: close.map(|word| word.str),
                        });
                        nodes.push(result);
                    }
                    (OpenType::Bracket("{"), None) => {
                        let result = ParserAst::Bracket(Bracket{
                            children,
                            open: Some(current.str),
                            close: None,
                        });
                        nodes.push(result);
                    }
                    (l, r) => unimplemented!("{:?} {:?} \t {:?}", l, r, children),
                }
            }
            (_, WordType::OpenBracket("[")) => {
                let open_ty = current.to_open_type().unwrap();
                let (children, close) = parse_words(env, words, Some(current.clone()));
                let close_ty = close.clone().and_then(|close| close.to_close_type());
                match ((open_ty, close_ty)) {
                    (OpenType::Bracket("["), Some(CloseType::Bracket("]"))) => {
                        let result = ParserAst::Bracket(Bracket{
                            children,
                            open: Some(current.str),
                            close: close.map(|word| word.str),
                        });
                        nodes.push(result);
                    }
                    (OpenType::Bracket("["), None) => {
                        let result = ParserAst::Bracket(Bracket{
                            children,
                            open: Some(current.str),
                            close: None,
                        });
                        nodes.push(result);
                    }
                    _ => unimplemented!(),
                }
            }
            (_, WordType::OpenBracket("(")) => {
                let open_ty = current.to_open_type().unwrap();
                let (children, close) = parse_words(env, words, Some(current.clone()));
                let close_ty = close.clone().and_then(|close| close.to_close_type());
                match ((open_ty, close_ty)) {
                    (OpenType::Bracket("("), Some(CloseType::Bracket(")"))) => {
                        let result = ParserAst::Bracket(Bracket{
                            children,
                            open: Some(current.str),
                            close: close.map(|word| word.str),
                        });
                        nodes.push(result);
                    }
                    (OpenType::Bracket("("), None) => {
                        let result = ParserAst::Bracket(Bracket{
                            children,
                            open: Some(current.str),
                            close: None,
                        });
                        nodes.push(result);
                    }
                    _ => unimplemented!(),
                }
            }
            (_, WordType::Quotation("\"")) => {
                let open_ty = current.to_open_type().unwrap();
                let (children, close) = parse_words(env, words, Some(current.clone()));
                let close_ty = close.clone().and_then(|close| close.to_close_type());
                match ((open_ty, close_ty)) {
                    (OpenType::Quotation("\""), Some(CloseType::Quotation("\""))) => {
                        let result = ParserAst::Quotation(Quotation{
                            children,
                            open: Some(current.str),
                            close: close.map(|word| word.str),
                        });
                        nodes.push(result);
                    }
                    (OpenType::Quotation("\""), None) => {
                        let result = ParserAst::Quotation(Quotation{
                            children,
                            open: Some(current.str),
                            close: None,
                        });
                        nodes.push(result);
                    }
                    _ => unimplemented!(),
                }
            }
            (_, WordType::Quotation("'")) => {
                let open_ty = current.to_open_type().unwrap();
                let (children, close) = parse_words(env, words, Some(current.clone()));
                let close_ty = close.clone().and_then(|close| close.to_close_type());
                match ((open_ty, close_ty)) {
                    (OpenType::Quotation("'"), Some(CloseType::Quotation("'"))) => {
                        let result = ParserAst::Quotation(Quotation{
                            children,
                            open: Some(current.str),
                            close: close.map(|word| word.str),
                        });
                        nodes.push(result);
                    }
                    (OpenType::Quotation("'"), None) => {
                        let result = ParserAst::Quotation(Quotation{
                            children,
                            open: Some(current.str),
                            close: None,
                        });
                        nodes.push(result);
                    }
                    _ => unimplemented!(),
                }
            }
            res => {
                let result = to_node(current.clone());
                if result.is_none() {
                    // INVALID CASES
                    match res {
                        (None, WordType::CloseBracket("}")) => {
                            nodes.push(ParserAst::InvalidToken(current.str));
                        }
                        _ => unimplemented!("What to do?")
                    }
                }
                // VALID
                if let Some(result) = result {
                    nodes.push(result);
                }
            }
        }
    }
    (nodes, None)
}

pub fn parse_source<T: AsRef<str>>(env: &CompilerEnv, source: T) -> crate::subscript::ast::Node {
    let mut words = init_words(source.as_ref());
    let (ast, res) = parse_words(env, &mut words, None);
    assert!(res.is_none());
    let ast = ast
        .into_iter()
        .map(ParserAst::to_node)
        .collect_vec();
    crate::subscript::ast::Node::Fragment(ast)
}

pub fn dev() {
    let source = std::fs::read_to_string("source.ss").unwrap();
    let env = CompilerEnv {
        file_path: PathBuf::from("source.ss")
    };
    let mut words = init_words(&source);
    let (ast, res) = parse_words(&env, &mut words, None);
    assert!(res.is_none());
    println!("{:#?}", ast);
}