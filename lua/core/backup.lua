-- lua/config/backup.lua
local M = {}

local function backup_dir()
	return vim.fn.stdpath("state") .. "/backup"
end

local function current_file()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return nil, "Current buffer has no file name"
	end
	return vim.fn.fnamemodify(name, ":p"), nil
end

local function backup_path_for(file)
	local dir = backup_dir()
	local ext = vim.o.backupext ~= "" and vim.o.backupext or "~"

	-- Neovim encodes path separators when using a central backupdir.
	-- For your setup this is showing up as '%' in the filename.
	local encoded = file:gsub("/", "%%")

	return dir .. "/" .. encoded .. ext
end

local function find_backup_for_current_file()
	local file, err = current_file()
	if not file then
		return nil, err
	end

	-- Avoid trying to resolve backups for files already inside the backup dir.
	local dir = vim.fn.fnamemodify(backup_dir(), ":p")
	local abs = vim.fn.fnamemodify(file, ":p")
	if abs:sub(1, #dir) == dir then
		return nil, "Current file is already inside backupdir"
	end

	local backup = backup_path_for(abs)
	if vim.fn.filereadable(backup) == 1 then
		return backup, nil
	end

	return nil, "No backup file found: " .. backup
end

function M.open_backup()
	local backup, err = find_backup_for_current_file()
	if not backup then
		vim.notify(err, vim.log.levels.WARN)
		return
	end
	vim.cmd("edit " .. vim.fn.fnameescape(backup))
end

function M.diff_backup()
	local backup, err = find_backup_for_current_file()
	if not backup then
		vim.notify(err, vim.log.levels.WARN)
		return
	end
	vim.cmd("vert diffsplit " .. vim.fn.fnameescape(backup))
end

function M.print_backup_path()
	local backup, err = find_backup_for_current_file()
	if not backup then
		vim.notify(err, vim.log.levels.WARN)
		return
	end
	vim.notify(backup, vim.log.levels.INFO)
end

return M
