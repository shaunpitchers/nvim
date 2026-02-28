# Neovim Configuration

Minimal, automation-first Neovim setup.

This configuration avoids heavy plugin stacks and focuses on:

-   Native Vim fluency\
-   Filetype-aware automation\
-   Minimal plugins with high ROI\
-   Project-aware build/test workflows\
-   Clean, predictable behavior

------------------------------------------------------------------------

## Philosophy

This config follows a few strict rules:

1.  **Minimal plugins**
    -   Every plugin must add real functionality.
    -   No cosmetic bloat.
    -   No "convenience" plugins unless they remove meaningful friction.
2.  **Prefer built-in functionality**
    -   Use native Vim motions.
    -   Use `:grep`, quickfix, and built-ins where possible.
    -   Learn defaults instead of remapping them away.
3.  **Filetype-local actions**
    -   `<leader>` → global/editor actions.
    -   `<localleader>` → filetype/project-specific actions.
4.  **Automation without magic**
    -   Build, run, test, and clean commands are predictable.
    -   No hidden behavior.
    -   No guessing unless it's clearly safe.

------------------------------------------------------------------------

## Leader Keys

    Leader        = <Space>
    LocalLeader   = ,

### Execution (Global)

    <leader>xb   → :Build
    <leader>xr   → :Run
    <leader>xo   → :Open
    <leader>xt   → :Test
    <leader>?    → Show leader mappings

### Filetype-Local (Examples)

    ,b   → Build
    ,r   → Run
    ,o   → Open artifact
    ,c   → Clean
    ,t   → Test

These are buffer-local and depend on filetype.

------------------------------------------------------------------------

## Build / Run / Test / Clean

Centralized logic supports:

### Python

-   `:Run` → run current file\
-   `:Test` → pytest (or unittest fallback)\
-   `:Clean` → remove `__pycache__`

### LaTeX

-   `:Build` → `latexmk`\
-   `:Open` → open PDF\
-   `:Clean` → `latexmk -c`

### Markdown

-   `:Build` → pandoc (PDF or HTML)\
-   `:Open` → open output file\
-   `:Clean` → remove generated output

### C / C++

-   CMake projects → configure + build in `./build`\
-   Makefile projects → `make`\
-   Single file → compile to `file.out`\
-   `:Test` → `ctest` or `make test`

### Rust

-   `cargo build`\
-   `cargo run`\
-   `cargo test`

### Go

-   `go build`\
-   `go run`\
-   `go test`

------------------------------------------------------------------------

## Snippets

Using:

-   `nvim-cmp`
-   `LuaSnip`

Snippets are:

-   Minimal\
-   Filetype-specific\
-   Personally curated\
-   No massive snippet collections

Supported filetypes:

-   `tex`
-   `markdown`
-   `html`
-   `css`
-   `python`

Snippets are stored in:

    lua/snippets/

------------------------------------------------------------------------

## Writing Ergonomics

For writing filetypes (LaTeX, Markdown):

-   Spell enabled\
-   Line wrapping enabled\
-   `breakindent` enabled\
-   Custom `showbreak`\
-   `textwidth` configured

Toggles:

    <leader>tw   → Toggle wrap
    <leader>ts   → Toggle spell
    <leader>tn   → Toggle line numbers

------------------------------------------------------------------------

## Performance

-   Lazy-loaded plugins\
-   Minimal runtime plugins\
-   `vim.loader.enable()` (if supported)\
-   No which-key\
-   No UI-heavy helpers\
-   Treesitter used intentionally

------------------------------------------------------------------------

## Mapping Help (which-key alternative)

    :Leader        → Show leader mappings
    :LocalLeader   → Show buffer-local mappings

No popup delay. Just clarity when needed.

------------------------------------------------------------------------

## Requirements

External tools (optional but recommended):

-   `ripgrep`
-   `latexmk`
-   `pandoc`
-   `pytest`
-   `cmake`
-   `make`
-   `cargo`
-   `go`
-   `zathura` (or any PDF viewer)
-   `shellcheck`

------------------------------------------------------------------------

## Design Goals

This setup is designed for:

-   Writing documents (LaTeX/Markdown)\
-   Editing scripts\
-   Python development\
-   Small to medium C/C++ projects\
-   Lightweight project workflows

It intentionally avoids:

-   Large IDE-like abstraction layers\
-   Over-automation\
-   Hidden behavior

------------------------------------------------------------------------

## Future Improvements

Improvements are added only when real bottlenecks appear.

Until then: stability \> features.
