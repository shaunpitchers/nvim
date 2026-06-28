# Markdown Treesitter Notes

## Current Status

Markdown Treesitter is disabled as a workaround for a Neovim 0.12 runtime issue.

Retested on 2026-06-28 with Neovim 0.12.3:

- `README.md` still reproduces the Treesitter decoration provider error when
  Markdown Treesitter is manually started.
- `~/docs/guides/vim-surround-cheat-sheet.md` still reproduces the same error.
- `docs/vim_refactor_fugitive_cheatsheet.md` did not reproduce the error in a
  headless manual-start test.
- All Lua files in this config opened with Treesitter active and no reproduced
  Treesitter highlighter error.

The failure seen when opening some Markdown files was:

```text
Decoration provider "start" (ns=nvim.treesitter.highlighter):
Lua: /usr/share/nvim/runtime/lua/vim/treesitter/languagetree.lua:215:
/usr/share/nvim/runtime/lua/vim/treesitter.lua:197:
attempt to call method 'range' (a nil value)
```

The issue reproduced on files such as:

- `~/docs/guides/vim-surround-cheat-sheet.md`
- Other Markdown guide files with inline markup or injected regions

## Cause

Neovim 0.12's bundled Markdown ftplugin starts Treesitter directly with:

```lua
vim.treesitter.start()
```

That bypasses the `nvim-treesitter` per-filetype disable list. Disabling Markdown
in `nvim-treesitter` alone was not enough, because the bundled runtime still
started the built-in Treesitter highlighter.

## Current Workaround

The workaround lives in:

```text
~/.config/nvim/after/ftplugin/markdown.lua
```

It does the following for Markdown buffers:

- Stops Treesitter with `vim.treesitter.stop(0)`.
- Sets `foldmethod=manual`.
- Sets `foldexpr=0`.
- Removes the bundled Treesitter heading maps: `gO`, `[[`, `]]`.

`nvim-treesitter` also has Markdown highlighting disabled in:

```text
~/.config/nvim/lua/plugins/treesitter.lua
```

## Functionality Temporarily Lost

The following Markdown Treesitter features are disabled:

- Treesitter Markdown highlighting.
- Treesitter Markdown folding.
- Treesitter-based Markdown outline with `gO`.
- Treesitter-based heading jumps with `[[` and `]]`.

## What Treesitter Provides Here

Treesitter parses code and prose into syntax trees instead of only matching text
with regexes. In this config it mainly gives:

- More accurate syntax highlighting for programming languages.
- Better nested-language handling, such as code blocks or injected languages.
- Structural editor features that can understand syntax nodes rather than plain
  lines.
- Plugin support for features such as rainbow delimiters.
- Filetype-specific folding and navigation where Neovim or plugins wire those
  features to Treesitter.

For Lua coding, the important active pieces are Treesitter highlighting and
rainbow delimiter support. LSP still handles diagnostics, completion, hover,
rename, and most semantic code intelligence.

For Markdown writing, Treesitter would mostly improve highlighting, fenced-code
handling, heading structure, outline/navigation maps, and folding. The normal
writing features are not dependent on it.

## Features Causing The Issue

The failing feature is the Treesitter highlighter decoration provider. The error
is raised while Neovim parses/highlights Markdown:

- `vim.treesitter.start()` starts the highlighter for the buffer.
- The highlighter parses Markdown plus injected regions, including
  `markdown_inline`.
- During decoration/highlighting, Neovim hits a language-tree range failure:
  `attempt to call method 'range' (a nil value)`.

The workaround only disables Markdown Treesitter startup, folding, and
Treesitter-provided Markdown heading maps. It does not disable Lua Treesitter or
Treesitter for other coding filetypes.

## Functionality Still Available

The normal writing workflow should still work:

- Markdown filetype detection.
- Vim regex syntax highlighting.
- Spell checking.
- Wrap, linebreak, textwidth, and prose settings.
- Marksman LSP.
- Markdown build/open/clean mappings.
- Completion and snippets.

## Long-Term Goal

Re-enable Markdown Treesitter once Neovim/runtime/parser compatibility improves.

The likely upstream area is one of:

- Neovim 0.12 Markdown runtime behavior.
- Markdown or `markdown_inline` Treesitter parser compatibility.
- Markdown injection/highlight query behavior.
- Interaction between bundled Neovim runtime queries and `nvim-treesitter`
  parser/query versions.

## Retest Plan

After a Neovim or Treesitter parser update, test without changing the main setup
first.

Useful test file:

```text
~/docs/guides/vim-surround-cheat-sheet.md
```

Suggested checks:

```vim
:checkhealth vim.treesitter
:TSUpdate markdown markdown_inline
```

Then temporarily comment out the workaround in:

```text
~/.config/nvim/after/ftplugin/markdown.lua
```

Restart Neovim fully and open the test file:

```sh
nvim ~/docs/guides/vim-surround-cheat-sheet.md
```

Check whether a Treesitter highlighter is active:

```vim
:lua print(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil)
```

Check the Neovim log for fresh decoration provider errors:

```sh
tail -n 40 ~/.local/state/nvim/nvim.log
```

## To Do

- Keep Neovim updated and retest after runtime changes.
- Keep `nvim-treesitter` and parsers updated.
- Re-test `vim-surround-cheat-sheet.md` after updates.
- If the bug is fixed, remove the Markdown Treesitter stop block from
  `after/ftplugin/markdown.lua`.
- If stable, re-enable Markdown Treesitter highlighting.
- If stable, restore Markdown Treesitter folding.
- If stable, restore `gO`, `[[`, and `]]` heading navigation.
- If the bug persists across updates, look for an upstream Neovim issue or file
  a minimal reproduction using `vim-surround-cheat-sheet.md`.
