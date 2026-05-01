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
autocmd({ "FocusGained", "BufEnter" }, {
	group = "auto_reload",
	command = "checktime",
})

-- Restore the last cursor position when reopening files
augroup("restore_cursor", { clear = true })
autocmd("BufReadPost", {
	group = "restore_cursor",
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Trim trailing whitespace for code/config buffers, but leave prose alone.
local trim_skip_ft = {
	markdown = true,
	tex = true,
	plaintex = true,
	text = true,
	mail = true,
	gitcommit = true,
	rst = true,
	asciidoc = true,
	org = true,
}

augroup("trim_code_whitespace", { clear = true })
autocmd("BufWritePre", {
	group = "trim_code_whitespace",
	callback = function(args)
		local bo = vim.bo[args.buf]
		if bo.buftype ~= "" or not bo.modifiable or bo.readonly or trim_skip_ft[bo.filetype] then
			return
		end

		local view = vim.fn.winsaveview()
		vim.api.nvim_buf_call(args.buf, function()
			vim.cmd([[%s/\s\+$//e]])
		end)
		pcall(vim.fn.winrestview, view)
	end,
})

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
			vim.opt_local.textwidth = 88
			vim.opt_local.wrap = true
			vim.opt_local.linebreak = true
			vim.opt_local.showbreak = "↳ "
			vim.opt_local.breakindent = true
			vim.opt_local.formatoptions:append({ "t" }) -- auto wrap while typing
			-- vim.opt.thesaurus = ".config/nvim/thesaurus/mthesaur.txt"
			vim.opt_local.thesaurus = vim.fn.expand("~/.config/nvim/thesaurus/mthesaur.txt")
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
		if client:supports_method("textDocument/documentHighlight") then
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
		if not client:supports_method("textDocument/formatting") then
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
				if vim.b[bufnr].format_on_save == false then
					return
				end
				vim.lsp.buf.format({ bufnr = bufnr, async = false })
			end,
		})
	end,
})
