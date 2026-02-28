local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Generic environment: beg<Tab>
  s("beg", fmt([[
\begin{{{}}}
  {}
\end{{{}}}
]], { i(1, "environment"), i(2), i(1) })),

  -- Figure environment: fig<Tab>
  s("fig", fmt([[
\begin{{figure}}[H]
  \centering
  \includegraphics[width=0.7\textwidth]{{figures/{}.png}}
  \caption{{{}}}
  \label{{fig:{}}}
\end{{figure}}
]], { i(1, "filename"), i(2, "caption"), i(3, "label") })),

  -- Table environment: tbl<Tab>
  s("tbl", fmt([[
\begin{{table}}[H]
  \centering
  \begin{{tabular}}{{{}}}
    \toprule
    {} \\
    \midrule
    {} \\
    \bottomrule
  \end{{tabular}}
  \caption{{{}}}
  \label{{tab:{}}}
\end{{table}}
]], {
    i(1, "lcr"),
    i(2, "Header1 & Header2 & Header3"),
    i(3, "Val1 & Val2 & Val3"),
    i(4, "Caption"),
    i(5, "label"),
  })),

  -- Sections
  s("sec", fmt("\\section{{{}}}", { i(1, "Section Title") })),
  s("ssec", fmt("\\subsection{{{}}}", { i(1, "Subsection Title") })),

  -- Math helpers
  s("frac", fmt("\\frac{{{}}}{{{}}}", { i(1), i(2) })),
  s("sum", fmt("\\sum_{{{}}}^{{{}}} {}", { i(1, "i=1"), i(2, "n"), i(3) })),
  s("int", fmt("\\int_{{{}}}^{{{}}} {}", { i(1, "a"), i(2, "b"), i(3) })),

  -- Equation / align
  s("eqn", fmt([[
\begin{{equation}}
  {}
\end{{equation}}
]], { i(1, "E = mc^2") })),

  s("aln", fmt([[
\begin{{align}}
  {}
\end{{align}}
]], { i(1) })),

  -- Itemize
  s("it", fmt([[
\begin{{itemize}}
  \item {}
\end{{itemize}}
]], { i(1) })),
}
