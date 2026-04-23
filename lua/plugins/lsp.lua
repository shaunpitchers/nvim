return {
	-- Mason: installer UI only (no auto-install bloat here)
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		cmd = "Mason",
		config = function()
			require("mason").setup({
				ui = {
					border = "rounded",
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},

	-- Mason-lspconfig: the *only* place we ensure servers
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = function()
			local lspconfig = require("lspconfig")
			local util = require("lspconfig.util")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- (Optional) some setups need this for clangd; harmless otherwise
			capabilities.offsetEncoding = { "utf-8" }

			return {
				automatic_installation = true,
				ensure_installed = {
					-- your actual use-cases
					"pyright",
					"ruff",
					"lua_ls",
					"bashls",
					"marksman",
					"jsonls",
					"yamlls",
					"texlab",
				},

				handlers = {
					-- default for anything else you manually install later
					function(server_name)
						lspconfig[server_name].setup({
							capabilities = capabilities,
						})
					end,

					-- Python
					pyright = function()
						lspconfig.pyright.setup({
							capabilities = capabilities,
							root_dir = util.root_pattern("pyproject.toml", "setup.py", ".git"),
							settings = {
								python = {
									analysis = {
										typeCheckingMode = "basic",
										autoSearchPaths = true,
										diagnosticMode = "workspace",
										useLibraryCodeForTypes = true,
									},
								},
							},
						})
					end,

					-- Ruff (linter). Keep hover off so Pyright owns hover docs.
					ruff = function()
						lspconfig.ruff.setup({
							capabilities = capabilities,
							init_options = {
								settings = {
									args = { "--ignore=E501" },
								},
							},
							on_attach = function(client)
								client.server_capabilities.hoverProvider = false
							end,
						})
					end,

					-- Lua (for your nvim config)
					lua_ls = function()
						lspconfig.lua_ls.setup({
							capabilities = capabilities,
							settings = {
								Lua = {
									runtime = { version = "LuaJIT" },
									diagnostics = { globals = { "vim" } },
									workspace = { checkThirdParty = false },
									telemetry = { enable = false },
								},
							},
						})
					end,

					-- Markdown
					marksman = function()
						lspconfig.marksman.setup({
							capabilities = capabilities,
							filetypes = { "markdown", "markdown.mdx" },
						})
					end,

					-- Shell
					bashls = function()
						lspconfig.bashls.setup({
							capabilities = capabilities,
							filetypes = { "sh", "zsh", "bash" },
						})
					end,

					-- JSON/YAML (config files)
					jsonls = function()
						lspconfig.jsonls.setup({ capabilities = capabilities })
					end,

					yamlls = function()
						lspconfig.yamlls.setup({ capabilities = capabilities })
					end,
				},
			}
		end,
	},

	-- LSP keymaps (stable + small)
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
					end

					map("n", "gd", vim.lsp.buf.definition, "Goto definition")
					map("n", "gr", vim.lsp.buf.references, "Goto references")
					map("n", "K", vim.lsp.buf.hover, "Hover docs")
					map("n", "<leader>r", vim.lsp.buf.rename, "Rename all in buffer")
					map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
					map("x", "<leader>ca", vim.lsp.buf.code_action, "Code action (range)")
					map("n", "<leader>cf", function()
						vim.lsp.buf.format({ bufnr = bufnr, async = true })
					end, "Format")
					map("n", "<leader>ci", "<cmd>LspInfo<CR>", "LSP info")
				end,
			})
		end,
	},
}
