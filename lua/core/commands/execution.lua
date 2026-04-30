-- ~/.config/nvim/lua/core/commands/execution.lua
-- Build, run, test, clean, and artifact-opening commands.

local U = require("core.utils")
local Tasks = require("core.build")

local M = {}

local function term(cmd, cwd)
	local full = cmd
	if cwd then
		full = "cd " .. vim.fn.shellescape(cwd) .. " && " .. cmd
	end
	vim.cmd("split | terminal " .. full)
end

local function run_current()
	local ft = vim.bo.filetype
	local file = vim.fn.expand("%:p")
	local dir = vim.fn.expand("%:p:h")
	local root = U.root(Tasks.ROOT_MARKERS)

	local function sh(cmd)
		term(cmd, nil)
	end

	if file == "" then
		vim.notify("No file to run", vim.log.levels.WARN)
		return
	end

	if ft == "rust" then
		term("cargo run", root)
		return
	elseif ft == "go" then
		term("go run .", root)
		return
	end

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
		local out = vim.fn.expand("%:p:r") .. ".out"
		local compile
		if ft == "c" then
			compile = "gcc " .. vim.fn.shellescape(file) .. " -O2 -Wall -Wextra -std=c11 -o " .. vim.fn.shellescape(out)
		else
			compile = "g++ "
				.. vim.fn.shellescape(file)
				.. " -O2 -Wall -Wextra -std=c++20 -o "
				.. vim.fn.shellescape(out)
		end
		sh("cd " .. vim.fn.shellescape(dir) .. " && " .. compile .. " && " .. vim.fn.shellescape(out))
		return
	end

	local cmd = cmd_by_ft[ft]
	if not cmd then
		local spec = Tasks.just_spec("run")
		if spec then
			term("just run", spec.cwd)
			return
		end
		vim.notify("No :Run command for filetype: " .. ft, vim.log.levels.WARN)
		return
	end

	term(cmd, nil)
end

local function open_artifact(opts)
	local ft = vim.bo.filetype
	local file = vim.fn.expand("%:p")
	local target = (opts.args ~= "" and vim.fn.expand(opts.args)) or nil

	if not target then
		if ft == "tex" or ft == "markdown" then
			target = vim.fn.expand("%:p:r") .. ".pdf"
		else
			target = file
		end
	end

	local function has(exe)
		return vim.fn.executable(exe) == 1
	end

	if target:sub(-4) == ".pdf" and has("zathura") then
		U.st("zathura " .. vim.fn.shellescape(target))
		return
	end

	if has("xdg-open") then
		U.st("xdg-open " .. vim.fn.shellescape(target))
		return
	end

	vim.notify("No opener found (install zathura or xdg-open)", vim.log.levels.WARN)
end

function M.setup()
	vim.api.nvim_create_user_command("Run", run_current, {})

	vim.api.nvim_create_user_command("Build", function(opts)
		local spec, err = Tasks.build_spec({ arg = opts.args })
		if not spec then
			vim.notify(err or "No :Build rule", vim.log.levels.WARN)
			return
		end

		U.job(spec.cmd, { cwd = spec.cwd, title = spec.title, success = "Build OK" })
	end, { nargs = "?" })

	vim.api.nvim_create_user_command("Clean", function()
		local spec, err = Tasks.clean_spec()
		if not spec then
			vim.notify(err or "No :Clean rule", vim.log.levels.WARN)
			return
		end
		U.job(spec.cmd, { cwd = spec.cwd, title = spec.title, success = "Clean OK" })
	end, {})

	vim.api.nvim_create_user_command("Test", function(opts)
		local spec, err = Tasks.test_spec({ arg = opts.args })
		if not spec then
			vim.notify(err or "No :Test rule", vim.log.levels.WARN)
			return
		end
		U.job(spec.cmd, {
			cwd = spec.cwd,
			title = spec.title,
			ok_exit_codes = spec.ok_exit_codes,
			success = nil,
			on_exit = function(code, _)
				if code == 0 then
					vim.notify("Test OK", vim.log.levels.INFO, { title = spec.title })
				elseif code == 5 and spec.title and spec.title:match("pytest") then
					vim.notify("No tests collected", vim.log.levels.WARN, { title = spec.title })
				end
			end,
		})
	end, { nargs = "?" })

	vim.api.nvim_create_user_command("Open", open_artifact, { nargs = "?" })
end

return M
