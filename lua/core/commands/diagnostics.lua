-- ~/.config/nvim/lua/core/commands/diagnostics.lua
-- Diagnostic list helpers.

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("Diagnostics", function(opts)
		if opts.bang then
			vim.diagnostic.setqflist({ open = true })
			return
		end

		vim.diagnostic.setloclist({ open = true })
	end, {
		bang = true,
		desc = "Open diagnostics in location list; use ! for quickfix",
	})
end

return M
