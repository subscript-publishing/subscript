use std::borrow::Cow;
use std::collections::HashSet;
use std::{collections::{HashMap, VecDeque}, path::PathBuf, fmt::Debug, rc::Rc};
use either::{Either, Either::Left, Either::Right};
use itertools::Itertools;
use crate::subscript::ast::{self, BracketType, Node, Children, Ann, Ident, IdentInitError, ToNode, AsNodeRef, Quotation};


// ////////////////////////////////////////////////////////////////////////////
// COMMAND CALL
// ////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone)]
pub struct CmdCall {
    pub identifier: Ann<Ident>,
    pub attributes: Attributes,
    pub arguments: Vec<Node>,
}

impl CmdCall {
    fn has_name(&self, ident: &str) -> bool {
        self.identifier.value == ident
    }
    fn has_attr(&self, key: impl AsNodeRef) -> bool {
        self.attributes.has_attr(key)
    }
    pub fn is_heading_node(&self) -> bool {
        self.has_name("\\h1") ||
        self.has_name("\\h2") ||
        self.has_name("\\h3") ||
        self.has_name("\\h4") ||
        self.has_name("\\h5") ||
        self.has_name("\\h6")
    }
}


// ////////////////////////////////////////////////////////////////////////////
// COMMAND DECLARATION
// ////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone)]
pub struct CmdDeclaration {
    pub identifier: Ident,
    /// This is the environment namespace where this command declaration is made available. 
    pub parent_env: ParentEnvNamespaceDecl,
    /// This is the child environment namespace that this command defines for its child elements.
    /// A value of `None` will not alter the environment in any way. 
    pub child_env: Option<ChildEnvNamespaceDecl>,
    pub attributes: HashMap<AttributeKey, Option<AttributeValue>>,
    pub ignore_attributes: bool,
    pub arguments: VariableArguments,
    pub processors: CmdCodegenRef,
    /// Just the the default implementation.
    pub internal: InternalCmdDeclOptions
}

#[derive(Debug, Clone)]
pub struct InternalCmdDeclOptions {
    pub automatically_apply_rewrites: bool,
}
impl Default for InternalCmdDeclOptions {
    fn default() -> Self {
        InternalCmdDeclOptions {
           automatically_apply_rewrites: true,
        }
    }
}

#[derive(Clone)]
pub struct CmdCodegenRef(pub Rc<dyn CmdCodegen>);

impl CmdCodegenRef {
    pub fn new(code_gen: impl CmdCodegen + 'static) -> Self {
        CmdCodegenRef(Rc::new(code_gen))
    }
}

impl Debug for CmdCodegenRef {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("CmdCodegenRef").finish()
    }
}

pub trait CmdCodegen {
    fn to_html(
        &self,
        env: &mut crate::codegen::HtmlCodegenEnv,
        scope: &SemanticScope,
        cmd: CmdCall
    ) -> crate::html::ast::Node {
        crate::codegen::html_cg::default_cmd_html_cg(env, scope, cmd)
    }
    fn to_latex(
        &self,
        env: &mut crate::codegen::LatexCodegenEnv,
        scope: &SemanticScope,
        cmd: CmdCall
    ) -> String {
        crate::codegen::latex_cg::default_cmd_latex_cg(env, scope, cmd)
    }
}


/// You can provide a function pointer to override specific code-gens, but if
/// it’s `None` (i.e. the default), it will just use the default implementation.
/// If you need more flexibility, use a specific implementation for `CmdCodegen`.
#[derive(Clone, Default)]
pub struct SimpleCodegen {
    pub to_html: Option<ToHtmlFnType>,
    pub to_latex: Option<fn(&mut crate::codegen::LatexCodegenEnv, CmdCall) -> String>,
}

type ToCmdFnType = fn(&SemanticScope, &CmdDeclaration, Ann<Ident>, Option<Attributes>, &[Node]) -> CmdCall;
type ToHtmlFnType = fn(&mut crate::codegen::HtmlCodegenEnv, &SemanticScope, CmdCall) -> crate::html::ast::Node;
type ToLatexFnType = fn(&mut crate::codegen::LatexCodegenEnv, CmdCall) -> String;

impl SimpleCodegen {
    // pub fn to_cmd(mut self, f: ToCmdFnType) -> Self {
    //     self.to_cmd = Some(f);
    //     self
    // }
    pub fn with_html_cg(mut self, f: ToHtmlFnType) -> Self {
        self.to_html = Some(f);
        self
    }
    pub fn with_latex_cg(mut self, f: ToLatexFnType) -> Self {
        self.to_latex = Some(f);
        self
    }
}

impl CmdCodegen for SimpleCodegen {
    // fn to_cmd_call(
    //     &self,
    //     scope: &SemanticScope,
    //     cmd_decl: &CmdDeclaration,
    //     ident: Ann<Ident>,
    //     attrs: Option<Attributes>,
    //     nodes: &[Node]
    // ) -> CmdCall {
    //     if let Some(f) = self.to_cmd {
    //         return f(scope, cmd_decl, ident, attrs, nodes)
    //     }
    //     CmdCall {
    //         identifier: ident,
    //         attributes: attrs.unwrap_or_default(),
    //         arguments: nodes.to_vec()
    //     }
    // }
    fn to_html(
        &self,
        env: &mut crate::codegen::HtmlCodegenEnv,
        scope: &SemanticScope,
        cmd: CmdCall
    ) -> crate::html::ast::Node {
        if let Some(f) = self.to_html {
            return f(env, scope, cmd)
        }
        crate::codegen::html_cg::default_cmd_html_cg(env, scope, cmd)
    }
    fn to_latex(
        &self,
        env: &mut crate::codegen::LatexCodegenEnv,
        scope: &SemanticScope,
        cmd: CmdCall
    ) -> String {
        if let Some(f) = self.to_latex {
            return f(env, cmd)
        }
        crate::codegen::latex_cg::default_cmd_latex_cg(env, scope, cmd)
    }
}
impl Debug for SimpleCodegen {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SimpleCmdProcessor").finish()
    }
}


// ////////////////////////////////////////////////////////////////////////////
// MISCELLANEOUS
// ////////////////////////////////////////////////////////////////////////////


#[derive(Debug, Clone)]
pub struct RewriteRule<T> {
    pub pattern: T,
    pub target: T,
}

// ////////////////////////////////////////////////////////////////////////////
// ENVIRONMENT
// ////////////////////////////////////////////////////////////////////////////

/// `SemanticScope` is used for storing environment information during AST traversals. 
#[derive(Debug, Clone)]
pub struct SemanticScope {
    /// A list of parent command names that a given node is located under.
    /// E.g. given `\note{\p{\x}}`
    /// * the `scope` of `\p` is `["\\note"]`.
    /// * the `scope` of `\x` is `["\\note", "\\p"]`.
    pub scope: Vec<Ident>,
    pub content_mode: ContentMode,
    pub layout_mode: LayoutMode,
}

impl SemanticScope {
    pub fn match_cmd(&self, cmd: &ParentEnvNamespaceDecl) -> bool {
        fn match_scope(scope: &Vec<Ident>, cmd: Option<&Ident>) -> bool {
            cmd.map(|cmd| {
                for parent_ident in scope.iter() {
                    if cmd == parent_ident {
                        return true
                    }
                }
                false
            })
            .unwrap_or(true)
        }
        let scope_match = match_scope(self.scope.as_ref(), cmd.parent.as_ref());
        let content_mode_match = self.content_mode == cmd.content_mode;
        let layout_mode_match = match (&self.layout_mode, &cmd.layout_mode) {
            (LayoutMode::Both, _) => true,
            (_, LayoutMode::Both) => true,
            (LayoutMode::Block, LayoutMode::Block) => true,
            (LayoutMode::Inline, LayoutMode::Inline) => true,
            (l, r) => {
                assert!(l != r);
                false
            }
        };
        scope_match && content_mode_match && layout_mode_match
    }
    pub fn new_scope(&self, parent: Ident) -> SemanticScope {
        let mut new_env = self.clone();
        new_env.scope.push(parent);
        new_env
    }
    pub fn is_math_env(&self) -> bool {
        unimplemented!()
    }
    pub fn is_default_env(&self) -> bool {
        !self.is_math_env()
    }
    pub fn has_parent(&self, parent: &str) -> bool {
        self.scope
            .iter()
            .any(|x| x == parent)
    }
}


impl Default for SemanticScope {
    fn default() -> Self {
        SemanticScope {
            scope: Default::default(),
            content_mode: ContentMode::Text,
            layout_mode: LayoutMode::Block,
        }
    }
}

#[derive(Debug, Clone)]
pub struct CompilerEnv {
    pub file_path: PathBuf
}

impl CompilerEnv {
    /// Use this to normalize file paths relative to the source file.
    pub fn normalize_file_path(&self, path: PathBuf) -> PathBuf {
        if let Some(rel_path) = self.file_path.parent() {
            let root_path = self.file_path.clone();
            let mut rel_path = rel_path.to_path_buf();
            rel_path.push(path.clone());
            return rel_path
        }
        path
    }
}


/// `EnvNamespaceDecl` is the declared environment where a given command is
/// available
#[derive(Debug, Clone)]
pub struct ParentEnvNamespaceDecl {
    /// In the context of a command declaration of it's parent `EnvNamespaceDecl`:
    /// * A `None` value targets the default global scope. A specific value will
    ///   only make this available within the scope of the given parent node name.
    ///   If you’d like to target e.g. the scope introduced by the `\math{}` cmd
    ///   specifically, set `parent` to `math`. If you want to target all math
    ///   scopes irrespective of the command that introduced such (which should be
    ///   preferred so your command can also e.g. be used in the equation scope),
    ///   set `parent` to `Node` and instead use `content_mode` and assign it to
    ///   e.g. `ContentMode::Symbolic(SymbolicModeType::All)` or
    ///   `ContentMode::Symbolic(SymbolicModeType::Math)`. 
    pub parent: Option<Ident>,
    /// Differentiate between text mode (the default) and the various symbolic
    /// modes, such as math modes that are activated by e.g. `\math{…}` and
    /// `\equation{…}` and so forth. 
    pub content_mode: ContentMode,
    pub layout_mode: LayoutMode,
}


#[derive(Debug, Clone)]
pub struct ChildEnvNamespaceDecl {
    pub content_mode: ContentMode,
    pub layout_mode: LayoutMode,
}

// ////////////////////////////////////////////////////////////////////////////
// COMMAND ARGUMENTS & INVOCATION
// ////////////////////////////////////////////////////////////////////////////

pub mod cmd_invocation {
    use super::*;

    #[derive(Debug, Clone)]
    pub struct Internal {
        pub rewrites: Option<Vec<RewriteRule<Vec<Node>>>>,
    }

    #[derive(Debug, Clone)]
    pub struct Metadata<'a> {
        pub compiler_env: &'a CompilerEnv,
        pub scope: &'a SemanticScope,
        pub cmd_decl: &'a CmdDeclaration,
    }

    pub struct CmdPayload {
        pub identifier: Ann<Ident>,
        pub attributes: Option<Attributes>,
        pub nodes: Vec<Node>,
    }

    #[derive(Clone)]
    pub struct ArgumentDeclMap(pub fn(&mut Internal, Metadata, CmdPayload) -> Node);

    impl Debug for ArgumentDeclMap {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            f.debug_struct("ArgumentDeclMap").finish()
        }
    }
}

#[derive(Debug, Clone, Default)]
pub struct VariableArguments(pub Vec<ArgumentsDeclInstance>);

#[derive(Debug, Clone)]
pub struct ArgumentsDeclInstance {
    /// Left currently means no arguments.
    /// Right means static/fixed arguments.
    pub ty: Either<Override, Vec<ArgumentType>>,
    pub apply: cmd_invocation::ArgumentDeclMap,
}

#[derive(Debug, Clone)]
pub enum Override {
    /// Will not match against ant arguments. 
    NoArguments,
    /// Will match against all following curly braces (zero or more).
    AllFollowingCurlyBraces,
}

#[derive(Debug, Copy, Clone)]
pub enum ArgumentType {
    CurlyBrace,
    SquareParen,
    Parens,
}

impl ArgumentType {
    pub fn curly_brace() -> Self {
        ArgumentType::CurlyBrace
    }
    pub fn square_paren() -> Self {
        ArgumentType::SquareParen
    }
    pub fn parens() -> Self {
        ArgumentType::Parens
    }
    pub const fn get_name(self) -> &'static str {
        match self {
            ArgumentType::CurlyBrace => "curly_brace",
            ArgumentType::SquareParen => "square_paren",
            ArgumentType::Parens => "parens",
        }
    }
}

// ////////////////////////////////////////////////////////////////////////////
// MACRO TYPS - BASICS
// ////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone)]
#[allow(non_snake_case)]
pub struct All;


#[derive(Debug, Clone)]
pub struct AttributeKey {
    pub key: String,
    pub required: IsRequired,
}

impl AttributeKey {
    pub fn new_attr(name: &str) -> Self {
        AttributeKey {
            key: name.to_owned(),
            required: IsRequired::Optional
        }
    }
    // pub fn optional_attr(name: &str) -> Self {
    //     AttributeKey {
    //         identifier: Node::new_text(name),
    //         required: IsRequired::Optional
    //     }
    // }
    // pub fn required_attr(name: &str) -> Self {
    //     AttributeKey {
    //         identifier: Node::new_text(name),
    //         required: IsRequired::Required
    //     }
    // }
    pub fn is_required(&self) -> bool {
        match self.required {
            IsRequired::Required => true,
            IsRequired::Optional => false,
        }
    }
    pub fn is_optional(&self) -> bool {
        match self.required {
            IsRequired::Optional => true,
            IsRequired::Required => false,
        }
    }
}


#[derive(Debug, Clone)]
pub struct AttributeValue {
    pub value_ty: AttributeValueType,
    pub required: IsRequired,
}

#[derive(Debug, Clone, PartialEq)]
pub enum AttributeValueType {
    /// A FilePath is also a string but is a more specific declaration of intent. 
    FilePath,
    /// Some arbitrary string.
    String,
    /// Some arbitrary integer.
    Int,
}


#[derive(Debug, Clone, PartialEq)]
pub enum IsRequired {
    Optional,
    Required,
}

#[derive(Debug, Clone, PartialEq)]
pub enum AttrValueRequired {
    Optional,
    Required,
}

#[derive(Debug, Clone, PartialEq)]
pub enum ContentMode {
    /// The default file mode.
    Text,
    /// Math mode, chemistry mode, and so forth.
    Symbolic(SymbolicModeType),
}

#[derive(Debug, Clone, PartialEq)]
pub enum SymbolicModeType {
    /// Math mode, chemistry mode, and so forth.
    All,
    Math,
}

#[derive(Debug, Clone, PartialEq)]
pub enum LayoutMode {
    Block,
    Inline,
    Both,
}

impl Default for LayoutMode {
    fn default() -> Self {LayoutMode::Both}
}
impl Default for SymbolicModeType {
    fn default() -> Self {SymbolicModeType::All}
}
impl Default for ContentMode {
    fn default() -> Self {ContentMode::Text}
}

pub trait SubscriptCmd {
    
}


// ////////////////////////////////////////////////////////////////////////////
// COMMAND ATTRIBUTES
// ////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone, Default)]
pub struct Attributes(VecDeque<Attribute>);

impl Attributes {
    pub fn parse_as_attribute_node(node: &Node) -> Option<Self> {
        parse_attrs(&node)
    }
    pub fn from_iter<K: ToNode, V: ToNode>(xs: impl IntoIterator<Item = (K, V)>) -> Attributes {
        let xs = xs
            .into_iter()
            .map(|(key, value)| {
                let key = key
                    .to_node()
                    .defragment_node_tree()
                    .trim_whitespace();
                let value = value
                    .to_node()
                    .defragment_node_tree()
                    .trim_whitespace();
                Attribute{key, value}
            })
            .collect::<VecDeque<_>>();
        Attributes(xs)
    }
    pub fn insert(&mut self, key: impl ToNode, value: impl ToNode) -> Option<Attribute> {
        let key = key.to_node();
        let value = value.to_node();
        let new_attribute = Attribute{key, value};
        for entry in self.0.iter_mut() {
            if entry.key.syntactically_equal(&new_attribute.key) {
                let old = entry.clone();
                *entry = new_attribute;
                return Some(old)
            }
        }
        self.0.push_back(new_attribute);
        None
    }
    pub fn get(&self, key: impl AsNodeRef) -> Option<&Attribute> {
        let key = key.as_node_ref();
        for entry in self.0.iter() {
            match key {
                Cow::Borrowed(x_key) => {
                    if entry.key.syntactically_equal(x_key) {
                        return Some(entry)
                    }
                }
                Cow::Owned(ref x_key) => {
                    if entry.key.syntactically_equal(x_key) {
                        return Some(entry)
                    }
                }
            }
        }
        None
    }
    pub fn has_attr(&self, key: impl AsNodeRef) -> bool {
        self.get(key).is_some()
    }
    pub fn consume(self) -> VecDeque<Attribute> {
        self.0
    }
}

#[derive(Debug, Clone)]
pub struct Attribute {
    pub key: Node,
    pub value: Node,
}

impl Attribute {
    pub fn to_tuple(&self) -> (&Node, &Node) {
        (&self.key, &self.value)
    }
    pub fn to_key_value_str(self) -> Option<(String, Option<String>)> {
        let key = self.key
            .defragment_node_tree()
            .trim_whitespace()
            .consume_text()?
            .consume();
        let value: Option<String> = self.value.as_stringified_attribute_value_str(" ");
        Some((key, value))
    }
}

fn parse_attrs(node: &Node) -> Option<Attributes> {
    if let Some(attrs) = node.clone().defragment_node_tree().trim_whitespace().unwrap_square_paren() {
        let xs = attrs
            .into_iter()
            .group_by(|x| {
                x.unwrap_symbol()
                    .map(|x| x.value == ",")
                    .unwrap_or(false)
            })
            .into_iter()
            .filter_map(|(key, xs)| -> Option<(Node, Node)> {
                if key == true {
                    return None
                }
                let xs = xs
                    .collect_vec()
                    .into_iter()
                    .group_by(|x| {
                        x.unwrap_symbol()
                         .map(|x| x.value == "=")
                         .unwrap_or(false)
                    })
                    .into_iter()
                    .map(|(key, ys)| {
                        ys.collect_vec()
                    })
                    .map(|xs| {
                        xs  .into_iter()
                            .map(Clone::clone)
                            .collect_vec()
                    })
                    .collect_vec();
                let mut left: Vec<Node> = Vec::new();
                let mut equal: Option<Ann<String>> = None;
                let mut right: Vec<Node> = Vec::new();
                for mut ys in xs.into_iter() {
                    if equal.is_some() {
                        right.extend(ys);
                        continue;
                    }
                    'inner: for y in ys {
                        if let Some(sym) = y.unwrap_symbol() {
                            if sym.value == "=" {
                                equal = Some(sym.clone());
                                continue 'inner;
                            }
                        }
                        left.push(y);
                    }
                }
                let left = Node::Fragment(left)
                    .defragment_node_tree()
                    .trim_whitespace();
                let right = Node::Fragment(right)
                    .defragment_node_tree()
                    .trim_whitespace();
                return Some((left, right))
                
            })
            .collect_vec();
        return Some(Attributes::from_iter(xs))
    }
    None
}
