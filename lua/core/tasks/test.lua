-- ~/.config/nvim/lua/core/tasks/test.lua
-- Test command selection for :Test.

local C = require("core.tasks.context")

local M = {}

function M.spec(opts)
	opts = opts or {}
	local c = C.ctx()
	local ft, file, dir, root = c.ft, c.file, c.dir, c.root
	local arg = (opts.arg or ""):lower()

	if file == "" then
		return nil, "No file"
	end

	if ft == "python" then
		if C.has("pytest") then
			if arg == "file" then
				return {
					cmd = { "pytest", "-q", vim.fn.expand("%") },
					cwd = root,
					title = "pytest (file)",
					ok_exit_codes = { 5 },
				}
			end

			return { cmd = { "pytest", "-q" }, cwd = root, title = "pytest", ok_exit_codes = { 5 } }
		end

		return { cmd = { "python3", "-m", "unittest", "discover" }, cwd = root, title = "unittest discover" }
	end

	if ft == "rust" then
		return { cmd = { "cargo", "test" }, cwd = root, title = "cargo test" }
	end

	if ft == "go" then
		return { cmd = { "go", "test", "./..." }, cwd = root, title = "go test" }
	end

	if ft == "c" or ft == "cpp" then
		if C.is_cmake_project(root) then
			local bdir = C.cmake_build_dir(root)
			if C.is_dir(bdir) then
				return { cmd = { "ctest", "--test-dir", bdir }, cwd = root, title = "ctest" }
			end
			return nil, "CMake build dir not found (build first)"
		end
		if C.is_make_project(root) then
			return { cmd = { "make", "test" }, cwd = root, title = "make test" }
		end
		local js = C.just_spec(root, "test")
		if js then
			return js
		end
		return nil, "No project tests (C/C++ without Make/CMake)"
	end

	if ft == "sh" or ft == "bash" or ft == "zsh" then
		if C.has("bats") then
			if arg == "file" then
				return { cmd = { "bats", vim.fn.expand("%") }, cwd = dir, title = "bats (file)" }
			end
			return { cmd = { "bats", "." }, cwd = dir, title = "bats" }
		end
		return nil, "No :Test rule for shell (install bats)"
	end

	if C.is_cmake_project(root) then
		local bdir = C.cmake_build_dir(root)
		if C.is_dir(bdir) then
			return { cmd = { "ctest", "--test-dir", bdir }, cwd = root, title = "ctest" }
		end
	end
	if C.is_make_project(root) then
		return { cmd = { "make", "test" }, cwd = root, title = "make test" }
	end

	local js = C.just_spec(root, "test")
	if js then
		return js
	end

	return nil, "No :Test rule for filetype: " .. ft
end

return M
