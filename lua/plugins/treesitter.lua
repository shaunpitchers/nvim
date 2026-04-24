return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master", -- IMPORTANT for older Neovim
		lazy = false, -- load immediately so commands exist
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"query",
					"gitcommit",
					"regex",
					"diff",
					"dockerfile",
					"make",

					"c",
					"cpp",

					"python",

					"markdown",
					"markdown_inline",

					"latex",
					"bibtex",

					"bash",
					"json",
					"yaml",
					"toml",
					"html",
					"css",
				},
				auto_install = true, -- installs missing parsers when you open a filetype
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				sync_install = false,
			})
		end,
	},

	{
		"HiPhish/rainbow-delimiters.nvim",
		lazy = false, -- load immediately (simplest + reliable)
		init = function()
			-- Minimal config; plugin uses these capture groups
			vim.g.rainbow_delimiters = {
				highlight = {
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
				},
			}
		end,
	},
}
