-- ~/.config/nvim/lua/core/tasks/build.lua
-- Build command selection for :Build and filetype build-on-save hooks.

local C = require("core.tasks.context")

local M = {}

-- Returns: spec table { cmd=string|table, cwd=string, artifact=string|nil, title=string|nil }
function M.spec(opts)
	opts = opts or {}
	local c = C.ctx()
	local ft, file, dir, root = c.ft, c.file, c.dir, c.root
	local arg = (opts.arg or ""):lower()

	if file == "" then
		return nil, "No file"
	end

	if ft == "tex" or ft == "plaintex" then
		return {
			cmd = {
				"latexmk",
				"-pdf",
				"-bibtex",
				"-interaction=nonstopmode",
				"-synctex=1",
				"-f",
				file,
			},
			cwd = dir,
			artifact = vim.fn.expand("%:p:r") .. ".pdf",
			title = "latexmk",
		}
	end

	if ft == "markdown" then
		local out_pdf = vim.fn.expand("%:p:r") .. ".pdf"
		local out_html = vim.fn.expand("%:p:r") .. ".html"
		if arg == "html" then
			return { cmd = { "pandoc", "-s", file, "-o", out_html }, cwd = dir, artifact = out_html, title = "pandoc" }
		end

		return { cmd = { "pandoc", file, "-o", out_pdf }, cwd = dir, artifact = out_pdf, title = "pandoc" }
	end

	if ft == "sh" or ft == "bash" or ft == "zsh" then
		if C.has("shellcheck") then
			return { cmd = { "shellcheck", file }, cwd = dir, artifact = nil, title = "shellcheck" }
		end
		return nil, "No build for shell (install shellcheck for :Build)"
	end

	if ft == "python" then
		return {
			cmd = { "python3", "-m", "compileall", dir },
			cwd = dir,
			artifact = nil,
			title = "python -m compileall",
		}
	end

	if ft == "lua" then
		if C.has("luac") then
			return { cmd = { "luac", "-p", file }, cwd = dir, artifact = nil, title = "luac -p" }
		end
		return nil, "luac not found"
	end

	if ft == "rust" then
		return { cmd = { "cargo", "build" }, cwd = root, artifact = nil, title = "cargo build" }
	end

	if ft == "go" then
		return { cmd = { "go", "build", "./..." }, cwd = root, artifact = nil, title = "go build" }
	end

	if ft == "c" or ft == "cpp" then
		if C.is_cmake_project(root) then
			local bdir = C.cmake_build_dir(root)
			if not C.is_dir(bdir) then
				return {
					cmd = {
						"sh",
						"-lc",
						string.format(
							"cd %q && cmake -S . -B %q -DCMAKE_BUILD_TYPE=Release && cmake --build %q",
							root,
							bdir,
							bdir
						),
					},
					cwd = root,
					artifact = nil,
					title = "cmake configure+build",
				}
			end

			return {
				cmd = { "cmake", "--build", bdir },
				cwd = root,
				artifact = nil,
				title = "cmake --build",
			}
		end

		if C.is_make_project(root) then
			return { cmd = { "make" }, cwd = root, artifact = nil, title = "make" }
		end

		local js = C.just_spec(root, "build")
		if js then
			return js
		end

		local out = vim.fn.expand("%:p:r") .. ".out"
		if ft == "c" then
			return {
				cmd = { "gcc", file, "-O2", "-Wall", "-Wextra", "-std=c11", "-o", out },
				cwd = dir,
				artifact = out,
				title = "gcc",
			}
		end

		return {
			cmd = { "g++", file, "-O2", "-Wall", "-Wextra", "-std=c++20", "-o", out },
			cwd = dir,
			artifact = out,
			title = "g++",
		}
	end

	if C.is_cmake_project(root) then
		local bdir = C.cmake_build_dir(root)
		if not C.is_dir(bdir) then
			return {
				cmd = {
					"sh",
					"-lc",
					string.format(
						"cd %q && cmake -S . -B %q -DCMAKE_BUILD_TYPE=Release && cmake --build %q",
						root,
						bdir,
						bdir
					),
				},
				cwd = root,
				artifact = nil,
				title = "cmake configure+build",
			}
		end
		return { cmd = { "cmake", "--build", bdir }, cwd = root, artifact = nil, title = "cmake --build" }
	end

	if C.is_make_project(root) then
		return { cmd = { "make" }, cwd = root, artifact = nil, title = "make" }
	end

	local js = C.just_spec(root, "build")
	if js then
		return js
	end

	return nil, "No :Build rule for filetype: " .. ft
end

return M
