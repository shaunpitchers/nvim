-- ~/.config/nvim/lua/core/commands/toggles.lua
-- User commands for editor and LSP toggles.

local M = {}

local function toggle_distraction_free()
	local b = vim.b

	if not b._df then
		b._df = {
			number = vim.wo.number,
			relativenumber = vim.wo.relativenumber,
			signcolumn = vim.wo.signcolumn,
			showmode = vim.o.showmode,
			laststatus = vim.o.laststatus,
			cmdheight = vim.o.cmdheight,
		}

		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.wo.signcolumn = "no"
		vim.o.showmode = false
		vim.o.laststatus = 0
		vim.o.cmdheight = 0
		vim.cmd("setlocal scrolloff=999")
	else
		vim.wo.number = b._df.number
		vim.wo.relativenumber = b._df.relativenumber
		vim.wo.signcolumn = b._df.signcolumn
		vim.o.showmode = b._df.showmode
		vim.o.laststatus = b._df.laststatus
		vim.o.cmdheight = b._df.cmdheight
		vim.cmd("setlocal scrolloff&")
		b._df = nil
	end
end

function M.setup()
	vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
		vim.b.format_on_save = not (vim.b.format_on_save ~= false)
		vim.notify("Format on save: " .. (vim.b.format_on_save and "ON" or "OFF"), vim.log.levels.INFO)
	end, {})

	vim.api.nvim_create_user_command("ToggleBuildOnSave", function()
		local enabled = vim.b.build_on_save ~= false
		vim.b.build_on_save = not enabled
		vim.notify("Build on save: " .. (vim.b.build_on_save and "ON" or "OFF"), vim.log.levels.INFO)
	end, {})

	vim.api.nvim_create_user_command("ToggleDistractionFree", toggle_distraction_free, {})

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
