local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Fenced code block: code<Tab>
  s("code", fmt([[
```{}
{}
```
]], { i(1, "text"), i(2) })),

  -- Link: link<Tab>
  s("link", fmt("[{}]({})", { i(1, "text"), i(2, "url") })),

  -- Image: img<Tab>
  s("img", fmt("![{}]({})", { i(1, "alt"), i(2, "path") })),

  -- Callout (Obsidian-style): note<Tab>
  s("note", fmt([[
> [!{}] {}
> {}
]], { i(1, "NOTE"), i(2, "Title"), i(3) })),

  -- Simple table: tbl<Tab>
  s("tbl", fmt([[
| {} | {} |
| --- | --- |
| {} | {} |
]], { i(1, "Header 1"), i(2, "Header 2"), i(3, "Cell 1"), i(4, "Cell 2") })),
}
