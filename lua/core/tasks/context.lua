-- ~/.config/nvim/lua/core/tasks/context.lua
-- Shared project and filetype helpers for build/test/clean tasks.

local U = require("core.utils")

local M = {}

M.ROOT_MARKERS = {
	".git",
	"Makefile",
	"justfile",
	"Justfile",
	".justfile",
	"CMakeLists.txt",
	"compile_commands.json",
	"pyproject.toml",
	"package.json",
	"go.mod",
	"Cargo.toml",
}

function M.has(exe)
	return vim.fn.executable(exe) == 1
end

function M.ctx()
	local ft = vim.bo.filetype
	local file = vim.fn.expand("%:p")
	local dir = vim.fn.expand("%:p:h")
	local root = U.root(M.ROOT_MARKERS) or dir
	return { ft = ft, file = file, dir = dir, root = root }
end

function M.is_file(path)
	return vim.fn.filereadable(path) == 1
end

function M.is_dir(path)
	return vim.fn.isdirectory(path) == 1
end

function M.cmake_build_dir(root)
	local b = root .. "/build"
	if M.is_dir(b) then
		return b
	end

	local b2 = root .. "/builddir"
	if M.is_dir(b2) then
		return b2
	end

	return b
end

function M.is_cmake_project(root)
	return M.is_file(root .. "/CMakeLists.txt")
end

function M.is_make_project(root)
	return M.is_file(root .. "/Makefile") or M.is_file(root .. "/makefile")
end

function M.is_just_project(root)
	return M.is_file(root .. "/justfile") or M.is_file(root .. "/Justfile") or M.is_file(root .. "/.justfile")
end

function M.just_has_recipe(root, recipe)
	if not (M.has("just") and M.is_just_project(root) and vim.system) then
		return false
	end

	local ok, obj = pcall(vim.system, { "just", "--summary" }, { cwd = root, text = true })
	if not (ok and obj) then
		return false
	end

	local result = obj:wait()
	if not result or result.code ~= 0 then
		return false
	end

	for item in (result.stdout or ""):gmatch("%S+") do
		if item == recipe then
			return true
		end
	end

	return false
end

function M.just_spec(root, recipe)
	if M.just_has_recipe(root, recipe) then
		return { cmd = { "just", recipe }, cwd = root, artifact = nil, title = "just " .. recipe }
	end

	return nil
end

return M
