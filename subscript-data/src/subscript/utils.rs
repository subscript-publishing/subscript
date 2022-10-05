use itertools::Itertools;
use either::{Either, Either::Left, Either::Right};
use super::ast::Node;

pub fn sep_by(nodes: &[Node], sep: impl Fn(&Node) -> bool) -> Vec<Vec<&Node>> {
    nodes
        .into_iter()
        .group_by(|x| sep(x))
        .into_iter()
        .filter_map(|(key, xs)| {
            if key {
                None
            } else {
                Some(xs.collect_vec())
            }
        })
        .map(|xs| {
            xs
        })
        .collect_vec()
}

pub fn partition(xs: Vec<&Node>, terminator: impl Fn(&Node) -> bool) -> Option<(Vec<&Node>, Vec<&Node>)> {
    let mut left: Vec<&Node> = Vec::new();
    let mut term: Option<&Node> = None;
    let mut right: Vec<&Node> = Vec::new();
    for x in xs {
        if term.is_some() {
            right.push(x);
            continue;
        }
        if terminator(&x) {
            term = Some(x);
            continue;
        }
        left.push(x);
    }
    if term.is_some() {
        return Some((left, right))
    }
    None
}


#[derive(Debug, Clone)]
pub struct ZipNodesAllMatch {
    pub all_match: bool,
    pub stop_node_ix: usize,
    pub stop_other_ix: usize,
    pub other_fully_consumed: bool,
}

pub fn zip_nodes_all_match<T>(
    nodes: &[Node],
    other: &[T],
    default: bool,
    f: impl Fn(&Node, &T) -> bool
) -> ZipNodesAllMatch {
    let mut node_index = 0;
    let mut other_index = 0;
    let other_len = other.len();
    let mut results: Vec<bool> = Vec::with_capacity(usize::max(nodes.len(), other.len()));
    // let mut matched: Vec<Node> = Vec::new();
    for (ix, node) in nodes.iter().enumerate() {
        assert!(ix == node_index);
        if node.is_whitespace() {
            node_index = node_index + 1;
            continue;
        }
        if let Some(other_item) = other.get(other_index) {
            let result = f(node, other_item);
            if !result {
                return ZipNodesAllMatch{
                    all_match: false,
                    stop_node_ix: node_index,
                    stop_other_ix: other_index,
                    other_fully_consumed: false,
                };
            }
            results.push(result);
        } else {
            return ZipNodesAllMatch{
                all_match: results.into_iter().all(|x| x),
                stop_node_ix: node_index,
                stop_other_ix: other_index,
                other_fully_consumed: true,
            };
        }
        other_index = other_index + 1;
        node_index = node_index + 1;
    }
    let other_fully_consumed = (other_index + 1) >= other_len;
    return ZipNodesAllMatch{
        //                   Seems redundant?
        //                 _____________________
        all_match: results.into_iter().all(|x| x),
        stop_node_ix: node_index,
        stop_other_ix: other_index,
        other_fully_consumed,
    }
}
