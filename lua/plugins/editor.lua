return {
	-- Auto pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	-- cs"' / ds" / ys{motion}" etc. (built-in gc covers commenting on 0.10+)
	{ "tpope/vim-surround", event = "BufReadPost" },

	-- auto-detect indent settings
	{
		"tpope/vim-sleuth",
		event = "BufReadPost",
	},
}
