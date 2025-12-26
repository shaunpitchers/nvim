return {
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

            -- List of packages to auto-install
            local packages = {
                -- Python
                "pyright", -- Python LSP
                "ruff",    -- Python linter
                "debugpy", -- Python debugger
                "black",   -- Python formatter
                "isort",   -- Python import sorter

                -- Lua
                "lua-language-server",
                "stylua",

                -- JavaScript/TypeScript
                "typescript-language-server",
                "prettier",
                "eslint-lsp",

                -- Bash
                "bash-language-server",
                "shellcheck",

                -- Docker
                "dockerfile-language-server",

                -- JSON/YAML
                "json-lsp",
                "yaml-language-server",

                -- Markdown
                "marksman",

                -- C/C++
                "clangd",
                "cpptools",

                --foam-ls
                "foam-language-server",

                -- Latex
                "texlab"
            }

            -- Auto-install packages on startup
            vim.schedule(function()
                local mr = require("mason-registry")
                for _, pkg in ipairs(packages) do
                    local ok, p = pcall(mr.get_package, pkg)
                    if ok and not p:is_installed() then
                        p:install()
                    end
                end
            end)
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = function()
            local lspconfig = require("lspconfig")
            local util = require("lspconfig.util")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            capabilities.offsetEncoding = { "utf-8" }

            return {
                automatic_installation = true,
                ensure_installed = { "pyright", "ruff", "lua_ls", "marksman" },
                handlers = {
                    -- Default handler for any installed server without a custom config
                    function(server_name)
                        lspconfig[server_name].setup({
                            capabilities = capabilities,
                            on_attach = function() end,
                        })
                    end,

                    -- Pyright (Python)
                    pyright = function()
                        lspconfig.pyright.setup({
                            capabilities = capabilities,
                            on_attach = function() end,
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

                    -- Ruff (Python Linter)
                    ruff = function()
                        lspconfig.ruff.setup({
                            capabilities = capabilities,
                            init_options = {
                                settings = {
                                    args = { "--ignore=E501" },
                                },
                            },
                            on_attach = function(client, _)
                                client.server_capabilities.hoverProvider = false
                            end,
                        })
                    end,

                    -- Lua LS
                    lua_ls = function()
                        lspconfig.lua_ls.setup({
                            capabilities = capabilities,
                            on_attach = function() end,
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

                    -- Marksman (Markdown)
                    marksman = function()
                        lspconfig.marksman.setup({
                            capabilities = capabilities,
                            on_attach = function(_, bufnr)
                                vim.keymap.set("n", "<leader>md", vim.lsp.buf.definition,
                                    { buffer = bufnr, desc = "Markdown Go to Definition" })
                                vim.keymap.set("n", "<leader>ml", vim.lsp.buf.rename,
                                    { buffer = bufnr, desc = "Markdown Rename" })
                            end,
                            filetypes = { "markdown", "markdown.mdx" },
                        })
                    end,

                    -- Bash
                    bashls = function()
                        lspconfig.bashls.setup({
                            capabilities = capabilities,
                            on_attach = function() end,

                            filetypes = { "sh", "zsh", "bash" },
                        })
                    end,

                    -- C/C++ (Clangd)
                    clangd = function()
                        lspconfig.clangd.setup({
                            capabilities = capabilities,
                            on_attach = function() end,

                            cmd = { "clangd", "--background-index" },
                        })
                    end,
                },
            }
        end,
    },

    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            -- Keymaps and capabilities setup
            --local capabilities = require("cmp_nvim_lsp").default_capabilities()


            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr = args.buf

                    -- Attach lsp_signature
                    require("lsp_signature").on_attach({
                        bind = true,
                        hint_enable = false,
                        floating_window = true,
                        handler_opts = { border = "rounded" },
                    }, bufnr)

                    -- General LSP mappings
                    local opts = { buffer = bufnr }
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                end,
            })


            -- -- Auto-start marksman for markdown files
            -- vim.api.nvim_create_autocmd("FileType", {
            --     pattern = "markdown",
            --     callback = function()
            --         if not require("lspconfig").marksman.manager then
            --             require("lspconfig").marksman.vim.lsp.buff_add()
            --         end
            --     end,
            -- })
        end,
    },


}
