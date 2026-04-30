-- after/ftplugin/c.lua

local U = require("core.utils")

-- localleader execution mappings
U.bufmap("<localleader>b", "<cmd>Build<cr>", "Build")
U.bufmap("<localleader>r", "<cmd>Run<cr>", "Run")
U.bufmap("<localleader>o", "<cmd>Open<cr>", "Open")
U.bufmap("<localleader>t", "<cmd>Test<cr>", "Test")
U.bufmap("<localleader>c", "<cmd>Clean<cr>", "Clean")

------------------------------------------------------------------
-- Auto rebuild suckless projects when editing config.h
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

-- Create autocmd for this buffer only
vim.api.nvim_create_autocmd("BufWritePost", {
	buffer = 0,
	callback = function()
		local cmd = string.format("cd %q && sudo make clean && make && sudo make install", root)

		U.job(cmd, { title = "Suckless Rebuild" })
	end,
})
