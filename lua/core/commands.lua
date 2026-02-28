-- ~/.config/nvim/lua/core/commands.lua
-- User commands for building / running / opening without extra plugins.

local U = require("utils")
local B = require("core.build")

local function term(cmd, cwd)
  local full = cmd
  if cwd then
    full = "cd " .. vim.fn.shellescape(cwd) .. " && " .. cmd
  end
  vim.cmd("split | terminal " .. full)
end

vim.api.nvim_create_user_command("Run", function()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local root = U.root(B.ROOT_MARKERS)

  local function sh(cmd)
    term(cmd, nil)
  end

  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end

  -- Project-aware runners where it matters.
  if ft == "rust" then
    term("cargo run", root)
    return
  elseif ft == "go" then
    term("go run .", root)
    return
  end

  -- File runners.
  local cmd_by_ft = {
    python = "python3 " .. vim.fn.shellescape(file),
    lua = "lua " .. vim.fn.shellescape(file),
    sh = (vim.fn.executable(file) == 1 and vim.fn.shellescape(file) or ("bash " .. vim.fn.shellescape(file))),
    bash = (vim.fn.executable(file) == 1 and vim.fn.shellescape(file) or ("bash " .. vim.fn.shellescape(file))),
    zsh = (vim.fn.executable(file) == 1 and vim.fn.shellescape(file) or ("zsh " .. vim.fn.shellescape(file))),
    javascript = "node " .. vim.fn.shellescape(file),
    typescript = "node " .. vim.fn.shellescape(file),
  }

  if ft == "c" or ft == "cpp" then
    -- Minimal, predictable: run current file by compiling to <name>.out, then executing it.
    local out = vim.fn.expand("%:p:r") .. ".out"
    local compile
    if ft == "c" then
      compile = "gcc " .. vim.fn.shellescape(file) .. " -O2 -Wall -Wextra -std=c11 -o " .. vim.fn.shellescape(out)
    else
      compile = "g++ " .. vim.fn.shellescape(file) .. " -O2 -Wall -Wextra -std=c++20 -o " .. vim.fn.shellescape(out)
    end
    sh("cd " .. vim.fn.shellescape(dir) .. " && " .. compile .. " && " .. vim.fn.shellescape(out))
    return
  end

  local cmd = cmd_by_ft[ft]
  if not cmd then
    vim.notify("No :Run command for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  term(cmd, nil)
end, {})

vim.api.nvim_create_user_command("Build", function(opts)
  local spec, err = B.build_spec({ arg = opts.args })
  if not spec then
    vim.notify(err or "No :Build rule", vim.log.levels.WARN)
    return
  end

  U.job(spec.cmd, { cwd = spec.cwd, title = spec.title, success = "Build OK" })
end, { nargs = "?" })

vim.api.nvim_create_user_command("Clean", function()
  local spec, err = B.clean_spec()
  if not spec then
    vim.notify(err or "No :Clean rule", vim.log.levels.WARN)
    return
  end
  U.job(spec.cmd, { cwd = spec.cwd, title = spec.title, success = "Clean OK" })
end, {})

vim.api.nvim_create_user_command("Open", function(opts)
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")

  -- If the user provides a path, open that directly (supports % and ~ expansions).
  local target = (opts.args ~= "" and vim.fn.expand(opts.args)) or nil

  -- Default "artifact" per filetype
  if not target then
    if ft == "tex" then
      target = vim.fn.expand("%:p:r") .. ".pdf"
    elseif ft == "markdown" then
      -- Default to PDF; use :Open %:r.html for HTML
      target = vim.fn.expand("%:p:r") .. ".pdf"
    else
      target = file
    end
  end

  local function has(exe)
    return vim.fn.executable(exe) == 1
  end

  -- Prefer zathura for PDFs (common on Linux); otherwise fall back to xdg-open.
  if target:sub(-4) == ".pdf" and has("zathura") then
    U.st("zathura " .. vim.fn.shellescape(target))
    return
  end

  if has("xdg-open") then
    U.st("xdg-open " .. vim.fn.shellescape(target))
    return
  end

  vim.notify("No opener found (install zathura or xdg-open)", vim.log.levels.WARN)
end, { nargs = "?" })

vim.keymap.set("n", "<leader>xr", "<cmd>Run<CR>", { desc = "Execute: run", nowait = true })
vim.keymap.set("n", "<leader>xb", "<cmd>Build<CR>", { desc = "Execute: build", nowait = true })
vim.keymap.set("n", "<leader>xo", "<cmd>Open<CR>", { desc = "Execute: open", nowait = true })
