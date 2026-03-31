-- ~/.config/nvim/after/ftplugin/markdown.lua
-- Markdown: build on save + localleader build/run/open/clean.
-- Build/Clean/Open are centralized in lua/core/build.lua and lua/core/commands.lua.

local U = require("core.utils")
local B = require("core.build")

-- Build lock (buffer-local) to avoid overlaps.
if vim.b.build_running == nil then
	vim.b.build_running = false
end

local group = U.augroup("MarkdownBuildOnSave", false)

-- Default: build PDF on save. If you prefer HTML for a buffer:
--   :let b:md_build_target = "html"
local function build_on_save()
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

local map = function(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc })
end

map("<localleader>b", "<cmd>Build<cr>", "Build (Markdown)")
map("<localleader>o", "<cmd>Open<cr>", "Open output (PDF by default)")
map("<localleader>c", "<cmd>Clean<cr>", "Clean outputs")
