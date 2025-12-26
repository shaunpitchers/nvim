return {
	-- Auto pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	--test
	{ "tpope/vim-surround" }, -- cs"'< etc.
	{ "tpope/vim-commentary" }, -- gcc / gc{motion}

	-- auto-detect indent settings
	{
		"tpope/vim-sleuth",
		event = "BufReadPost",
	},
}
