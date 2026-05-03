return {
  {
    "vimtex",
    for_cat = 'latex',
    ft = { "tex", "bib" },
    before = function(_)
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_compiler_method = 'latexmk'
      vim.g.vimtex_mappings_enabled = 1
    end,
    after = function(_)
      vim.keymap.set("n", "<leader>lc", "<cmd>VimtexCompile<CR>",    { desc = "LaTeX compile" })
      vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<CR>",       { desc = "LaTeX view PDF" })
      vim.keymap.set("n", "<leader>le", "<cmd>VimtexErrors<CR>",     { desc = "LaTeX errors" })
      vim.keymap.set("n", "<leader>ls", "<cmd>VimtexStop<CR>",       { desc = "LaTeX stop compiler" })
      vim.keymap.set("n", "<leader>lt", "<cmd>VimtexTocToggle<CR>",  { desc = "LaTeX TOC toggle" })
      vim.keymap.set("n", "<leader>lw", "<cmd>VimtexCountWords<CR>", { desc = "LaTeX word count" })

      local ls = require('luasnip')
      local s = ls.snippet
      local sn = ls.snippet_node
      local t = ls.text_node
      local i = ls.insert_node
      local d = ls.dynamic_node
      local fmt = require('luasnip.extras.fmt').fmt
      local rep = require('luasnip.extras').rep

      local in_mathzone = function()
        local ok, result = pcall(function()
          return vim.fn['vimtex#syntax#in_mathzone']() == 1
        end)
        return ok and result
      end

      local math = { condition = in_mathzone }

      -- ── Structural snippets (always available in tex) ─────────────────────
      ls.add_snippets("tex", {
        s({ trig = "mk", name = "inline math" },
          fmt("${}$", { i(1) })),

        s({ trig = "dm", name = "display math" },
          fmt("\\[\n\t{}\n\\]", { i(1) })),

        s({ trig = "beg", name = "begin/end environment" },
          fmt("\\begin{{{}}}\n\t{}\n\\end{{{}}}", { i(1), i(2), rep(1) })),

        s({ trig = "ali", name = "align*" },
          fmt("\\begin{{align*}}\n\t{}\n\\end{{align*}}", { i(1) })),

        s({ trig = "eq", name = "equation*" },
          fmt("\\begin{{equation*}}\n\t{}\n\\end{{equation*}}", { i(1) })),

        s({ trig = "thm", name = "theorem" },
          fmt("\\begin{{theorem}}\n\t{}\n\\end{{theorem}}", { i(1) })),

        s({ trig = "prop", name = "proposition" },
          fmt("\\begin{{proposition}}\n\t{}\n\\end{{proposition}}", { i(1) })),

        s({ trig = "lem", name = "lemma" },
          fmt("\\begin{{lemma}}\n\t{}\n\\end{{lemma}}", { i(1) })),

        s({ trig = "def", name = "definition" },
          fmt("\\begin{{definition}}\n\t{}\n\\end{{definition}}", { i(1) })),

        s({ trig = "cor", name = "corollary" },
          fmt("\\begin{{corollary}}\n\t{}\n\\end{{corollary}}", { i(1) })),

        s({ trig = "prf", name = "proof" },
          fmt("\\begin{{proof}}\n\t{}\n\\end{{proof}}", { i(1) })),

        s({ trig = "bf", name = "bold text" },
          fmt("\\textbf{{{}}}", { i(1) })),

        s({ trig = "em", name = "italic/emphasis" },
          fmt("\\emph{{{}}}", { i(1) })),

        s({ trig = "sec", name = "section" },
          fmt("\\section{{{}}}", { i(1) })),

        s({ trig = "ssec", name = "subsection" },
          fmt("\\subsection{{{}}}", { i(1) })),
      })

      -- ── Math-mode autosnippets (Castel-style) ─────────────────────────────
      ls.add_snippets("tex", {
        -- Fractions
        s({ trig = "//", name = "fraction", snippetType = "autosnippet" },
          fmt("\\frac{{{}}}{{{}}} ", { i(1), i(2) }),
          math),

        -- Parenthesised expression → fraction: (expr)//
        s({ trig = "(%b())//", name = "fraction from parens", snippetType = "autosnippet", regTrig = true },
          d(1, function(_, snip)
            local content = snip.captures[1]:sub(2, -2)
            return sn(nil, { t("\\frac{" .. content .. "}{"), i(1), t("}") })
          end),
          math),

        -- Powers / decorators
        s({ trig = "sr",    name = "squared",    snippetType = "autosnippet" }, t("^{2}"),    math),
        s({ trig = "cb",    name = "cubed",      snippetType = "autosnippet" }, t("^{3}"),    math),
        s({ trig = "compl", name = "complement", snippetType = "autosnippet" }, t("^{c}"),    math),
        s({ trig = "td",    name = "to power",   snippetType = "autosnippet" },
          fmt("^{{{}}}", { i(1) }), math),

        s({ trig = "hat",  name = "hat",       snippetType = "autosnippet" }, fmt("\\hat{{{}}}",      { i(1) }), math),
        s({ trig = "bar",  name = "overline",  snippetType = "autosnippet" }, fmt("\\overline{{{}}}",  { i(1) }), math),
        s({ trig = "vec",  name = "vector",    snippetType = "autosnippet" }, fmt("\\vec{{{}}}",      { i(1) }), math),
        s({ trig = "tld",  name = "tilde",     snippetType = "autosnippet" }, fmt("\\tilde{{{}}}",    { i(1) }), math),
        s({ trig = "dot",  name = "dot",       snippetType = "autosnippet" }, fmt("\\dot{{{}}}",      { i(1) }), math),
        s({ trig = "ddot", name = "ddot",      snippetType = "autosnippet" }, fmt("\\ddot{{{}}}",     { i(1) }), math),

        -- Relations
        s({ trig = "!=", name = "neq",    snippetType = "autosnippet" }, t("\\neq "),    math),
        s({ trig = ">=", name = "geq",    snippetType = "autosnippet" }, t("\\geq "),    math),
        s({ trig = "<=", name = "leq",    snippetType = "autosnippet" }, t("\\leq "),    math),
        s({ trig = ">>", name = "gg",     snippetType = "autosnippet" }, t("\\gg "),     math),
        s({ trig = "<<", name = "ll",     snippetType = "autosnippet" }, t("\\ll "),     math),
        s({ trig = "~~", name = "sim",    snippetType = "autosnippet" }, t("\\sim "),    math),
        s({ trig = "~=", name = "approx", snippetType = "autosnippet" }, t("\\approx "), math),
        s({ trig = "==", name = "aligned equals", snippetType = "autosnippet" }, t("&= "), math),

        -- Arrows
        s({ trig = "->",  name = "to",              snippetType = "autosnippet" }, t("\\to "),             math),
        s({ trig = "!>",  name = "mapsto",           snippetType = "autosnippet" }, t("\\mapsto "),         math),
        s({ trig = "<->", name = "leftrightarrow",   snippetType = "autosnippet" }, t("\\leftrightarrow "), math),
        s({ trig = "=>",  name = "implies",          snippetType = "autosnippet" }, t("\\implies "),        math),
        s({ trig = "=<",  name = "impliedby",        snippetType = "autosnippet" }, t("\\impliedby "),      math),
        s({ trig = "iff", name = "iff",              snippetType = "autosnippet" }, t("\\iff "),            math),

        -- Common symbols
        s({ trig = "ooo",   name = "infinity",  snippetType = "autosnippet" }, t("\\infty "),    math),
        s({ trig = "...",   name = "ldots",     snippetType = "autosnippet" }, t("\\ldots"),      math),
        s({ trig = "nab",   name = "nabla",     snippetType = "autosnippet" }, t("\\nabla "),     math),
        s({ trig = "partial", name = "partial", snippetType = "autosnippet" }, t("\\partial "),   math),

        -- Roots / norms
        s({ trig = "sq",   name = "sqrt",           snippetType = "autosnippet" }, fmt("\\sqrt{{{}}}",  { i(1) }), math),
        s({ trig = "norm", name = "norm",            snippetType = "autosnippet" }, fmt("\\|{}\\|",       { i(1) }), math),
        s({ trig = "abs",  name = "absolute value",  snippetType = "autosnippet" }, fmt("|{}|",           { i(1) }), math),

        -- Number sets (double-struck)
        s({ trig = "RR", name = "real numbers",     snippetType = "autosnippet" }, t("\\mathbb{R}"), math),
        s({ trig = "QQ", name = "rationals",        snippetType = "autosnippet" }, t("\\mathbb{Q}"), math),
        s({ trig = "ZZ", name = "integers",         snippetType = "autosnippet" }, t("\\mathbb{Z}"), math),
        s({ trig = "NN", name = "naturals",         snippetType = "autosnippet" }, t("\\mathbb{N}"), math),
        s({ trig = "CC", name = "complex numbers",  snippetType = "autosnippet" }, t("\\mathbb{C}"), math),
        s({ trig = "OO", name = "emptyset",         snippetType = "autosnippet" }, t("\\emptyset"),  math),

        -- Set operations
        s({ trig = "inn",   name = "in",        snippetType = "autosnippet" }, t("\\in "),      math),
        s({ trig = "notin", name = "not in",    snippetType = "autosnippet" }, t("\\notin "),   math),
        s({ trig = "sbs",   name = "subset",    snippetType = "autosnippet" }, t("\\subset "),  math),
        s({ trig = "sps",   name = "supset",    snippetType = "autosnippet" }, t("\\supset "),  math),
        s({ trig = "cap",   name = "intersect", snippetType = "autosnippet" }, t("\\cap "),     math),
        s({ trig = "cup",   name = "union",     snippetType = "autosnippet" }, t("\\cup "),     math),

        -- Big operators
        s({ trig = "sum", name = "sum", snippetType = "autosnippet" },
          fmt("\\sum_{{{}}}^{{{}}} {}", { i(1, "n=1"), i(2, "\\infty"), i(3) }),
          math),
        s({ trig = "prod", name = "product", snippetType = "autosnippet" },
          fmt("\\prod_{{{}}}^{{{}}} {}", { i(1, "n=1"), i(2, "\\infty"), i(3) }),
          math),
        s({ trig = "lim", name = "limit", snippetType = "autosnippet" },
          fmt("\\lim_{{{}}} {}", { i(1, "n \\to \\infty"), i(2) }),
          math),
        s({ trig = "int", name = "integral", snippetType = "autosnippet" },
          fmt("\\int_{{{}}}^{{{}}} {} \\, d{}", { i(1, "-\\infty"), i(2, "\\infty"), i(3), i(4, "x") }),
          math),

        -- Delimiters
        s({ trig = "lr(",  name = "left-right parens",   snippetType = "autosnippet" }, fmt("\\left( {} \\right)",     { i(1) }), math),
        s({ trig = "lr[",  name = "left-right brackets",  snippetType = "autosnippet" }, fmt("\\left[ {} \\right]",     { i(1) }), math),
        s({ trig = "lr{",  name = "left-right braces",    snippetType = "autosnippet" }, fmt("\\left\\{{ {} \\right\\}}", { i(1) }), math),
        s({ trig = "lr|",  name = "left-right abs",        snippetType = "autosnippet" }, fmt("\\left| {} \\right|",    { i(1) }), math),

        -- Fonts
        s({ trig = "mcal", name = "mathcal",    snippetType = "autosnippet" }, fmt("\\mathcal{{{}}}",  { i(1) }), math),
        s({ trig = "mbb",  name = "mathbb",     snippetType = "autosnippet" }, fmt("\\mathbb{{{}}}",   { i(1) }), math),
        s({ trig = "mbf",  name = "mathbf",     snippetType = "autosnippet" }, fmt("\\mathbf{{{}}}",   { i(1) }), math),
        s({ trig = "text", name = "text in math", snippetType = "autosnippet" }, fmt("\\text{{{}}}",   { i(1) }), math),

        -- Greek letters (;letter prefix to avoid conflicts)
        s({ trig = ";a",  name = "alpha",   snippetType = "autosnippet" }, t("\\alpha"),   math),
        s({ trig = ";b",  name = "beta",    snippetType = "autosnippet" }, t("\\beta"),    math),
        s({ trig = ";g",  name = "gamma",   snippetType = "autosnippet" }, t("\\gamma"),   math),
        s({ trig = ";G",  name = "Gamma",   snippetType = "autosnippet" }, t("\\Gamma"),   math),
        s({ trig = ";d",  name = "delta",   snippetType = "autosnippet" }, t("\\delta"),   math),
        s({ trig = ";D",  name = "Delta",   snippetType = "autosnippet" }, t("\\Delta"),   math),
        s({ trig = ";e",  name = "epsilon", snippetType = "autosnippet" }, t("\\epsilon"), math),
        s({ trig = ";ve", name = "varepsilon", snippetType = "autosnippet" }, t("\\varepsilon"), math),
        s({ trig = ";z",  name = "zeta",    snippetType = "autosnippet" }, t("\\zeta"),    math),
        s({ trig = ";h",  name = "eta",     snippetType = "autosnippet" }, t("\\eta"),     math),
        s({ trig = ";t",  name = "theta",   snippetType = "autosnippet" }, t("\\theta"),   math),
        s({ trig = ";T",  name = "Theta",   snippetType = "autosnippet" }, t("\\Theta"),   math),
        s({ trig = ";i",  name = "iota",    snippetType = "autosnippet" }, t("\\iota"),    math),
        s({ trig = ";k",  name = "kappa",   snippetType = "autosnippet" }, t("\\kappa"),   math),
        s({ trig = ";l",  name = "lambda",  snippetType = "autosnippet" }, t("\\lambda"),  math),
        s({ trig = ";L",  name = "Lambda",  snippetType = "autosnippet" }, t("\\Lambda"),  math),
        s({ trig = ";m",  name = "mu",      snippetType = "autosnippet" }, t("\\mu"),      math),
        s({ trig = ";n",  name = "nu",      snippetType = "autosnippet" }, t("\\nu"),      math),
        s({ trig = ";x",  name = "xi",      snippetType = "autosnippet" }, t("\\xi"),      math),
        s({ trig = ";X",  name = "Xi",      snippetType = "autosnippet" }, t("\\Xi"),      math),
        s({ trig = ";p",  name = "pi",      snippetType = "autosnippet" }, t("\\pi"),      math),
        s({ trig = ";P",  name = "Pi",      snippetType = "autosnippet" }, t("\\Pi"),      math),
        s({ trig = ";r",  name = "rho",     snippetType = "autosnippet" }, t("\\rho"),     math),
        s({ trig = ";s",  name = "sigma",   snippetType = "autosnippet" }, t("\\sigma"),   math),
        s({ trig = ";S",  name = "Sigma",   snippetType = "autosnippet" }, t("\\Sigma"),   math),
        s({ trig = ";o",  name = "omega",   snippetType = "autosnippet" }, t("\\omega"),   math),
        s({ trig = ";O",  name = "Omega",   snippetType = "autosnippet" }, t("\\Omega"),   math),
        s({ trig = ";f",  name = "phi",     snippetType = "autosnippet" }, t("\\phi"),     math),
        s({ trig = ";F",  name = "Phi",     snippetType = "autosnippet" }, t("\\Phi"),     math),
        s({ trig = ";vf", name = "varphi",  snippetType = "autosnippet" }, t("\\varphi"),  math),
        s({ trig = ";c",  name = "chi",     snippetType = "autosnippet" }, t("\\chi"),     math),
        s({ trig = ";ps", name = "psi",     snippetType = "autosnippet" }, t("\\psi"),     math),
        s({ trig = ";Ps", name = "Psi",     snippetType = "autosnippet" }, t("\\Psi"),     math),
      })
    end,
  },
}
