# Parsing some CSS file VIA `swc_css_parser`


## Dependencies

```toml
swc_css_parser = "0.123.4"
swc_css_ast = "0.114.4"
swc_css_visit = "0.113.4"
swc_common = "0.29.3"
```

## Code

```rust
use std::sync::Arc;
use swc_common::SourceMap;
use swc_common::FilePathMapping;
use swc_common::{input::StringInput, FileName, Span, SyntaxContext, DUMMY_SP};
use swc_css_ast::Stylesheet;
use swc_css_parser::{lexer::Lexer, parser::Parser};
use swc_css_visit::{Fold, FoldWith, VisitMut, VisitMutWith};
let cm = Arc::new(SourceMap::new(FilePathMapping::empty()));
let fm = cm.new_source_file(FileName::Anon, source.into());
let lexer = Lexer::new(StringInput::from(&*fm), Default::default());
let mut parser = Parser::new(lexer, Default::default());
let stylesheet: Stylesheet = parser.parse_all().unwrap();
println!("{:#?}", stylesheet);
```


## Prints the following to STDOUT

```rust
Stylesheet {
    span: Span {
        lo: BytePos(
            1,
        ),
        hi: BytePos(
            23,
        ),
        ctxt: #0,
    },
    rules: [
        QualifiedRule(
            QualifiedRule {
                span: Span {
                    lo: BytePos(
                        1,
                    ),
                    hi: BytePos(
                        22,
                    ),
                    ctxt: #0,
                },
                prelude: SelectorList(
                    SelectorList {
                        span: Span {
                            lo: BytePos(
                                1,
                            ),
                            hi: BytePos(
                                5,
                            ),
                            ctxt: #0,
                        },
                        children: [
                            ComplexSelector {
                                span: Span {
                                    lo: BytePos(
                                        1,
                                    ),
                                    hi: BytePos(
                                        5,
                                    ),
                                    ctxt: #0,
                                },
                                children: [
                                    CompoundSelector(
                                        CompoundSelector {
                                            span: Span {
                                                lo: BytePos(
                                                    1,
                                                ),
                                                hi: BytePos(
                                                    5,
                                                ),
                                                ctxt: #0,
                                            },
                                            nesting_selector: None,
                                            type_selector: Some(
                                                TagName(
                                                    TagNameSelector {
                                                        span: Span {
                                                            lo: BytePos(
                                                                1,
                                                            ),
                                                            hi: BytePos(
                                                                5,
                                                            ),
                                                            ctxt: #0,
                                                        },
                                                        name: WqName {
                                                            span: Span {
                                                                lo: BytePos(
                                                                    1,
                                                                ),
                                                                hi: BytePos(
                                                                    5,
                                                                ),
                                                                ctxt: #0,
                                                            },
                                                            prefix: None,
                                                            value: Ident {
                                                                span: Span {
                                                                    lo: BytePos(
                                                                        1,
                                                                    ),
                                                                    hi: BytePos(
                                                                        5,
                                                                    ),
                                                                    ctxt: #0,
                                                                },
                                                                value: Atom('body' type=static),
                                                                raw: Some(
                                                                    Atom('body' type=static),
                                                                ),
                                                            },
                                                        },
                                                    },
                                                ),
                                            ),
                                            subclass_selectors: [],
                                        },
                                    ),
                                ],
                            },
                        ],
                    },
                ),
                block: SimpleBlock {
                    span: Span {
                        lo: BytePos(
                            6,
                        ),
                        hi: BytePos(
                            22,
                        ),
                        ctxt: #0,
                    },
                    name: '{',
                    value: [
                        StyleBlock(
                            Declaration(
                                Declaration {
                                    span: Span {
                                        lo: BytePos(
                                            10,
                                        ),
                                        hi: BytePos(
                                            19,
                                        ),
                                        ctxt: #0,
                                    },
                                    name: Ident(
                                        Ident {
                                            span: Span {
                                                lo: BytePos(
                                                    10,
                                                ),
                                                hi: BytePos(
                                                    16,
                                                ),
                                                ctxt: #0,
                                            },
                                            value: Atom('margin' type=static),
                                            raw: Some(
                                                Atom('margin' type=static),
                                            ),
                                        },
                                    ),
                                    value: [
                                        Integer(
                                            Integer {
                                                span: Span {
                                                    lo: BytePos(
                                                        18,
                                                    ),
                                                    hi: BytePos(
                                                        19,
                                                    ),
                                                    ctxt: #0,
                                                },
                                                value: 0,
                                                raw: Some(
                                                    Atom('0' type=inline),
                                                ),
                                            },
                                        ),
                                    ],
                                    important: None,
                                },
                            ),
                        ),
                    ],
                },
            },
        ),
    ],
}
```

For the given source code:

```css
body {
    margin: 0;
}
```
