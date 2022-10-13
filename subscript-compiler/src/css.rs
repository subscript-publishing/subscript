use std::sync::Arc;
use swc_common::SourceMap;
use swc_common::FilePathMapping;
use swc_common::{input::StringInput, FileName, Span, SyntaxContext, DUMMY_SP};
use swc_css_ast::Stylesheet;
use swc_css_parser::{lexer::Lexer, parser::Parser};
use swc_css_visit::{Fold, FoldWith, VisitMut, VisitMutWith};
use swc_css_visit::VisitMutAstPath;
use swc_css_codegen::writer::basic::BasicCssWriter;
use swc_css_codegen::writer::basic::BasicCssWriterConfig;
use swc_css_codegen::CodeGenerator;
use swc_css_codegen::CodegenConfig;
use swc_css_codegen::Emit;


pub fn rewrite_stylesheet<T: Into<String>>(source: T) -> String {
    fn code_gen(stylesheet: Stylesheet) -> String {
        let mut css_str = String::new();
        let wr = BasicCssWriter::new(
            &mut css_str,
            None, // Some(&mut src_map_buf),
            BasicCssWriterConfig::default(),
        );
        let minify = false;
        let mut gen = CodeGenerator::new(wr, CodegenConfig { minify });
        let _: () = gen.emit(&stylesheet).unwrap();
        css_str
    }

    let cm = Arc::new(SourceMap::new(FilePathMapping::empty()));
    let fm = cm.new_source_file(FileName::Anon, source.into());
    let lexer = Lexer::new(StringInput::from(&*fm), Default::default());
    let mut parser = Parser::new(lexer, Default::default());
    let mut stylesheet: Stylesheet = parser.parse_all().unwrap();
    stylesheet.visit_mut_with(&mut SubscriptCssRewrites);
    code_gen(stylesheet)
}

struct SubscriptCssRewrites;

use swc_css_ast::TagNameSelector;
use swc_css_ast::Ident;

impl VisitMut for SubscriptCssRewrites {
    fn visit_mut_tag_name_selector(&mut self, n: &mut TagNameSelector) {
        if &n.name.value.value == "body" {
            n.name.value.value = "test".into();
        }
    }
}
