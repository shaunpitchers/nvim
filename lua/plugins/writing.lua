return {
	{
		"Ron89/thesaurus_query.vim",
		ft = { "text", "markdown", "tex", "mail", "gitcommit" }, -- only load for writing buffers
		init = function()
			-- Prefer local backends (fast, offline). You can add online later.
			vim.g.tq_enabled_backends = { "openoffice_en", "mthesaur_txt" }
			vim.g.tq_mthesaur_file = vim.fn.expand("~/.config/nvim/thesaurus/mthesaur.txt")
			vim.g.tq_enabled_backends = { "mthesaur_txt" }
			vim.g.tq_openoffice_en_file = vim.fn.expand("~/.config/nvim/thesaurus/mythes/th_en_US_new")
			vim.g.tq_truncation_on_definition_num = 3
			vim.g.tq_truncation_on_syno_list_size = 40

			-- If you later want online fallback, you can do:
			-- vim.g.tq_enabled_backends = { "thesaurus_com", "mthesaur_txt" }
			-- vim.g.tq_online_backends_timeout = 0.6
		end,
		config = function()
			-- Keymaps: pick something you like
			-- Replace current word with chosen synonym
			vim.keymap.set(
				"n",
				"<leader>tt",
				"<cmd>ThesaurusQueryReplaceCurrentWord<CR>",
				{ desc = "Thesaurus: replace word" }
			)
			-- Query synonyms (without replacing)
		end,
	},

	-- Word count
	{
		"vimpostor/vim-tpipeline", -- Works with tmux
		ft = { "markdown", "text", "latex" },
		config = function()
			vim.g.tpipeline_wordcount = 1
			vim.g.tpipeline_autoembed = 0
		end,
	},
}
