-- Writing settings (Markdown)
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_gb"

vim.opt_local.textwidth = 80
vim.opt_local.formatoptions:append({ "t" }) -- auto-wrap text while typing
vim.opt_local.formatoptions:remove({ "c", "r", "o" }) -- avoid auto comment insertion on new lines

vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true

-- wrapped-line friendly movement
vim.keymap.set("n", "j", "gj", { buffer = true, silent = true })
vim.keymap.set("n", "k", "gk", { buffer = true, silent = true })

-- quick manual reflow of paragraph
vim.keymap.set("n", "<leader>fw", "gqap", { buffer = true, desc = "Format paragraph (80 cols)" })
vim.keymap.set("v", "<leader>fw", "gq",   { buffer = true, desc = "Format selection (80 cols)" })

