-- ~/.config/nvim/after/ftplugin/python.lua

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

-- in after/ftplugin/<ft>.lua
local map = function(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc })
end

map("<localleader>b", "<cmd>Build<cr>", "Build")
map("<localleader>r", "<cmd>Run<cr>", "Run")
map("<localleader>o", "<cmd>Open<cr>", "Open")
map("<localleader>t", "<cmd>Test<cr>", "Test")
-- map("<localleader>c", "<cmd>Clean<cr>", "Clean") -- optional
