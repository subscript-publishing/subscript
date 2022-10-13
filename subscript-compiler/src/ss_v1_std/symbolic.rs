//! All Subscript STEM related notation typesetting. 
use crate::ss::ast_data::HeadingType;
use crate::ss::SemanticScope;
use crate::ss::SymbolicModeType;
use crate::ss::ast_traits::SyntacticallyEq;

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
        .arguments(default_arg1_type())
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let mut latex_env = crate::ss::env::LatexCodegenEnv::from_scope(scope);
                let latex_code = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_latex(&mut latex_env, scope))
                    .map(|x| x.trim().to_string())
                    .collect::<String>();
                let is_unique = !scope.in_heading_scope();
                let html_node = env.math_env.add_inline_entry(latex_code, is_unique);
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
                    .map(|x| x.to_latex(&mut latex_env, scope))
                    .map(|x| x.trim().to_string())
                    .collect::<String>();
                let latex_code = match preset {
                    Some((open, close)) => format!("{open}{latex_code}{close}"),
                    _ => latex_code
                };
                env.math_env.add_block_entry(latex_code, is_unique)
            }
        })
        .finish();
    let equation = CmdDeclBuilder::new(Ident::from("\\equation").unwrap())
        .child_layout_mode(LayoutMode::Inline)
        .child_content_mode(ContentMode::Symbolic(SymbolicModeType::Math))
        .arguments(default_arg1_type())
        .to_html(to_html! {
            fn (env, scope, cmd) {
                let config = LabelMeta::from_attributes(&cmd.attributes);
                let (start, end) = config.for_each(LabelMetaApply {
                    default: &|| {
                        let start = "\\begin{equation*}\\begin{split}";
                        let end = "\\end{equation*}\\end{split}";
                        (start.to_owned(), end.to_owned())
                    },
                    tag: &|tag: &str| {
                        let start = format!("\\begin{{equation}}\\tag{{{tag}}}\\begin{{split}}");
                        let end = "\\end{equation}\\end{split}";
                        (start.to_owned(), end.to_owned())
                    },
                    numbered: &|| {
                        let start = "\\begin{equation}\\begin{split}";
                        let end = "\\end{equation}\\end{split}";
                        (start.to_owned(), end.to_owned())
                    },
                });
                let is_unique = !scope.in_heading_scope();
                let mut latex_env = crate::ss::env::LatexCodegenEnv::from_scope(scope);
                let latex_code = cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_latex(&mut latex_env, scope))
                    .map(|x| x.trim().to_string())
                    .collect::<String>();
                let latex_code = format!("{start}{latex_code}{end}");
                env.math_env.add_block_entry(latex_code, is_unique)
            }
        })
        .finish();
    vec![
        inline_math,
        math_block,
        equation,
    ]
}

pub fn all_subscript_symbolic_mode_commands() -> Vec<cmd_decl::CmdDeclaration> {
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
    vec![
        frac,
    ]
}
