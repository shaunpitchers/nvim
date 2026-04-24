-- ~/.config/nvim/after/plugin/zk.lua
-- Minimal ZK helpers: templates, frontmatter fill, and gf resolution for [[ID]] links.

local uv = vim.uv or vim.loop

-- ---------- Helpers ----------
local function file_exists(p)
	local st = uv.fs_stat(p)
	return st and st.type == "file"
end

local function read_file(p)
	local fd = uv.fs_open(p, "r", 420)
	if not fd then
		return nil
	end
	local stat = uv.fs_fstat(fd)
	if not stat then
		uv.fs_close(fd)
		return nil
	end
	local data = uv.fs_read(fd, stat.size, 0)
	uv.fs_close(fd)
	return data
end

local function buf_is_empty(bufnr)
	bufnr = bufnr or 0
	if vim.api.nvim_buf_line_count(bufnr) > 1 then
		return false
	end
	local line = (vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or "")
	return line == ""
end

-- Extract /.../zettelkasten from a full path
local function zk_root_from_path(p)
	if not p or p == "" then
		return nil
	end
	return p:match("^(.-/zettelkasten)/")
end

local function zk_paths(root)
	return {
		root = root,
		inbox = root .. "/00-inbox",
		notes = root .. "/10-notes",
		mocs = root .. "/20-mocs",
		sources = root .. "/30-sources",
		projects = root .. "/40-projects",
		templ = root .. "/templates",
	}
end

-- Strip [[...]] and optional |label from <cWORD>
-- local function wiki_target_under_cursor()
-- 	local word = vim.fn.expand("<cWORD>") or ""
-- 	if not word:find("%[%[", 1, true) then
-- 		return nil
-- 	end

-- 	local t = word:gsub("^%[%[", ""):gsub("%]%]$", "")
-- 	t = (t:match("^(.-)|") or t)
-- 	t = t:gsub("^%s+", ""):gsub("%s+$", "")
-- 	t = t:gsub("%s+", "")
-- 	return t
-- end

-- Find a [[...]] link that the cursor is inside, by scanning the whole line.
local function wiki_target_under_cursor()
	local _, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()

	-- col is 0-based; Lua string indices are 1-based
	local cursor = col + 1

	-- Find all [[...]] spans and see if cursor is within one
	local i = 1
	while true do
		local s, e = line:find("%[%[[^%]]-%]%]", i)
		if not s then
			break
		end

		if cursor >= s and cursor <= e then
			local inner = line:sub(s + 2, e - 2)
			inner = inner:gsub("^%s+", ""):gsub("%s+$", "")
			local target = inner:match("^(.-)|") or inner
			target = target:gsub("^%s+", ""):gsub("%s+$", "")
			return target
		end

		i = e + 1
	end

	-- Bonus: if you're on a bare 14-digit ID (even without brackets), treat it as a target
	local cword = vim.fn.expand("<cword>") or ""
	if cword:match("^%d%d%d%d%d%d%d%d%d%d%d%d%d%d$") then
		return cword
	end

	return nil
end

-- ---------- Template insertion ----------
local function insert_template(template_path)
	if not file_exists(template_path) then
		return
	end
	local data = read_file(template_path)
	if not data then
		return
	end
	local lines = vim.split(data, "\n", { plain = true })
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*.md",
	callback = function(args)
		if not buf_is_empty(args.buf) then
			return
		end

		local f = vim.api.nvim_buf_get_name(args.buf)
		local root = zk_root_from_path(f)
		if not root then
			return
		end

		local p = zk_paths(root)
		local template

		if f:find(p.notes, 1, true) then
			template = p.templ .. "/note.md"
		end
		if f:find(p.mocs, 1, true) then
			template = p.templ .. "/moc.md"
		end
		if f:find(p.sources, 1, true) then
			template = p.templ .. "/source.md"
		end
		if f:find(p.projects, 1, true) then
			template = p.templ .. "/project.md"
		end
		if f:find(p.inbox, 1, true) then
			template = p.templ .. "/inbox.md"
		end

		if template then
			insert_template(template)
			vim.cmd("normal! gg")
		end
	end,
})

-- ---------- Auto-fill id/created on new notes + inbox ----------
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*.md",
	callback = function()
		local f = vim.api.nvim_buf_get_name(0)
		local root = zk_root_from_path(f)
		if not root then
			return
		end

		-- Only notes + inbox
		if not (f:find(root .. "/10-notes/", 1, true) or f:find(root .. "/00-inbox/", 1, true)) then
			return
		end

		local fname = vim.fn.expand("%:t")
		local id = fname:match("^(%d%d%d%d%d%d%d%d%d%d%d%d%d%d)")
		if not id then
			return
		end

		local created = os.date("!%Y-%m-%dT%H:%M:%S")

		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		if #lines == 0 then
			return
		end

		local changed = false
		for i, line in ipairs(lines) do
			if line:match("^id:%s*$") then
				lines[i] = "id: " .. id
				changed = true
			elseif line:match("^created:%s*$") then
				lines[i] = "created: " .. created
				changed = true
			end
		end

		if changed then
			vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
		end
	end,
})

-- ---------- gf resolver for [[ID]] ----------
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(args)
		local bufname = vim.api.nvim_buf_get_name(args.buf)
		local root = zk_root_from_path(bufname)
		if not root then
			return
		end

		local p = zk_paths(root)

		vim.keymap.set("n", "gf", function()
			local target = wiki_target_under_cursor()

			-- Not on a wiki-link: normal gf
			if not target then
				vim.cmd("normal! gf")
				return
			end

			-- ID link: [[YYYYMMDDHHMMSS]] — search all subdirs
			if target:match("^%d%d%d%d%d%d%d%d%d%d%d%d%d%d$") then
				local res = vim.fn.glob(p.root .. "/**/" .. target .. "-*.md", false, true)
				local hit = (type(res) == "table" and res[1]) or nil
				if hit and hit ~= "" then
					vim.cmd("edit " .. vim.fn.fnameescape(hit))
				else
					vim.notify("ZK link not found: " .. target, vim.log.levels.WARN)
				end
				return
			end

			-- For now: non-ID wiki links are not resolved here
			vim.notify("ZK wiki link not understood: " .. target, vim.log.levels.WARN)
		end, { buffer = args.buf, silent = true })
	end,
})
