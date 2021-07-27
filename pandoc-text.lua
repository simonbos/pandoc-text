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
local image_captions = {}
local table_captions = {}
local links = {}
local equations = {}
local code = {}

-- Convenience Empty methods
function EmptyInline() return "" end
function EmptyBlock() return "" end

-- Hereafter follow the required definitions for a custom writer, see:
-- https://github.com/jgm/pandoc/blob/master/src/Text/Pandoc/Writers/Custom.hs
--
-- Note on argument names:
-- 's': the value has already been Stringified
-- 'ls': the list of values have already been Stringified

function Blocksep() return "\n\n" end

function Doc(body, metadata, variables)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end

  -- Abstract
  if (metadata.abstract) then
    add(Header(1, "Abstract", {}))
    add(metadata.abstract)
  end
  -- Body
  add(body)
  -- Footnotes
  if #notes > 0 then
    add(Header(1, "Footnotes", {}))
    add(DefinitionList(notes))
  end
  -- Image captions
  if #image_captions > 0 then
    add(Header(1, "Image captions", {}))
    add(DefinitionList(image_captions))
  end
  -- Table captions
  if #table_captions > 0 then
    add(Header(1, "Table captions", {}))
    add(DefinitionList(table_captions))
  end
  return table.concat(buffer, Blocksep()) .. LineBreak()
end

-- Required definitions for Blocks
function Plain(s) return s end

function CaptionedImage(src, tit, s, attr)
    table.insert(
        image_captions,
        "Figure" .. Space() .. (#image_captions + 1) .. ":" .. Space() .. s
    )
    return EmptyBlock()
end

function Para(s) return s:gsub(SoftBreak(), Space()) end

function LineBlock(ls) return table.concat(ls, SoftBreak()) end

function RawBlock(format, str) return EmptyBlock() end

function HorizontalRule() return EmptyBlock() end

function Header(lev, s, attr) return s end

function CodeBlock(str, attr) return EmptyBlock() end

function BlockQuote(s) return DoubleQuoted(s) end

function Table(s, aligns, widths, headers, rows)
    table.insert(
        table_captions,
        "Table" .. Space() .. (#table_captions + 1) .. ":" .. Space() .. s
    )
    return EmptyBlock()
end

function BulletList(ls) return table.concat(ls, SoftBreak()) end

function OrderedList(ls) return table.concat(ls, SoftBreak()) end

function DefinitionList(ls) return table.concat(ls, SoftBreak()) end

function Div(s, attr)
    if (string.find(attr["class"], "references")) then
        -- Removing references since they usually contain a lot of abbreviations
        -- or people names which are hard to and don't need to be spell-check
        return EmptyBlock()
    elseif (attr["class"] == "IEEEkeywords") then
        -- Usefull for LaTeX documents with IEEE style
        return "Index Terms:" .. Space()  .. s
    else
        return s
    end
end

-- Required definitions for Inlines
function Str(str) return str end

function Space() return " " end

function SoftBreak() return "\n" end

function Emph(s) return s end

function Underline(s) return s end

function Strong(s) return s end

function Strikeout(s) return EmptyInline() end

function Superscript(s) return "^" .. s end

function Subscript(s) return "~" .. s end

function SmallCaps(s) return s end

function SingleQuoted(s) return "'" .. s .. "'" end

function DoubleQuoted(s) return "\"" .. s .. "\"" end

function Cite(s, cs) return s end

function Code(str, attr)
    table.insert(code, str)
    return "C"  .. #code
end

function DisplayMath(str) return EmptyInline() end

function InlineMath(str)
    table.insert(equations, str)
    return "X"  .. #equations
end

function RawInline(format, str) return EmptyInline() end

function LineBreak() return "\n" end

function Link(s, src, tit, attr)
   if string.match(s, "%[.*%]") then
       -- Unresolved links are usually enclosed by square brackets.
       -- This hack returns a number instead of the unresolved link content.
       table.insert(links, src)
       return "L" .. #links
   else
       return s
   end
end

function Image(s, src, tit, attr) return EmptyInline() end

function Note(s)
  local num = #notes + 1
  table.insert(notes, Superscript(num) .. ":" .. Space() .. s)
  return Superscript(num)
end

function Span(s, attr) return s end

-- The following code will produce runtime warnings when you haven't defined
-- all of the functions you need for the custom writer, so it's useful
-- to include when you're working on a writer.
local meta = {}
meta.__index =
  function(_, key)
    io.stderr:write(string.format("WARNING: Undefined function \'%s\'\n",key))
    return function() return "" end
  end
setmetatable(_G, meta)
