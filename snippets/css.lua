local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Flex container: flex<Tab>
  s("flex", fmt([[
display: flex;
flex-direction: {};
gap: {};
align-items: {};
justify-content: {};
]], {
    i(1, "row"),
    i(2, "0.5rem"),
    i(3, "center"),
    i(4, "space-between"),
  })),

  -- Grid container: grid<Tab>
  s("grid", fmt([[
display: grid;
grid-template-columns: repeat({}, 1fr);
gap: {};
]], { i(1, "3"), i(2, "1rem") })),

  -- Media query: mq<Tab>
  s("mq", fmt([[
@media (max-width: {}px) {{
  {}
}}
]], { i(1, "768"), i(2) })),

  -- Center block: center<Tab>
  s("center", fmt([[
margin-left: auto;
margin-right: auto;
max-width: {};
]], { i(1, "70ch") })),
}
