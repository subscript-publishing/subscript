use either::{Either, Either::Left, Either::Right};
use itertools::Itertools;
use std::{collections::HashMap, hash::Hash, path::PathBuf, rc::Rc};

use crate::ss::ast_data::HeadingType;
use crate::ss::SemanticScope;
use crate::ss::SymbolicModeType;
use crate::ss::ast_traits::SyntacticallyEq;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// ARGUMENT MATCHING
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

macro_rules! argument_decl_impl {
    ($arg_instances:ident, $internal:ident, $metadata:ident, $cmd_payload:ident, (.. as $args:ident), $body:block) => {{
        fn apply(
            $internal: &mut cmd_decl::cmd_invocation::Internal,
            $metadata: cmd_decl::cmd_invocation::Metadata,
            $cmd_payload: cmd_decl::cmd_invocation::CmdPayload,
        ) -> Option<Node> {
            let $args: Vec<Node> = $cmd_payload.nodes.clone();
            Some($body)
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
        ) -> Option<Node> {
            Some($body)
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
        ) -> Option<Node> {
            let $arg1: Node = $cmd_payload.nodes.get(0).expect(&format!(
                "should match with 1 arg: {:#?}", $cmd_payload,
            )).clone();
            Some($body)
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
        ) -> Option<Node> {
            let $arg1: Node = $cmd_payload.nodes.get(0).unwrap().clone();
            let $arg2: Node = $cmd_payload.nodes.get(1).unwrap().clone();
            Some($body)
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
            let $arg1: Node = $cmd_payload.nodes.get(0)?.clone();
            let $arg2: Node = $cmd_payload.nodes.get(0)?.clone();
            let $arg3: Node = $cmd_payload.nodes.get(0)?.clone();
            Some($body)
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


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TO HTML HELPER
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

macro_rules! to_html {
    (fn ($env:ident, $scope:ident, $cmd:ident) $block:block) => {{
        fn f(
            $env: &$crate::ss::env::HtmlCodegenEnv,
            $scope: &$crate::ss::env::SemanticScope,
            $cmd: $crate::ss::CmdCall,
        ) -> $crate::html::ast::Node {
            $block
        }
        f
    }};
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TO LATEX HELPER
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

macro_rules! to_latex {
    (fn ($env:ident, $scope:ident, $cmd:ident) $block:block) => {{
        fn f(
            $env: &$crate::ss::env::LatexCodegenEnv,
            $scope: &$crate::ss::env::SemanticScope,
            $cmd: CmdCall,
        ) -> String {
            $block
        }
        f
    }};
    (fn ($env:ident, $scope:ident, $cmd:ident, all $children:ident) $block:block) => {{
        fn f(
            $env: &$crate::ss::env::LatexCodegenEnv,
            $scope: &$crate::ss::env::SemanticScope,
            $cmd: CmdCall,
        ) -> String {
            let $children: String = $cmd.arguments
                .into_iter()
                .flat_map(Node::unblock_root_curly_brace)
                .map(|x| x.to_latex($env, $scope))
                .collect::<Vec<_>>()
                .join("");
            $block
        }
        f
    }};
    (fn ($env:ident, $scope:ident, $cmd:ident, args {$arg1:ident} {$arg2:ident}) $block:block) => {{
        fn f(
            $env: &$crate::ss::env::LatexCodegenEnv,
            $scope: &$crate::ss::env::SemanticScope,
            $cmd: CmdCall,
        ) -> String {
            let $arg1 = $cmd.arguments.get(0).map(|x| x.clone().to_latex($env, $scope));
            let $arg2 = $cmd.arguments.get(1).map(|x| x.clone().to_latex($env, $scope));
            $block
        }
        f
    }};
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// TO LATEX BETTER HELPER
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――



#[derive(Default)]
pub struct LatexHandlers {
    pub arg0: Option<fn(
        env: &crate::ss::LatexCodegenEnv,
        scope: &SemanticScope,
        attrs: crate::ss::Attributes,
        arg0: (),
    ) -> String>,
    pub arg1: Option<fn(
        env: &crate::ss::LatexCodegenEnv,
        scope: &SemanticScope,
        attrs: crate::ss::Attributes,
        arg1: crate::ss::Node,
    ) -> String>,
    pub arg2: Option<fn(
        env: &crate::ss::LatexCodegenEnv,
        scope: &SemanticScope,
        attrs: crate::ss::Attributes,
        arg1: crate::ss::Node,
        arg2: crate::ss::Node,
    ) -> String>,
    pub arg3: Option<fn(
        env: &crate::ss::LatexCodegenEnv,
        scope: &SemanticScope,
        attrs: crate::ss::Attributes,
        arg1: crate::ss::Node,
        arg2: crate::ss::Node,
        arg3: crate::ss::Node,
    ) -> String>,
    pub default: Option<fn(
        env: &crate::ss::LatexCodegenEnv,
        scope: &SemanticScope,
        default: crate::ss::CmdCall,
    ) -> String>,
}

impl LatexHandlers {
    pub fn run(
        &self,
        env: &crate::ss::LatexCodegenEnv,
        scope: &crate::ss::SemanticScope,
        cmd_call: crate::ss::CmdCall,
    ) -> String {
        let attributes = cmd_call.attributes.clone();
        match cmd_call.arguments.len() {
            0 if self.arg0.is_some() => {
                if let Some(f) = self.arg0 {
                    return f(
                        env,
                        scope,
                        attributes.clone(),
                        ()
                    )
                } else {
                    let def = self.default.unwrap();
                    return def(
                        env,
                        scope,
                        cmd_call.clone(),
                    );
                }
            }
            1 if self.arg1.is_some() => {
                if let Some(f) = self.arg1 {
                    return f(
                        env,
                        scope,
                        attributes.clone(),
                        cmd_call.arguments[0].clone(),
                    )
                } else {
                    let def = self.default.unwrap();
                    return def(
                        env,
                        scope,
                        cmd_call.clone(),
                    );
                }
            }
            2 if self.arg2.is_some() => {
                if let Some(f) = self.arg2 {
                    return f(
                        env,
                        scope,
                        attributes.clone(),
                        cmd_call.arguments[0].clone(),
                        cmd_call.arguments[1].clone(),
                    );
                } else {
                    let def = self.default.unwrap();
                    return def(
                        env,
                        scope,
                        cmd_call.clone(),
                    );
                }
            }
            _ => unimplemented!("{} => {:#?}", cmd_call.arguments.len(), cmd_call.arguments)
        }
    }

}


macro_rules! to_latex_case_impl {
    ($handlers:ident, $env:ident, $scope:ident, $attrs:ident, (), $body:block) => {{
        fn handler(
            $env: &crate::ss::LatexCodegenEnv,
            $scope: &SemanticScope,
            $attrs: crate::ss::Attributes,
            arg0: (),
        ) -> String {
            $body
        }
        $handlers.arg0 = Some(handler);
    }};
    ($handlers:ident, $env:ident, $scope:ident, $attrs:ident, (
        {$arg1:ident}
    ), $body:block) => {{
        fn handler(
            $env: &crate::ss::LatexCodegenEnv,
            $scope: &SemanticScope,
            $attrs: crate::ss::Attributes,
            arg1: crate::ss::Node,
        ) -> String {
            let $arg1 = arg1.to_latex($env, $scope);
            $body
        }
        $handlers.arg1 = Some(handler);
    }};
    ($handlers:ident, $env:ident, $scope:ident, $attrs:ident, (
        {$arg1:ident}, {$arg2:ident}
    ), $body:block) => {{
        fn handler(
            $env: &crate::ss::LatexCodegenEnv,
            $scope: &SemanticScope,
            $attrs: crate::ss::Attributes,
            arg1: Node,
            arg2: Node,
        ) -> String {
            let $arg1 = arg1.to_latex($env, $scope);
            let $arg2 = arg2.to_latex($env, $scope);
            $body
        }
        $handlers.arg2 = Some(handler);
    }};
    ($handlers:ident, $env:ident, $scope:ident, $attrs:ident, (
        {$arg1:ident}, {$arg2:ident}, {$arg3:ident}
    ), $body:block) => {{
        fn handler(
            $env: &crate::ss::LatexCodegenEnv,
            $scope: &SemanticScope,
            $attrs: crate::ss::Attributes,
            arg1: Node,
            arg2: Node,
            arg3: Node,
        ) -> String {
            let $arg1 = arg1.to_latex($env, $scope);
            let $arg2 = arg2.to_latex($env, $scope);
            let $arg3 = arg3.to_latex($env, $scope);
            $body
        }
        $handlers.arg3 = Some(handler);
    }};
}

macro_rules! to_latex_cases {
    (for ($env:ident, $scope:ident, $cmd:ident) match {
        default $def_args:ident => $default_handler:block, $($args:tt => $body:block),* $(,)?
    }) => {{
        fn to_latex(
            env: &crate::ss::LatexCodegenEnv,
            scope: &SemanticScope,
            cmd_call: CmdCall
        ) -> String {
            use $crate::ss::ast_data::Node;
            use $crate::ss::cmd_decl::cmd_invocation;
            let mut handlers = $crate::ss_v1_std::macros::LatexHandlers::default();
            fn default_handler(
                $env: &crate::ss::LatexCodegenEnv,
                $scope: &SemanticScope,
                def_cmd: crate::ss::CmdCall,
            ) -> String {
                let $def_args: String = def_cmd.arguments
                    .into_iter()
                    .flat_map(Node::unblock_root_curly_brace)
                    .map(|x| x.to_latex($env, $scope))
                    .collect::<Vec<_>>()
                    .join("");
                $default_handler
            }
            handlers.default = Some(default_handler);
            $({
                to_latex_case_impl!(handlers, $env, $scope, $cmd, $args, $body)
            })*
            handlers.run(env, scope, cmd_call)
        }
        to_latex
    }};
}


pub fn dev() {
    use crate::ss::*;
    let node = Node::from_str_sym_mode("\\mol").unwrap();
    println!("node {node:#?}");
    let cmd_call = node.get_cmd().unwrap().clone();
    let scope = {
        let mut scope = SemanticScope::default();
        scope.content_mode = crate::ss::ContentMode::Symbolic(crate::ss::SymbolicModeType::All);
        scope
    };
    let mut env = LatexCodegenEnv::from_scope(&scope);
    let handlers = to_latex_cases!{
        for (env, scope, attrs) match {
            default contents => {{
                String::new()
            }},
            ({arg1}, {arg2}) => {
                String::from("Y")
            },
            ({arg1}) => {
                String::from("X")
            },
            () => {
                String::from("Z")
            },
        }
    };
    let result = handlers(&mut env, &scope, cmd_call);
    println!("result {result:#?}");
}




