# Welcome to the SubScript Note-Taking Tools

## Features

### Subscript Markup Language

- Based on HTML tags with LaTeX-like syntax.
- Compile your notes to HTML webpages, or PDF files (WIP).
- Seamlessly intermix markup with hand drawn content VIA the Subscript Freehand Tools (iPad only).
- Seamless dark/light mode support throughout all subscript tools. 

#### Math Support 

| Cmd | Type |
|---|---|
| `\math{…}` | Math Block |
| `\{…}` | Inline Math |
| `\equation{…}` | Math Block where the environment is equivalent to LaTeX's equation + split env |

### File Import Support With Relative Headings

For example
![Include syntax example](assets/preview-images/include-syntax-example.png)

Furthermore, this rule is recursively applied in a bottom-up fashion when files import other files that import other files and so forth (I really wish there were more HTML heading tags). So in any `.ss` file, always begin with H1 and decrement sub-headings relative to such (so the headings therefrom will result in the appropriate level in any given hierarchical context of file imports).

### Automatic Table Of Content Generation

Currently being reimplemented to better handle multi-page and nested (hierarchical) page layouts.


### Unicode Support and Typography
- The parser is based on the `unicode-segmentation` crate (which identifies Grapheme Cluster, Word and Sentence boundaries according to Unicode Standard Annex #29 rules).
- Unicode beautification of characters such as mapping `"..."` → `“…”`

### Local (anonymous) rewrite rules (VIA the `\!where` macro)

![Where cmd syntax example](assets/preview-images/where-cmd-syntax-example.png)

This was initially motivated by the ungodly mess that happened when I tried to color-code a complex bit of LaTeX math, where the resulting markup thereafter was incredibly hard to read... What I wanted was something akin to
![Where cmd syntax example](assets/preview-images/where-cmd-syntax-example-2.png)


### Integration with hand drawn notes VIA your iPad and Apple Pencil (With Dark/Light Mode Support!)


For rapid note taking and freeform content creation such as diagrams and hand drawn visualizations. Which the Subscript Markup Language and compiler natively supports for seamless integration into your published content. 

![UI Editor Preview](assets/preview-images/dark-canvas-preview.jpeg)
![UI Editor Preview](assets/preview-images/light-canvas-preview.jpeg)

Safe your files to e.g. `iCloud Drive` and seamlessly include such in your notes 

![Freeform drawing import example](assets/preview-images/include-ss1-drawing-syntax-example.png)


- Freeform files are essentially vector objects and are therefore resolution independent.
- The strokes are rendered into relatively beautiful SVG paths (compared to other implementations out there was used ugly fixed diameter strokes with hard cutoffs).
- NOTE: It's not yet available on the App Store since dev licenses are expensive (but you don't need a dev license to compile and run your own iPad). Although if this project gains traction with users, I may eventually publish such to the app store... 

Each freeform file can contain multiple drawing entries, which can be manipulated & formatted like so (note that this interface is unstable and likely to change):

![Freeform drawing import example](assets/preview-images/drawing-import-with-rewrites-syntax-example.png)


## Lots more planned! 




# Sub-projects Overview

- `./apps/SSIOS`
    + iPad freeform drawing apps:
        1. `SubscriptDraw` [file extension = `.ss1-drawing`] simple drawing only files
        2. `SubscriptComposition` [file extension = `.ss1-composition`] multiple drawings organized in a hierarchal manner, it's the notebook version of `SubscriptDraw`, but limited to a single page.
        3. There is also a notebook version of Subscript that maps to multiple HTML pages but it's yet to integrated with the compiler.
- `./subscript-compiler`
    - The compiler implementation for the subscript markup language (i.e. `.ss` files). Can be used directly, or indirectly in an automated manner VIA the `subscript` build tool.
- `./ss-language-server`
    + Dev tools/plugins for your text-editor
        - `./ss-language-server/vscode-subscript-markup-language`
            + Basic syntax highlighting for `.ss` files.
        - `./ss-language-server/vscode-subscript-autocomplete`
            + Basic autocomplete for `.ss` files.
        - Eventually there will be a rust language server that uses the compiler for analysis. But for now, the rust project (`ss-language-server`) is currently unimplemented, since `vscode-subscript-markup-language` and `vscode-subscript-autocomplete` works well enough for an MVP... 
- `./subscript`: an opinionated build tool. 
- `./example-project`: Example project showcasing a subscript project using the `subscript-project` toolchain.
- `./format-ss-drawing`: internal (used by `subscript-compiler`)
    + Parser for `.ss1-drawing` and `.ss1-composition` files and SVG compiler for each format respectively. 

## Supported Compilation Targets/Formats

| Format | Supported |
|---|---|
| Web Target (HTML/CSS/JS) | ✅  |
| PDF Target | ❌ |

Regarding PDF support, there are multiple options to chose from

- `Paged.js`: One such option is to use `Paged.js` or something related, which are generally built upon the `CSS Paged Media Modules` for defining layout and content that maps to pages.
    - Originally my aspiration for Subscript was to be a content publishing platform using web technologies VIA a LaTeX like system, and therein benefit from the vast and myriad array of preexisting stuff that arguably outnumbers the feature-set provided by LaTeX packages... The problem is, PDF rendering VIA a browser is terrible! The design side isn't all that bad, but for some reason simple things like selecting and highlighting text doesn't work on my MacOS provided PDF renderer/client (no idea why).
        - But the uniformity benefit is HUGE! If technical problems can be worked out this is a very attractive option... 
- Another option is to use a hybrid approach, and render graphics VIA a browser, and use something else for overall layout and text rendering...
- Part of me likes the idea of integrating with the SILE typesetter -if only it was implemented in rust! I know how to work with C++ and embed such in a rust project, but it's a massive pain and complicates a multitude of things... Especially with regards cross-compilation and running in a browser environment/runtime...
- Just re-implement the SILE typesetter in rust.


# Development

## Issues 

I'm having a hard time laying out drawings in a compact manner on the right, as opposed to the HTML target on the left:

![Include syntax example](assets/preview-images/latex-issue.jpg)
