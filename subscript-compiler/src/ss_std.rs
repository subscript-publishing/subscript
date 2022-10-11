//! I’ve overhauled the parser (didn’t realize how bad the previous implementation was), and the core compiler data models, with a unified interface for command declarations, where commands can be implemented and made available in a very fined tuned manner.
//! So you can have commands that are available based on parent command scope (for instance the `\row{…}` cmd is only available if it's nested under the `\table` cmd (doesn’t need to be a direct descendant)), block/inline mode, or content mode (i.e. text (the default) or the multitude “symbolic modes” (such as math, chemistry, both, etc.)). For instance, LaTeX technically has two different fraction macros, where one is for block display modes and the other for inline fractions (can’t remember what it’s called), with the interface I have: you can use the came command identifier for both, and the compiler will automatically select the appropriate version.
//! **Although at the time of this writing, not all information is propagated during relevant AST traversals.** Also there needs to be support for defining documentation for a given command, which I haven’t yet got to. 
//! Defining/declaring SS commands in rust is somewhat awkward and very verbose, and perhaps could be better, but the real innovation here (as opposed to previous implementations) is that all commands are defined in a manner that (in theory) is easily fed to autocomplete engines. Furthermore, everything pertaining to a given command is defined in one place, from post-parser structure to target specific code-gens. Furthermore, for a given processing stage, all commands are essentially processed in a single traversal. 
// use crate::ss::ast::{Ann, Bracket, Ident, IdentInitError, Node};
use either::{Either, Either::Left, Either::Right};
use itertools::Itertools;
use std::{collections::HashMap, hash::Hash, path::PathBuf, rc::Rc};

use crate::ss::SemanticScope;
use crate::ss::SymbolicModeType;
use crate::ss::ast_traits::SyntacticallyEq;


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// // DEV
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

macro_rules! argument_decl_impl {
    ($arg_instances:ident, $internal:ident, $metadata:ident, $cmd_payload:ident, (.. as $args:ident), $body:block) => {{
        fn apply(
            $internal: &mut cmd_decl::cmd_invocation::Internal,
            $metadata: cmd_decl::cmd_invocation::Metadata,
            $cmd_payload: cmd_decl::cmd_invocation::CmdPayload,
        ) -> Node {
            let $args: Vec<Node> = $cmd_payload.nodes.clone();
            $body
        }
        let arg_instance: cmd_decl::ArgumentsDeclInstance = cmd_decl::ArgumentsDeclInstance {
            ty: Either::Left(cmd_decl::Override::AllFollowingCurlyBraces),
            apply: cmd_decl::cmd_invocation::ArgumentDeclMap(apply),
        };
        $arg_instances.0.push(arg_instance);
    }};
    ($arg_instances:ident, $internal:ident, $metadata:ident, $cmd_payload:ident, (), $body:block) => {{
        fn apply(
            $internal: &mut cmd_decl::cmd_invocation::Internal,
            $metadata: cmd_decl::cmd_invocation::Metadata,
            $cmd_payload: cmd_decl::cmd_invocation::CmdPayload,
        ) -> Node {
            $body
        }
        let arg_instance: cmd_decl::ArgumentsDeclInstance = cmd_decl::ArgumentsDeclInstance {
            ty: Either::Left(cmd_decl::Override::NoArguments),
            apply: cmd_decl::cmd_invocation::ArgumentDeclMap(apply),
        };
        $arg_instances.0.push(arg_instance);
    }};
    ($arg_instances:ident, $internal:ident, $metadata:ident, $cmd_payload:ident, (
        {$arg1:ident}
    ), $body:block) => {{
        fn apply(
            $internal: &mut cmd_decl::cmd_invocation::Internal,
            $metadata: cmd_decl::cmd_invocation::Metadata,
            $cmd_payload: cmd_decl::cmd_invocation::CmdPayload,
        ) -> Node {
            if let Some($arg1) = $cmd_payload.nodes.get(0).map(Clone::clone) {
                $body
            } else {
                let nodes = $cmd_payload.nodes;
                panic!("internal compiler error: args are 2 but such is empty. Given: {nodes:#?}")
            }
        }
        let arg_instance: cmd_decl::ArgumentsDeclInstance = cmd_decl::ArgumentsDeclInstance {
            ty: Either::Right(vec![cmd_decl::ArgumentType::curly_brace()]),
            apply: cmd_decl::cmd_invocation::ArgumentDeclMap(apply),
        };
        $arg_instances.0.push(arg_instance);
    }};
    ($arg_instances:ident, $internal:ident, $metadata:ident, $cmd_payload:ident, (
        {$arg1:ident}, {$arg2:ident}
    ), $body:block) => {{
        fn apply(
            $internal: &mut cmd_decl::cmd_invocation::Internal,
            $metadata: cmd_decl::cmd_invocation::Metadata,
            $cmd_payload: cmd_decl::cmd_invocation::CmdPayload,
        ) -> Node {
            let $arg1: Node = $cmd_payload.nodes.get(0).unwrap().clone();
            let $arg2: Node = $cmd_payload.nodes.get(0).unwrap().clone();
            $body
        }
        let arg_instance: cmd_decl::ArgumentsDeclInstance = cmd_decl::ArgumentsDeclInstance {
            ty: ::either::Either::Right(vec![
                cmd_decl::ArgumentType::curly_brace(),
                cmd_decl::ArgumentType::curly_brace(),
            ]),
            apply: cmd_decl::cmd_invocation::ArgumentDeclMap(apply),
        };
        $arg_instances.0.push(arg_instance);
    }};
    ($arg_instances:ident, $internal:ident, $metadata:ident, $cmd_payload:ident, (
        {$arg1:ident}, {$arg2:ident}, {$arg3:ident}
    ), $body:block) => {{
        fn apply(
            $internal: &mut cmd_decl::cmd_invocation::Internal,
            $metadata: cmd_decl::cmd_invocation::Metadata,
            $cmd_payload: cmd_decl::cmd_invocation::CmdPayload,
        ) -> Node {
            let $arg1: Node = $cmd_payload.nodes.get(0).unwrap().clone();
            let $arg2: Node = $cmd_payload.nodes.get(0).unwrap().clone();
            let $arg3: Node = $cmd_payload.nodes.get(0).unwrap().clone();
            $body
        }
        let arg_instance: cmd_decl::ArgumentsDeclInstance = cmd_decl::ArgumentsDeclInstance {
            ty: Either::Right(vec![
                cmd_decl::ArgumentType::curly_brace(),
                cmd_decl::ArgumentType::curly_brace(),
                cmd_decl::ArgumentType::curly_brace(),
            ]),
            apply: cmd_decl::cmd_invocation::ArgumentDeclMap(apply),
        };
        $arg_instances.0.push(arg_instance);
    }};
}

macro_rules! arguments {
    (for ($internal:ident, $metadata:ident, $cmd_payload:ident) match {$($args:tt => $body:block),* $(,)?}) => {{
        use $crate::ss::ast_data::Node;
        use $crate::ss::cmd_decl::cmd_invocation;
        let mut arg_instances = cmd_decl::VariableArguments::default();
        $({
            argument_decl_impl!(arg_instances, $internal, $metadata, $cmd_payload, $args, $body)
        })*
        arg_instances
    }};
}

macro_rules! to_html {
    (fn ($env:ident, $scope:ident, $cmd:ident) $block:block) => {{
        fn f(
            $env: &mut $crate::ss::env::HtmlCodegenEnv,
            $scope: &$crate::ss::env::SemanticScope,
            $cmd: $crate::ss::CmdCall,
        ) -> $crate::html::ast::Node {
            $block
        }
        f
    }};
}

macro_rules! to_latex {
    (fn ($env:ident, $scope:ident, $cmd:ident) $block:block) => {{
        fn f(
            $env: &mut $crate::ss::env::LatexCodegenEnv,
            $scope: &$crate::ss::env::SemanticScope,
            $cmd: CmdCall,
        ) -> String {
            $block
        }
        f
    }};
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// // MACRO COMMAND BUILDER API
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


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// // SUBSCRIPT MACRO HELPERS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum HeadingType {
    H1,
    H2,
    H3,
    H4,
    H5,
    H6,
}

impl HeadingType {
    pub fn to_id(&self) -> Ident {
        match self {
            HeadingType::H1 => Ident::from("\\h1").unwrap(),
            HeadingType::H2 => Ident::from("\\h2").unwrap(),
            HeadingType::H3 => Ident::from("\\h3").unwrap(),
            HeadingType::H4 => Ident::from("\\h4").unwrap(),
            HeadingType::H5 => Ident::from("\\h5").unwrap(),
            HeadingType::H6 => Ident::from("\\h6").unwrap(),
        }
    }
    pub fn from_id(id: &Ident) -> Option<HeadingType> {
        match id.clone().to_tex_ident() {
            "\\h1" => Some(HeadingType::H1),
            "\\h2" => Some(HeadingType::H2),
            "\\h3" => Some(HeadingType::H3),
            "\\h4" => Some(HeadingType::H4),
            "\\h5" => Some(HeadingType::H5),
            "\\h6" => Some(HeadingType::H6),
            _ => None,
        }
    }
    pub fn from_u8(ix: u8) -> Option<HeadingType> {
        match ix {
            0 => Some(HeadingType::H1),
            1 => Some(HeadingType::H2),
            2 => Some(HeadingType::H3),
            3 => Some(HeadingType::H4),
            4 => Some(HeadingType::H5),
            5 => Some(HeadingType::H6),
            _ => None,
        }
    }
    pub fn to_u8(&self) -> u8 {
        match self {
            HeadingType::H1 => 0,
            HeadingType::H2 => 1,
            HeadingType::H3 => 2,
            HeadingType::H4 => 3,
            HeadingType::H5 => 4,
            HeadingType::H6 => 5,
        }
    }
    pub fn to_decrement_amount(&self) -> u8 {
        match self {
            HeadingType::H1 => 0,
            HeadingType::H2 => 1,
            HeadingType::H3 => 2,
            HeadingType::H4 => 3,
            HeadingType::H5 => 4,
            HeadingType::H6 => 5,
        }
    }
    pub fn decrement(&self) -> HeadingType {
        match self {
            HeadingType::H1 => HeadingType::H2,
            HeadingType::H2 => HeadingType::H3,
            HeadingType::H3 => HeadingType::H4,
            HeadingType::H4 => HeadingType::H5,
            HeadingType::H5 => HeadingType::H6,
            HeadingType::H6 => HeadingType::H6,
        }
    }
    pub fn decrement_by(&self, amount: u8) -> HeadingType {
        match amount {
            0 => *self,
            1 => self.decrement(),
            2 => self.decrement().decrement(),
            3 => self.decrement().decrement().decrement(),
            4 => self.decrement().decrement().decrement().decrement(),
            5 | _ => self
                .decrement()
                .decrement()
                .decrement()
                .decrement()
                .decrement(),
        }
    }
}

fn normalize_ref_headings(baseline: HeadingType, node: Node) -> Node {
    let decrement_amount = baseline.to_u8();
    let f = |node: Node| -> Node {
        match node {
            Node::Cmd(mut cmd) if cmd.is_heading_node() => {
                let heading_type = HeadingType::from_id(&cmd.identifier.value).unwrap();
                let heading_type = heading_type.decrement_by(decrement_amount);
                cmd.identifier = Ann::unannotated(heading_type.to_id());
                Node::Cmd(cmd)
            }
            node => node,
        }
    };
    node.transform(Rc::new(f))
}

fn process_ssd1_include(
    scope: &SemanticScope,
    file_path: &PathBuf,
    rewrite_rules: Option<Vec<crate::ss::RewriteRule<Vec<Node>>>>,
) -> Vec<Node> {
    let file_path = file_path.clone();
    let file_path = scope.normalize_file_path(file_path);
    unimplemented!();
    // if let Ok(svgs) = crate::ss_drawing::api::parse_file(file_path).map(|x| x.canvas.entries) {
    //     let rewrite_rules = rewrite_rules
    //         .and_then(|rules| rules.first().map(Clone::clone))
    //         .and_then(|rule| -> Option<RewriteRule<Node>> {
    //             let pattern = Node::Fragment(rule.pattern.clone());
    //             let target = Node::Fragment(rule.target.clone());
    //             Some(RewriteRule { pattern, target })
    //         });
    //     if let Some(rewrite_rule) = rewrite_rules {
    //         let children = svgs
    //             .clone()
    //             .into_iter()
    //             .map(|svg| -> Node {
    //                 let f = {
    //                     let svg = svg.clone();
    //                     let pattern = rewrite_rule.pattern.clone();
    //                     move |scope: SemanticScope, node: Node| -> Node {
    //                         if node.syntactically_equal(&pattern) {
    //                             return Node::Drawing(crate::ss_drawing::Drawing::Ssd1(svg.clone()));
    //                         }
    //                         node
    //                     }
    //                 };
    //                 let scope = SemanticScope::default();
    //                 rewrite_rule.target.clone().transform(scope, Rc::new(f))
    //                 // .unblock(crate::subscript::BracketType::CurlyBrace)
    //             })
    //             .collect_vec();
    //         return children;
    //     }
    //     return svgs
    //         .into_iter()
    //         .map(|svg| Node::Drawing(crate::ss_drawing::Drawing::Ssd1(svg)))
    //         .collect_vec();
    // }
    vec![]
}

fn process_ss1_drawing(
    file_path: &PathBuf,
    rewrite_rules: Option<Vec<crate::ss::RewriteRule<Vec<Node>>>>,
) -> Vec<Node> {
    if let Ok(model) = ss_freeform_format::CanvasDataModel::parse_file(file_path) {
        let rewrite_rules = rewrite_rules
            .and_then(|rules| rules.first().map(Clone::clone))
            .and_then(|rule| -> Option<RewriteRule<Node>> {
                let pattern = Node::Fragment(rule.pattern.clone());
                let target = Node::Fragment(rule.target.clone());
                Some(RewriteRule { pattern, target })
            });
        if let Some(rewrite_rule) = rewrite_rules {
            let drawings = model.entries;
            let children = drawings
                .clone()
                .into_iter()
                .map(|drawing| -> Node {
                    let f = {
                        let drawing = drawing.clone();
                        let pattern = rewrite_rule.pattern.clone();
                        move |node: Node| -> Node {
                            if node.syn_eq(&pattern) {
                                return Node::Drawing(drawing.clone());
                            }
                            node
                        }
                    };
                    rewrite_rule.target.clone().transform(Rc::new(f))
                    // .unblock(crate::subscript::BracketType::CurlyBrace)
                })
                .collect_vec();
            return children;
        }
        let drawings = model.entries
            .into_iter()
            .map(Node::Drawing)
            .collect::<Vec<_>>();
        return drawings
    }
    Vec::new()
}

fn process_ss1_composition(
    scope: &SemanticScope,
    rewrite_rules: Option<Vec<RewriteRule<Vec<Node>>>>,
) -> Vec<Node> {
    use ss_freeform_format::PageDataModel;
    if let Ok(model) = PageDataModel::parse_file(scope.file_path.as_ref().unwrap()) {

    }
    unimplemented!()
}

fn handle_include(
    scope: &SemanticScope,
    attributes: &Option<Attributes>,
    rewrite_rules: Option<Vec<RewriteRule<Vec<Node>>>>,
) -> Option<Node> {
    let attributes = attributes.as_ref()?;
    let baseline = attributes
        .get("baseline")
        .and_then(|x| x.value.clone().as_stringified_attribute_value_str(""))
        .and_then(|x| match x.as_str() {
            "h1" => Some(HeadingType::H1),
            "h2" => Some(HeadingType::H2),
            "h3" => Some(HeadingType::H3),
            "h4" => Some(HeadingType::H4),
            "h5" => Some(HeadingType::H5),
            "h6" => Some(HeadingType::H6),
            _ => None,
        });
    let src_path_str = attributes
        .get("src")?
        .value
        .clone()
        .as_stringified_attribute_value_str("")?;
    let src_path = scope.normalize_file_path(&src_path_str)
        .unwrap_or_else(|()| PathBuf::from(&src_path_str));
    let ext = src_path.extension()?.to_str();
    match ext {
        Some("ss") => {
            let sub_scope = scope.new_file(&src_path);
            let mut nodes = crate::compiler::low_level_api::parse_process(&sub_scope).ok()?;
            if let Some(baseline) = baseline {
                nodes = normalize_ref_headings(baseline, nodes);
            }
            return Some(nodes);
        }
        Some(ext) if ss_freeform_format::SS1FreeformSuite::is_ss1_drawing_file_ext(ext) => {
            let nodes = process_ss1_drawing(&src_path, rewrite_rules);
            return Some(Node::Fragment(nodes));
        }
        Some(ext) if ss_freeform_format::SS1FreeformSuite::is_ss1_composition_file_ext(ext) => {
            let sub_scope = scope.new_file(&src_path);
            let nodes = process_ss1_composition(&sub_scope, rewrite_rules);
            return Some(Node::Fragment(nodes));
        }
        _ => None,
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// // ALL SUBSCRIPT MACROS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


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

fn all_supported_html_tags() -> Vec<cmd_decl::CmdDeclaration> {
    vec![
        CmdDeclBuilder::new(Ident::from("\\address").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\article").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\aside").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\footer").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\header").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\h1").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\h2").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\h3").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\h4").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\h5").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\h6").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\section").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\blockquote").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\dd").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\dl").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\dt").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\figcaption").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\figure").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\hr").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\li").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .child_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\ol").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\p").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .child_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\pre").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\ul").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\a").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\abbr").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\b").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\bdi").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\bdo").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\br").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\cite").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\code").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\data").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\dfn").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\em").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\i").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\kbd").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\mark").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\q").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\s").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\samp").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\small").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\span").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\strong").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\sub").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\sup").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\time").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\u").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\var").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\wbr").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\audio").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\img").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\map").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\area").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\track").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\video").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\object").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\picture").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\source").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\del").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\ins").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\table").unwrap())
            .arguments(default_arg1_type())
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\caption").unwrap())
            .parent(Ident::from("\\table").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .arguments(default_arg1_type())
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\col").unwrap())
            .parent(Ident::from("\\table").unwrap())
            .arguments(default_arg1_type())
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\colgroup").unwrap())
            .parent(Ident::from("\\table").unwrap())
            .arguments(default_arg1_type())
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\tbody").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .parent(Ident::from("\\table").unwrap())
            .arguments(default_arg1_type())
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\td").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .parent(Ident::from("\\table").unwrap())
            .arguments(default_arg1_type())
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\tfoot").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .parent(Ident::from("\\table").unwrap())
            .arguments(default_arg1_type())
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\th").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .parent(Ident::from("\\table").unwrap())
            .arguments(default_arg1_type())
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\thead").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .parent(Ident::from("\\table").unwrap())
            .arguments(default_arg1_type())
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\tr").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .parent(Ident::from("\\table").unwrap())
            .arguments(default_arg1_type())
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\details").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\summary").unwrap())
            .arguments(default_arg1_type())
            .parent_layout_mode(LayoutMode::Block)
            .child_layout_mode(LayoutMode::Block)
            .finish(),
    ]
}

pub fn all_commands_list() -> Vec<cmd_decl::CmdDeclaration> {
    let inline_math = CmdDeclBuilder::new(Ident::from("\\").unwrap())
        .child_layout_mode(LayoutMode::Inline)
        .child_content_mode(ContentMode::Symbolic(SymbolicModeType::Math))
        .arguments(default_arg1_type())
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let mut latex_env = crate::ss::env::LatexCodegenEnv::from_scope(scope);
                let latex_code = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_latex(&mut latex_env, scope))
                    .collect::<String>();
                let html_node = env.math_env.add_inline_entry(latex_code);
                html_node
            }
        })
        .finish();
    let math_block = CmdDeclBuilder::new(Ident::from("\\math").unwrap())
        .child_layout_mode(LayoutMode::Inline)
        .child_content_mode(ContentMode::Symbolic(SymbolicModeType::Math))
        .arguments(default_arg1_type())
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let mut latex_env = crate::ss::env::LatexCodegenEnv::from_scope(scope);
                let latex_code = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_latex(&mut latex_env, scope))
                    .collect::<String>();
                let html_node = env.math_env.add_block_entry(latex_code);
                html_node
            }
        })
        .finish();
    //
    let frac = CmdDeclBuilder::new(Ident::from("\\frac").unwrap())
        .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                ({den}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![
                            Node::new_curly_brace(vec![
                                Node::new_text("1")
                            ]),
                            den
                        ]
                    })
                },
                ({num}, {den}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![num, den]
                    })
                },
            }
        })
        .finish();
    let note = CmdDeclBuilder::new(Ident::from("\\note").unwrap())
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                ({arg1}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![arg1]
                    })
                },
            }
        })
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let mut attributes = HashMap::default();
                attributes.insert(String::from("data-tag-note"), String::new());
                let children = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_html(env, scope))
                    .collect_vec();
                crate::html::Node::Element(crate::html::Element {
                    name: String::from("section"),
                    attributes,
                    children,
                })
            }
        })
        .finish();
    let include = CmdDeclBuilder::new(Ident::from("\\include").unwrap())
        .child_layout_mode(LayoutMode::Inline)
        .child_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .internal_cmd_options(cmd_decl::InternalCmdDeclOptions {
            automatically_apply_rewrites: false,
        })
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                () => {
                    let result = handle_include(
                        &metadata.scope,
                        &cmd_payload.attributes,
                        internal.rewrites.clone()
                    );
                    match result {
                        Some(result) => result,
                        None => Node::Fragment(Vec::new())
                    }
                },
            }
        })
        .finish();
    let table_row = CmdDeclBuilder::new(Ident::from("\\row").unwrap())
        .parent_layout_mode(LayoutMode::Block)
        .parent(Ident::from("\\table").unwrap())
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                (.. as nodes) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: nodes
                    })
                },
            }
        })
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let children = cmd.arguments
                    .into_iter()
                    .flat_map(|x| {
                        if let Some(block) = x.clone().into_curly_brace_children() {
                            if block.len() == 1 && block[0].is_cmd_with_name("\\td") {
                                return block
                                    .into_iter()
                                    .map(|x| x.to_html(env, scope))
                                    .collect_vec()
                            }
                            return vec![
                                crate::html::Node::Element(crate::html::Element {
                                    name: String::from("td"),
                                    attributes: HashMap::default(),
                                    children: block
                                        .into_iter()
                                        .map(|x| x.to_html(env, scope))
                                        .collect_vec(),
                                })
                            ]
                        }
                        return vec![x.to_html(env, scope)]
                    })
                    .collect_vec();
                crate::html::Node::Element(crate::html::Element {
                    name: String::from("tr"),
                    attributes: HashMap::default(),
                    children,
                })
            }
        })
        .finish();
    vec![
        vec![include, math_block, inline_math, frac, note, table_row],
        all_supported_html_tags(),
    ]
    .concat()
}




