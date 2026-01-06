-- ~/.config/nvim/after/ftplugin/tex.lua
-- LaTeX: latexmk build on save (no overlap) + writing settings

-- Writing-friendly settings
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_gb"
vim.opt_local.textwidth = 80
vim.opt_local.formatoptions:append({ "t" })
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true

-- Build lock (buffer-local)
if vim.b.latex_build_running == nil then
	vim.b.latex_build_running = false
end

local group = vim.api.nvim_create_augroup("LatexBuildOnSave", { clear = false })

local function latex_build()
	if vim.b.latex_build_running then
		return
	end

	local file = vim.fn.expand("%:p")
	if file == "" then
		return
	end

	vim.b.latex_build_running = true
	local dir = vim.fn.expand("%:p:h")

	vim.fn.jobstart({
		"latexmk",
		"-pdf",
		"-quiet",
		"-bibtex",
		"-pdflatex=pdflatex -interaction=nonstopmode -synctex=1 -file-line-error",
		"-f",
		file,
	}, {
		cwd = dir,
		stdout_buffered = true,
		stderr_buffered = true,

		-- Always release the lock
		on_exit = function(_, code)
			vim.b.latex_build_running = false
			if code == 0 then
				vim.notify("LaTeX: build OK", vim.log.levels.INFO)
			else
				vim.notify("LaTeX: build FAILED (see :messages)", vim.log.levels.ERROR)
			end
		end,
	})
end

-- Important: make autocmd buffer-local so it doesn't duplicate
vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	buffer = 0,
	callback = latex_build,
})
