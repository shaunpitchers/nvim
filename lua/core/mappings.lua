local map = vim.keymap.set

--------------
-- Navigation
--------------
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

--------------
-- LSP
--------------
-- Diagnostic navigation
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "gl", vim.diagnostic.open_float, { desc = "Line diagnostics" })

--------------
-- Quickfix
--------------
local function qf(cmd)
	local ok, err = pcall(vim.cmd, cmd)
	if not ok then
		vim.notify(err, vim.log.levels.WARN)
	end
end

map("n", "]q", function()
	qf("cnext")
end, { desc = "Next quickfix" })
map("n", "[q", function()
	qf("cprevious")
end, { desc = "Prev quickfix" })
map("n", "<leader>co", "<cmd>copen<CR>", { desc = "Open quickfix" })
map("n", "<leader>cc", "<cmd>cclose<CR>", { desc = "Close quickfix" })
map("n", "<leader>cl", "<cmd>Diagnostics<CR>", { desc = "Diagnostics to loclist" })
map("n", "<leader>cq", "<cmd>Diagnostics!<CR>", { desc = "Diagnostics to quickfix" })

--------------
-- Git
--------------

-- vim-fugitive
map("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
map("n", "<leader>gd", "<cmd>Gdiffsplit<CR>", { desc = "Git diff" })
map("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
map("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git push" })
map("n", "<leader>gP", "<cmd>Git pull<CR>", { desc = "Git pull" })
map("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
map("n", "<leader>gr", "<cmd>Gread<CR>", { desc = "Git read file" })
map("n", "<leader>gw", "<cmd>Gwrite<CR>", { desc = "Git stage file" })

--------------
-- File Explorer
--------------
map("n", "<leader>e", ":Lexplore<CR>", { desc = "Open File Explorer" })

map("n", "<leader>sf", ":Files<CR>", { desc = "Fuzzy Find" })
map("n", "<leader>sg", ":Rg<CR>", { desc = "Live Grep" })

-- scp netrw connection to workstation84.
-- Re-enable this if the remote browse workflow becomes regular again.
-- map("n", "<leader>W", function()
-- 	vim.cmd("edit scp://workstation84//")
-- end, { desc = "Browse workstation84 via scp (netrw)" })

--------------
--Extra Vim magic
--------------

-- Change working directory
map("n", "<leader>cd", "<cmd>lcd %:p:h<CR>", { desc = "CD to file dir" })

--------------
-- Execution
--------------
map("n", "<leader>xb", "<cmd>Build<CR>", { desc = "Execute: build" })
map("n", "<leader>xr", "<cmd>Run<CR>", { desc = "Execute: run" })
map("n", "<leader>xo", "<cmd>Open<CR>", { desc = "Execute: open" })
map("n", "<leader>xt", "<cmd>Test<CR>", { desc = "Execute: test" })
map("n", "<leader>xl", "<cmd>Lint<CR>", { desc = "Execute: lint" })

------------
---Writing
------------
vim.keymap.set("i", "<C-d>", "<C-x><C-k>", { desc = "Dictionary completion" })
map("n", "<leader>ww", "<cmd>WordCount<CR>", { desc = "Word count" })
map("n", "<leader>wp", "<cmd>ReadingPosition<CR>", { desc = "Reading position" })
map("n", "<leader>wm", "<cmd>ToggleMarkdownTarget<CR>", { desc = "Toggle Markdown target" })

--------------
-- Toggles
--------------
local function toggle_wrap()
	vim.wo.wrap = not vim.wo.wrap
	vim.notify("Wrap: " .. (vim.wo.wrap and "ON" or "OFF"), vim.log.levels.INFO)
end

local function toggle_spell()
	vim.wo.spell = not vim.wo.spell
	vim.notify("Spell: " .. (vim.wo.spell and "ON" or "OFF"), vim.log.levels.INFO)
end

local function toggle_numbers()
	-- cycle: number -> relativenumber -> off
	if vim.wo.number and not vim.wo.relativenumber then
		vim.wo.relativenumber = true
	elseif vim.wo.number and vim.wo.relativenumber then
		vim.wo.number = false
		vim.wo.relativenumber = false
	else
		vim.wo.number = true
		vim.wo.relativenumber = false
	end
end

map("n", "<leader>tw", toggle_wrap, { desc = "Toggle wrap" })
map("n", "<leader>ts", toggle_spell, { desc = "Toggle spell" })
map("n", "<leader>tn", toggle_numbers, { desc = "Toggle line numbers" })
map("n", "<leader>tf", "<cmd>ToggleFormatOnSave<CR>", { desc = "Toggle format on save" })
map("n", "<leader>tb", "<cmd>ToggleBuildOnSave<CR>", { desc = "Toggle build on save" })
map("n", "<leader>th", "<cmd>ToggleInlayHints<CR>", { desc = "Toggle inlay hints" })
map("n", "<leader>zz", "<cmd>ToggleDistractionFree<CR>", { desc = "Toggle distraction-free" })
map("n", "<leader>?", "<cmd>Leader<cr>", { desc = "Show <leader> mappings" })
