//! I’ve overhauled the parser (didn’t realize how bad the previous implementation was), and the core compiler data models, with a unified interface for command declarations, where commands can be implemented and made available in a very fined tuned manner.
//! So you can have commands that are available based on parent command scope (for instance the `\row{…}` cmd is only available if it's nested under the `\table` cmd (doesn’t need to be a direct descendant)), block/inline mode, or content mode (i.e. text (the default) or the multitude “symbolic modes” (such as math, chemistry, both, etc.)). For instance, LaTeX technically has two different fraction macros, where one is for block display modes and the other for inline fractions (can’t remember what it’s called), with the interface I have: you can use the came command identifier for both, and the compiler will automatically select the appropriate version.
//! **Although at the time of this writing, not all information is propagated during relevant AST traversals.** Also there needs to be support for defining documentation for a given command, which I haven’t yet got to. 
//! Defining/declaring SS commands in rust is somewhat awkward and very verbose, and perhaps could be better, but the real innovation here (as opposed to previous implementations) is that all commands are defined in a manner that (in theory) is easily fed to autocomplete engines. Furthermore, everything pertaining to a given command is defined in one place, from post-parser structure to target specific code-gens. Furthermore, for a given processing stage, all commands are essentially processed in a single traversal. 
// use crate::ss::ast::{Ann, Bracket, Ident, IdentInitError, Node};
use either::{Either, Either::Left, Either::Right};
use itertools::Itertools;
use std::{collections::HashMap, hash::Hash, path::PathBuf, rc::Rc};

use crate::ss::ast_data::HeadingType;
use crate::ss::SemanticScope;
use crate::ss::SymbolicModeType;
use crate::ss::ast_traits::SyntacticallyEq;

#[macro_use]
pub mod macros;

#[macro_use]
pub mod core;
pub mod html_tags;
pub mod html_sugar;
pub mod symbolic;
pub mod formatting;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// DEV
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――



//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MACRO COMMAND BUILDER API
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

use crate::ss::{Ann, Ident, ContentMode, LayoutMode, Attributes, Node, CmdCall};
use crate::ss::RewriteRule;
use crate::ss::cmd_decl;

pub struct CmdDeclBuilder {
    identifier: Ident,
    parent: Option<Ident>,
    parent_content_mode: Option<ContentMode>,
    parent_layout_mode: Option<LayoutMode>,
    child_env_content_mode: Option<ContentMode>,
    child_env_layout_mode: Option<LayoutMode>,
    ignore_attributes: Option<bool>,
    attributes: HashMap<cmd_decl::AttributeKey, Option<cmd_decl::AttributeValue>>,
    arguments: Option<cmd_decl::VariableArguments>,
    to_cmd: Option<
        fn(&SemanticScope, &cmd_decl::CmdDeclaration, Ann<Ident>, Option<Attributes>, &[Node]) -> CmdCall,
    >,
    to_html: Option<
        fn(&mut crate::ss::HtmlCodegenEnv, &SemanticScope, CmdCall) -> crate::html::ast::Node,
    >,
    to_latex: Option<fn(&mut crate::ss::LatexCodegenEnv, CmdCall) -> String>,
    internal: Option<cmd_decl::InternalCmdDeclOptions>,
}

impl CmdDeclBuilder {
    pub fn new(identifier: Ident) -> CmdDeclBuilder {
        CmdDeclBuilder {
            identifier,
            parent: None,
            parent_content_mode: None,
            parent_layout_mode: None,
            child_env_content_mode: None,
            child_env_layout_mode: None,
            ignore_attributes: None,
            attributes: HashMap::default(),
            arguments: None,
            to_cmd: None,
            to_html: None,
            to_latex: None,
            internal: None,
        }
    }
    pub fn parent(mut self, ident: Ident) -> Self {
        self.parent = Some(ident);
        self
    }
    pub fn parent_content_mode(mut self, mode: ContentMode) -> Self {
        self.parent_content_mode = Some(mode);
        self
    }
    pub fn parent_layout_mode(mut self, mode: LayoutMode) -> Self {
        self.parent_layout_mode = Some(mode);
        self
    }
    pub fn child_content_mode(mut self, mode: ContentMode) -> Self {
        self.child_env_content_mode = Some(mode);
        self
    }
    pub fn child_layout_mode(mut self, mode: LayoutMode) -> Self {
        self.child_env_layout_mode = Some(mode);
        self
    }
    pub fn ignore_attributes(mut self, ignore_attributes: bool) -> Self {
        self.ignore_attributes = Some(ignore_attributes);
        self
    }
    pub fn instance(mut self, arg_decl: cmd_decl::ArgumentsDeclInstance) -> Self {
        if self.arguments.is_none() {
            self.arguments = Some(cmd_decl::VariableArguments(vec![arg_decl]));
            return self;
        }
        self.arguments.as_mut().unwrap().0.push(arg_decl);
        self
    }
    pub fn arguments(mut self, arguments: cmd_decl::VariableArguments) -> Self {
        self.arguments = Some(arguments);
        self
    }
    pub fn to_html(
        mut self,
        f: fn(
            &mut crate::ss::HtmlCodegenEnv,
            &SemanticScope,
            CmdCall,
        ) -> crate::html::ast::Node,
    ) -> Self {
        self.to_html = Some(f);
        self
    }
    pub fn to_latex(
        mut self,
        f: fn(&mut crate::ss::LatexCodegenEnv, CmdCall) -> String,
    ) -> Self {
        self.to_latex = Some(f);
        self
    }
    pub fn internal_cmd_options(mut self, internal: cmd_decl::InternalCmdDeclOptions) -> Self {
        self.internal = Some(internal);
        self
    }
    pub fn finish(self) -> cmd_decl::CmdDeclaration {
        let child_env = match (self.child_env_content_mode, self.child_env_layout_mode) {
            (None, None) => None,
            (Some(content_mode), Some(layout_mode)) => Some(cmd_decl::ChildEnvNamespaceDecl {
                content_mode,
                layout_mode,
            }),
            (None, Some(layout_mode)) => Some(cmd_decl::ChildEnvNamespaceDecl {
                content_mode: ContentMode::default(),
                layout_mode,
            }),
            (Some(content_mode), None) => Some(cmd_decl::ChildEnvNamespaceDecl {
                content_mode,
                layout_mode: LayoutMode::default(),
            }),
        };
        cmd_decl::CmdDeclaration {
            identifier: self.identifier,
            parent_env: cmd_decl::ParentEnvNamespaceDecl {
                parent: self.parent,
                content_mode: self.parent_content_mode.unwrap_or_default(),
                layout_mode: self.parent_layout_mode.unwrap_or_default(),
            },
            child_env,
            ignore_attributes: self.ignore_attributes.unwrap_or(false),
            attributes: self.attributes,
            arguments: self.arguments.unwrap_or_default(),
            processors: cmd_decl::CmdCodegenRef::new({
                cmd_decl::SimpleCodegen {
                    // to_cmd: self.to_cmd,
                    to_html: self.to_html,
                    to_latex: self.to_latex,
                }
            }),
            internal: self.internal.unwrap_or_default(),
        }
    }
}



/// A command that accepts a single curly brace based argument and simply
/// returns a cmd_call with such. 
fn default_arg1_type() -> cmd_decl::VariableArguments {
    arguments! {
        for (internal, metadata, cmd_payload) match {
            ({xs}) => {
                Node::Cmd(CmdCall {
                    identifier: cmd_payload.identifier,
                    attributes: cmd_payload.attributes.unwrap_or_default(),
                    arguments: vec![xs]
                })
            },
        }
    }
}

/// A command that accepts no arguments. 
fn default_no_arg_type() -> cmd_decl::VariableArguments {
    arguments! {
        for (internal, metadata, cmd_payload) match {
            () => {
                Node::Cmd(CmdCall {
                    identifier: cmd_payload.identifier,
                    attributes: cmd_payload.attributes.unwrap_or_default(),
                    arguments: vec![]
                })
            },
        }
    }
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SUBSCRIPT MACRO HELPERS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――




pub fn all_commands_list() -> Vec<cmd_decl::CmdDeclaration> {
    let commands = [
        core::core_subscript_commands(),
        html_tags::all_supported_html_tags(),
        html_sugar::html_syntactic_sugar_extras(),
        symbolic::all_subscript_symbolic_environments(),
        symbolic::all_subscript_symbolic_mode_commands(),
        formatting::all_inline_formatting_commands(),
        formatting::all_block_formatting_commands(),
    ];
    commands.concat()
}




