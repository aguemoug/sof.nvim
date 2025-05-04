-- ~/.config/nvim/lua/luasnip/tex/snippets.lua
--
--
--
local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require 'luasnip.util.events'
local ai = require 'luasnip.nodes.absolute_indexer'
local extras = require 'luasnip.extras'
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta
local conds = require 'luasnip.extras.expand_conditions'
local postfix = require('luasnip.extras.postfix').postfix
local types = require 'luasnip.util.types'
local parse = require('luasnip.util.parser').parse_snippet
local ms = ls.multi_snippet
local autosnippet = ls.extend_decorator.apply(s, { snippetType = 'autosnippet' })

--[
-- personal imports
--]
local make_condition = require('luasnip.extras.conditions').make_condition
local in_bullets_cond = make_condition(in_bullets)
local line_begin = require('luasnip.extras.conditions.expand').line_begin

function in_math()
  return vim.api.nvim_eval 'vimtex#syntax#in_mathzone()' == 1
end

-- comment detection
function in_comment()
  return vim.fn['vimtex#syntax#in_comment']() == 1
end

-- document class
function in_beamer()
  return vim.b.vimtex['documentclass'] == 'beamer'
end

-- general env function
local function env(name)
  local is_inside = vim.fn['vimtex#env#is_inside'](name)
  return (is_inside[1] > 0 and is_inside[2] > 0)
end

function in_preamble()
  return not env 'document'
end

function in_text()
  return env 'document' and not in_math()
end

function in_tikz()
  return env 'tikzpicture'
end

function in_bullets()
  return env 'itemize' or env 'enumerate'
end

function in_align()
  return env 'align' or env 'align*' or env 'aligned'
end

function show_line_begin(line_to_cursor)
  return #line_to_cursor <= 3
end

return {

  s(
    { trig = 'beg', name = 'begin/end', dscr = 'begin/end environment (generic)' },
    fmta(
      [[
    \begin{<>}
    <>
    \end{<>}
    ]],
      { i(1), i(0), rep(1) }
    ),
    { condition = in_text, show_condition = in_text }
  ),

  s(
    { trig = '-i', name = 'itemize', dscr = 'bullet points (itemize)' },
    fmta(
      [[ 
    \begin{itemize}
    \item <>
    \end{itemize}
    ]],
      { c(1, { i(0), sn(
        nil,
        fmta(
          [[
        [<>] <>
        ]],
          { i(1), i(0) }
        )
      ) }) }
    ),
    { condition = in_text, show_condition = in_text }
  ),

  -- requires enumitem
  s(
    { trig = '-e', name = 'enumerate', dscr = 'numbered list (enumerate)' },
    fmta(
      [[ 
    \begin{enumerate}<>
    \item <>
    \end{enumerate}
    ]],
      {
        c(1, {
          t '',
          sn(
            nil,
            fmta(
              [[
        [label=<>]
        ]],
              { c(1, { t '(\\alph*)', t '(\\roman*)', i(1) }) }
            )
          ),
        }),
        c(2, { i(0), sn(
          nil,
          fmta(
            [[
        [<>] <>
        ]],
            { i(1), i(0) }
          )
        ) }),
      }
    ),
    { condition = in_text, show_condition = in_text }
  ),

  -- generate new bullet points
  autosnippet({ trig = '--', hidden = true }, { t '\\item' }, { condition = in_bullets * line_begin, show_condition = in_bullets }),
}
