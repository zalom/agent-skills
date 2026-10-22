# Placing figures in a document

Open this when a diagram set goes into a report, a proposal, or a deck, or when it replaces
figures already in one.

## Numbering and captions

- Figures are numbered in reading order through the whole document, and every figure is
  referred to by its number in the text ("figure 4", lowercase mid-sentence).
- A replacement keeps the host's figure numbers. When one figure becomes two, every later
  number moves and every reference moves with it; check the last reference after the edit.
- The caption names the view and the scope, and for a fill the fill as well: "Figure 6. The
  assistant components, Rails fill: where each component is built." The caption does not
  repeat the diagram's title line.
- A caption is one or two sentences. Detail that a reader may skip goes in a note under the
  figure or in an expander, not in the caption.

## Fonts and colors

- The host adopts the set's typefaces, or the set adopts the host's, so figures and text
  share one typeface. Two sans-serif faces side by side read as a paste.
- The set's color tokens are declared once in the host's stylesheet when the host already
  has a palette, so the diagrams follow the host's light and dark sets.

## Width and overflow

- A figure sits inside the page's column at the column width. A diagram wider than the
  column is scaled, never cropped; the smallest label still reads at the scaled size.
- After the figures are in, render the document in a browser and check every page for a
  label over a box, a line through an element, and a figure that overflows the column.
  These faults never show in the source.

## One set, several documents

- The same figure placed in two documents is the same SVG, copied, never redrawn.
- Each document keeps its own numbering; a figure that is figure 3 in the proposal may be
  figure 11 in the set page.
