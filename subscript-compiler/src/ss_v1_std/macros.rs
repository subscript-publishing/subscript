use either::{Either, Either::Left, Either::Right};
use itertools::Itertools;
use std::{collections::HashMap, hash::Hash, path::PathBuf, rc::Rc};

use crate::ss::ast_data::HeadingType;
use crate::ss::SemanticScope;
use crate::ss::SymbolicModeType;
use crate::ss::ast_traits::SyntacticallyEq;

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
            // let $arg1: Node = $cmd_payload.nodes.get(0).unwrap().clone();
            // let $arg2: Node = $cmd_payload.nodes.get(1).unwrap().clone();
            // Some($body)
            unimplemented!()
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
            // let $arg1: Node = $cmd_payload.nodes.get(0)?.clone();
            // let $arg2: Node = $cmd_payload.nodes.get(0)?.clone();
            // let $arg3: Node = $cmd_payload.nodes.get(0)?.clone();
            // Some($body)
            unimplemented!()
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
