-- ~/.config/nvim/after/ftplugin/python.lua

-- Buffer-local options
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4

vim.opt_local.textwidth = 88 -- Black default
vim.opt_local.colorcolumn = "89" -- optional; delete if you dislike

-- Don't auto-wrap code while typing (manual gq is still available)
vim.opt_local.formatoptions:remove({ "t", "c", "r", "o" })


-- --------------
-- Format on save
-- --------------
-- Formatting is handled globally in lua/core/autocmds.lua.
-- For Python, enable by default; disable per-buffer with:
--   :lua vim.b.format_on_save = false
if vim.b.format_on_save == nil then
	vim.b.format_on_save = true
end

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

-- in after/ftplugin/<ft>.lua
local map = function(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc })
end

map("<localleader>b", "<cmd>Build<cr>", "Build")
map("<localleader>r", "<cmd>Run<cr>", "Run")
map("<localleader>o", "<cmd>Open<cr>", "Open")
-- map("<localleader>c", "<cmd>Clean<cr>", "Clean") -- optional
