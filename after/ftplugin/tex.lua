-- Compile LaTeX on save using latexmk (minimal + reliable)

local function latex_build()
  local file = vim.fn.expand("%:p")
  if file == "" then return end

  -- run in file directory so aux/pdf land next to the tex file
  local dir = vim.fn.expand("%:p:h")

  vim.fn.jobstart({
    "latexmk",
    "-pdf",
    "-pdflatex=pdflatex",
    "-bibtex",
    "-interaction=nonstopmode",
    "-synctex=1",
    "-file-line-error",
    "-f",
    file,
  }, {
    cwd = dir,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(_, data)
      if data and #data > 1 then
        vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("LaTeX: build OK", vim.log.levels.INFO)
      else
        vim.notify("LaTeX: build FAILED (see :messages)", vim.log.levels.ERROR)
      end
    end,
  })
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.tex",
  callback = latex_build,
})

vim.opt_local.spell = true
vim.opt_local.spelllang = "en_gb"
vim.opt_local.textwidth = 80
vim.opt_local.formatoptions:append({ "t" })
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
