-- ~/.config/nvim/lua/core/commands/help.lua
-- Mapping help commands, kept small as a which-key alternative.

local M = {}

local function open_map_help(title, lines)
	vim.cmd("new")
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false
	vim.bo.modifiable = true
	vim.api.nvim_buf_set_name(0, title)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.bo.modifiable = false
	vim.bo.filetype = "help"
	vim.wo.wrap = false
end

local function collect_maps(leader, maps)
	local by_lhs = {}
	for _, m in ipairs(maps) do
		if m.lhs and m.lhs:sub(1, #leader) == leader then
			local rhs = m.desc or m.rhs or ""
			by_lhs[m.lhs] = string.format("%-14s %s", m.lhs, rhs)
		end
	end

	local out = vim.tbl_values(by_lhs)
	table.sort(out)
	if #out == 0 then
		out = { "No mappings found." }
	end
	return out
end

function M.setup()
	vim.api.nvim_create_user_command("Leader", function()
		local leader = vim.g.mapleader or "\\"
		local maps = vim.api.nvim_get_keymap("n")
		vim.list_extend(maps, vim.api.nvim_buf_get_keymap(0, "n"))
		open_map_help("Leader mappings", collect_maps(leader, maps))
	end, {})

	vim.api.nvim_create_user_command("LocalLeader", function()
		local leader = vim.g.maplocalleader or ","
		local maps = vim.api.nvim_buf_get_keymap(0, "n")
		open_map_help("LocalLeader mappings", collect_maps(leader, maps))
	end, {})
end

return M
