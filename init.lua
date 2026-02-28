vim.g.mapleader = " "
vim.g.maplocalleader = ","

pcall(function()
  if vim.loader and vim.loader.enable then
    vim.loader.enable()
  end
end)

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
safe_require("core.commands")

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
	-- { import = "plugins.telescope" },
	{ import = "plugins.lsp" },
	{ import = "plugins.cmp" },
	-- IDE enhancements
	{ import = "plugins.treesitter" },

	-- Editor enhancements
	{ import = "plugins.editor" },
	{ import = "plugins.git" },

	-- Which-key, keybindings enhancements
	-- { import = "plugins.which-key" },
}, {
	performance = {
		rtp = {
			disabled_plugins = {
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
				"gzip",
				"getscript",
				"getscriptPlugin",
				"logipat",
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
pcall(vim.cmd.colorscheme, "industry")

-- Load keymaps after plugins
vim.defer_fn(function()
	safe_require("core.mappings")
end, 0)

-- Configure Python path
vim.g.python3_host_prog = vim.fn.exepath("python3") or vim.fn.exepath("python")

-- Optional LSP attach notifications (disable by default for less noise)
vim.g.lsp_attach_notify = vim.g.lsp_attach_notify or false
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		if not vim.g.lsp_attach_notify then
			return
		end
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client then
			vim.notify(string.format("LSP: %s attached", client.name), vim.log.levels.INFO)
		end
	end,
})
