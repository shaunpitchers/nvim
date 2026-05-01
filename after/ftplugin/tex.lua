-- ~/.config/nvim/after/ftplugin/tex.lua
-- LaTeX: build on save + localleader build/run/open/clean.
-- Build/Clean/Open are centralized in lua/core/tasks/ and lua/core/commands/.

local U = require("core.utils")
local B = require("core.build")

-- Build lock (buffer-local) to avoid overlaps on frequent saves.
if vim.b.build_running == nil then
	vim.b.build_running = false
end

local group = U.augroup("TexBuildOnSave", false)

local function build_on_save()
	if vim.b.build_on_save == false then
		return
	end

	if vim.b.build_running then
		return
	end
	vim.b.build_running = true
	B.build_current_job({
		success = "LaTeX: build OK",
		failure = "LaTeX: build FAILED (see :messages)",
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

-- Filetype-local execution keys
U.bufmap("<localleader>b", "<cmd>Build<cr>", "Build (LaTeX)")
U.bufmap("<localleader>o", "<cmd>Open<cr>", "Open PDF")
U.bufmap("<localleader>c", "<cmd>Clean<cr>", "Clean aux")
U.bufmap("<localleader>v", function()
	vim.lsp.buf.execute_command({
		command = "texlab.forwardSearch",
		arguments = {
			{
				uri = vim.uri_from_bufnr(0),
				position = { line = vim.fn.line(".") - 1, character = 0 },
			},
		},
	})
end, "Forward search (synctex → zathura)")
