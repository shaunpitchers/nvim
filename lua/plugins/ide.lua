return {
	{ "junegunn/fzf", lazy = true },
	{
		"junegunn/fzf.vim",
		cmd = { "Files", "Rg", "Buffers", "Lines", "BLines", "Commits", "History", "Maps" },
		dependencies = { "junegunn/fzf" },
	},
}
