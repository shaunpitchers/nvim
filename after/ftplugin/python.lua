-- ~/.config/nvim/after/ftplugin/python.lua

local U = require("core.utils")

-- Buffer-local options
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4

vim.opt_local.textwidth = 88 -- Black default
vim.opt_local.colorcolumn = "89" -- optional; delete if you dislike

-- Don't auto-wrap code while typing (manual gq is still available)
vim.opt_local.formatoptions:remove({ "t", "c", "r", "o" })

-- --------------
-- Format on save
-- --------------
-- Formatting is handled globally in lua/core/autocmds.lua.
-- For Python, enable by default; disable per-buffer with:
--   :lua vim.b.format_on_save = false
if vim.b.format_on_save == nil then
	vim.b.format_on_save = true
end

-- Minimal MatchIt words for Python (for % to jump between blocks)
-- Requires matchit.vim loaded (Neovim usually has it available)
vim.cmd("runtime! macros/matchit.vim")

-- b:match_words in Vimscript becomes vim.b.match_words in Lua
-- This is a simple set; you can extend later.
vim.b.match_words = table.concat({
	"if:elif:else",
	"for:else",
	"while:else",
	"try:except:else:finally",
	"def",
	"class",
}, ",")

U.bufmap("<localleader>b", "<cmd>Build<cr>", "Build")
U.bufmap("<localleader>r", "<cmd>Run<cr>", "Run")
U.bufmap("<localleader>o", "<cmd>Open<cr>", "Open")
U.bufmap("<localleader>t", "<cmd>Test<cr>", "Test")
U.bufmap("<localleader>c", "<cmd>Clean<cr>", "Clean")
