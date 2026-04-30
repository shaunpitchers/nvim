-- ~/.config/nvim/lua/core/commands/toggles.lua
-- User commands for editor and LSP toggles.

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
		vim.b.format_on_save = not (vim.b.format_on_save ~= false)
		vim.notify("Format on save: " .. (vim.b.format_on_save and "ON" or "OFF"), vim.log.levels.INFO)
	end, {})

	vim.api.nvim_create_user_command("ToggleInlayHints", function()
		if not (vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable and vim.lsp.inlay_hint.is_enabled) then
			vim.notify("Inlay hints are not supported by this Neovim", vim.log.levels.WARN)
			return
		end

		local bufnr = vim.api.nvim_get_current_buf()
		local ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled, { bufnr = bufnr })
		if not ok then
			vim.notify("Could not read inlay hint state", vim.log.levels.WARN)
			return
		end

		vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
		vim.notify("Inlay hints: " .. (not enabled and "ON" or "OFF"), vim.log.levels.INFO)
	end, {})
end

return M
