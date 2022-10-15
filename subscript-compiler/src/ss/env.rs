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

impl CommandDeclarations {
    pub fn len(&self) -> usize {
        self.map.len()
    }
}


// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// ENVIRONMENT - RESOURCE-ENV
// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

#[derive(Debug, Clone, Default)]
pub struct ResourceEnv {
    pub image_paths: Vec<ImagePath>
}

impl ResourceEnv {
    pub fn is_empty(&self) -> bool {
        self.image_paths.is_empty()
    }
    pub fn merge(mut self, other: ResourceEnv) -> ResourceEnv {
        self.image_paths.extend(other.image_paths);
        self
    }
    pub fn add_image(&mut self, scope: &SemanticScope, img_src: impl AsRef<Path>) -> Option<PathBuf> {
        let abs_file_file = img_src.as_ref().canonicalize().ok()?;
        let abs_base_path = scope.base_path.as_ref().unwrap();
        let abs_base_path = abs_base_path.canonicalize().unwrap();
        let rel_file_file = abs_file_file.strip_prefix(&abs_base_path).unwrap().to_path_buf();
        let image_paths = ImagePath {
            rel_path: rel_file_file.clone(),
            abs_path: abs_file_file,
        };
        self.image_paths.push(image_paths);
        Some(rel_file_file)
    }
    pub fn write_sym_links(&self, output_dir: impl AsRef<Path>) {
        use std::os::unix::fs::symlink;
        for ImagePath{rel_path, abs_path} in self.image_paths.iter() {
            let mut out_img_path = output_dir.as_ref().to_path_buf().clone();
            out_img_path.push(&rel_path);
            if let Some(parent) = out_img_path.parent() {
                std::fs::remove_dir_all(&parent).unwrap();
            }
            if !out_img_path.exists() {
                symlink(abs_path, out_img_path);
                println!("WROTE SYM LINKS");
            } else {
                println!("DID NOT WROTE SYM LINKS");
            }
        }
    }
}

#[derive(Debug, Clone)]
pub struct ImagePath {
    rel_path: PathBuf,
    abs_path: PathBuf,
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

// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// ENVIRONMENT - SEMANTIC-SCOPE
// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

/// `SemanticScope` is used for storing environment information during AST traversals. 
#[derive(Debug, Clone)]
pub struct SemanticScope {
    pub base_path: Option<PathBuf>,
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
    pub fn new(
        base_path: impl AsRef<Path>,
        file_path: impl Into<PathBuf>,
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
            base_path: Some(base_path.as_ref().to_path_buf()),
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
            base_path: None,
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
        let mut map: HashMap<Ident, Vec<CmdDeclaration>> = HashMap::default();
        for cmd in commands {
            if let Some(cmd_set) = map.get_mut(&cmd.identifier) {
                cmd_set.push(cmd);
                continue;
            }
            assert!(map.insert(cmd.identifier.clone(), vec![cmd]).is_none());
        }
        let cmd_decls = CommandDeclarations{map};
        let scope = SemanticScope {
            base_path: None,
            file_path: None,
            cmd_decls,
            scope: Vec::default(),
            content_mode: ContentMode::default(),
            layout_mode: LayoutMode::default(),
        };
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
    // pub fn match_cmd(&self, cmd: &ParentEnvNamespaceDecl) -> bool {
    //     self.match_cmd_debug("none", cmd)
    // }
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
        let content_mode_match = match (&self.content_mode, &cmd.content_mode) {
            (ContentMode::Symbolic(_), ContentMode::Symbolic(_)) => true,
            (ContentMode::Text, ContentMode::Text) => true,
            _ => false
        };
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
    pub fn get_cmd_decl<'a>(&self, env: &mut ResourceEnv, cmd_call: &CmdCall) -> Option<&CmdDeclaration> {
        let cmd_set = self.cmd_decls.map.get(&cmd_call.identifier.value);
        if let Some(cmd_set) = cmd_set {
            for cmd_decl in cmd_set {
                if cmd_decl.matches_cmd(env, &self, cmd_call) {
                    return Some(cmd_decl);
                }
            }
        }
        None
    }
    pub fn to_matching_cmd_call<'a>(&self, env: &mut ResourceEnv, nodes: &'a [Node]) -> Option<(Node, &'a [Node], usize)> {
        if let Some(Ann{value: ident, ..}) = nodes.first().and_then(Node::get_ident_ref) {
            if let Some(matching_cmds) = self.cmd_decls.map.get(&ident) {
                for matching_cmd in matching_cmds {
                    if let Some(payload) = matching_cmd.match_nodes(env, self, nodes) {
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
                let code_gen = cmd_decl.processors;
                return Some(code_gen.to_html(env, self, cmd));
            }
        }
        None
    }
    pub fn cmd_call_to_latex(
        &self,
        env: &mut LatexCodegenEnv,
        cmd_call: CmdCall,
    ) -> Option<String> {
        let cmd_decl = self.get_cmd_decl(&mut env.resource_env, &cmd_call)?;
        // let code_gen = cmd_decl.processors;
        let sub_scope = self.new_scope(&mut env.resource_env, &cmd_call);
        return Some(cmd_decl.processors.to_latex(env, &sub_scope, cmd_call))
    }
    pub fn new_scope(
        &self,
        env: &mut ResourceEnv,
        cmd_call: &CmdCall
    ) -> SemanticScope {
        let mut new_env = self.clone();
        let cmd_decl = self.get_cmd_decl(env, cmd_call).unwrap();
        if let Some(child_meta) = cmd_decl.child_env.as_ref() {
            new_env.content_mode = child_meta.content_mode.clone();
            new_env.layout_mode = child_meta.layout_mode.clone();
        }
        new_env.scope.push(cmd_call.identifier.value.clone());
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

impl Default for SemanticScope {
    fn default() -> Self {
        let commands = crate::ss_v1_std::all_commands_list();
        SemanticScope::test_mode_with_cmds(commands)
    }
}


// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// HTML CODE-GEN ENVIRONMENT
// ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――


#[derive(Default)]
pub struct HtmlCodegenEnv {
    pub math_env: MathEnv,
    pub resource_env: ResourceEnv,
}

impl HtmlCodegenEnv {
    pub fn from_scope(scope: &SemanticScope) -> Self {
        HtmlCodegenEnv {
            ..Default::default()
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
                // let options: &[(String, String)] = &[
                //     (String::from("throwOnError"), String::from("true")),
                //     (String::from("displayMode"), match x.mode {
                //         LayoutMode::Block => String::from("true"),
                //         LayoutMode::Both => String::from("true"),
                //         LayoutMode::Inline => String::from("false"),
                //     }),
                //     (String::from("strict"), String::from("false")),
                //     (String::from("trust"), String::from("true")),
                // ];
                // let options = options
                //     .into_iter()
                //     .map(|(k, v)| format!("{k}:{v}"))
                //     .join(",");
                // let options = format!("{{options}}");
                let options: &[(String, String)] = &[
                    (String::from("throwOnError"), String::from("false")),
                    (String::from("displayMode"), match x.mode {
                        LayoutMode::Block => String::from("true"),
                        LayoutMode::Both => String::from("true"),
                        LayoutMode::Inline => String::from("false"),
                    }),
                    (String::from("strict"), String::from("false")),
                    (String::from("trust"), String::from("true")),
                ];
                let options = options
                    .into_iter()
                    .map(|(k, v)| format!("{k}: {v}"))
                    .join(",");
                let options = format!("{{{options}}}");
                let render_code = if x.unique {
                    format!("katex.render({code}, document.getElementById('{id}'), {options});\n")
                } else {
                    format!(
                        "document.querySelectorAll('[data-math-target=\"{id}\"]').forEach(function(x){{katex.render({code}, x, {options});}})\n"
                    )
                };
                format!("try{{\n{render_code}\n}}catch(msg){{console.log(\"Error\", msg)}}\n")
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


#[derive(Debug, Clone, Default)]
pub struct LatexCodegenEnv {
    pub resource_env: ResourceEnv,
    // pub commands: CommandDeclarations,
    // pub drawings: HashMap<String, crate::ss_drawing::Drawing>,
}

impl LatexCodegenEnv {
    pub fn from_scope(scope: &SemanticScope) -> Self {
        LatexCodegenEnv {
            ..Default::default()
        }
    }
}