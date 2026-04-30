-- ~/.config/nvim/lua/core/tasks/init.lua
-- Public task API used by commands and ftplugins.

local U = require("core.utils")
local Context = require("core.tasks.context")
local Build = require("core.tasks.build")
local Clean = require("core.tasks.clean")
local Test = require("core.tasks.test")

local M = {
	ROOT_MARKERS = Context.ROOT_MARKERS,
}

M.build_spec = Build.spec
M.clean_spec = Clean.spec
M.test_spec = Test.spec

function M.just_spec(recipe)
	local c = Context.ctx()
	return Context.just_spec(c.root, recipe)
end

-- A small helper for ftplugins that want "build on save" with a lock.
function M.build_current_job(opts)
	opts = opts or {}
	local spec, err = M.build_spec({ arg = opts.arg })
	if not spec then
		if err then
			vim.notify(err, vim.log.levels.WARN)
		end
		return
	end

	U.job(spec.cmd, {
		cwd = spec.cwd,
		title = spec.title or (type(spec.cmd) == "table" and table.concat(spec.cmd, " ") or tostring(spec.cmd)),
		success = opts.success or "Build OK",
		failure = opts.failure or "Build FAILED (see :messages)",
		on_exit = opts.on_exit,
	})
end

return M
