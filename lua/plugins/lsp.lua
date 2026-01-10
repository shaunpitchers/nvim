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
					"stylua",
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
					local opts = { buffer = bufnr }

					-- If you keep lsp_signature, attach it; if not, no crash.
					local ok, sig = pcall(require, "lsp_signature")
					if ok then
						sig.on_attach({
							bind = true,
							hint_enable = false,
							floating_window = true,
							handler_opts = { border = "rounded" },
						}, bufnr)
					end

					-- Core mappings (you already use these)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				end,
			})
		end,
	},
}
