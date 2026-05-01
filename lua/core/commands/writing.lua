-- ~/.config/nvim/lua/core/commands/writing.lua
-- Small commands for writing buffers.

local M = {}

local function word_count()
	local wc = vim.fn.wordcount()
	local words = wc.visual_words or wc.words or 0
	local chars = wc.visual_chars or wc.chars or 0
	vim.notify(("Words: %d | Chars: %d"):format(words, chars), vim.log.levels.INFO)
end

local function reading_position()
	local line = vim.fn.line(".")
	local total = vim.fn.line("$")
	local percent = total > 0 and math.floor((line / total) * 100 + 0.5) or 0
	vim.notify(("Line %d/%d (%d%%)"):format(line, total, percent), vim.log.levels.INFO)
end

local function toggle_markdown_target()
	if vim.bo.filetype ~= "markdown" then
		vim.notify("Markdown target only applies to markdown buffers", vim.log.levels.WARN)
		return
	end

	local use_html = vim.b.md_build_target ~= "html"
	vim.b.md_build_target = use_html and "html" or ""
	vim.notify("Markdown build target: " .. (use_html and "HTML" or "PDF"), vim.log.levels.INFO)
end

function M.setup()
	vim.api.nvim_create_user_command("WordCount", word_count, {})
	vim.api.nvim_create_user_command("ReadingPosition", reading_position, {})
	vim.api.nvim_create_user_command("ToggleMarkdownTarget", toggle_markdown_target, {})
end

return M
