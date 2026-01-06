-- ~/.config/nvim/after/ftplugin/markdown.lua
-- Minimal Markdown writing + pandoc build on save + separate open commands

-- Writing defaults
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_gb"
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.textwidth = 80
vim.opt_local.formatoptions:append({ "t" })
vim.opt_local.formatoptions:remove({ "c", "r", "o" })

-- Manual reflow
-- vim.keymap.set("n", "<leader>fw", "gqap", { buffer = true, desc = "Format paragraph (80 cols)" })
-- vim.keymap.set("v", "<leader>fw", "gq",   { buffer = true, desc = "Format selection (80 cols)" })

-- Helper: open command in new st window
local function st(cmd)
	vim.fn.jobstart({ "st", "-e", "sh", "-lc", cmd }, { detach = true })
end

-- Paths
local function md_paths()
	local file = vim.fn.expand("%:p")
	if file == "" then
		return nil
	end
	local dir = vim.fn.expand("%:p:h")
	local base = vim.fn.expand("%:t:r")
	return {
		file = file,
		dir = dir,
		pdf = base .. ".pdf",
		html = base .. ".html",
	}
end

-- Build lock (buffer-local) to avoid overlaps
if vim.b.md_build_running == nil then
	vim.b.md_build_running = false
end

local function md_build_pdf()
	if vim.b.md_build_running then
		return
	end
	local p = md_paths()
	if not p then
		return
	end
	vim.b.md_build_running = true

	vim.fn.jobstart({
		"pandoc",
		p.file,
		"-o",
		p.pdf,
	}, {
		cwd = p.dir,
		stdout_buffered = true,
		stderr_buffered = true,
		on_exit = function(_, code)
			vim.b.md_build_running = false
			if code == 0 then
				vim.notify("Markdown: PDF built", vim.log.levels.INFO)
			else
				vim.notify("Markdown: PDF build FAILED (see :messages)", vim.log.levels.ERROR)
			end
		end,
	})
end

local function md_build_html()
	if vim.b.md_build_running then
		return
	end
	local p = md_paths()
	if not p then
		return
	end
	vim.b.md_build_running = true

	vim.fn.jobstart({
		"pandoc",
		"-s",
		p.file,
		"-o",
		p.html,
	}, {
		cwd = p.dir,
		stdout_buffered = true,
		stderr_buffered = true,
		on_exit = function(_, code)
			vim.b.md_build_running = false
			if code == 0 then
				vim.notify("Markdown: HTML built", vim.log.levels.INFO)
			else
				vim.notify("Markdown: HTML build FAILED (see :messages)", vim.log.levels.ERROR)
			end
		end,
	})
end

local function md_open_pdf()
	local p = md_paths()
	if not p then
		return
	end
	st("cd " .. vim.fn.shellescape(p.dir) .. " && zathura " .. vim.fn.shellescape(p.pdf))
end

local function md_open_html()
	local p = md_paths()
	if not p then
		return
	end
	st("cd " .. vim.fn.shellescape(p.dir) .. " && xdg-open " .. vim.fn.shellescape(p.html) .. " && read _")
end

-- Keymaps: split build and open
vim.keymap.set("n", "<leader>mb", md_build_pdf, { buffer = true, desc = "Markdown: build PDF" })
vim.keymap.set("n", "<leader>mo", md_open_pdf, { buffer = true, desc = "Markdown: open PDF (st)" })
vim.keymap.set("n", "<leader>hb", md_build_html, { buffer = true, desc = "Markdown: build HTML" })
vim.keymap.set("n", "<leader>ho", md_open_html, { buffer = true, desc = "Markdown: open HTML (st)" })

-- Build on save (like your LaTeX workflow)
-- Default: build PDF on save. (Change to md_build_html if you prefer.)
local group = vim.api.nvim_create_augroup("MarkdownBuildOnSave", { clear = false })
vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	buffer = 0,
	callback = md_build_pdf,
})
