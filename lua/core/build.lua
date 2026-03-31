-- ~/.config/nvim/lua/core/build.lua
-- Centralized build/run/clean logic used by :Build / :Run / :Clean and ftplugins.
-- Philosophy: minimal magic, predictable defaults, and project-root aware when it matters.

local U = require("core.utils")

local M = {}

M.ROOT_MARKERS = {
	".git",
	"Makefile",
	"justfile",
	"CMakeLists.txt",
	"compile_commands.json",
	"pyproject.toml",
	"package.json",
	"go.mod",
	"Cargo.toml",
}

local function has(exe)
	return vim.fn.executable(exe) == 1
end

local function ctx()
	local ft = vim.bo.filetype
	local file = vim.fn.expand("%:p")
	local dir = vim.fn.expand("%:p:h")
	local root = U.root(M.ROOT_MARKERS) or dir
	return { ft = ft, file = file, dir = dir, root = root }
end

local function is_file(path)
	return vim.fn.filereadable(path) == 1
end

local function is_dir(path)
	return vim.fn.isdirectory(path) == 1
end

local function cmake_build_dir(root)
	local b = root .. "/build"
	if is_dir(b) then
		return b
	end
	-- common alternative
	local b2 = root .. "/builddir"
	if is_dir(b2) then
		return b2
	end
	return b
end

local function is_cmake_project(root)
	return is_file(root .. "/CMakeLists.txt")
end

local function is_make_project(root)
	return is_file(root .. "/Makefile") or is_file(root .. "/makefile")
end

local function is_suckless_project(root)
	return is_file(root .. "/config.mk") and (is_file(root .. "/Makefile") or is_file(root .. "/makefile"))
end

-- Returns: spec table { cmd=string|table, cwd=string, artifact=string|nil, title=string|nil }
function M.build_spec(opts)
	opts = opts or {}
	local c = ctx()
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
		-- default pdf
		return { cmd = { "pandoc", file, "-o", out_pdf }, cwd = dir, artifact = out_pdf, title = "pandoc" }
	end

	if ft == "sh" or ft == "bash" or ft == "zsh" then
		if has("shellcheck") then
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
		if has("luac") then
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
		if is_cmake_project(root) then
			local bdir = cmake_build_dir(root)
			-- Configure if build dir missing
			if not is_dir(bdir) then
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

		if is_make_project(root) then
			return { cmd = { "make" }, cwd = root, artifact = nil, title = "make" }
		end

		-- Single-file fallback
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

	-- Generic project fallback: if you're in a repo with a Makefile/CMakeLists, :Build should "do the obvious".
	if is_cmake_project(root) then
		local bdir = cmake_build_dir(root)
		if not is_dir(bdir) then
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

	if is_make_project(root) then
		return { cmd = { "make" }, cwd = root, artifact = nil, title = "make" }
	end

	return nil, "No :Build rule for filetype: " .. ft
end

function M.clean_spec()
	local c = ctx()
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

	if ft == "rust" then
		return { cmd = { "cargo", "clean" }, cwd = root, title = "cargo clean" }
	end

	if ft == "go" then
		return { cmd = { "go", "clean", "./..." }, cwd = root, title = "go clean" }
	end

	if ft == "c" or ft == "cpp" then
		-- Prefer project-level clean when applicable
		if is_cmake_project(root) then
			local bdir = cmake_build_dir(root)
			if is_dir(bdir) then
				return { cmd = { "cmake", "--build", bdir, "--target", "clean" }, cwd = root, title = "cmake clean" }
			end
		end
		if is_make_project(root) then
			return { cmd = { "make", "clean" }, cwd = root, title = "make clean" }
		end
		-- Single-file fallback: delete produced .out
		local out = vim.fn.expand("%:p:r") .. ".out"
		return { cmd = { "sh", "-lc", "rm -f " .. vim.fn.shellescape(out) }, cwd = dir, title = "rm .out" }
	end

	if ft == "sh" or ft == "bash" or ft == "zsh" then
		return nil, "Nothing to clean"
	end

	-- Generic project fallback
	if is_cmake_project(root) then
		local bdir = cmake_build_dir(root)
		if is_dir(bdir) then
			return { cmd = { "cmake", "--build", bdir, "--target", "clean" }, cwd = root, title = "cmake clean" }
		end
	end
	if is_make_project(root) then
		return { cmd = { "make", "clean" }, cwd = root, title = "make clean" }
	end
	return nil, "No :Clean rule for filetype: " .. ft
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

function M.test_spec(opts)
	opts = opts or {}
	local c = ctx()
	local ft, file, dir, root = c.ft, c.file, c.dir, c.root
	local arg = (opts.arg or ""):lower()

	if file == "" then
		return nil, "No file"
	end

	if ft == "python" then
		if has("pytest") then
			if arg == "file" then
				return {
					cmd = { "pytest", "-q", vim.fn.expand("%") },
					cwd = root,
					title = "pytest (file)",
					ok_exit_codes = { 5 },
				}
			end
			-- pytest exit code 5 means "no tests collected"; treat it as a non-error.
			return { cmd = { "pytest", "-q" }, cwd = root, title = "pytest", ok_exit_codes = { 5 } }
		end
		-- fallback to unittest discovery
		return { cmd = { "python3", "-m", "unittest", "discover" }, cwd = root, title = "unittest discover" }
	end

	if ft == "rust" then
		return { cmd = { "cargo", "test" }, cwd = root, title = "cargo test" }
	end

	if ft == "go" then
		return { cmd = { "go", "test", "./..." }, cwd = root, title = "go test" }
	end

	if ft == "c" or ft == "cpp" then
		if is_cmake_project(root) then
			local bdir = cmake_build_dir(root)
			if is_dir(bdir) then
				return { cmd = { "ctest", "--test-dir", bdir }, cwd = root, title = "ctest" }
			end
			return nil, "CMake build dir not found (build first)"
		end
		if is_make_project(root) then
			return { cmd = { "make", "test" }, cwd = root, title = "make test" }
		end
		return nil, "No project tests (C/C++ without Make/CMake)"
	end

	if ft == "sh" or ft == "bash" or ft == "zsh" then
		if has("bats") then
			if arg == "file" then
				return { cmd = { "bats", vim.fn.expand("%") }, cwd = dir, title = "bats (file)" }
			end
			return { cmd = { "bats", "." }, cwd = dir, title = "bats" }
		end
		return nil, "No :Test rule for shell (install bats)"
	end

	-- Generic project fallback
	if is_cmake_project(root) then
		local bdir = cmake_build_dir(root)
		if is_dir(bdir) then
			return { cmd = { "ctest", "--test-dir", bdir }, cwd = root, title = "ctest" }
		end
	end
	if is_make_project(root) then
		return { cmd = { "make", "test" }, cwd = root, title = "make test" }
	end

	return nil, "No :Test rule for filetype: " .. ft
end

return M
