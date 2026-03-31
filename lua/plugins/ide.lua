return {

	{ "junegunn/fzf" },
	{
		"junegunn/fzf.vim",
		dependencies = { "junegunn/fzf" },
	},
	-- Function signatures
	-- {
	-- 	"ray-x/lsp_signature.nvim",
	-- 	event = "LspAttach",
	-- 	config = function()
	-- 		require("lsp_signature").setup({
	-- 			bind = true,
	-- 			hint_enable = false,
	-- 			floating_window = true,
	-- 			handler_opts = { border = "rounded" },
	-- 		})
	-- 	end,
	-- },
}
