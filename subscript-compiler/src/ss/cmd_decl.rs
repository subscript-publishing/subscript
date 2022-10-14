//! I’ve overhauled the parser (didn’t realize how bad the previous implementation was), and the core compiler data models, with a unified interface for command declarations, where commands can be implemented and made available in a very fined tuned manner.
//! So you can have commands that are available based on parent command scope (for instance the `\row{…}` cmd is only available if it's nested under the `\table` cmd (doesn’t need to be a direct descendant)), block/inline mode, or content mode (i.e. text (the default) or the multitude “symbolic modes” (such as math, chemistry, both, etc.)). For instance, LaTeX technically has two different fraction macros, where one is for block display modes and the other for inline fractions (can’t remember what it’s called), with the interface I have: you can use the came command identifier for both, and the compiler will automatically select the appropriate version.
//! **Although at the time of this writing, not all information is propagated during relevant AST traversals.** Also there needs to be support for defining documentation for a given command, which I haven’t yet got to. 
//! Defining/declaring SS commands in rust is somewhat awkward and very verbose, and perhaps could be better, but the real innovation here (as opposed to previous implementations) is that all commands are defined in a manner that (in theory) is easily fed to autocomplete engines. Furthermore, everything pertaining to a given command is defined in one place, from post-parser structure to target specific code-gens. Furthermore, for a given processing stage, all commands are essentially processed in a single traversal. 

use std::borrow::Cow;
use std::collections::HashSet;
use std::{collections::{HashMap, VecDeque}, path::PathBuf, fmt::Debug, rc::Rc};
use either::{Either, Either::Left, Either::Right};
use itertools::Itertools;
use crate::ss::*;


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COMMAND DECLARATION
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

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
    pub processors: CmdCodegen,
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

// #[derive(Clone)]
// pub struct CmdCodegenRef(pub Rc<dyn CmdCodegen>);

// impl CmdCodegenRef {
//     pub fn new(code_gen: impl CmdCodegen + 'static) -> Self {
//         CmdCodegenRef(Rc::new(code_gen))
//     }
// }

// impl Debug for CmdCodegenRef {
//     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
//         f.debug_struct("CmdCodegenRef").finish()
//     }
// }

// pub trait CmdCodegen {
//     fn to_html(
//         &self,
//         env: &mut crate::ss::HtmlCodegenEnv,
//         scope: &SemanticScope,
//         cmd: CmdCall
//     ) -> crate::html::ast::Node {
//         crate::ss::codegen::default_cmd_html_cg(env, scope, cmd)
//     }
//     fn to_latex(
//         &self,
//         env: &mut crate::ss::LatexCodegenEnv,
//         scope: &SemanticScope,
//         cmd: CmdCall
//     ) -> String {
//         crate::ss::codegen::default_cmd_latex_cg(env, scope, cmd)
//     }
// }


/// You can provide a function pointer to override specific code-gens, but if
/// it’s `None` (i.e. the default), it will just use the default implementation.
/// If you need more flexibility, use a specific implementation for `CmdCodegen`.
#[derive(Clone, Default)]
pub struct CmdCodegen {
    pub to_html: Option<ToHtmlFnType>,
    pub to_latex: Option<ToLatexFnType>,
}

type ToCmdFnType = fn(&SemanticScope, &CmdDeclaration, Ann<Ident>, Option<Attributes>, &[Node]) -> CmdCall;
type ToHtmlFnType = fn(&mut crate::ss::HtmlCodegenEnv, &SemanticScope, CmdCall) -> crate::html::ast::Node;
type ToLatexFnType = fn(&mut crate::ss::LatexCodegenEnv, &SemanticScope, CmdCall) -> String;

impl CmdCodegen {
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

impl CmdCodegen {
    pub fn to_html(
        &self,
        env: &mut crate::ss::HtmlCodegenEnv,
        scope: &SemanticScope,
        cmd: CmdCall
    ) -> crate::html::ast::Node {
        if let Some(f) = self.to_html {
            return f(env, scope, cmd)
        }
        crate::ss::codegen::default_cmd_html_cg(env, scope, cmd)
    }
    pub fn to_latex(
        &self,
        env: &mut crate::ss::LatexCodegenEnv,
        scope: &SemanticScope,
        cmd: CmdCall
    ) -> String {
        if let Some(f) = self.to_latex {
            return f(env, scope, cmd)
        }
        crate::ss::codegen::default_cmd_latex_cg(env, scope, cmd)
    }
}
impl Debug for CmdCodegen {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SimpleCmdProcessor").finish()
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// PARENT/CHILD ENVIRONMENT DECLARATION
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


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

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COMMAND ARGUMENTS & INVOCATION
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

pub mod cmd_invocation {
    use super::*;

    #[derive(Debug, Clone)]
    pub struct Internal {
        pub rewrites: Option<Vec<RewriteRule<Vec<Node>>>>,
    }

    #[derive(Debug, Clone)]
    pub struct Metadata<'a> {
        pub scope: &'a SemanticScope,
        pub cmd_decl: &'a CmdDeclaration,
    }

    #[derive(Debug, Clone)]
    pub struct CmdPayload {
        pub identifier: Ann<Ident>,
        pub attributes: Option<Attributes>,
        pub nodes: Vec<Node>,
    }

    #[derive(Clone)]
    pub struct ArgumentDeclMap(pub fn(&mut Internal, Metadata, CmdPayload) -> Option<Node>);

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

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// - COMMAND DECLARATION - ATTRIBUTE SPECIFICATION -
// NOTE:
// * This converts to autocomplete what the expected attributes are of a given
//   command declaration
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

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

