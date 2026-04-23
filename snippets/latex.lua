local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	-- Figure environment
	s(
		"fig",
		fmt(
			[[
    \begin{{figure}}[H]
      \centering
      \includegraphics[width=0.7\textwidth]{{figures/{}.png}}
      \caption{{{}}}
      \label{{fig:{}}}
    \end{{figure}}
  ]],
			{
				i(1, "filename"),
				i(2, "caption"),
				i(3, "label"),
			}
		)
	),

	-- Table environment
	s(
		"tbl",
		fmt(
			[[
    \begin{{table}}[H]
      \centering
      \begin{{tabular}}{{{}}}
        \toprule
        {} \\\\
        \midrule
        {} \\\\
        \bottomrule
      \end{{tabular}}
      \caption{{{}}}
      \label{{tab:{}}}
    \end{{table}}
  ]],
			{
				i(1, "lcr"),
				i(2, "Header1 & Header2 & Header3"),
				i(3, "Val1 & Val2 & Val3"),
				i(4, "Caption"),
				i(5, "label"),
			}
		)
	),

	-- Section and subsection
	s("sec", fmt("\\section{{{}}}", { i(1, "Section Title") })),
	s("ssec", fmt("\\subsection{{{}}}", { i(1, "Subsection Title") })),

	-- Numbered equation environment
	s(
		"eqn",
		fmt(
			[[
    \begin{{equation}}
      {}
    \end{{equation}}
  ]],
			{ i(1, "E = mc^2") }
		)
	),
}
