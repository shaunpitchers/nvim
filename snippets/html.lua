local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	-- HTML5 boilerplate: html<Tab>
	s(
		"html",
		fmt(
			[[
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{}</title>
    <link rel="stylesheet" href="{}" />
  </head>
  <body>
    {}
  </body>
</html>
]],
			{ i(1, "Title"), i(2, "style.css"), i(3) }
		)
	),

	-- div with class: divc<Tab>
	s("divc", fmt('<div class="{}">\n  {}\n</div>', { i(1, "class"), i(2) })),

	-- link tag: a<Tab>
	s("a", fmt('<a href="{}">{}</a>', { i(1, "url"), i(2, "text") })),

	-- script include: js<Tab>
	s("js", fmt('<script src="{}"></script>', { i(1, "app.js") })),
}
