local M = {}

function M.check_lsp()
  local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
  
  if #buf_clients == 0 then
    vim.notify("No LSP client attached", vim.log.levels.WARN)
    return
  end

  local messages = {"Active LSP clients:"}
  for _, client in ipairs(buf_clients) do
    table.insert(messages, string.format(
      "• %s (id=%d)\n  Filetypes: %s\n  Root: %s",
      client.name,
      client.id,
      client.config.filetypes and table.concat(client.config.filetypes, ", ") or "none",
      client.config.root_dir or "none"
    ))
  end

  vim.notify(table.concat(messages, "\n\n"), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("LspStatus", M.check_lsp, {})

return M