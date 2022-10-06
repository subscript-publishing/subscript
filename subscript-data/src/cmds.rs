use std::{collections::HashMap, path::PathBuf, hash::Hash, rc::Rc};
use itertools::Itertools;
use either::{Either, Either::Left, Either::Right};
use crate::subscript::ast::{Node, Ann, Bracket, Ident, IdentInitError};

pub mod data;
pub mod apply;
pub mod macros;
use data::{
    CmdDeclaration,
    SemanticScope,
    AttributeKey,
    AttributeValue,
    AttributeValueType,
    ArgumentType,
    ContentMode,
    SymbolicModeType,
    LayoutMode,
    IsRequired,
    ParentEnvNamespaceDecl,
    ChildEnvNamespaceDecl,
    Attributes,
    SimpleCodegen,
    CmdCodegenRef,
    CmdCall,
    VariableArguments,
    ArgumentsDeclInstance,
    InternalCmdDeclOptions,
    cmd_invocation,
    RewriteRule,
};
use crate::html;

use self::data::CompilerEnv;


// ////////////////////////////////////////////////////////////////////////////
// DEV
// ////////////////////////////////////////////////////////////////////////////


macro_rules! declare_cmd {
    () => ();
}

// Internal
// Metadata
// CmdPayload

macro_rules! argument_decl_impl {
    ($arg_instances:ident, $internal:ident, $metadata:ident, $cmd_payload:ident, (), $body:block) => {{
        fn apply(
            $internal: &mut cmd_invocation::Internal,
            $metadata: cmd_invocation::Metadata,
            $cmd_payload: cmd_invocation::CmdPayload,
        ) -> Node {
            $body
        }
        let arg_instance: ArgumentsDeclInstance = ArgumentsDeclInstance {
            ty: Either::Left(()),
            apply: cmd_invocation::ArgumentDeclMap(apply),
        };
        $arg_instances.0.push(arg_instance);
    }};
    ($arg_instances:ident, $internal:ident, $metadata:ident, $cmd_payload:ident, (
        {$arg1:ident}
    ), $body:block) => {{
        fn apply(
            $internal: &mut cmd_invocation::Internal,
            $metadata: cmd_invocation::Metadata,
            $cmd_payload: cmd_invocation::CmdPayload,
        ) -> Node {
            if let Some($arg1) = $cmd_payload.nodes.get(0).map(Clone::clone) {
                $body
            } else {
                let nodes = $cmd_payload.nodes;
                panic!("internal compiler error: args are 2 but such is empty. Given: {nodes:#?}")
            }
        }
        let arg_instance: ArgumentsDeclInstance = ArgumentsDeclInstance {
            ty: Either::Right(vec![
                ArgumentType::curly_brace(),
            ]),
            apply: cmd_invocation::ArgumentDeclMap(apply),
        };
        $arg_instances.0.push(arg_instance);
    }};
    ($arg_instances:ident, $internal:ident, $metadata:ident, $cmd_payload:ident, (
        {$arg1:ident}, {$arg2:ident}
    ), $body:block) => {{
        fn apply(
            $internal: &mut cmd_invocation::Internal,
            $metadata: cmd_invocation::Metadata,
            $cmd_payload: cmd_invocation::CmdPayload,
        ) -> Node {
            let $arg1: Node = $cmd_payload.nodes.get(0).unwrap().clone();
            let $arg2: Node = $cmd_payload.nodes.get(0).unwrap().clone();
            $body
        }
        let arg_instance: ArgumentsDeclInstance = ArgumentsDeclInstance {
            ty: Either::Right(vec![
                ArgumentType::curly_brace(),
                ArgumentType::curly_brace(),
            ]),
            apply: cmd_invocation::ArgumentDeclMap(apply),
        };
        $arg_instances.0.push(arg_instance);
    }};
    ($arg_instances:ident, $internal:ident, $metadata:ident, $cmd_payload:ident, (
        {$arg1:ident}, {$arg2:ident}, {$arg3:ident}
    ), $body:block) => {{
        fn apply(
            $internal: &mut cmd_invocation::Internal,
            $metadata: cmd_invocation::Metadata,
            $cmd_payload: cmd_invocation::CmdPayload,
        ) -> Node {
            let $arg1: Node = $cmd_payload.nodes.get(0).unwrap().clone();
            let $arg2: Node = $cmd_payload.nodes.get(0).unwrap().clone();
            let $arg3: Node = $cmd_payload.nodes.get(0).unwrap().clone();
            $body
        }
        let arg_instance: ArgumentsDeclInstance = ArgumentsDeclInstance {
            ty: Either::Right(vec![
                ArgumentType::curly_brace(),
                ArgumentType::curly_brace(),
                ArgumentType::curly_brace(),
            ]),
            apply: cmd_invocation::ArgumentDeclMap(apply),
        };
        $arg_instances.0.push(arg_instance);
    }};
}

macro_rules! arguments {
    (for ($internal:ident, $metadata:ident, $cmd_payload:ident) match {$($args:tt => $body:block),* $(,)?}) => {{
        let mut arg_instances = VariableArguments::default();
        $({
            argument_decl_impl!(arg_instances, $internal, $metadata, $cmd_payload, $args, $body)
        })*
        arg_instances
    }};
}

macro_rules! to_html {
    (fn ($env:ident, $scope:ident, $cmd:ident) $block:block) => {{
        fn f($env: &mut crate::codegen::HtmlCodegenEnv, $scope: &SemanticScope, $cmd: CmdCall) -> crate::html::ast::Node {
            $block
        }
        f
    }};
}

macro_rules! to_latex {
    (fn ($env:ident, $cmd:ident) $block:block) => {{
        fn f($env: &mut crate::codegen::LatexCodegenEnv, $cmd: CmdCall) -> String {
            $block
        }
        f
    }};
}


pub fn dev() {
    // dev1();
    // let mut iter1 = (0..);
    // let xs = vec!['a', 'b', 'c', 'd'];
    // let res = iter1.zip_longest(other)
    // let x: ArgumentsDeclInstance = unimplemented!();
    // let f: fn(&SemanticScope, &CmdDeclaration, Ann<Ident>, Option<Attributes>, &[Node]) -> Node = unimplemented!();
    // let xs: VariableArguments = unimplemented!();
    // let x = arguments!{
    //     for (scope, cmd_decl, identifier, attrs) match {
    //         // (arg1: ArgumentType::CurlyBrace, arg2: ArgumentType::CurlyBrace) => {},
    //         ({arg1}) => {
    //             unimplemented!()
    //         },
    //         ({arg1}, {arg2}) => {
    //             unimplemented!()
    //         }
    //     }
    // };
}



// ////////////////////////////////////////////////////////////////////////////
// MACRO COMMAND BUILDER API
// ////////////////////////////////////////////////////////////////////////////

pub struct CmdDeclBuilder {
    identifier: Ident,
    parent: Option<Ident>,
    parent_content_mode: Option<ContentMode>,
    parent_layout_mode: Option<LayoutMode>,
    child_env_content_mode: Option<ContentMode>,
    child_env_layout_mode: Option<LayoutMode>,
    ignore_attributes: Option<bool>,
    attributes: HashMap<AttributeKey, Option<AttributeValue>>,
    arguments: Option<VariableArguments>,
    to_cmd: Option<fn(&SemanticScope, &CmdDeclaration, Ann<Ident>, Option<Attributes>, &[Node]) -> CmdCall>,
    to_html: Option<fn(&mut crate::codegen::HtmlCodegenEnv, &SemanticScope, CmdCall) -> crate::html::ast::Node>,
    to_latex: Option<fn(&mut crate::codegen::LatexCodegenEnv, CmdCall) -> String>,
    internal: Option<InternalCmdDeclOptions>,
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
    pub fn instance(mut self, arg_decl: ArgumentsDeclInstance) -> Self {
        if self.arguments.is_none() {
            self.arguments = Some(VariableArguments(vec![arg_decl]));
            return self
        }
        self.arguments.as_mut().unwrap().0.push(arg_decl);
        self
    }
    pub fn arguments(mut self, arguments: VariableArguments) -> Self {
        self.arguments = Some(arguments);
        self
    }
    pub fn to_html(
        mut self,
        f: fn(&mut crate::codegen::HtmlCodegenEnv, &SemanticScope, CmdCall) -> crate::html::ast::Node
    ) -> Self {
        self.to_html = Some(f);
        self
    }
    pub fn to_latex(mut self, f: fn(&mut crate::codegen::LatexCodegenEnv, CmdCall) -> String) -> Self {
        self.to_latex = Some(f);
        self
    }
    pub fn internal_cmd_options(mut self, internal: InternalCmdDeclOptions) -> Self {
        self.internal = Some(internal);
        self
    }
    pub fn finish(self) -> CmdDeclaration {
        let child_env = match (self.child_env_content_mode, self.child_env_layout_mode) {
            (None, None) => None,
            (Some(content_mode), Some(layout_mode)) => Some(ChildEnvNamespaceDecl {
                content_mode,
                layout_mode,
            }),
            (None, Some(layout_mode)) => Some(ChildEnvNamespaceDecl {
                content_mode: ContentMode::default(),
                layout_mode,
            }),
            (Some(content_mode), None) => Some(ChildEnvNamespaceDecl {
                content_mode,
                layout_mode: LayoutMode::default(),
            }),
        };
        CmdDeclaration{
            identifier: self.identifier,
            parent_env: ParentEnvNamespaceDecl {
                parent: self.parent,
                content_mode: self.parent_content_mode.unwrap_or_default(),
                layout_mode: self.parent_layout_mode.unwrap_or_default(),
            },
            child_env,
            ignore_attributes: self.ignore_attributes.unwrap_or(false),
            attributes: self.attributes,
            arguments: self.arguments.unwrap_or_default(),
            processors: CmdCodegenRef::new({
                SimpleCodegen {
                    // to_cmd: self.to_cmd,
                    to_html: self.to_html,
                    to_latex: self.to_latex,
                }
            }),
            internal: self.internal.unwrap_or_default(),
        }
    }
}

// ////////////////////////////////////////////////////////////////////////////
// SUBSCRIPT MACRO HELPERS
// ////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum HeadingType {H1, H2, H3, H4, H5, H6}

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
            _ => None
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
            0 => {
                *self
            }
            1 => {
                self.decrement()
            }
            2 => {
                self.decrement().decrement()
            }
            3 => {
                self.decrement().decrement().decrement()
            }
            4 => {
                self.decrement().decrement().decrement().decrement()
            }
            5 | _ => {
                self.decrement().decrement().decrement().decrement().decrement()
            }
        }
    }
}

fn normalize_ref_headings(baseline: HeadingType, node: Node) -> Node {
    let decrement_amount = baseline.to_u8();
    let f = |env: SemanticScope, node: Node| -> Node {
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
    let scope = SemanticScope::default();
    node.transform(scope, Rc::new(f))
}

fn process_ssd1_include(
    env: &CompilerEnv,
    file_path: &PathBuf,
    rewrite_rules: Option<Vec<RewriteRule<Vec<Node>>>>,
) -> Vec<Node> {
    let file_path = file_path.clone();
    let file_path = env.normalize_file_path(file_path);
    if let Ok(svgs) = crate::ss_drawing::api::parse_file(file_path).map(|x| x.canvas.entries) {
        let rewrite_rules = rewrite_rules
            .and_then(|rules| {
                rules.first().map(Clone::clone)
            })
            .and_then(|rule| -> Option<RewriteRule<Node>> {
                let pattern = Node::Fragment(rule.pattern.clone());
                let target = Node::Fragment(rule.target.clone());
                println!("REWRITE {pattern:#?} {target:#?}\n");
                Some(RewriteRule {
                    pattern,
                    target,
                })
            });
        if let Some(rewrite_rule) = rewrite_rules {
            let children = svgs
                .clone()
                .into_iter()
                .map(|svg| -> Node {
                    let f = {
                        let svg = svg.clone();
                        let pattern = rewrite_rule.pattern.clone();
                        move |scope: SemanticScope, node: Node| -> Node {
                            println!("NODE {node:#?}");
                            if node.syntactically_equal(&pattern) {
                                return Node::Drawing(crate::ss_drawing::Drawing::Ssd1(svg.clone()))
                            }
                            node
                        }
                    };
                    let scope = SemanticScope::default();
                    rewrite_rule.target.clone().transform(scope, Rc::new(f))
                        // .unblock(crate::subscript::BracketType::CurlyBrace)
                })
                .collect_vec();
            println!("HERE {children:#?}");
            return children
        }
        return svgs
            .into_iter()
            .map(|svg| {
                Node::Drawing(crate::ss_drawing::Drawing::Ssd1(svg))
            })
            .collect_vec()
    }
    vec![]
}

fn handle_include(
    env: &CompilerEnv,
    attributes: &Option<Attributes>,
    rewrite_rules: Option<Vec<RewriteRule<Vec<Node>>>>,
) -> Option<Node> {
    let attributes = attributes.as_ref()?;
    let baseline = attributes
        .get("baseline")
        .and_then(|x| x.value.clone().as_stringified_attribute_value_str(""))
        .and_then(|x| match x.as_str()  {
            "h1" => Some(HeadingType::H1),
            "h2" => Some(HeadingType::H2),
            "h3" => Some(HeadingType::H3),
            "h4" => Some(HeadingType::H4),
            "h5" => Some(HeadingType::H5),
            "h6" => Some(HeadingType::H6),
            _ => None
        });
    let src_path_str = attributes
        .get("src")?.value
        .clone()
        .as_stringified_attribute_value_str("")?;
    let src_path = PathBuf::from(&src_path_str);
    let src_path = env.normalize_file_path(src_path);
    let ext = src_path.extension()?.to_str();
    match ext {
        Some("ss") => {
            let mut nodes = crate::compiler::low_level_api::parse_process(&src_path).ok()?;
            if let Some(baseline) = baseline {
                nodes = normalize_ref_headings(baseline, nodes);
            }
            return Some(nodes)
        }
        Some("ssd1") => {
            let nodes = process_ssd1_include(env, &src_path, rewrite_rules);
            return Some(Node::Fragment(nodes));
        }
        _ => None
    }
}

// ////////////////////////////////////////////////////////////////////////////
// ALL SUBSCRIPT MACROS
// ////////////////////////////////////////////////////////////////////////////


pub fn all_commands_list() -> Vec<CmdDeclaration> {
    fn header_cmd(ty: HeadingType) -> CmdDeclaration {
        CmdDeclBuilder::new(ty.to_id())
            .child_layout_mode(LayoutMode::Inline)
            .arguments(arguments!{
                for (internal, metadata, cmd_payload) match {
                    ({xs}) => {
                        Node::Cmd(CmdCall {
                            identifier: cmd_payload.identifier,
                            attributes: cmd_payload.attributes.unwrap_or_default(),
                            arguments: vec![xs]
                        })
                    },
                }
            })
            .finish()
    }
    let math = CmdDeclBuilder::new(Ident::from("\\math").unwrap())
        .child_layout_mode(LayoutMode::Inline)
        .child_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(arguments!{
            for (internal, metadata, cmd_payload) match {
                ({xs}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                            attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![xs]
                    })
                },
            }
        })
        .finish();
    // 
    let frac = CmdDeclBuilder::new(Ident::from("\\frac").unwrap())
        .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(arguments!{
            for (internal, metadata, cmd_payload) match {
                ({den}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![
                            Node::curly_brace(vec![
                                Node::text("1")
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
        .arguments(arguments!{
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
        .to_html(to_html!{
            fn (env, scope, cmd) {
                let mut attributes = HashMap::default();
                attributes.insert(String::from("data-tag-note"), String::new());
                let children = cmd.arguments
                    .into_iter()
                    .map(|x| x.to_html(env, scope))
                    .collect_vec();
                html::Node::Element(html::Element {
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
        .internal_cmd_options(InternalCmdDeclOptions {
            automatically_apply_rewrites: false
        })
        .arguments(arguments!{
            for (internal, metadata, cmd_payload) match {
                () => {
                    let result = handle_include(
                        &metadata.compiler_env,
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
    vec![
        header_cmd(HeadingType::H1),
        header_cmd(HeadingType::H2),
        header_cmd(HeadingType::H3),
        header_cmd(HeadingType::H4),
        header_cmd(HeadingType::H5),
        header_cmd(HeadingType::H6),
        include,
        math,
        frac,
        note
    ]
}

pub fn all_commands_map() -> HashMap<Ident, Vec<CmdDeclaration>> {
    let mut xs: HashMap<Ident, Vec<CmdDeclaration>> = HashMap::default();
    for cmd in all_commands_list() {
        if let Some(cmds) = xs.get_mut(&cmd.identifier) {
            cmds.push(cmd);
            continue;
        }
        assert!(xs.insert(cmd.identifier.clone(), vec![cmd]).is_none());
    }
    xs
}


