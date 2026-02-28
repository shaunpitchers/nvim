return {
	-- {
	-- "lewis6991/gitsigns.nvim",
	-- event = { "BufReadPre", "BufNewFile" },
	-- opts = {
	-- 	signs = {
	-- 		add = { text = "▎" },
	-- 		change = { text = "▎" },
	-- 		delete = { text = "" },
	-- 		topdelete = { text = "" },
	-- 		changedelete = { text = "▎" },
	-- 		untracked = { text = "▎" },
	-- 	},
	-- 	on_attach = function(buffer)
	-- 		local gs = package.loaded.gitsigns

	-- 		local function map(mode, l, r, desc)
	-- 			vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
	-- 		end

	-- 		-- Navigation
	-- 		map("n", "]h", gs.next_hunk, "Next Hunk")
	-- 		map("n", "[h", gs.prev_hunk, "Prev Hunk")

	-- 		-- Actions
	-- 		map("n", "<leader>gh", gs.preview_hunk, "Preview Hunk")
	-- 		map("n", "<leader>gb", function()
	-- 			gs.blame_line({ full = true })
	-- 		end, "Blame Line")
	-- 		map("n", "<leader>gd", gs.diffthis, "Diff This")
	-- 		map("n", "<leader>gD", function()
	-- 			gs.diffthis("~")
	-- 		end, "Diff This ~")
	-- 		map("n", "<leader>gt", gs.toggle_deleted, "Toggle Deleted")
	-- 	end,
	-- },
	-- },

	-- Git commands
	{
		"tpope/vim-fugitive",
		cmd = { "G", "Git", "Gstatus", "Gcommit", "Gpush", "Gpull" },
		init = function()
			vim.api.nvim_create_user_command("GitSync", function()
				vim.cmd("G pull --rebase")
				vim.cmd("G push")
			end, {})
		end,
	},
}
