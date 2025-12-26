return {

	-- Zenmode (keep, but don't change global UI permanently)

	{
		"folke/zen-mode.nvim",
		dependencies = { "folke/twilight.nvim" },
		config = function()
			require("zen-mode").setup({
				window = {
					backdrop = 1, -- Full opacity (you can make it slightly dim if you prefer)
					width = 80, -- Ideal for writing
					options = {
						signcolumn = "no",
						number = false,
						relativenumber = false,
						cursorline = false,
					},
				},
				plugins = {
					twilight = { enabled = true }, -- This enables Twilight automatically!
					gitsigns = { enabled = true },
					tmux = { enabled = false },
				},
				on_open = function()
					pcall(vim.cmd, "IBLDisable") -- indent-blankline (optional)
					vim.g._zen_laststatus = vim.o.laststatus
					vim.o.laststatus = 0
				end,
				on_close = function()
					pcall(vim.cmd, "IBLEnable")
					vim.o.laststatus = vim.g._zen_laststatus or 2
				end,
			})
		end,
	},

}
