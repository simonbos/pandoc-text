pandoc-text
===========
A Lua [custom writer for Pandoc](https://pandoc.org/MANUAL.html#custom-writers) generating a plain text file with as few markup as possible. The goal of the custom writer is to generate a plain text file that contains all displayed text but doesn't confuse spelling and grammar checkers. To this purpose, following rules are applied:
- The abstract is added at the beginning of the document.
- All inline equations, inline code and unresolved links are replaced by respectively `Xi`, `Ci` and `Li` (with i corresponding to the i'th appearance).
- Footnotes are displayed in the text as `^i` (with i corresponding to the i'th appearance) and the content is appended at the end of the document.
- Images and tables are removed and their captions are appended at the end of the document.

### Installation
Just download the file `pandoc-text.lua` and put it in a convenient location. (Pandoc includes a lua interpreter, so lua need not be installed separately.)

### Usage
To convert the LaTeX file `examples/example.tex`, use the following command:

```
pandoc --citeproc \
       --csl https://www.zotero.org/styles/ieee \
       --bibliography examples/example.bib \
       -f latex \
       -t pandoc-text.lua \
       -o example.txt \
       examples/example.tex
```
One-liner: `pandoc --citeproc --csl https://www.zotero.org/styles/ieee --bibliography examples/example.bib -f latex -t pandoc-text.lua -o example.txt examples/example.tex`

### Known issues
- In LaTeX, captions of tikzpicture environments inside figure environments are parsed incorrectly.
  Therefore, these do not show up in the resulting document.
  See: https://github.com/jgm/pandoc/issues/5084
