use std::process::Command;
use std::{collections::HashMap, path::PathBuf};
use itertools::Itertools;
use either::{Either, Either::Left, Either::Right};
// use rayon::prelude::*;
use crate::ss::{Node, Ann, Bracket, Ident, IdentInitError};
use crate::ss::{CmdCall, BracketType, ToNode, AsNodeRef, Quotation};
use crate::ss::cmd_decl::{
    CmdDeclaration,
    AttributeKey,
    AttributeValue,
    AttributeValueType,
    ArgumentType,
    IsRequired,
    ParentEnvNamespaceDecl,
    ChildEnvNamespaceDecl,
    CmdCodegen,
    // CmdCodegenRef,
    // CmdCodegen,
    VariableArguments,
    ArgumentsDeclInstance,
    cmd_invocation,
    Override,
};

use crate::ss::{SemanticScope, ContentMode, SymbolicModeType, LayoutMode,};
use crate::ss::ast_data::{Attribute, Attributes};
use crate::ss::utils::{sep_by, partition};
use crate::ss::RewriteRule;
use crate::ss::ast_traits::SyntacticallyEq;



//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// REWRITE RULES - HELPERS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

fn parse_where_block(nodes: &[Node]) -> Option<Vec<RewriteRule<Vec<Node>>>> {
    fn parse_where_arms(nodes: &[Node]) -> Vec<RewriteRule<Vec<Node>>> {
        use either::{Either, {Either::Left, Either::Right}};
        let mut all_valid: Vec<bool> = Vec::new();
        let groups = sep_by(nodes, |x| {
            x   .get_symbol()
                .map(|sym| sym.value == ";")
                .unwrap_or(false)
        });
        let groups = groups
            .into_iter()
            .filter_map(|group| {
                partition(group, |x| {
                    x   .get_symbol()
                        .map(|sym| sym.value == "=>")
                        .unwrap_or(false)
                })
            })
            .map(|(pattern, target)| -> RewriteRule<Vec<Node>> {
                let pattern = pattern
                    .into_iter()
                    .filter_map(|x| x.get_curly_brace_children())
                    .flat_map(|x| x)
                    .map(Clone::clone)
                    .collect_vec();
                let target = target
                    .into_iter()
                    .filter_map(|x| x.get_curly_brace_children())
                    .flat_map(|x| x)
                    .map(Clone::clone)
                    .collect_vec();
                RewriteRule{pattern, target}
            })
            .collect_vec();
        groups
    }
    let ref where_id = Ident::from("\\where!").unwrap();
    match nodes {
        [l, r] if l.match_ident_id(where_id) && r.is_curly_brace() => {
            let children = r
                .clone()
                .defragment_node_tree()
                .trim_whitespace();
            let children = children
                .get_curly_brace_children()
                .unwrap();
            let results = parse_where_arms(children);
            Some(results)
        }
        _ => None
    }
}

impl RewriteRule<Vec<Node>> {
    fn rewrite_matches<'a>(&self, nodes: &'a [Node]) -> Option<(Vec<Node>, &'a [Node])> {
        let mut index = 0;
        let mut arg_match_counter = 0;
        let all_match = self.pattern
            .iter()
            .zip(nodes.into_iter())
            .all(|(pattern, node)| {
                index = index + 1;
                arg_match_counter = arg_match_counter + 1;
                let result = pattern.syn_eq(node);
                result
            });
        let all_patterns_matched = arg_match_counter == self.pattern.len();
        if all_match {
            let target = self.target.clone();
            let rest_of_nodes = &nodes[index..];
            return Some((target, rest_of_nodes));
        }
        None
    }
}

fn apply_rewrites_to_children<'a>(
    rewrites: &Vec<RewriteRule<Vec<Node>>>,
    mut nodes: &'a [Node],
) -> (Vec<Node>, &'a [Node]) {
    let mut processed: Vec<Node> = Vec::new();
    if let Some(node_head) = nodes.first() {
        for rewrite in rewrites {
            if let Some((mut target, rest)) = rewrite.rewrite_matches(nodes) {
                processed.extend(target);
                nodes = rest;
                break;
            }
        }
    }
    if let Some(left) = nodes.get(0) {
        processed.push(left.clone());
        let (result, unprocessed) = apply_rewrites_to_children(rewrites, &nodes[1..]);
        processed.extend(result);
        return (processed, unprocessed);
    }
    (processed, &[])
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// COMMAND DECLARATION MATCHER
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl CmdDeclaration {
    pub fn matches_cmd(&self, scope: &SemanticScope, cmd_call: &CmdCall) -> bool {
        let match_ident = cmd_call.identifier.value == self.identifier;
        let match_scope = scope.match_cmd(&self.parent_env);
        match_ident && match_scope
    }
    pub fn match_nodes<'a>(
        &self,
        scope: &SemanticScope,
        nodes: &'a [Node]
    ) -> Option<(Node, &'a [Node], usize)> {
        let mut index = 0;
        if let Some(ident) = nodes.first().and_then(Node::get_ident_ref) {
            index = index + 1;
            let match_ident = ident.value == self.identifier;
            let match_scope = {
                scope.match_cmd(&self.parent_env)
            };
            if match_ident && match_scope {
                while let Some(_) = nodes.get(index).and_then(Node::get_whitespace_ref) {
                    index = index + 1;
                }
                // PARSE ATTRIBUTES
                let parsed_attributes: Option<Attributes> = {
                    let mut parsed_attributes: Option<Attributes> = None;
                    let are_any_attrs_required = self
                        .attributes
                        .iter()
                        .any(|(key, _)| key.is_required());
                    if !self.ignore_attributes {
                        match nodes.get(index).and_then(Attributes::parse_as_attribute_node) {
                            Some(node_attrs) => {
                                index = index + 1;
                                parsed_attributes = Some(node_attrs);
                            }
                            None if are_any_attrs_required => {
                                return None
                            }
                            None => {}
                        }
                    }
                    parsed_attributes
                };
                while let Some(_) = nodes.get(index).and_then(Node::get_whitespace_ref) {
                    index = index + 1;
                }
                let start_of_args = index;
                if let Some(arg_match) = self.arguments.match_instances(
                    ident.value.as_str(),
                    scope,
                    &nodes[index..]
                ) {
                    index = index + arg_match.stop_node_index;
                    let rewrites = nodes
                        .get(index..(index + 2))
                        .and_then(|xs| {
                            let rewrites = parse_where_block(xs);
                            if rewrites.is_some() {
                                index = index + 2;
                            }
                            rewrites
                        });
                    let mut intenral = cmd_invocation::Internal {
                        rewrites,
                    };
                    let metadata = cmd_invocation::Metadata {
                        scope: scope,
                        cmd_decl: self,
                    };
                    let cmd_arguments = arg_match
                        .args
                        .into_iter()
                        .map(Clone::clone)
                        // .filter(|x| !x.is_whitespace())
                        .collect_vec();
                    let cmd_payload = cmd_invocation::CmdPayload {
                        identifier: ident.clone(),
                        attributes: parsed_attributes,
                        nodes: cmd_arguments.clone(),
                    };
                    let mut cmd_call: Node = arg_match.apply.0(
                        &mut intenral,
                        metadata,
                        cmd_payload,
                    ).unwrap();
                    if let Some(rewrites) = intenral.rewrites {
                        if self.internal.automatically_apply_rewrites {
                            cmd_call = cmd_call.apply_rewrite_rules(&rewrites);
                        }
                    }
                    let rest = &nodes[index..];
                    return Some((cmd_call, rest, index));
                    // unimplemented!()
                }
                return None
            }
        }
        None
    }
}

struct ArgumentMatch<'a> {
    args: &'a [Node],
    rest: &'a [Node],
    stop_node_index: usize,
    apply: cmd_invocation::ArgumentDeclMap
}

impl VariableArguments {
    fn match_instances<'a>(&self, debug: &str, scope: &SemanticScope, nodes: &'a [Node]) -> Option<ArgumentMatch<'a>> {
        for instance in self.0.iter() {
            if let Some(res) = instance.match_instance(debug, scope, nodes) {
                return Some(res)
            }
        }
        None
    }
}

impl ArgumentsDeclInstance {
    fn match_instance<'a>(&self, debug: &str, scope: &SemanticScope, nodes: &'a [Node]) -> Option<ArgumentMatch<'a>> {
        match &self.ty {
            Either::Left(Override::NoArguments) => {
                return Some(ArgumentMatch{
                    args: &[],
                    rest: &nodes,
                    stop_node_index: 0,
                    apply: self.apply.clone(),
                })
            }
            Either::Left(Override::AllFollowingCurlyBraces) => {
                use itertools::FoldWhile::{Continue, Done};
                let index = nodes
                    .into_iter()
                    .position(|node| {
                        !node.is_curly_brace()
                    });
                if let Some(index) = index {
                    return Some(ArgumentMatch{
                        args: &nodes[..index],
                        rest: &nodes[index..],
                        stop_node_index: index,
                        apply: self.apply.clone(),
                    })
                }
                Some(ArgumentMatch{
                    args: &nodes[..],
                    rest: &[],
                    stop_node_index: nodes.len(),
                    apply: self.apply.clone(),
                })
            }
            Either::Right(ty_list) => {
                let zip_result = crate::ss::utils::zip_nodes_all_match(
                    debug,
                    nodes,
                    ty_list,
                    true,
                    |node, arg_ty| {
                        match (arg_ty, node.bracket_kind()) {
                            (ArgumentType::CurlyBrace, Some(BracketType::CurlyBrace)) => {
                                true
                            }
                            (ArgumentType::SquareParen, Some(BracketType::SquareParen)) => {
                                true
                            }
                            (ArgumentType::Parens, Some(BracketType::Parens)) => {
                                true
                            }
                            (l, r) => {
                                false
                            }
                        }
                    },
                );
                if zip_result.all_match && zip_result.other_fully_consumed {
                    let args = &nodes[..zip_result.stop_node_ix];
                    let rest = &nodes[zip_result.stop_node_ix..];
                    return Some(ArgumentMatch{
                        args: args,
                        rest: rest,
                        stop_node_index: zip_result.stop_node_ix,
                        apply: self.apply.clone(),
                    })
                }
                None
            }
        }
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// NODE COMMAND APPLYER - HELPERS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

fn apply_commands_to_children<'a>(
    scope: &SemanticScope,
    nodes: &'a [Node],
) -> (Vec<Node>, &'a [Node]) {
    let mut processed: Vec<Node> = Vec::with_capacity(nodes.len());
    let mut index_skip: Option<usize> = None;
    for (ix, next_node) in nodes.into_iter().enumerate() {
        if let Some(skip_to_index) = index_skip {
            if ix < skip_to_index {
                continue;
            }
        }
        if let Some((node, rest, skip_to_index)) = scope.to_matching_cmd_call(&nodes[ix..]) {
            processed.push(node);
            index_skip = Some(ix + skip_to_index);
        } else {
            processed.push(next_node.clone());
        }
    }
    (processed, &[])
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// NODE COMMAND APPLYER
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

impl Node {
    pub fn apply_commands(self, scope: &SemanticScope) -> Node {
        fn process_children(
            scope: &SemanticScope,
            xs: Vec<Node>
        ) -> Vec<Node> {
            let (processed, unprocessed) = apply_commands_to_children(scope, &xs[..]);
            let mut xs = Vec::new();
            xs.extend(processed);
            xs.extend_from_slice(unprocessed);
            xs
        }
        match self {
            Node::Cmd(mut cmd_call) => {
                let child_scope = scope.new_scope(&cmd_call);
                cmd_call.arguments = {
                    process_children(&child_scope, cmd_call.arguments)
                };
                cmd_call.arguments = cmd_call.arguments
                    .into_iter()
                    .map(|x| {
                        x.apply_commands(&child_scope)
                    })
                    .collect::<Vec<_>>();
                Node::Cmd(cmd_call)
            }
            Node::Bracket(Ann{mut value, range}) => {
                value.children = process_children(scope, value.children);
                value.children = value.children
                    .into_iter()
                    .map(|x| x.apply_commands(scope))
                    .collect::<Vec<_>>();
                Node::Bracket(Ann{range, value})
            }
            Node::Quotation(Ann{mut value, range}) => {
                value.children = process_children(scope, value.children);
                value.children = value.children
                    .into_iter()
                    .map(|x| x.apply_commands(scope))
                    .collect::<Vec<_>>();
                Node::Quotation(Ann{range, value})
            }
            Node::Fragment(xs) => {
                let xs = process_children(scope, xs);
                let xs = xs
                    .into_iter()
                    .map(|x| x.apply_commands(scope))
                    .collect::<Vec<_>>();
                Node::Fragment(xs)
            }
            node @ Node::Ident(_) => {
                Node::Fragment(process_children(&scope, vec![node])).defragment_node_tree()
            },
            node @ Node::Text(_) => node,
            node @ Node::Symbol(_) => node,
            node @ Node::InvalidToken(_) => node,
            node @ Node::Drawing(_) => node,
        }
    }
    fn apply_rewrite_rules(self, rewrites: &Vec<RewriteRule<Vec<Node>>>) -> Node {
        fn process_children(rewrites: &Vec<RewriteRule<Vec<Node>>>, xs: Vec<Node>) -> Vec<Node> {
            let (processed, unprocessed) = apply_rewrites_to_children(rewrites, &xs[..]);
            let mut xs = Vec::new();
            xs.extend(processed);
            xs.extend_from_slice(unprocessed);
            xs
        }
        match self {
            Node::Cmd(mut cmd_call) => {
                cmd_call.arguments = cmd_call.arguments
                    .into_iter()
                    .map(|x| x.apply_rewrite_rules(rewrites))
                    .collect::<Vec<_>>();
                cmd_call.arguments = process_children(rewrites, cmd_call.arguments);
                Node::Cmd(cmd_call)
            }
            Node::Bracket(Ann{mut value, range}) => {
                value.children = value.children
                    .into_iter()
                    .map(|x| x.apply_rewrite_rules(rewrites))
                    .collect::<Vec<_>>();
                value.children = process_children(rewrites, value.children);
                Node::Bracket(Ann{range, value})
            }
            Node::Quotation(Ann{mut value, range}) => {
                value.children = value.children
                    .into_iter()
                    .map(|x| x.apply_rewrite_rules(rewrites))
                    .collect_vec();
                value.children = process_children(rewrites, value.children);
                Node::Quotation(Ann{range, value})
            }
            Node::Fragment(xs) => {
                let xs = xs
                    .into_iter()
                    .map(|x| x.apply_rewrite_rules(rewrites))
                    .collect::<Vec<_>>();
                let xs = process_children(rewrites, xs);
                Node::Fragment(xs)
            }
            node @ Node::Ident(_) => node,
            node @ Node::Text(_) => node,
            node @ Node::Symbol(_) => node,
            node @ Node::InvalidToken(_) => node,
            node @ Node::Drawing(_) => node,
        }
    }
}

