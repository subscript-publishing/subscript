use itertools::Itertools;
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
