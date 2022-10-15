use std::{fmt::Display, path::{PathBuf, Path}, collections::HashMap};
use itertools::Itertools;
use rayon::prelude::*;
use futures::channel::mpsc::{channel, Receiver};
use futures::{SinkExt, StreamExt};
use notify::{Event, RecommendedWatcher, RecursiveMode, Watcher, Config, EventKind};
use notify::event::ModifyKind;
use notify::event::DataChange;
use crate::html::toc::TocPageEntry;
use crate::html::template::TemplateFile;
use crate::ss::{SemanticScope, HtmlCodegenEnv, ResourceEnv};
use super::Compiler;


fn async_watcher() -> notify::Result<(RecommendedWatcher, Receiver<notify::Result<Event>>)> {
    let (mut tx, rx) = channel(1);
    let watcher = RecommendedWatcher::new(move |res| {
        futures::executor::block_on(async {
            tx.send(res).await.unwrap();
        })
    }, Config::default())?;
    Ok((watcher, rx))
}

impl Compiler {
    pub fn recompile(&self, resource_env: &mut ResourceEnv, source_path: impl AsRef<Path>) {
        let toc_entries = self.files
            .iter()
            .filter_map(|entry| {
                if entry.matches_path(source_path.as_ref()) {
                    let toc_entry = self.compile_page_to_html(resource_env, &entry);
                    println!("Recompiled: {:?}", entry.src_file);
                    return Some(toc_entry);
                }
                None
            })
            .collect_vec();
    }
    async fn compile_watch_loop(self, mut resource_env: ResourceEnv) -> notify::Result<()> {
        let mut watching_files = Vec::new();
        for entry in self.files.iter() {
            watching_files.push(entry.src_file.clone());
        }
        let _ = self.html_metadata
            .as_ref()
            .and_then(|meta| meta.html_template_path.as_ref())
            .map(|template_path| {
                watching_files.push(template_path.clone());
            });
        println!("Watching:");
        let (mut watcher, mut rx) = async_watcher()?;
        for file in watching_files.iter() {
            println!("\t-{file:?}");
            watcher.watch(file.as_ref(), RecursiveMode::NonRecursive)?;
        }
        while let Some(res) = rx.next().await {
            match res {
                Ok(event) => {
                    match &event.kind {
                        EventKind::Modify(ModifyKind::Data(DataChange::Content)) => {
                            for path in event.paths.clone() {
                                self.recompile(&mut resource_env, &path);
                            }
                        }
                        _ => ()
                    }
                },
                Err(e) => println!("watch error: {e:?}"),
            }
        }
        Ok(())
    }
    pub fn compile_html_watch_sources(self) {
        let mut resource_env = ResourceEnv::default();
        self.compile_pages_to_html(&mut resource_env);
        futures::executor::block_on(async {
            if let Err(e) = self.compile_watch_loop(resource_env).await {
                println!("error: {:?}", e)
            }
        });
    }
}

