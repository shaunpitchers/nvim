local M = {}

function M.check()
  local issues = {}

  -- Check Python
  if vim.fn.executable("python") == 0 then
    table.insert(issues, "Python not found in PATH")
  end

  -- Check Black formatter
  if vim.fn.executable("black") == 0 then
    table.insert(issues, "Black formatter not installed (pip install black)")
  end

  -- Check Ruff
  if vim.fn.executable("ruff") == 0 then
    table.insert(issues, "Ruff not installed (pip install ruff)")
  end

  -- Check Node.js (for LSP servers)
  if vim.fn.executable("node") == 0 then
    table.insert(issues, "Node.js not installed (required for many LSP servers)")
  end

  -- Check Git
  if vim.fn.executable("git") == 0 then
    table.insert(issues, "Git not installed (required for many plugins)")
  end

  if #issues > 0 then
    vim.notify("Health check issues:\n" .. table.concat(issues, "\n"), vim.log.levels.WARN)
  else
    vim.notify("All dependencies are installed correctly!", vim.log.levels.INFO)
  end
end

vim.api.nvim_create_user_command("CheckDeps", M.check, {})

return M