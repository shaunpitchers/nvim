-- ~/.config/nvim/lua/utils.lua
-- Small helper functions to keep the rest of the config simple.
-- Everything here is plugin-free on purpose.

local M = {}

---Create (or reuse) an augroup by name.
---@param name string
---@param clear boolean?
---@return integer
function M.augroup(name, clear)
	return vim.api.nvim_create_augroup("user_" .. name, { clear = clear ~= false })
end

---Run a command in a detached st terminal.
---Uses `sh -lc` so you can pass shell pipelines safely.
---@param cmd string
function M.st(cmd)
	vim.fn.jobstart({ "st", "-e", "sh", "-lc", cmd }, { detach = true })
end

---Find a project root by walking up for marker files/dirs.
---Falls back to the current file's directory.
---@param markers string[]
---@param startpath string?
---@return string
function M.root(markers, startpath)
	local start = startpath or vim.fn.expand("%:p:h")
	if start == "" then
		return vim.loop.cwd()
	end

	local found = vim.fs.find(markers, { upward = true, path = start })[1]
	if found then
		return vim.fs.dirname(found)
	end
	return start
end

---Start an async job with buffered stdout/stderr and a simple notification.
---
---Notes:
---  - cmd can be a list (preferred) or a shell string.
---  - Some tools use non-zero exit codes for "non-error" states (e.g. pytest exit 5 = no tests collected).
---    Use opts.ok_exit_codes to treat those as success.
---@param cmd string[]|string command + args, or a shell string
---@param opts table? { cwd=string, on_exit=function(code, signal), title=string, success=string, failure=string, ok_exit_codes=integer[] }
function M.job(cmd, opts)
	opts = opts or {}
	if type(cmd) == "string" then
		cmd = { "sh", "-lc", cmd }
	end
	local title = opts.title or table.concat(cmd, " ")
	local ok = {}
	ok[0] = true
	if type(opts.ok_exit_codes) == "table" then
		for _, c in ipairs(opts.ok_exit_codes) do
			ok[c] = true
		end
	end
	return vim.fn.jobstart(cmd, {
		cwd = opts.cwd,
		stdout_buffered = true,
		stderr_buffered = true,
		on_exit = function(_, code, signal)
			if opts.on_exit then
				pcall(opts.on_exit, code, signal)
			end
			if ok[code] then
				if opts.success then
					vim.notify(opts.success, vim.log.levels.INFO, { title = title })
				end
			else
				vim.notify(opts.failure or ("Failed (exit " .. code .. ")"), vim.log.levels.ERROR, { title = title })
			end
		end,
	})
end

return M
