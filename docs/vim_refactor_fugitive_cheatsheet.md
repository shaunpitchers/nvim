# Vim Refactoring & Fugitive Cheat Sheet

Minimal workflows for **repo-wide refactoring** and **Git operations** in Neovim using mostly **native Vim + Fugitive**.

---

# 1. Repo-Wide Refactoring

Three main strategies:

1. LSP Rename (symbol-aware)
2. Search + Quickfix + Substitution
3. Search + Quickfix + Macros

---

## LSP Rename

Best for renaming:

- functions
- classes
- variables
- methods

Workflow:

1. Place cursor on symbol
2. Trigger rename (`vim.lsp.buf.rename()` or mapping)
3. Enter new name

Advantages:

- understands Python symbols
- avoids accidental text replacement
- updates across files safely

---

## Search + Quickfix

Search project:

:grep old_name

Open results:

:copen

Navigate:

:cnext
:cprev
:cc

Quickfix becomes a **work queue**.

Search -> review -> operate.

---

## Apply Change to All Matches

:cdo s/old/new/ge | update

Explanation:

cdo = run command for each quickfix match
g = replace all matches on line
e = suppress errors
update = save only if modified

---

## Apply Change Once Per File

:cfdo %s/old/new/ge | update

Difference:

cdo -> per match
cfdo -> per file

---

## Safe Refactor Pattern

1. Search

:grep old_api

2. Inspect

:copen

3. Replace

:cfdo %s/old_api/new_api/ge | update

4. Run tests

---

## Macros Across Quickfix

Example:

:grep old_call(
:copen

Record macro:

qa
(edit)
q

Apply:

:cdo normal! @a | update

This allows structured edits across many files.

---

## Arglist Edits

Operate across selected files:

:args **/*.py
:argdo %s/foo/bar/ge | update

Use when intentionally targeting many files.

---

# 2. Python Refactoring Strategy

Preferred order:

1. LSP rename
2. :grep + quickfix
3. :cfdo / :cdo
4. macros
5. external codemod tools

External codemods (when needed):

- ruff
- bowler
- libcst

Neovim orchestrates the workflow but should not do everything itself.

---

# 3. Fugitive Git Workflows

Fugitive integrates Git directly into Vim.

---

## Status

:Git

Acts like `git status` but inside Vim.

Use it as the central Git interface.

---

## Commit

:Git commit
:Git commit --amend

Allows editing commit messages inside Vim.

---

## Branching

Create branch:

:Git switch -c feature-x

Switch branch:

:Git switch main

Merge:

:Git merge feature-x

---

## Diff Views

:Gdiffsplit
:Gvdiffsplit

Navigate changes:

]c  next change
[c  previous change
do  obtain change
dp  put change

---

## Open File From Another Commit

:Gedit HEAD~1:path/to/file.py

Useful for:

- reviewing history
- copying old code

---

## Conflict Resolution

:Gvdiffsplit!

Use diff commands:

do
dp

or

:diffget
:diffput

---

# 4. Practical Workflows

## Rename Symbol

1. LSP rename
2. Run tests

---

## Repo-Wide Text Refactor

:grep old_pattern
:copen
:cfdo %s/old_pattern/new_pattern/ge | update

---

## Structured Change With Macro

:grep old_call(
:copen
qa
(edit)
q
:cdo normal! @a | update

---

## Feature Branch Workflow

Create branch:

:Git switch -c feature-x

Commit:

:Git
:Git commit

Merge:

:Git switch main
:Git merge feature-x

---

# 5. Plugins That Add Real Value

Keep:

- vim-fugitive
- vim-surround
- vim-commentary
- vim-sleuth
- rainbow-delimiters

Optional:

- Gitsigns (for hunk staging)
- Trouble.nvim (better quickfix UI)

Avoid large abstraction layers unless truly needed.

---

# 6. About lsp_signature.nvim

Shows function parameter hints.

Pros:

- helps understand APIs
- reduces lookup time

Cons:

- popup noise
- IDE-style assistance
- can reduce fluency

Recommendation:

Leave disabled for now.

Use hover docs and completion instead.

Add only if you frequently need argument hints.

---

# 7. High-Value Skills

Refactoring:

1. :grep
2. quickfix navigation
3. :cfdo
4. :cdo
5. macros

Git:

1. :Git
2. :Git commit
3. :Git switch
4. :Git merge
5. :Gvdiffsplit
6. conflict resolution

Minimal tools + strong fluency = powerful workflow.
