vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true
-- Set encoding to UTF-8
vim.opt.encoding = "utf-8"

-- Enable airline powerline fonts
vim.g.airline_powerline_fonts = 1

-- Bracket matching
vim.opt.showmatch = true
vim.opt.matchtime = 1
vim.cmd("runtime plugin/matchparen.vim")

-- UI Options (aim for a classic Vim look)
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = false
vim.opt.signcolumn = "yes"
vim.opt.showmode = true
vim.opt.title = true
vim.opt.termguicolors = true
vim.opt.pumheight = 15
vim.opt.showtabline = 1
vim.opt.showmatch = true
vim.opt.matchtime = 5 -- tenths of a second; tweak to taste

-- Better splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Editing Behavior
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.spelllang = "en_us"
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.breakindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Performance
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.ttimeoutlen = 10

-- Scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- Diffing
vim.opt.diffopt:append("linematch:60")

-- Diagnostics
vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		spacing = 4,
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
	},
})

-- netrw: behave like a left-side file tree
vim.g.netrw_banner = 0 -- no help banner
vim.g.netrw_liststyle = 3 -- tree view
vim.g.netrw_browse_split = 4 -- open in a vertical split
vim.g.netrw_winsize = 25 -- width in percent
vim.g.netrw_altv = 1 -- split to the LEFT
vim.g.netrw_keepdir = 0 -- follow directory changes
vim.g.netrw_localrmdir = "rm -r"
vim.g.netrw_dirhistmax = 0 -- no directory history clutter

-- Define diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Classic statusline behaviour
vim.opt.winbar = ""
vim.opt.laststatus = 2
vim.opt.ruler = true

vim.cmd([[
  highlight SpellBad   cterm=reverse,bold gui=reverse,bold
  highlight SpellCap   cterm=reverse     gui=reverse
  highlight SpellRare  cterm=reverse     gui=reverse
  highlight SpellLocal cterm=reverse     gui=reverse
]])
