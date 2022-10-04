use std::process::Command;
use std::{collections::HashMap, path::PathBuf};
use itertools::Itertools;
use crate::subscript::ast::{Node, Ann, Bracket, Ident, IdentInitError};
use crate::subscript::ast::{self, BracketType, ToNode, AsNodeRef, Quotation};
use super::data::{
    CmdDeclaration,
    SemanticScope,
    AttributeKey,
    AttributeValue,
    AttributeValueType,
    ArgumentDecl,
    ArgumentType,
    ContentMode,
    SymbolicModeType,
    LayoutMode,
    IsRequired,
    ParentEnvNamespaceDecl,
    ChildEnvNamespaceDecl,
    Attribute,
    Attributes,
    SimpleCmdProcessor,
    CmdCodegenRef,
    CmdCall,
    CmdCodegen,
};
use crate::subscript::utils::{sep_by, partition};


impl SemanticScope {
    fn match_cmd(&self, cmd: &ParentEnvNamespaceDecl) -> bool {
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
        let layout_mode_match = self.layout_mode == cmd.layout_mode;
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

// ////////////////////////////////////////////////////////////////////////////
// COMMAND DECLARATION MATCHER - HELPERS
// ////////////////////////////////////////////////////////////////////////////

fn match_attrs(
    node_attrs: Attributes,
    cmd_attrs: &HashMap<AttributeKey, Option<AttributeValue>>
) {
    for (cmd_key, cmd_value) in cmd_attrs.iter() {
        let res = node_attrs
            .get(&cmd_key.identifier)
            .map(Attribute::to_tuple)
            .map(|(node_key, node_value)| {
                match (cmd_value) {
                    Some(AttributeValue{value_ty: AttributeValueType::FilePath, required: IsRequired::Required}) => {
                        unimplemented!()
                    }
                    Some(AttributeValue{value_ty: AttributeValueType::String, required: IsRequired::Required}) => {
                        unimplemented!()
                    }
                    Some(AttributeValue{value_ty: AttributeValueType::Int, required: IsRequired::Required}) => {
                        unimplemented!()
                    }
                    Some(AttributeValue{value_ty: AttributeValueType::FilePath, required: IsRequired::Optional}) => {
                        unimplemented!()
                    }
                    Some(AttributeValue{value_ty: AttributeValueType::String, required: IsRequired::Optional}) => {
                        unimplemented!()
                    }
                    Some(AttributeValue{value_ty: AttributeValueType::Int, required: IsRequired::Optional}) => {
                        unimplemented!()
                    }
                    None => {
                        unimplemented!()
                    }
                    None => {
                        unimplemented!()
                    }
                }
            });
    }
    unimplemented!()
}

fn apply_cmd(
    scope: &SemanticScope,
    cmd_decl: &CmdDeclaration,
    ident: Ann<Ident>,
    attrs: Option<Attributes>,
    nodes: &[Node],
) -> CmdCall {
    let code_gen: &dyn CmdCodegen = cmd_decl.processors.0.as_ref();
    let cmd_call = code_gen.to_cmd_call(scope, cmd_decl, ident, attrs, nodes);
    cmd_call
}



// ////////////////////////////////////////////////////////////////////////////
// REWRITE RULES - HELPERS
// ////////////////////////////////////////////////////////////////////////////

#[derive(Debug)]
struct RewriteRule<T> {
    pattern: T,
    target: T,
}

fn parse_where_block(nodes: &[Node]) -> Option<Vec<RewriteRule<Vec<Node>>>> {
    fn parse_where_arms(nodes: &[Node]) -> Vec<RewriteRule<Vec<Node>>> {
        use either::{Either, {Either::Left, Either::Right}};
        let mut all_valid: Vec<bool> = Vec::new();
        let groups = sep_by(nodes, |x| {
            x   .unwrap_symbol()
                .map(|sym| sym.value == ";")
                .unwrap_or(false)
        });
        let groups = groups
            .into_iter()
            .filter_map(|group| {
                partition(group, |x| {
                    x   .unwrap_symbol()
                        .map(|sym| sym.value == "=>")
                        .unwrap_or(false)
                })
            })
            .map(|(pattern, target)| -> RewriteRule<Vec<Node>> {
                let pattern = pattern
                    .into_iter()
                    .filter_map(|x| x.unpack_curly_brace())
                    .flat_map(|x| x)
                    .map(Clone::clone)
                    .collect_vec();
                let target = target
                    .into_iter()
                    .filter_map(|x| x.unpack_curly_brace())
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
                .unpack_curly_brace()
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
        let border = "-".repeat(80);
        let all_match = self.pattern
            .iter()
            .zip(nodes.into_iter())
            .all(|(pattern, node)| {
                index = index + 1;
                arg_match_counter = arg_match_counter + 1;
                let result = pattern.syntactically_equal(node);
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

// ////////////////////////////////////////////////////////////////////////////
// COMMAND DECLARATION MATCHER
// ////////////////////////////////////////////////////////////////////////////

impl CmdDeclaration {
    pub fn match_nodes<'a>(
        &self,
        scope: &SemanticScope,
        nodes: &'a [Node]
    ) -> Option<(Node, &'a [Node])> {
        if let Some(ident) = nodes.first().and_then(Node::unwrap_ident) {
            let match_ident = ident.value == self.identifier;
            let match_scope = scope.match_cmd(&self.parent_env);
            if match_ident && match_scope {
                let mut index = 1;
                // PARSE ATTRIBUTES
                let parsed_attributes: Option<Attributes> = {
                    let mut parsed_attributes: Option<Attributes> = None;
                    let are_any_attrs_required = self
                        .attributes
                        .iter()
                        .any(|(key, _)| key.is_required());
                    if !self.attributes.is_empty() {
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
                let start_of_args = index;
                // PARSE ARGUMENTS
                let mut arg_match_counter = 0;
                let arguments_match = self.arguments
                    .clone()
                    .into_iter()
                    .zip(nodes[index..].into_iter())
                    .all(|(arg, node)| -> bool {
                        index = index + 1;
                        arg_match_counter = arg_match_counter + 1;
                        match (arg.ty, node.bracket_kind()) {
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
                    });
                let arguments_fully_matched = arg_match_counter == self.arguments.len();
                if !arguments_fully_matched {
                    return None
                }
                let end_of_args = index;
                let rewrites = nodes
                    .get(index..(index + 2))
                    .and_then(|xs| {
                        index = index + 2;
                        let rewrites = parse_where_block(xs);
                        rewrites
                    });
                if arguments_match && arguments_fully_matched {
                    let cmd_nodes = &nodes[start_of_args..end_of_args];
                    let cmd_call = apply_cmd(scope, self, ident.clone(), parsed_attributes, cmd_nodes);
                    let mut cmd_call: Node = Node::Cmd(cmd_call);
                    if let Some(rewrites) = rewrites {
                        cmd_call = cmd_call.apply_rewrite_rules(&rewrites);
                    }
                    return Some((cmd_call, &nodes[index..]));
                }
                return None
            }
        }
        None
    }
}

// ////////////////////////////////////////////////////////////////////////////
// NODE COMMAND APPLYER - HELPERS
// ////////////////////////////////////////////////////////////////////////////

fn apply_commands_to_children<'a>(
    scope: &SemanticScope,
    cmds: &HashMap<Ident, CmdDeclaration>,
    mut nodes: &'a [Node],
) -> (Vec<Node>, &'a [Node]) {
    let mut processed: Vec<Node> = Vec::new();
    if let Some(Ann{value: ident, ..}) = nodes.first().and_then(Node::unwrap_ident) {
        if let Some(cmd) = cmds.get(&ident) {
            if let Some((node, rest)) = cmd.match_nodes(scope, nodes) {
                processed.push(node);
                nodes = rest;
            }
        }
    }
    if let Some(left) = nodes.get(0) {
        processed.push(left.clone());
        let (result, unprocessed) = apply_commands_to_children(scope, cmds, &nodes[1..]);
        processed.extend(result);
        return (processed, unprocessed);
    }
    (processed, &[])
}


// ////////////////////////////////////////////////////////////////////////////
// NODE COMMAND APPLYER
// ////////////////////////////////////////////////////////////////////////////

impl Node {
    pub fn apply_commands(self, scope: &SemanticScope, cmds: &HashMap<Ident, CmdDeclaration>) -> Node {
        fn process_children(scope: &SemanticScope, cmds: &HashMap<Ident, CmdDeclaration>, xs: Vec<Node>) -> Vec<Node> {
            let (processed, unprocessed) = apply_commands_to_children(scope, cmds, &xs[..]);
            let mut xs = Vec::new();
            xs.extend(processed);
            xs.extend_from_slice(unprocessed);
            xs
        }
        match self {
            Node::Cmd(mut cmd_call) => {
                cmd_call.arguments = cmd_call.arguments
                    .into_iter()
                    .map(|x| x.apply_commands(scope, cmds))
                    .collect_vec();
                cmd_call.arguments = process_children(scope, cmds, cmd_call.arguments);
                Node::Cmd(cmd_call)
            }
            Node::Bracket(Ann{mut value, range}) => {
                value.children = value.children
                    .into_iter()
                    .map(|x| x.apply_commands(scope, cmds))
                    .collect_vec();
                value.children = process_children(scope, cmds, value.children);
                Node::Bracket(Ann{range, value})
            }
            Node::Quotation(Ann{mut value, range}) => {
                value.children = value.children
                    .into_iter()
                    .map(|x| x.apply_commands(scope, cmds))
                    .collect_vec();
                value.children = process_children(scope, cmds, value.children);
                Node::Quotation(Ann{range, value})
            }
            Node::Fragment(xs) => {
                let xs = xs
                    .into_iter()
                    .map(|x| x.apply_commands(scope, cmds))
                    .collect_vec();
                let xs = process_children(scope, cmds, xs);
                Node::Fragment(xs)
            }
            node @ Node::Ident(_) => node,
            node @ Node::Text(_) => node,
            node @ Node::Symbol(_) => node,
            node @ Node::InvalidToken(_) => node,
            Node::HtmlCode(x) => {
                unimplemented!()
            }
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
                    .collect_vec();
                cmd_call.arguments = process_children(rewrites, cmd_call.arguments);
                Node::Cmd(cmd_call)
            }
            Node::Bracket(Ann{mut value, range}) => {
                value.children = value.children
                    .into_iter()
                    .map(|x| x.apply_rewrite_rules(rewrites))
                    .collect_vec();
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
                    .collect_vec();
                let xs = process_children(rewrites, xs);
                Node::Fragment(xs)
            }
            node @ Node::Ident(_) => node,
            node @ Node::Text(_) => node,
            node @ Node::Symbol(_) => node,
            node @ Node::InvalidToken(_) => node,
            Node::HtmlCode(x) => {
                unimplemented!()
            }
        }
    }
}

