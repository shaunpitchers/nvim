-- ~/.config/nvim/after/ftplugin/markdown.lua
-- Markdown: build on save + localleader build/run/open/clean.
-- Build/Clean/Open are centralized in lua/core/tasks/ and lua/core/commands/.

local U = require("core.utils")
local B = require("core.build")

-- Lazy-loaded Markdown plugins can cause the ftplugin to be re-applied.
-- Neovim's bundled markdown.lua may emit E31 while undoing Treesitter maps.
if vim.b.undo_ftplugin then
	local undo = vim.b.undo_ftplugin
	undo = undo:gsub("call v:lua%.vim%.treesitter%.stop%(%)", "silent! call v:lua.vim.treesitter.stop()")
	undo = undo:gsub("|sil! nunmap <buffer> %[%[", "")
	undo = undo:gsub("|sil! nunmap <buffer> %]%]", "")
	undo = undo:gsub("|sil! xunmap <buffer> %[%[", "")
	undo = undo:gsub("|sil! xunmap <buffer> %]%]", "")
	undo = undo:gsub('\n sil! exe "nunmap <buffer> gO"', "")
	undo = undo:gsub('\n sil! exe "nunmap <buffer> %]%]" | sil! exe "nunmap <buffer> %[%["', "")
	vim.b.undo_ftplugin = undo
		.. "\n call v:lua.require('core.utils').bufunmap(['n', 'x'], '[[')"
		.. "\n call v:lua.require('core.utils').bufunmap(['n', 'x'], ']]')"
		.. "\n call v:lua.require('core.utils').bufunmap('n', 'gO')"
end

-- Build lock (buffer-local) to avoid overlaps.
if vim.b.build_running == nil then
	vim.b.build_running = false
end

local group = U.augroup("MarkdownBuildOnSave", false)

-- Default: build PDF on save. If you prefer HTML for a buffer:
--   :let b:md_build_target = "html"
local function build_on_save()
	if vim.b.build_on_save == false then
		return
	end

	if vim.b.build_running then
		return
	end
	vim.b.build_running = true

	local target = vim.b.md_build_target or ""
	B.build_current_job({
		arg = target,
		success = "Markdown: build OK",
		failure = "Markdown: build FAILED (see :messages)",
		on_exit = function()
			vim.b.build_running = false
		end,
	})
end

vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	buffer = 0,
	callback = build_on_save,
})

U.bufmap("<localleader>b", "<cmd>Build<cr>", "Build (Markdown)")
U.bufmap("<localleader>o", "<cmd>Open<cr>", "Open output (PDF by default)")
U.bufmap("<localleader>c", "<cmd>Clean<cr>", "Clean outputs")
