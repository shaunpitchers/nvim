return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile" },
		cmd = "Lint",
		config = function()
			local lint = require("lint")

			local linters_by_ft = {}

			local function executable(cmd)
				return vim.fn.executable(cmd) == 1
			end

			local function add(ft, linter, cmd)
				if executable(cmd or linter) then
					linters_by_ft[ft] = linters_by_ft[ft] or {}
					table.insert(linters_by_ft[ft], linter)
					return true
				end
				return false
			end

			local function add_first(ft, candidates)
				for _, candidate in ipairs(candidates) do
					if add(ft, candidate[1], candidate[2]) then
						return
					end
				end
			end

			add("sh", "shellcheck")
			add("bash", "shellcheck")
			add("zsh", "zsh")
			add("lua", "luac")
			add_first("markdown", {
				{ "markdownlint-cli2", "markdownlint-cli2" },
				{ "markdownlint", "markdownlint" },
			})
			add("tex", "chktex")
			add("plaintex", "chktex")
			add("yaml", "yamllint")
			add("dockerfile", "hadolint")

			lint.linters_by_ft = linters_by_ft

			local function try_lint()
				lint.try_lint()
			end

			vim.api.nvim_create_user_command("Lint", try_lint, {
				desc = "Run nvim-lint for the current buffer",
			})

			vim.api.nvim_create_autocmd("BufWritePost", {
				group = vim.api.nvim_create_augroup("UserLint", { clear = true }),
				callback = try_lint,
			})
		end,
	},
}
