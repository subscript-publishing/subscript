use crate::ss::ast_data::HeadingType;
use crate::ss::SemanticScope;
use crate::ss::SymbolicModeType;
use crate::ss::ast_traits::SyntacticallyEq;

use super::*;

pub fn all_supported_html_tags() -> Vec<cmd_decl::CmdDeclaration> {
    vec![
        CmdDeclBuilder::new(Ident::from("\\address").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\article").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\aside").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\footer").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\header").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\h1").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\h2").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\h3").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\h4").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\h5").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\h6").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\section").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\blockquote").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\dd").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\dl").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\dt").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\figcaption").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\figure").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\hr").unwrap())
            .arguments(default_no_arg_type())
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\li").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .child_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\ol").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\p").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .child_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\pre").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\ul").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\a").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\abbr").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\b").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\bdi").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\bdo").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\br").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\cite").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\code").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\data").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\dfn").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\em").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\i").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\kbd").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\mark").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\q").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\s").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\samp").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\small").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\span").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\strong").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\sub").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\sup").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\time").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\u").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\var").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Inline)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\wbr").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\audio").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\img").unwrap())
            .arguments(default_no_arg_type())
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\map").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\area").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\track").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\video").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\object").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\picture").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\source").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\del").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\ins").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Both)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\table").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\caption").unwrap())
            .parent(Ident::from("\\table").unwrap())
            .parent_layout_mode(LayoutMode::Block)
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\col").unwrap())
            .parent(Ident::from("\\table").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\colgroup").unwrap())
            .parent(Ident::from("\\table").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\tbody").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .parent(Ident::from("\\table").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\td").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .parent(Ident::from("\\table").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\tfoot").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .parent(Ident::from("\\table").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\th").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .parent(Ident::from("\\table").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\thead").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .parent(Ident::from("\\table").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\tr").unwrap())
            .parent_layout_mode(LayoutMode::Block)
            .parent(Ident::from("\\table").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\details").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .finish(),
        CmdDeclBuilder::new(Ident::from("\\summary").unwrap())
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
                        () => {
                            Node::Cmd(CmdCall {
                                identifier: cmd_payload.identifier,
                                attributes: cmd_payload.attributes.unwrap_or_default(),
                                arguments: vec![]
                            })
                        },
                    }
                }
            )
            .parent_layout_mode(LayoutMode::Block)
            .child_layout_mode(LayoutMode::Block)
            .finish(),
    ]
}