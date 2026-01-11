-- Error handling wrapper for requires
local function safe_require(name)
	local ok, mod = pcall(require, name)
	if not ok then
		vim.notify(string.format("Error loading %s: %s", name, mod), vim.log.levels.ERROR)
		return nil
	end
	return mod
end

-- Load core configs with error handling
safe_require("core.options")
safe_require("core.autocmds")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins with lazy.nvim
require("lazy").setup({
	-- Core functionality
	{ import = "plugins.telescope" },
	{ import = "plugins.lsp" },
	{ import = "plugins.cmp" },
	-- IDE enhancements
	-- { import = "plugins.ide" },
	{ import = "plugins.treesitter" },

	-- Editor enhancements
	{ import = "plugins.editor" },
	{ import = "plugins.git" },

	-- Which-key, keybindings enhancements
	{ import = "plugins.which-key" },

	-- Writing components
	{ import = "plugins.writing" },
	-- { import = "plugins.zettelkasten" },
}, {
	performance = {
		rtp = {
			disabled_plugins = {
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
})

-- Vim-like defaults: keep the builtin look
pcall(vim.cmd.colorscheme, "vim")

-- Load keymaps after plugins
vim.defer_fn(function()
	safe_require("core.mappings")
end, 0)

-- Configure Python path
vim.g.python3_host_prog = vim.fn.exepath("python3") or vim.fn.exepath("python")

-- LSP notifications
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		vim.notify(string.format("LSP: %s attached", client.name), vim.log.levels.INFO)
	end,
})
