return {
	-- Git commands
	{
		"tpope/vim-fugitive",
		cmd = { "G", "Git", "Gstatus", "Gcommit", "Gpush", "Gpull", "Gdiffsplit", "Gread", "Gwrite" },
		init = function()
			vim.api.nvim_create_user_command("GitSync", function()
				vim.cmd("G pull --rebase")
				vim.cmd("G push")
			end, {})
		end,
	},
}
