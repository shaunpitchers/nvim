-- ~/.config/nvim/lua/core/commands/backup.lua
-- User commands for central backup files.

local Backup = require("core.backup")

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("OpenBackup", Backup.open_backup, {})
	vim.api.nvim_create_user_command("DiffBackup", Backup.diff_backup, {})
	vim.api.nvim_create_user_command("BackupPath", Backup.print_backup_path, {})
end

return M
