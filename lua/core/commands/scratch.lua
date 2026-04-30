-- ~/.config/nvim/lua/core/commands/scratch.lua
-- Scratch buffer command.

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("Scratch", function()
		vim.cmd("new")
		vim.bo.buftype = "nofile"
		vim.bo.bufhidden = "wipe"
		vim.bo.swapfile = false
		vim.api.nvim_buf_set_name(0, "Scratch")
	end, {})
end

return M
