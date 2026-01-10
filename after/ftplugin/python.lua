-- ~/.config/nvim/after/ftplugin/python.lua

-- Buffer-local options
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4

vim.opt_local.textwidth = 88 -- Black default
vim.opt_local.colorcolumn = "89" -- optional; delete if you dislike

-- Don't auto-wrap code while typing (manual gq is still available)
vim.opt_local.formatoptions:remove({ "t", "c", "r", "o" })

-- Enable Tree-sitter folding for Python (if available)
-- Folding is window-local, so use vim.wo / setlocal
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldlevel = 99 -- start unfolded; set 0 if you prefer folded
vim.wo.foldenable = true

-- --------------
-- Format on save
-- --------------
-- Enable by default for Python buffers. If you ever want to disable for a buffer:
-- :lua vim.b.format_on_save = false
if vim.b.format_on_save == nil then
	vim.b.format_on_save = true
end

local group = vim.api.nvim_create_augroup("PythonFormatOnSave", { clear = false })
vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = group,
	buffer = 0,
	callback = function()
		if not vim.b.format_on_save then
			return
		end
		-- Never let formatting errors break editing/startup
		pcall(function()
			vim.lsp.buf.format({ async = false })
		end)
	end,
})

-- ----------------
-- Pytest commands
-- ----------------
local function root_dir()
	local dir = vim.fn.expand("%:p:h")
	local markers = { "pyproject.toml", "pytest.ini", "setup.cfg", ".git" }

	for _ = 1, 25 do
		for _, m in ipairs(markers) do
			if vim.fn.filereadable(dir .. "/" .. m) == 1 or vim.fn.isdirectory(dir .. "/" .. m) == 1 then
				return dir
			end
		end
		local parent = vim.fn.fnamemodify(dir, ":h")
		if parent == dir then
			break
		end
		dir = parent
	end

	return vim.fn.expand("%:p:h")
end

local function run_pytest(args)
	vim.fn.jobstart(vim.list_extend({ "pytest" }, args), {
		cwd = root_dir(),
		stdout_buffered = true,
		stderr_buffered = true,
		on_exit = function(_, code)
			if code == 0 then
				vim.notify("Pytest: OK", vim.log.levels.INFO)
			else
				vim.notify("Pytest: FAILED", vim.log.levels.ERROR)
			end
		end,
	})
end

vim.api.nvim_buf_create_user_command(0, "Pytest", function(opts)
	local args = {}
	if opts.args ~= "" then
		for a in opts.args:gmatch("%S+") do
			table.insert(args, a)
		end
	else
		args = { "-q" }
	end
	run_pytest(args)
end, { nargs = "*" })

vim.api.nvim_buf_create_user_command(0, "PytestFile", function(opts)
	local file = vim.fn.expand("%")
	local args = { "-q", file }
	if opts.args ~= "" then
		for a in opts.args:gmatch("%S+") do
			table.insert(args, a)
		end
	end
	run_pytest(args)
end, { nargs = "*" })

-- Minimal MatchIt words for Python (for % to jump between blocks)
-- Requires matchit.vim loaded (Neovim usually has it available)
vim.cmd("runtime! macros/matchit.vim")

-- b:match_words in Vimscript becomes vim.b.match_words in Lua
-- This is a simple set; you can extend later.
vim.b.match_words = table.concat({
	"if:elif:else",
	"for:else",
	"while:else",
	"try:except:else:finally",
	"def",
	"class",
}, ",")
