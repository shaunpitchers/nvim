local map = vim.keymap.set
local ok, builtin = pcall(require, "telescope.builtin")
if not ok then
	builtin = nil
end

--------------
-- Navigation
--------------
-- map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
-- map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
-- map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
-- map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

--------------
-- Buffers
--------------
-- map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New buffer" })
-- map("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Delete buffer" })
-- map("n", "<leader>bs", "<cmd>vsplit<CR>", { desc = "Vertical split" })
-- map("n", "<leader>bv", "<cmd>split<CR>", { desc = "Horizontal split" })
-- map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
-- map("n", "<leader>bf", "<cmd>bfirst<CR>", { desc = "First buffer" })
-- map("n", "<leader>bl", "<cmd>blast<CR>", { desc = "Last buffer" })
-- -- Quick file navigation
-- map("n", "<leader>be", "<cmd>e ", { desc = "Open file in current buffer" }) -- Type filename after
-- map("n", "<leader>bE", "<cmd>e %:h/", { desc = "Open file in current dir" }) -- Type filename after

--------------
-- LSP
--------------
map("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "Goto references" })
-- map("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })

map("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename all in buffer" })
map("n", "<leader>cf", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format" })
-- LSP info
map("n", "<leader>ci", "<cmd>LspInfo<CR>", { desc = "LSP info" })

-- LSP range code action (visual mode)
map("v", "<leader>ca", "<ESC><cmd>lua vim.lsp.buf.range_code_action()<CR>", { desc = "Code action (range)" })

-- Diagnostic navigation
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })

--------------
-- Git
--------------

-- Gitsigns
-- map("n", "<leader>gj", "<cmd>Gitsigns next_hunk<cr>", { desc = "Next hunk" })
-- map("n", "<leader>gk", "<cmd>Gitsigns prev_hunk<cr>", { desc = "Prev hunk" })
-- vim-fugitive
map("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
map("n", "<leader>gd", "<cmd>Gdiffsplit<CR>", { desc = "Git diff" })
map("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
map("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git push" })
map("n", "<leader>gP", "<cmd>Git pull<CR>", { desc = "Git pull" })
map("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
map("n", "<leader>gr", "<cmd>Gread<CR>", { desc = "Git revert to HEAD" })
map("n", "<leader>gw", "<cmd>Gwrite<CR>", { desc = "Git stage file" })

--------------
-- File Explorer
--------------
map("n", "<leader>e", ":Lexplore<CR>", { desc = "Open File Explorer" })

-- Macro management
map("n", "<leader>ql", "<cmd>reg<CR>", { desc = "List macros (registers)" })

map("n", "<leader>qe", function()
	local r = vim.fn.nr2char(vim.fn.getchar())
	vim.fn.setreg(r, "")
	print("Cleared register @" .. r)
end, { desc = "Clear register (press register key)" })

-- scp netrw connection to workstation84
map("n", "<leader>s", function()
	vim.cmd("edit scp://workstation84//")
end, { desc = "Browse workstation84 via scp (netrw)" })

--------------
--Extra Vim magic
--------------

-- Change working directory
map("n", "<leader>cd", "<cmd>lcd %:p:h<CR>", { desc = "CD to file dir" })

------------
---Writing
------------
vim.keymap.set("i", "<C-d>", "<C-x><C-k>", { desc = "Dictionary completion" })

vim.keymap.set("n", "<leader>t", function()
	vim.opt_local.spell = not vim.opt_local.spell:get()
end, { desc = "Toggle spell" })
