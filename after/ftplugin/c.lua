-- after/ftplugin/c.lua

local U = require("core.utils")

-- localleader execution mappings
U.bufmap("<localleader>b", "<cmd>Build<cr>", "Build")
U.bufmap("<localleader>r", "<cmd>Run<cr>", "Run")
U.bufmap("<localleader>o", "<cmd>Open<cr>", "Open")
U.bufmap("<localleader>t", "<cmd>Test<cr>", "Test")
U.bufmap("<localleader>c", "<cmd>Clean<cr>", "Clean")

------------------------------------------------------------------
-- Suckless project install helper for config.h
------------------------------------------------------------------

-- Only trigger for config.h
if vim.fn.expand("%:t") ~= "config.h" then
	return
end

-- Detect project root by looking for config.mk + Makefile
local root = U.root({ "config.mk", "Makefile", ".git" })
if not root then
	return
end

-- Ensure this is actually a suckless-style tree
if vim.fn.filereadable(root .. "/config.mk") == 0 then
	return
end

local function install_suckless()
	local cmd = string.format("cd %q && sudo make clean && make && sudo make install", root)
	U.job(cmd, { title = "Suckless Install" })
end

vim.api.nvim_buf_create_user_command(0, "SucklessInstall", install_suckless, {})
U.bufmap("<localleader>i", "<cmd>SucklessInstall<cr>", "Install suckless project")

local group = U.augroup("SucklessAutoInstall", false)
vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	buffer = 0,
	callback = function()
		if vim.b.suckless_auto_install or vim.g.suckless_auto_install then
			install_suckless()
		end
	end,
})
