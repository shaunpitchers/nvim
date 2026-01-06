local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup("highlight_yank", { clear = true })
autocmd("TextYankPost", {
	group = "highlight_yank",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

-- Auto-resize splits
augroup("auto_resize", { clear = true })
autocmd("VimResized", {
	group = "auto_resize",
	command = "wincmd =",
})

-- Auto-create dir when saving
augroup("auto_mkdir", { clear = true })
autocmd("BufWritePre", {
	group = "auto_mkdir",
	callback = function(ctx)
		local dir = vim.fn.fnamemodify(ctx.file, ":p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

-- Auto-reload files when changed externally
augroup("auto_reload", { clear = true })
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	group = "auto_reload",
	command = "checktime",
})

-- Filetype specific settings
augroup("filetype_settings", { clear = true })
autocmd("FileType", {
	group = "filetype_settings",
	pattern = { "markdown", "text" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- Python specific settings
augroup("python_settings", { clear = true })
autocmd("FileType", {
	group = "python_settings",
	pattern = "python",
	callback = function()
		vim.opt_local.colorcolumn = "88"
		vim.opt_local.shiftwidth = 4
	end,
})

-- Force .py to be a Python filetype
vim.api.nvim_create_autocmd("BufRead", {
	pattern = "*.py",
	callback = function()
		vim.bo.filetype = "python" -- Override incorrect filetype
	end,
})

---@type rainbow_delimiters.config
vim.g.rainbow_delimiters = {
	strategy = {
		[""] = "rainbow-delimiters.strategy.global",
		vim = "rainbow-delimiters.strategy.local",
	},
	query = {
		[""] = "rainbow-delimiters",
		lua = "rainbow-blocks",
	},
	priority = {
		[""] = 110,
		lua = 210,
	},
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
-- Spell settings: enable for writing buffers, disable for code buffers

vim.api.nvim_create_user_command("Run", function()
	local ft = vim.bo.filetype
	local fname = vim.fn.expand("%")

	local cmd = ({
		python = "python3 " .. fname,
		lua = "lua " .. fname,
		sh = "bash " .. fname,
		c = "gcc " .. fname .. " && ./a.out",
	})[ft]

	if cmd then
		vim.cmd("split | terminal " .. cmd)
	else
		print("No run command for filetype: " .. ft)
	end
end, {})

-- Spell settings: enable for writing buffers, disable for code buffers

local aug = vim.api.nvim_create_augroup("SpellControl", { clear = true })

-- Filetypes where you DO want spell
local spell_ft = {
	"text",
	"markdown",
	"tex",
	"plaintex",
	"mail", -- covers neomutt emails when editor is nvim
	"gitcommit",
	"rst",
	"asciidoc",
	"org",
}

-- Filetypes where you explicitly DO NOT want spell
-- (even if some plugins mis-detect)
local nospell_ft = {
	"lua",
	"python",
	"c",
	"cpp",
	"rust",
	"go",
	"java",
	"kotlin",
	"javascript",
	"typescript",
	"sh",
	"bash",
	"zsh",
	"vim",
	"query",
	"json",
	"yaml",
	"toml",
	"dockerfile",
	"make",
}

vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	callback = function(args)
		local ft = vim.bo[args.buf].filetype

		-- Always disable for code-ish types
		if vim.tbl_contains(nospell_ft, ft) then
			vim.opt_local.spell = false
			return
		end

		-- Enable for writing types
		if vim.tbl_contains(spell_ft, ft) then
			vim.opt_local.spell = true
			vim.opt_local.spelllang = "en_gb"
			vim.opt_local.textwidth = 80
			vim.opt_local.formatoptions:append({ "t" }) -- auto wrap while typing
			vim.opt.thesaurus = ".config/nvim/thesaurus/mthesaur.txt"

			return
		end

		-- Default: leave it off
		vim.opt_local.spell = false
	end,
})

-- Make spell highlights visible (re-applies after any colorscheme)
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		-- Strong and terminal-safe: reverse video
		vim.cmd([[
      highlight SpellBad   cterm=reverse,bold gui=reverse,bold
      highlight SpellCap   cterm=reverse      gui=reverse
      highlight SpellRare  cterm=reverse      gui=reverse
      highlight SpellLocal cterm=reverse      gui=reverse
    ]])
	end,
})

-- Apply once right now too (in case colorscheme already loaded)
vim.cmd([[
  highlight SpellBad   cterm=reverse,bold gui=reverse,bold
  highlight SpellCap   cterm=reverse      gui=reverse
  highlight SpellRare  cterm=reverse      gui=reverse
  highlight SpellLocal cterm=reverse      gui=reverse
]])

--- LSP highlight replaces vim-illuminate
local aug = vim.api.nvim_create_augroup("LspDocumentHighlights", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = aug,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end

		-- Only enable if the server supports it
		if client.supports_method("textDocument/documentHighlight") then
			local bufnr = args.buf

			-- Trigger highlights on hold
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				group = aug,
				buffer = bufnr,
				callback = vim.lsp.buf.document_highlight,
			})

			-- Clear when moving
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				group = aug,
				buffer = bufnr,
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})

-- Format code on save :w
local fmt = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = fmt,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end
		if not client.supports_method("textDocument/formatting") then
			return
		end

		local bufnr = args.buf

		-- Optional: disable for filetypes you don't want autoformat on save
		local ft = vim.bo[bufnr].filetype
		local disable = { "markdown", "tex" }
		if vim.tbl_contains(disable, ft) then
			return
		end

		vim.api.nvim_clear_autocmds({ group = fmt, buffer = bufnr })

		vim.api.nvim_create_autocmd("BufWritePre", {
			group = fmt,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr, async = false })
			end,
		})
	end,
})

-- Minimal distraction-free writing toggle (no ZenMode plugin)
local function toggle_distraction_free()
	local b = vim.b

	if not b._df then
		b._df = {
			number = vim.wo.number,
			relativenumber = vim.wo.relativenumber,
			signcolumn = vim.wo.signcolumn,
			showmode = vim.o.showmode,
			laststatus = vim.o.laststatus,
			cmdheight = vim.o.cmdheight,
		}

		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.wo.signcolumn = "no"
		vim.o.showmode = false
		vim.o.laststatus = 0
		vim.o.cmdheight = 0
		vim.cmd("setlocal scrolloff=999")
	else
		vim.wo.number = b._df.number
		vim.wo.relativenumber = b._df.relativenumber
		vim.wo.signcolumn = b._df.signcolumn
		vim.o.showmode = b._df.showmode
		vim.o.laststatus = b._df.laststatus
		vim.o.cmdheight = b._df.cmdheight
		vim.cmd("setlocal scrolloff&")
		b._df = nil
	end
end

vim.keymap.set("n", "<leader>zz", toggle_distraction_free, { desc = "Toggle distraction-free" })
