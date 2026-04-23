-- ~/.config/nvim/lua/core/options.lua
-- Core editor options. Keep this file boring and predictable.

-- Basic
vim.g.have_nerd_font = true
vim.opt.encoding = "utf-8"

-- Bracket matching (built-in)
vim.opt.showmatch = true
vim.opt.matchtime = 1
vim.cmd("runtime plugin/matchparen.vim")

-- UI (classic Vim-ish)
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = false
vim.opt.signcolumn = "yes"
vim.opt.showmode = true
vim.opt.title = true
vim.opt.termguicolors = true
vim.opt.pumheight = 15
vim.opt.showtabline = 1

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Editing
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.opt.shortmess:append("c") -- don't show completion messages

-- backups
vim.opt.backup = true
vim.opt.writebackup = true
vim.opt.backupdir = vim.fn.stdpath("state") .. "/backup//"

-- undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo//"

-- swap
vim.opt.swapfile = true

-- safe copy behavior
vim.opt.backupcopy = "auto"
vim.opt.backupext = "~"

-- Indentation (defaults; filetype plugins may override)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.opt.showbreak = "↳ "

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Performance / responsiveness
vim.opt.updatetime = 250
vim.opt.timeout = true
vim.opt.timeoutlen = 800
vim.opt.ttimeoutlen = 10

-- Scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Folding (Tree-sitter if available)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- Diffing
vim.opt.diffopt:append("linematch:60")

-- Spell defaults (writing filetypes enable spell via autocmds.lua)
vim.opt.spelllang = "en_gb"

-- Diagnostics (keep it readable: no inline virtual_text)
vim.diagnostic.config({
	virtual_text = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "always" },
})

-- netrw: behave like a left-side file tree (plugin-free "explorer")
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 25
vim.g.netrw_altv = 1
vim.g.netrw_keepdir = 0
vim.g.netrw_localrmdir = "rm -r"
vim.g.netrw_dirhistmax = 0

-- commandline completion
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest:full", "full" }
vim.opt.wildignorecase = true
vim.opt.path:append("**") -- enables recursive :find
vim.opt.suffixesadd:append({ ".lua", ".py", ".c", ".cpp", ".h", ".hpp", ".tex", ".md" })

-- grep Search
vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"

-- Statusline behaviour (default-ish)
vim.opt.winbar = ""
vim.opt.laststatus = 2
vim.opt.ruler = true
