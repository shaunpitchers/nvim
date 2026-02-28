return {
  -- Completion core (always available)
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "onsails/lspkind.nvim",
      -- snippet deps are intentionally NOT here anymore
    },
    config = function()
      local cmp = require("cmp")

      local has_luasnip, luasnip = pcall(require, "luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            if has_luasnip then
              luasnip.lsp_expand(args.body)
            end
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),

          -- Keep Tab simple unless LuaSnip is loaded
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif has_luasnip and luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif has_luasnip and luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          -- Snippet source only works when loaded (see below)
          { name = "buffer" },
          { name = "path" },
        }),

        formatting = {
          format = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            menu = {
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              path = "[Path]",
              luasnip = "[Snip]",
            },
          }),
        },
      })
    end,
  },

  -- Snippets only for writing filetypes
  {
    "L3MON4D3/LuaSnip",
    ft = { "tex", "plaintex", "markdown", "html", "css", "python" },
    build = "make install_jsregexp",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local luasnip = require("luasnip")
      luasnip.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
      })

      -- load friendly-snippets lazily
      require("luasnip.loaders.from_vscode").lazy_load()

      -- load your personal Lua snippets (kept small + intentional)
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })

      -- Treat tex as latex for snippet purposes
      luasnip.filetype_extend("tex", { "latex" })
      luasnip.filetype_extend("plaintex", { "latex" })

      -- When LuaSnip loads, also enable the cmp snippet source
      local ok, cmp = pcall(require, "cmp")
      if ok then
        cmp.setup.buffer({
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
          }),
        })
      end
    end,
  },
}

