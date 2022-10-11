

pub fn dev() {
    // use crate::ss::ast_traits::{StrictlyEq, SyntacticallyEq};
    // use crate::ss::{Node, Ann, Ident, CharRange, CharIndex, Bracket, SemanticScope, Attributes, CmdCall};
    // let commands = crate::ss_std::all_commands_list();
    // let scope = SemanticScope::test_mode_with_cmds(commands);
    // let source = "\\h1{\\test1 \\test1}\\where!{{\\test1}=>{Text}}";
    // let parsed = crate::ss::parser::parse_source(&scope, source);
    // let processed = crate::compiler::low_level_api::process_commands(&scope, parsed);
    // println!("{processed:#?}");
}



#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn where_rewrite_test1() {
        use crate::ss::ast_traits::{StrictlyEq, SyntacticallyEq};
        use crate::ss::{Node, Ann, Ident, CharRange, CharIndex, Bracket, SemanticScope, Attributes, CmdCall};
        let commands = crate::ss_std::all_commands_list();
        let scope = SemanticScope::test_mode_with_cmds(commands);
        let source = "\\h1{\\test1_{x}}\\where!{{\\test1_{x}}=>{HelloWorld}}";
        let parsed = crate::ss::parser::parse_source(&scope, source);
        let processed = crate::compiler::low_level_api::process_commands(&scope, parsed);
        let expected = Node::Fragment(vec![Node::Cmd(CmdCall {
            identifier: Ann {
                range: Some(CharRange {
                    start: CharIndex {byte_index: 0, char_index: 0},
                    end: CharIndex {byte_index: 3, char_index: 3},
                }),
                value: Ident::from("\\h1").unwrap(),
            },
            attributes: Attributes::default(),
            arguments: vec![
                Node::Bracket(Ann {
                    range: None,
                    value: Bracket {
                        open: Some(Ann {
                            range: Some(CharRange {
                                start: CharIndex {byte_index: 3, char_index: 3},
                                end: CharIndex {byte_index: 4, char_index: 4},
                            }),
                            value: "{".to_string(),
                        }),
                        close: Some(Ann {
                            range: Some(CharRange {
                                start: CharIndex {byte_index: 14, char_index: 14},
                                end: CharIndex {byte_index: 15, char_index: 15},
                            }),
                            value: "}".to_string(),
                        }),
                        children: vec![
                            Node::Text(Ann {range: None, value: "HelloWorld".to_owned()}),
                        ],
                    },
                },
            )],
        })]);
        assert!(processed.syn_eq(&expected));
    }

    #[test]
    pub fn where_rewrite_test2() {
        use crate::ss::ast_traits::{StrictlyEq, SyntacticallyEq};
        use crate::ss::{Node, Ann, Ident, CharRange, CharIndex, Bracket, SemanticScope, Attributes, CmdCall};
        let commands = crate::ss_std::all_commands_list();
        let scope = SemanticScope::test_mode_with_cmds(commands);
        let source = "\\h1{\\test1-\\test2}\\where!{{\\test1}=>{Hello};{\\test2}=>{World}}";
        let parsed = crate::ss::parser::parse_source(&scope, source);
        let processed = crate::compiler::low_level_api::process_commands(&scope, parsed);
        let expected = Node::Fragment(vec![Node::Cmd(CmdCall {
            identifier: Ann {
                range: Some(CharRange {
                    start: CharIndex {byte_index: 0, char_index: 0},
                    end: CharIndex {byte_index: 3, char_index: 3},
                }),
                value: Ident::from("\\h1").unwrap(),
            },
            attributes: Attributes::default(),
            arguments: vec![Node::Bracket(Ann{
                range: None,
                value: Bracket {
                    open: Some(Ann {
                        range: Some(CharRange {
                            start: CharIndex {byte_index: 3, char_index: 3},
                            end: CharIndex {byte_index: 4, char_index: 4},
                        }),
                        value: "{".to_string(),
                    }),
                    close: Some(Ann {
                        range: Some(CharRange {
                            start: CharIndex {byte_index: 17, char_index: 17},
                            end: CharIndex {byte_index: 18, char_index: 18},
                        }),
                        value: "}".to_string(),
                    }),
                    children: vec![
                        Node::Text(Ann{range: None, value: "Hello".to_string()}),
                        Node::Symbol(Ann {
                            range: Some(CharRange {
                                start: CharIndex {byte_index: 10, char_index: 10},
                                end: CharIndex {byte_index: 11, char_index: 11},
                            }),
                            value: "-".to_string(),
                        }),
                        Node::Text(Ann {range: None, value: "World".to_string()})]}})]})]);
        assert!(processed.syn_eq(&expected));
    }
}

