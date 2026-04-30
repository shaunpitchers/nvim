-- ~/.config/nvim/lua/core/tasks/clean.lua
-- Clean command selection for :Clean.

local C = require("core.tasks.context")

local M = {}

function M.spec()
	local c = C.ctx()
	local ft, file, dir, root = c.ft, c.file, c.dir, c.root
	if file == "" then
		return nil, "No file"
	end

	if ft == "tex" or ft == "plaintex" then
		return { cmd = { "latexmk", "-c", file }, cwd = dir, title = "latexmk -c" }
	end

	if ft == "markdown" then
		local pdf = vim.fn.expand("%:p:r") .. ".pdf"
		local html = vim.fn.expand("%:p:r") .. ".html"
		return {
			cmd = { "sh", "-lc", "rm -f " .. vim.fn.shellescape(pdf) .. " " .. vim.fn.shellescape(html) },
			cwd = dir,
			title = "rm outputs",
		}
	end

	if ft == "python" then
		return {
			cmd = { "sh", "-lc", "find . -type d -name __pycache__ -prune -exec rm -rf {} +" },
			cwd = root,
			title = "remove __pycache__",
		}
	end

	if ft == "rust" then
		return { cmd = { "cargo", "clean" }, cwd = root, title = "cargo clean" }
	end

	if ft == "go" then
		return { cmd = { "go", "clean", "./..." }, cwd = root, title = "go clean" }
	end

	if ft == "c" or ft == "cpp" then
		if C.is_cmake_project(root) then
			local bdir = C.cmake_build_dir(root)
			if C.is_dir(bdir) then
				return { cmd = { "cmake", "--build", bdir, "--target", "clean" }, cwd = root, title = "cmake clean" }
			end
		end
		if C.is_make_project(root) then
			return { cmd = { "make", "clean" }, cwd = root, title = "make clean" }
		end
		local js = C.just_spec(root, "clean")
		if js then
			return js
		end

		local out = vim.fn.expand("%:p:r") .. ".out"
		return { cmd = { "sh", "-lc", "rm -f " .. vim.fn.shellescape(out) }, cwd = dir, title = "rm .out" }
	end

	if ft == "sh" or ft == "bash" or ft == "zsh" then
		return nil, "Nothing to clean"
	end

	if C.is_cmake_project(root) then
		local bdir = C.cmake_build_dir(root)
		if C.is_dir(bdir) then
			return { cmd = { "cmake", "--build", bdir, "--target", "clean" }, cwd = root, title = "cmake clean" }
		end
	end
	if C.is_make_project(root) then
		return { cmd = { "make", "clean" }, cwd = root, title = "make clean" }
	end
	local js = C.just_spec(root, "clean")
	if js then
		return js
	end

	return nil, "No :Clean rule for filetype: " .. ft
end

return M
