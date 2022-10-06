use std::collections::HashMap;
pub mod html_cg;
pub mod latex_cg;

use crate::subscript::ast::Ident;

#[derive(Debug, Clone)]
pub struct LatexCodegenEnv {
    pub commands: HashMap<Ident, crate::cmds::data::CmdDeclaration>,
    pub drawings: HashMap<String, crate::ss_drawing::Drawing>,
}

impl LatexCodegenEnv {
    pub fn add_image(&mut self, drawing: crate::ss_drawing::Drawing) {
        
    }
}

pub struct HtmlCodegenEnv {
    pub commands: HashMap<Ident, Vec<crate::cmds::data::CmdDeclaration>>
}


