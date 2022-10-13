use std::borrow::Cow;
use std::collections::HashSet;
use std::path::Path;
use std::{collections::{HashMap, VecDeque}, path::PathBuf, fmt::Debug, rc::Rc};
use either::{Either, Either::Left, Either::Right};
use itertools::Itertools;
use crate::ss::{Ident, Ann, Node};
use crate::ss::cmd_decl::CmdDeclaration;
use crate::ss::cmd_decl::ParentEnvNamespaceDecl;
use crate::ss::CmdCall;
use crate::ss::cmd_decl::CmdCodegen;


// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MISCELLANEOUS
// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, PartialEq)]
pub enum ContentMode {
    /// The default file mode.
    Text,
    /// Math mode, chemistry mode, and so forth.
    Symbolic(SymbolicModeType),
}

#[derive(Debug, Clone, PartialEq)]
pub enum SymbolicModeType {
    /// Math mode, chemistry mode, and so forth.
    All,
    Math,
}

#[derive(Debug, Clone, PartialEq)]
pub enum LayoutMode {
    Block,
    Inline,
    Both,
}

impl Default for LayoutMode {
    fn default() -> Self {LayoutMode::Both}
}
impl Default for SymbolicModeType {
    fn default() -> Self {SymbolicModeType::All}
}
impl Default for ContentMode {
    fn default() -> Self {ContentMode::Text}
}

// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// ENVIRONMENT
// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone)]
pub struct CommandDeclarations {
    map: HashMap<Ident, Vec<CmdDeclaration>>,
}

// impl Default for CommandDeclarations {
//     fn default() -> Self {
//         let list = crate::cmds::all_commands_list();
//         let mut map: HashMap<Ident, Vec<CmdDeclaration>> = HashMap::with_capacity(list.len());
//         for cmd in list {
//             if let Some(map) = map.get_mut(&cmd.identifier) {
//                 map.push(cmd);
//                 continue;
//             }
//             assert!(map.insert(cmd.identifier.clone(), vec![cmd]).is_none());
//         }
//         CommandDeclarations {
//             map,
//         }
//     }
// }

/// `SemanticScope` is used for storing environment information during AST traversals. 
#[derive(Debug, Clone)]
pub struct SemanticScope {
    pub file_path: Option<PathBuf>,
    pub cmd_decls: CommandDeclarations,
    /// A list of parent command names that a given node is located under.
    /// E.g. given `\note{\p{\x}}`
    /// * the `scope` of `\p` is `["\\note"]`.
    /// * the `scope` of `\x` is `["\\note", "\\p"]`.
    pub scope: Vec<Ident>,
    pub content_mode: ContentMode,
    pub layout_mode: LayoutMode,
}

impl SemanticScope {
    pub fn new<T: Into<PathBuf>>(
        file_path: T,
        commands: Vec<crate::ss::cmd_decl::CmdDeclaration>
    ) -> Self {
        let mut map: HashMap<Ident, Vec<CmdDeclaration>> = HashMap::default();
        for cmd in commands {
            if let Some(cmd_set) = map.get_mut(&cmd.identifier) {
                cmd_set.push(cmd);
                continue;
            }
            assert!(map.insert(cmd.identifier.clone(), vec![cmd]).is_none());
        }
        let cmd_decls = CommandDeclarations{map};
        let file_path = file_path.into();
        SemanticScope {
            file_path: Some(file_path),
            cmd_decls,
            scope: Vec::default(),
            content_mode: ContentMode::default(),
            layout_mode: LayoutMode::default(),
        }
    }
    /// **Warning**: this will match against no commands, this is really only
    /// used for testing. Depending on what you’re doing, if `SemanticScope`
    /// isn’t property configured this can break things. 
    pub fn test_mode_empty() -> Self {
        SemanticScope {
            file_path: None,
            cmd_decls: CommandDeclarations { map: HashMap::default() },
            scope: Vec::default(),
            content_mode: ContentMode::default(),
            layout_mode: LayoutMode::default(),
        }
    }
    /// **WARNING**: This is for testing only. Depending on what you’re doing,
    /// if `SemanticScope` isn’t property configured this can break things. 
    pub fn test_mode_with_cmds(commands: Vec<crate::ss::cmd_decl::CmdDeclaration>) -> Self {
        let mut scope = SemanticScope::new(".", commands);
        scope.file_path = None;
        scope
    }
    pub fn in_inline_mode(&self) -> bool {
        match self.layout_mode {
            LayoutMode::Inline => true,
            _ => false
        }
    }
    pub fn in_block_mode(&self) -> bool {
        match self.layout_mode {
            LayoutMode::Block => true,
            _ => false
        }
    }
    /// Use this to normalize file paths relative to the source file.
    pub fn normalize_file_path<T: AsRef<Path>>(&self, path: T) -> Result<PathBuf, ()> {
        if let Some(file_path) = self.file_path.as_ref() {
            if let Some(rel_path) = file_path.parent() {
                let root_path = file_path.clone();
                let mut rel_path = rel_path.to_path_buf();
                rel_path.push(path.as_ref());
                return Ok(rel_path)
            }
        }
        Err(())
    }
    pub fn match_cmd(&self, cmd: &ParentEnvNamespaceDecl) -> bool {
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
        let layout_mode_match = match (&self.layout_mode, &cmd.layout_mode) {
            (LayoutMode::Both, _) => true,
            (_, LayoutMode::Both) => true,
            (LayoutMode::Block, LayoutMode::Block) => true,
            (LayoutMode::Inline, LayoutMode::Inline) => true,
            (l, r) => {
                assert!(l != r);
                false
            }
        };
        scope_match && content_mode_match && layout_mode_match
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
    pub fn in_heading_scope(&self) -> bool {
        self.scope
            .iter()
            .any(|x| x.is_heading_node())
    }
    pub fn to_matching_cmd_call<'a>(&self, nodes: &'a [Node]) -> Option<(Node, &'a [Node], usize)> {
        if let Some(Ann{value: ident, ..}) = nodes.first().and_then(Node::get_ident_ref) {
            if let Some(matching_cmds) = self.cmd_decls.map.get(&ident) {
                for matching_cmd in matching_cmds {
                    if let Some(payload) = matching_cmd.match_nodes(self, nodes) {
                        return Some(payload)
                    }
                }
            }
        }
        None
    }
    pub fn cmd_call_to_html(
        &self,
        env: &mut HtmlCodegenEnv,
        cmd: CmdCall,
    ) -> Option<crate::html::ast::Node> {
        let cmd_decl_set: Vec<CmdDeclaration> = self.cmd_decls.map.get(&cmd.identifier.value)?.clone();
        for cmd_decl in cmd_decl_set {
            let matches_cmd = self.match_cmd(&cmd_decl.parent_env);
            if matches_cmd {
                let code_gen: &dyn CmdCodegen = cmd_decl.processors.0.as_ref();
                return Some(code_gen.to_html(env, self, cmd));
            }
        }
        None
    }
    pub fn cmd_call_to_latex(
        &self,
        env: &mut LatexCodegenEnv,
        cmd: CmdCall,
    ) -> Option<String> {
        let cmd_decl_set: Vec<CmdDeclaration> = self.cmd_decls.map.get(&cmd.identifier.value)?.clone();
        for cmd_decl in cmd_decl_set {
            let matches_cmd = self.match_cmd(&cmd_decl.parent_env);
            if matches_cmd {
                let code_gen: &dyn CmdCodegen = cmd_decl.processors.0.as_ref();
                return Some(code_gen.to_latex(env, self, cmd));
            }
        }
        None
    }
    pub fn new_scope(&self, parent: Ident) -> SemanticScope {
        let mut new_env = self.clone();
        new_env.scope.push(parent);
        new_env
    }
    pub fn new_file<T: AsRef<Path>>(
        &self,
        file_path: T
    ) -> SemanticScope {
        let mut new_scope = self.clone();
        new_scope.file_path = Some(file_path.as_ref().to_path_buf());
        new_scope
    }
    // pub fn new_
}



// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// HTML CODE-GEN ENVIRONMENT
// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Default)]
pub struct HtmlCodegenEnv {
    pub math_env: MathEnv,
}

impl HtmlCodegenEnv {
    pub fn from_scope(scope: &SemanticScope) -> Self {
        HtmlCodegenEnv {
            math_env: Default::default()
        }
    }
}

#[derive(Debug, Clone, Default)]
pub struct MathEnv {
    pub entries: Vec<MathCodeEntry>,
}

impl MathEnv {
    pub fn add_inline_entry<'a>(
        &mut self,
        code: String,
        unique: bool,
    ) -> crate::html::Element {
        let id = crate::utils::random_str_id();
        let mut attributes: HashMap<String, String> = Default::default();
        if unique {
            attributes.insert(String::from("id"), id.clone());
        } else {
            attributes.insert(String::from("data-math-target"), id.clone());
        }
        attributes.insert("data-math-node".to_owned(), "inline".to_owned());
        let entry = MathCodeEntry {id, code, mode: LayoutMode::Inline, unique};
        self.entries.push(entry);
        crate::html::Element{
            name: String::from("span"),
            attributes,
            children: Vec::new(),
        }
    }
    pub fn add_block_entry<'a>(
        &mut self,
        code: String,
        unique: bool,
    ) -> crate::html::Element {
        let id = crate::utils::random_str_id();
        let mut attributes: HashMap<String, String> = Default::default();
        if unique {
            attributes.insert(String::from("id"), id.clone());
        } else {
            attributes.insert(String::from("data-math-target"), id.clone());
        }
        attributes.insert("data-math-node".to_owned(), "block".to_owned());
        let entry = MathCodeEntry {id, code, mode: LayoutMode::Block, unique};
        self.entries.push(entry);
        crate::html::Element{
            name: String::from("div"),
            attributes,
            children: Vec::new(),
        }
    }
    pub fn to_javascript(&self) -> String {
        self.entries
            .iter()
            .map(|x| {
                let code = format!("{:?}", x.code);
                let id = x.id.clone();
                let display_mode = match x.mode {
                    LayoutMode::Block => true,
                    LayoutMode::Both => true,
                    LayoutMode::Inline => false,
                };
                let options: &[(String, String)] = &[
                    (String::from("throwOnError"), String::from("true")),
                    (String::from("displayMode"), match x.mode {
                        LayoutMode::Block => String::from("true"),
                        LayoutMode::Both => String::from("true"),
                        LayoutMode::Inline => String::from("false"),
                    }),
                    (String::from("strict"), String::from("false")),
                    (String::from("trust"), String::from("true")),
                ];
                // let options = options
                //     .into_iter()
                //     .map(|(k, v)| format!(""))
                if x.unique {
                    format!("katex.render({code}, document.getElementById('{id}'), {{throwOnError: true, displayMode: {display_mode}}});")
                } else {
                    format!(
                        "document.querySelectorAll('[data-math-target=\"{id}\"]').forEach(function(x){{katex.render({code}, x, {{throwOnError: true, displayMode: {display_mode}}});}})"
                    )
                }
            })
            .join("\n")
    }
}

#[derive(Debug, Clone)]
pub struct MathCodeEntry {
    pub id: String,
    pub code: String,
    pub mode: LayoutMode,
    pub unique: bool,
}



// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// LaTeX CODE-GEN ENVIRONMENT
// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Debug, Clone)]
pub struct LatexCodegenEnv {
    // pub commands: CommandDeclarations,
    // pub drawings: HashMap<String, crate::ss_drawing::Drawing>,
}

impl LatexCodegenEnv {
    pub fn from_scope(scope: &SemanticScope) -> Self {
        LatexCodegenEnv {
            
        }
    }
}