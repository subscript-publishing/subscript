use std::collections::HashMap;
pub mod html_cg;
pub mod latex_cg;

use crate::subscript::ast::Ident;

#[derive(Debug, Clone)]
pub struct LatexCodegenEnv {
    pub commands: HashMap<Ident, crate::cmds::data::CmdDeclaration>
}

pub struct HtmlCodegenEnv {
    pub commands: HashMap<Ident, crate::cmds::data::CmdDeclaration>
}


