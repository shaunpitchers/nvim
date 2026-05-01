# Neovim Configuration

Minimal, automation-first Neovim setup for writing, scripting, and small project work.

The config keeps the editor close to native Vim/Neovim behaviour while adding a small set of high-value workflows:

- project-aware build, run, test, and clean commands
- writing ergonomics for Markdown, LaTeX, mail, and prose
- lightweight LSP, completion, snippets, and Treesitter
- plugin-free defaults where built-ins are good enough
- filetype-local actions through `<localleader>`

## Layout

| Path | Purpose |
| --- | --- |
| `init.lua` | Bootstraps core config and lazy.nvim. |
| `lua/core/options.lua` | Global editor options. |
| `lua/core/autocmds.lua` | General autocmds for editing, writing, formatting, and LSP behaviour. |
| `lua/core/mappings.lua` | Global keymaps. |
| `lua/core/commands.lua` | User-command registry. |
| `lua/core/commands/` | Focused command modules. |
| `lua/core/tasks/` | Build, clean, test, and project-detection logic. |
| `lua/core/zk.lua` | Zettelkasten Markdown helpers. |
| `lua/plugins/` | lazy.nvim plugin specs. |
| `after/ftplugin/` | Filetype-local options, mappings, and automation. |
| `after/plugin/zk.lua` | Tiny Zettelkasten loader. |
| `snippets/` | Local LuaSnip snippets. |
| `docs/` | Reference notes and cheatsheets. |
| `thesaurus/` | Local thesaurus data used for writing completion. |

## Core Principles

1. Keep plugins minimal and purposeful.
2. Prefer native quickfix, location lists, netrw, grep, and Vim motions.
3. Use `<leader>` for global/editor commands.
4. Use `<localleader>` for filetype or project-specific actions.
5. Prefer explicit commands over hidden automation.
6. Make automation easy to disable when it gets in the way.

## Leader Keys

```text
Leader       <Space>
LocalLeader  ,
```

## Global Mappings

| Mapping | Action |
| --- | --- |
| `<C-h/j/k/l>` | Move between windows. |
| `]d` / `[d` | Next / previous diagnostic. |
| `gl` | Show diagnostics for current line. |
| `]q` / `[q` | Next / previous quickfix item. |
| `<leader>co` | Open quickfix. |
| `<leader>cc` | Close quickfix. |
| `<leader>cl` | Send current diagnostics to the location list. |
| `<leader>cq` | Send workspace diagnostics to quickfix. |
| `<leader>sf` | Fuzzy-find files with fzf. |
| `<leader>sg` | Live grep with ripgrep/fzf. |
| `<leader>e` | Open netrw file explorer. |
| `<leader>cd` | Set local working directory to the current file directory. |
| `<leader>?` | Show leader mappings. |

## Git Mappings

| Mapping | Action |
| --- | --- |
| `<leader>gs` | Fugitive status. |
| `<leader>gd` | Fugitive diff split. |
| `<leader>gc` | Commit. |
| `<leader>gp` | Push. |
| `<leader>gP` | Pull. |
| `<leader>gb` | Blame. |
| `<leader>gw` | Stage current file. |
| `<leader>gr` | Read file from Git index/HEAD through Fugitive. |

## Build, Run, Test, Clean

Global execution mappings:

| Mapping | Command |
| --- | --- |
| `<leader>xb` | `:Build` |
| `<leader>xr` | `:Run` |
| `<leader>xo` | `:Open` |
| `<leader>xt` | `:Test` |

Filetype-local mappings generally use:

| Mapping | Action |
| --- | --- |
| `,b` | Build. |
| `,r` | Run. |
| `,o` | Open generated artifact or current file. |
| `,c` | Clean generated files. |
| `,t` | Test. |

### Supported Workflows

| Filetype / project | Behaviour |
| --- | --- |
| Python | `:Run` runs the current file, `:Test` uses pytest or unittest, `:Clean` removes `__pycache__`. |
| Markdown | `:Build` uses pandoc, `:Open` opens the output, `:Clean` removes generated PDF/HTML. |
| LaTeX | `:Build` uses latexmk, `:Open` opens the PDF, `:Clean` runs `latexmk -c`. |
| C / C++ | CMake, Makefile, justfile, or single-file compile-to-`.out` workflow. |
| Rust | `cargo build`, `cargo run`, `cargo test`, `cargo clean`. |
| Go | `go build`, `go run`, `go test`, `go clean`. |
| Shell | `:Build` uses shellcheck if available, `:Test` uses bats if available. |
| justfile projects | `just build`, `just run`, `just test`, `just clean` when recipes exist. |

### Build On Save

Markdown and LaTeX build on save by default.

```vim
:ToggleBuildOnSave
```

For Markdown, the default build target is PDF. Toggle HTML output per buffer:

```vim
:ToggleMarkdownTarget
```

## Writing Workflow

Writing filetypes get spell checking, wrapping, `breakindent`, `textwidth`, and thesaurus completion.

Writing filetypes include:

- Markdown
- LaTeX / plaintex
- text
- mail
- gitcommit
- rst
- asciidoc
- org

Useful writing commands:

| Mapping / command | Action |
| --- | --- |
| `<C-d>` in insert mode | Dictionary completion. |
| `<leader>ww` / `:WordCount` | Show word and character count. |
| `<leader>wp` / `:ReadingPosition` | Show current line and percentage through file. |
| `<leader>wm` / `:ToggleMarkdownTarget` | Toggle Markdown PDF/HTML target. |
| `<leader>zz` / `:ToggleDistractionFree` | Toggle distraction-free writing view. |

## Coding Workflow

Code and config buffers get:

- LSP diagnostics without inline virtual text
- document highlights on cursor hold when supported by the server
- LSP format-on-save where supported, excluding Markdown and TeX
- trailing whitespace trimming on save
- cursor position restore when reopening files
- automatic parent-directory creation before saving new files
- automatic file reload checks on focus/buffer enter

Useful commands:

| Command | Action |
| --- | --- |
| `:Diagnostics` | Open current diagnostics in the location list. |
| `:Diagnostics!` | Open diagnostics in quickfix. |
| `:ToggleFormatOnSave` | Toggle LSP format-on-save for the current buffer. |
| `:ToggleInlayHints` | Toggle LSP inlay hints for the current buffer. |
| `:Scratch` | Open a throwaway nofile buffer. |

## LSP Mappings

| Mapping | Action |
| --- | --- |
| `gd` | Go to definition. |
| `gI` | Go to implementation. |
| `gD` | Go to type definition. |
| `gr` | References. |
| `K` | Hover docs. |
| `<leader>r` | Rename. |
| `<leader>ca` | Code action. |
| `<leader>cf` | Format. |
| `<leader>ci` | LSP info. |

## Suckless Projects

When editing a suckless-style `config.h`, the C ftplugin detects `config.mk` and adds:

```vim
:SucklessInstall
```

and:

```text
,i
```

Auto-install on save is intentionally opt-in. Enable it per buffer:

```vim
:let b:suckless_auto_install = v:true
```

or globally:

```vim
:let g:suckless_auto_install = v:true
```

## Zettelkasten Helpers

Markdown files inside a `zettelkasten` tree get small helpers from `core.zk`:

- insert templates for new notes, inbox items, sources, MOCs, and projects
- fill empty `id:` and `created:` frontmatter fields for new note/inbox files
- resolve `[[YYYYMMDDHHMMSS]]` links with `gf`

## Snippets

Completion uses `nvim-cmp` and `LuaSnip`.

Local snippets live in:

```text
snippets/
```

Supported local snippet filetypes:

- `tex`
- `markdown`
- `html`
- `css`
- `python`

## Search And Navigation

- fzf.vim provides `:Files`, `:Rg`, `:Buffers`, `:Lines`, `:BLines`, `:Commits`, `:History`, and `:Maps`.
- `ripgrep` powers `:grep` through `grepprg`.
- netrw remains the file explorer.
- `:Leader` and `:LocalLeader` provide lightweight mapping help without which-key.

## Backups And Undo

The config enables:

- persistent undo in Neovim state
- central backup files in Neovim state
- helper commands for current-file backups

Backup commands:

| Command | Action |
| --- | --- |
| `:OpenBackup` | Open the current file's backup. |
| `:DiffBackup` | Diff the current file against its backup. |
| `:BackupPath` | Print the detected backup path. |

## Requirements

Core tools:

- `git`
- `ripgrep`
- `fzf`

Recommended by workflow:

- `python3`
- `pytest`
- `shellcheck`
- `bats`
- `pandoc`
- `latexmk`
- `zathura`
- `cmake`
- `make`
- `just`
- `cargo`
- `go`

Neovim health checks are handled by the normal:

```vim
:checkhealth
```

## Plugin Policy

Plugins are kept small and purposeful:

- LSP: `mason.nvim`, `mason-lspconfig.nvim`, `nvim-lspconfig`
- Completion: `nvim-cmp`, LuaSnip, cmp sources
- Syntax: `nvim-treesitter`, `rainbow-delimiters.nvim`
- Search: fzf/fzf.vim
- Git: vim-fugitive
- Editing: vim-surround, vim-sleuth, nvim-autopairs

`lazy-lock.json` is tracked so plugin versions are reproducible.

## Design Goal

This setup is intended to stay fast, boring, and predictable while still covering daily writing and coding work. New features should remove real friction rather than turn the config into a large framework.
