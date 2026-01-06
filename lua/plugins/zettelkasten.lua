-- ~/.config/nvim/lua/plugins/zettelkasten.lua
return {
	-- No plugin dependency; this is just a "config-only" module for lazy.nvim
	-- If you prefer, you can move the config() body into after/plugin/zettelkasten.lua
	-- lazy = false,
	-- priority = 900,
	config = function()
		local uv = vim.uv or vim.loop

		-- =========
		-- Settings
		-- =========
		local home = vim.env.HOME or os.getenv("HOME")
		local zk_root = vim.env.ZK_DIR or (home .. "/zettelkasten")

		local paths = {
			notes_active = zk_root .. "/active/notes",
			topics_active = zk_root .. "/active/topics",
			archive = zk_root .. "/archive",
			templates = zk_root .. "/templates",
			-- Pinned files you mentioned (adjust if yours differ)
			journal = zk_root .. "/active/journal.md",
			ideas = zk_root .. "/active/ideas.md",
			inbox = zk_root .. "/active/inbox.md",
		}

		-- Optional: call ZenMode if present, otherwise do nothing
		local function maybe_zenmode()
			local ok = pcall(vim.cmd, "ZenMode")
			return ok
		end

		local function notify(msg, level)
			vim.notify(msg, level or vim.log.levels.INFO, { title = "ZK" })
		end

		local function mkdirp(dir)
			if not dir or dir == "" then
				return
			end
			vim.fn.mkdir(dir, "p")
		end

		local function file_exists(p)
			return vim.fn.filereadable(p) == 1
		end

		local function sanitize_title(s)
			s = (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
			if s == "" then
				return "untitled"
			end
			-- conservative filename-safe transform
			s = s:gsub("%s+", "_")
			s = s:gsub("[^%w%-%._]", "")
			if s == "" then
				return "untitled"
			end
			return s
		end

		local function timestamp_id()
			-- Keep your original style: YYYY-MM-DD-HHMMSS
			return os.date("%Y-%m-%d-%H%M%S")
		end

		local function edit_file(path)
			mkdirp(vim.fn.fnamemodify(path, ":h"))
			vim.cmd("edit " .. vim.fn.fnameescape(path))
		end

		local function insert_template_if_new(template_path)
			-- Only insert if buffer is empty/new
			local line_count = vim.api.nvim_buf_line_count(0)
			local first = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
			local empty = (line_count == 1 and first == "")

			if empty and file_exists(template_path) then
				local lines = vim.fn.readfile(template_path)
				vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
			end
		end

		-- ==================
		-- Note constructors
		-- ==================
		local function new_note()
			local title = vim.fn.input("Note title: ")
			local id = timestamp_id()
			local slug = sanitize_title(title)
			local filename = string.format("%s/%s-%s.md", paths.notes_active, id, slug)

			edit_file(filename)

			-- Template: zettelkasten/templates/note.md (rename as you like)
			insert_template_if_new(paths.templates .. "/note.md")

			-- Put cursor at end for quick writing
			vim.cmd("normal! G")
			maybe_zenmode()
		end

		local function new_topic()
			local title = vim.fn.input("Topic title: ")
			local slug = sanitize_title(title)
			local filename = string.format("%s/%s.md", paths.topics_active, slug)

			edit_file(filename)
			insert_template_if_new(paths.templates .. "/topic.md")
			vim.cmd("normal! G")
			maybe_zenmode()
		end

		local function open_pinned(which)
			local p = paths[which]
			if not p then
				notify("Unknown pinned file: " .. tostring(which), vim.log.levels.ERROR)
				return
			end
			edit_file(p)
		end

		-- ==================
		-- Archiving
		-- ==================
		local function archive_current_note()
			local cur = vim.fn.expand("%:p")
			if cur == "" then
				return
			end

			-- Only archive markdown files under zk_root (safety guard)
			local normalized = vim.fs.normalize(cur)
			local root_norm = vim.fs.normalize(zk_root)
			if not normalized:find("^" .. vim.pesc(root_norm)) then
				notify("Refusing to archive file outside ZK_DIR", vim.log.levels.WARN)
				return
			end

			-- Ensure written before moving
			if vim.bo.modified then
				vim.cmd("write")
			end

			local year = os.date("%Y")
			local target_dir = paths.archive .. "/" .. year
			mkdirp(target_dir)

			local target = target_dir .. "/" .. vim.fn.fnamemodify(cur, ":t")

			-- Use libuv rename for better error messages; fall back to os.rename
			local ok, err
			if uv and uv.fs_rename then
				ok, err = uv.fs_rename(cur, target)
				if not ok then
					-- fallback
					ok, err = os.rename(cur, target)
				end
			else
				ok, err = os.rename(cur, target)
			end

			if not ok then
				notify("Archive failed: " .. tostring(err), vim.log.levels.ERROR)
				return
			end

			-- Close buffer after moving file
			vim.cmd("bdelete")
			notify("Archived to: " .. target)
		end

		-- ==================
		-- Commands
		-- ==================
		vim.api.nvim_create_user_command("ZkNew", new_note, { desc = "New ZK note" })
		vim.api.nvim_create_user_command("ZkTopic", new_topic, { desc = "New ZK topic" })
		vim.api.nvim_create_user_command("ZkJournal", function()
			open_pinned("journal")
		end, { desc = "Open journal" })
		vim.api.nvim_create_user_command("ZkIdeas", function()
			open_pinned("ideas")
		end, { desc = "Open ideas" })
		vim.api.nvim_create_user_command("ZkInbox", function()
			open_pinned("inbox")
		end, { desc = "Open inbox" })
		vim.api.nvim_create_user_command("ZkArchive", archive_current_note, { desc = "Archive current note" })

		-- ==================
		-- Minimal keybinds
		-- ==================
		-- Keep these lightweight; adjust to your leader scheme
		vim.keymap.set("n", "<leader>zn", "<cmd>ZkNew<cr>", { desc = "ZK: new note" })
		vim.keymap.set("n", "<leader>zt", "<cmd>ZkTopic<cr>", { desc = "ZK: new topic" })
		vim.keymap.set("n", "<leader>zj", "<cmd>ZkJournal<cr>", { desc = "ZK: journal" })
		vim.keymap.set("n", "<leader>zi", "<cmd>ZkIdeas<cr>", { desc = "ZK: ideas" })
		vim.keymap.set("n", "<leader>zx", "<cmd>ZkInbox<cr>", { desc = "ZK: inbox" })
		vim.keymap.set("n", "<leader>za", "<cmd>ZkArchive<cr>", { desc = "ZK: archive current" })
	end,
}
