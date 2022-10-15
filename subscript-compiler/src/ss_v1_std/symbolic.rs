//! All Subscript STEM related notation typesetting. 
use crate::html;
use crate::ss::ast_data::HeadingType;
use crate::ss::SemanticScope;
use crate::ss::SymbolicModeType;
use crate::ss::ast_traits::SyntacticallyEq;
use crate::ss::ResourceEnv;

use super::*;

// enum MathMode {
//     Default,
//     Center,
//     Align,
// }

// impl MathMode {
//     pub fn from_attributes(attributes: &Attributes) {
//         let mode = attributes.get_str_value("mode");
//         let mode = attributes.get_str_value("center");
//         let mode = attributes.get_str_value("multiline");
//     }
// }

enum EnvironmentPreset {
    // Multiline,
    Centered,
    Equations,
}

struct LabelMeta {
    /// Automatic numbered equations 
    num: bool,
    /// Use a given value for the tag. 
    tag: Option<String>,
}

struct LabelMetaApply<'a, T, U, V> {
    default: &'a T,
    tag: &'a U,
    numbered: &'a V
}

impl LabelMeta {
    fn from_attributes(attributes: &Attributes) -> LabelMeta {
        let num = attributes.has_truthy_option("num");
        let tag = attributes.get_str_value("tag").map(String::from);
        LabelMeta {num, tag}
    }
    pub fn for_each<'a, T, F1, F2, F3>(
        &self,
        apply: LabelMetaApply<'a, F1, F2, F3>
    ) -> T where F1: Fn() -> T, F2: Fn(&str) -> T, F3: Fn() -> T {
        match (self.num, self.tag.as_ref().map(String::as_str)) {
            (_, Some(tag)) => (apply.tag)(tag),
            (true, None) => (apply.numbered)(),
            (false, None) => (apply.default)(),
            _ => (apply.default)()
        }
    }
}

pub fn all_subscript_symbolic_environments() -> Vec<cmd_decl::CmdDeclaration> {
    let inline_math = CmdDeclBuilder::new(Ident::from("\\").unwrap())
        .child_layout_mode(LayoutMode::Inline)
        .child_content_mode(ContentMode::Symbolic(SymbolicModeType::Math))
        .arguments(
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
        )
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let child_scope = scope.new_scope(&mut env.resource_env, &cmd);
                let mut latex_env = crate::ss::env::LatexCodegenEnv::from_scope(&child_scope);
                let latex_code = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_latex(&mut latex_env, &child_scope))
                    .collect::<String>();
                let is_unique = !scope.in_heading_scope();
                let mut html_node = env.math_env.add_inline_entry(latex_code, is_unique);
                html_node.attributes.insert(String::from("data-cmd"), String::from("inline-math"));
                html::Node::Element(html_node)
            }
        })
        .finish();
    let math_block = CmdDeclBuilder::new(Ident::from("\\math").unwrap())
        .child_layout_mode(LayoutMode::Inline)
        .child_content_mode(ContentMode::Symbolic(SymbolicModeType::Math))
        .arguments(
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
        )
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let child_scope = scope.new_scope(&mut env.resource_env, &cmd);
                let mut latex_env = crate::ss::env::LatexCodegenEnv::from_scope(&child_scope);
                let preset = cmd.attributes
                    .get_str_value("preset")
                    .and_then(|val| {
                        match val.as_str() {
                            // "multiline" | "ml" => Some(EnvironmentPreset::Multiline),
                            "centered" | "c" => Some(EnvironmentPreset::Centered),
                            "equations" | "e" => Some(EnvironmentPreset::Equations),
                            _ => None
                        }
                    })
                    .map(|preset| {
                        let label = LabelMeta::from_attributes(&cmd.attributes);
                        match preset {
                            // EnvironmentPreset::Multiline => label.for_each(LabelMetaApply {
                            //     default: &|| {
                            //         let start = "\\begin{multline*}";
                            //         let end = "\\end{multline*}\\end{split}";
                            //         (start.to_owned(), end.to_owned())
                            //     },
                            //     tag: &|tag: &str| {
                            //         let start = format!("\\begin{{multline}}\\tag{{{tag}}}");
                            //         let end = "\\end{multline}";
                            //         (start.to_owned(), end.to_owned())
                            //     },
                            //     numbered: &|| {
                            //         let start = "\\begin{multline}";
                            //         let end = "\\end{multline}";
                            //         (start.to_owned(), end.to_owned())
                            //     },
                            // }),
                            EnvironmentPreset::Centered => label.for_each(LabelMetaApply {
                                default: &|| {
                                    let start = "\\begin{gather*}";
                                    let end = "\\end{gather*}";
                                    (start.to_owned(), end.to_owned())
                                },
                                tag: &|tag: &str| {
                                    let start = format!("\\begin{{gather}}\\tag{{{tag}}}");
                                    let end = "\\end{gather}";
                                    (start.to_owned(), end.to_owned())
                                },
                                numbered: &|| {
                                    let start = "\\begin{gather}";
                                    let end = "\\end{gather}";
                                    (start.to_owned(), end.to_owned())
                                },
                            }),
                            EnvironmentPreset::Equations => label.for_each(LabelMetaApply {
                                default: &|| {
                                    let start = "\\begin{align*}";
                                    let end = "\\end{align*}";
                                    (start.to_owned(), end.to_owned())
                                },
                                tag: &|tag: &str| {
                                    let start = format!("\\begin{{align}}\\tag{{{tag}}}");
                                    let end = "\\end{align}";
                                    (start.to_owned(), end.to_owned())
                                },
                                numbered: &|| {
                                    let start = "\\begin{align}";
                                    let end = "\\end{align}";
                                    (start.to_owned(), end.to_owned())
                                },
                            }),
                        }
                    });
                let is_unique = !scope.in_heading_scope();
                let latex_code = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_latex(&mut latex_env, &child_scope))
                    .collect::<String>();
                let latex_code = match preset {
                    Some((open, close)) => format!("{open}{latex_code}{close}"),
                    _ => latex_code
                };
                let mut html_node = env.math_env.add_block_entry(latex_code, is_unique);
                html_node.attributes.insert(String::from("data-cmd"), String::from("math"));
                html::Node::Element(html_node)
            }
        })
        .finish();
    let equation = CmdDeclBuilder::new(Ident::from("\\equation").unwrap())
        .child_layout_mode(LayoutMode::Inline)
        .child_content_mode(ContentMode::Symbolic(SymbolicModeType::Math))
        .arguments(
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
        )
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let config = LabelMeta::from_attributes(&cmd.attributes);
                let (start, end) = config.for_each(LabelMetaApply {
                    default: &|| {
                        let start = "\\begin{equation*}\\begin{split}";
                        let end = "\\end{split}\\end{equation*}";
                        (start.to_owned(), end.to_owned())
                    },
                    tag: &|tag: &str| {
                        let start = format!("\\begin{{equation}}\\tag{{{tag}}}\\begin{{split}}");
                        let end = "\\end{split}\\end{equation}";
                        (start.to_owned(), end.to_owned())
                    },
                    numbered: &|| {
                        let start = "\\begin{equation}\\begin{split}";
                        let end = "\\end{split}\\end{equation}";
                        (start.to_owned(), end.to_owned())
                    },
                });
                let is_unique = !scope.in_heading_scope();
                let child_scope = scope.new_scope(&mut env.resource_env, &cmd);
                let mut latex_env = crate::ss::env::LatexCodegenEnv::from_scope(&child_scope);
                let latex_code = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_latex(&mut latex_env, &child_scope))
                    .collect::<String>();
                let latex_code = format!("{start}{latex_code}{end}");
                let mut html_node = env.math_env.add_block_entry(latex_code, is_unique);
                html_node.attributes.insert(String::from("data-cmd"), String::from("equation"));
                html::Node::Element(html_node)

            }
        })
        .finish();
    let chem = CmdDeclBuilder::new(Ident::from("\\chem").unwrap())
        .child_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(
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
        )
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let child_scope = scope.new_scope(&mut env.resource_env, &cmd);
                let mut latex_env = crate::ss::env::LatexCodegenEnv::from_scope(&child_scope);
                let latex_code = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_latex(&mut latex_env, &child_scope))
                    .collect::<String>();
                let latex_code = format!("\\ce{{{latex_code}}}");
                let is_unique = !scope.in_heading_scope();
                let mut html_node = if scope.in_inline_mode() {
                    env.math_env.add_inline_entry(latex_code, is_unique)
                } else {
                    env.math_env.add_block_entry(latex_code, is_unique)
                };
                html_node.attributes.insert(String::from("data-cmd"), String::from("chem"));
                html::Node::Element(html_node)
            }
        })
        .finish();
    let unit = CmdDeclBuilder::new(Ident::from("\\unit").unwrap())
        .child_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(
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
        )
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let child_scope = scope.new_scope(&mut env.resource_env, &cmd);
                let mut latex_env = crate::ss::env::LatexCodegenEnv::from_scope(&child_scope);
                let latex_code = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_latex(&mut latex_env, &child_scope))
                    .collect::<String>();
                let latex_code = format!("\\pu{{{latex_code}}}");
                let is_unique = !scope.in_heading_scope();
                let mut html_node = if scope.in_inline_mode() {
                    env.math_env.add_inline_entry(latex_code, is_unique)
                } else {
                    env.math_env.add_block_entry(latex_code, is_unique)
                };
                html_node.attributes.insert(String::from("data-cmd"), String::from("unit"));
                html::Node::Element(html_node)
            }
        })
        .finish();
    vec![
        inline_math,
        math_block,
        equation,
        chem,
        unit,
    ]
}

pub fn all_subscript_symbolic_mode_commands() -> Vec<cmd_decl::CmdDeclaration> {
    let frac = CmdDeclBuilder::new(Ident::from("\\frac").unwrap())
        .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                ({num}, {den}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![num, den]
                    })
                },
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
            }
        })
        .finish();
    macro_rules! token_hack {
        ($cmd:expr, $token:expr) => {{
            CmdDeclBuilder::new(Ident::from($cmd).unwrap())
                .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
                .arguments(arguments! {
                    for (internal, metadata, cmd_payload) match {
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                })
                .to_latex(to_latex!{
                    fn (env, scope, cmd) {
                        if cmd.attributes.has_truthy_option("inline") {
                            $token.to_string()
                        } else {
                            $cmd.to_string()
                        }
                    }
                })
                .finish()
        }}
    }
    let color = CmdDeclBuilder::new(Ident::from("\\color").unwrap())
        .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                ({arg}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![arg]
                    })
                },
            }
        })
        .to_latex(to_latex!{
            // TODO
            fn (env, scope, cmd, all contents) {
                contents
            }
        })
        .finish();
    let hbrace = CmdDeclBuilder::new(Ident::from("\\hbrace").unwrap())
        .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                ({arg}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![arg]
                    })
                },
            }
        })
        .to_latex(to_latex!{
            fn (env, scope, cmd, all contents) {
                if cmd.attributes.has_truthy_option("left") {
                    let open = "\\begin{dcases}";
                    let close = "\\end{dcases}";
                    return format!("{open}{contents}{close}")
                }
                if cmd.attributes.has_truthy_option("right") {
                    let open = "\\begin{rcases}";
                    let close = "\\end{rcases}";
                    return format!("{open}{contents}{close}")
                }
                contents
            }
        })
        .finish();
    let small_text = CmdDeclBuilder::new(Ident::from("\\smallText").unwrap())
        .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                ({arg}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![arg]
                    })
                },
            }
        })
        .to_latex(to_latex!{
            fn (env, scope, cmd, all contents) {
                format!("\\small\\text{{{contents}}}\\normalsize")
            }
        })
        .finish();
    let tiny_text = CmdDeclBuilder::new(Ident::from("\\tinyText").unwrap())
        .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                ({arg}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![arg]
                    })
                },
            }
        })
        .to_latex(to_latex!{
            fn (env, scope, cmd, all contents) {
                format!("\\tiny\\text{{{contents}}}\\normalsize")
            }
        })
        .finish();
    let smaller = CmdDeclBuilder::new(Ident::from("\\smaller").unwrap())
        .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                ({arg}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![arg]
                    })
                },
            }
        })
        .to_latex(to_latex!{
            fn (env, scope, cmd, all contents) {
                format!("\\small{{{contents}}}\\normalsize")
            }
        })
        .finish();
    let tinier = CmdDeclBuilder::new(Ident::from("\\tinier").unwrap())
        .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                ({arg}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![arg]
                    })
                },
            }
        })
        .to_latex(to_latex!{
            fn (env, scope, cmd) {
                let contents = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_latex(env, scope))
                    .collect::<Vec<_>>()
                    .join("");
                format!("\\tiny{{{contents}}}\\normalsize")
            }
        })
        .finish();
    let sci = CmdDeclBuilder::new(Ident::from("\\sci").unwrap())
        .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                ({arg1}, {arg2}) => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: cmd_payload.attributes.unwrap_or_default(),
                        arguments: vec![
                            arg1,
                            arg2
                        ]
                    })
                },
            }
        })
        .to_latex(to_latex_cases!{
            for (env, scope, attrs) match {
                default contents => {{
                    String::new()
                }},
                ({arg1}, {arg2}) => {
                    format!("{{{arg1}}} \\times 10^{{{arg2}}}")
                },
            }
        })
        .finish();
    let mol_unit = CmdDeclBuilder::new(Ident::from("\\mol").unwrap())
        .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
        .arguments(arguments! {
            for (internal, metadata, cmd_payload) match {
                () => {
                    Node::Cmd(CmdCall {
                        identifier: cmd_payload.identifier,
                        attributes: Default::default(),
                        arguments: vec![]
                    })
                },
            }
        })
        .to_latex(to_latex!{
            fn (env, scope, cmd) {
                String::from("\\pu{mol}")
            }
        })
        .finish();
    let parens = CmdDeclBuilder::new(Ident::from("\\parens").unwrap())
        .parent_content_mode(ContentMode::Symbolic(SymbolicModeType::All))
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
        .to_latex(to_latex!{
            fn (env, scope, cmd, all children) {
                format!("\\left({{{children}}}\\right)")
            }
        })
        .finish();
    let reciprocal = CmdDeclBuilder::new(Ident::from("\\reciprocal").unwrap())
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
            }
        })
        .finish();
    vec![
        token_hack!("\\lbrace", "{"),
        token_hack!("\\rbrace", "}"),
        token_hack!("\\lparen", "("),
        token_hack!("\\rparen", ")"),
        token_hack!("\\lbrack", "["),
        token_hack!("\\rbrack", "]"),
        frac,
        color,
        hbrace,
        small_text,
        tiny_text,
        smaller,
        tinier,
        sci,
        mol_unit,
        parens,
        reciprocal,
    ]
}
