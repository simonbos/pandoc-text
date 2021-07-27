-- pandoc-text.lua
-- Custom pandoc writer with (almost) no markup
-- Adapted from: https://github.com/jgm/pandoc/blob/master/data/sample.lua
--
-- Invoke with: pandoc -t pandoc-text.lua

-- The global variable PANDOC_DOCUMENT contains the full AST of
-- the document which is going to be written. It can be used to
-- configure the writer.
local meta = PANDOC_DOCUMENT.meta

-- Extra tables to store footnotes, captions, figure references,
-- equations and code.
local notes = {}
local captions = {}
local fig_refs = {}
local equations = {}
local code = {}

-- Required definitions.
function Blocksep() return "\n\n" end

function Doc(body, metadata, variables)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  if (metadata.abstract) then
    add(Header(1, 'Abstract', {}) .. "\n")
    add(metadata.abstract .. "\n")
  end
  add(body)
  if #notes > 0 then
    add('Footnotes:')
    for _,note in pairs(notes) do
      add(note)
    end
  end
  if #captions > 0 then
    if #notes > 0 then add('\nCaptions:') else add('Captions:') end
    for _,caption in pairs(captions) do
      add(caption)
    end
  end
  return table.concat(buffer,'\n') .. '\n'
end

function Str(s) return s end

function Space() return " " end

function SoftBreak() return "\n" end

function LineBreak() return "\n" end

function Emph(s) return Str(s) end

function Strong(s) return Str(s) end

function Subscript(s) return "~" .. Str(s) end

function Superscript(s) return "^" .. Str(s) end

function SmallCaps(s) return Str(s) end

function Strikeout(s) return '' end

function Link(s, tgt, tit, attr)
   if string.match(s, '%[fig:.*%]') then
       -- Due to a bug in pandoc, tikzpicture environments inside figure environments are parsed
       -- incorrectly. Therefore, also the references are wrong. This hack adds a random number
       -- as reference text instead of [fig:...]
       -- See: https://github.com/jgm/pandoc/issues/5084
       local num = #fig_refs + 1
       table.insert(fig_refs, tgt)
       return num
   else
       return s
   end
end

function Image(s, src, tit, attr) return '' end

function Code(s, attr)
    local num = #code + 1
    table.insert(code, s)
    return "C"  .. num
end

function InlineMath(s)
    local num = #equations + 1
    table.insert(equations, s)
    return "X"  .. num
end

function DisplayMath(s) return '' end

function SingleQuoted(s) return "'" .. Str(s) .. "'" end

function DoubleQuoted(s) return '"' .. Str(s) .. '"' end

function Note(s)
  local num = #notes + 1
  table.insert(notes, '[F' .. num .. ']' .. Space() .. Str(s))
  return Space() .. '[F' .. num .. ']'
end

function Span(s, attr) return Str(s) end

function RawInline(format, str) return str end

function Cite(s, cs) return s end

function Plain(s) return Str(s) end

function Para(s) return Str(s:gsub('\n', Space())) end

function Header(lev, s, attr) return Str(s) end

function BlockQuote(s) return DoubleQuoted(s) end

function HorizontalRule() return '' end

function LineBlock(ls) return table.concat(ls, '\n') end

function CodeBlock(s, attr) return '' end

function BulletList(items) return table.concat(items, "\n") .. "\n" end

function OrderedList(items) return table.concat(items, "\n") .. "\n" end

function DefinitionList(items) return table.concat(items, "\n") .. "\n" end

function CaptionedImage(src, tit, caption, attr)
    local num = #captions + 1
    table.insert(captions, '[C' .. num .. ']' .. Space() .. caption)
    return ''
end

function Table(caption, aligns, widths, headers, rows)
    local num = #captions + 1
    table.insert(captions, '[C' .. num .. ']' .. Space() .. caption)
    return ''
end

function RawBlock(format, str) return str end

function Div(s, attr)
    if (string.find(attr['class'], 'references')) then
        return ''
    elseif (attr['class'] == 'csl-entry') then
        return ''
    elseif (attr['class'] == 'IEEEkeywords') then
        return "Index Terms:" .. Space()  .. Str(s)
    else
        return Str(s)
    end
end

-- The following code will produce runtime warnings when you haven't defined
-- all of the functions you need for the custom writer, so it's useful
-- to include when you're working on a writer.
local meta = {}
meta.__index =
  function(_, key)
    io.stderr:write(string.format("WARNING: Undefined function '%s'\n",key))
    return function() return "" end
  end
setmetatable(_G, meta)
