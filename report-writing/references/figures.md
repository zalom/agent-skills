# Figures

Open this when deciding whether a figure earns its place, numbering and captioning it, or
placing an architecture view.

## When a figure earns its place

| The text would say | Draw |
|---|---|
| How parts connect, who uses what, what talks to what | An architecture view |
| What happens in which order | A flow with numbered steps |
| How one thing became another over stages | A progression, one row per stage |
| How options compare on the same parts | One base with a fill per option |
| A quantity over time or across categories | A chart, with the data in a table beside it |

A figure that repeats a table, or that shows one box, is cut. A figure that needs a paragraph
to be understood is redrawn.

## Architecture views

Draw architecture with the `c4-model-diagramming` skill <!-- lint-ok: shorthand; C4 is the name of the model -->
and choose the view by what the section decides:

| The section decides | View |
|---|---|
| Who uses the system and what it depends on | System context |
| What runs, with which technology, and what each part stores | Container |
| How one container is built, or how two implementation options differ | Component, one base with a fill per option |
| What happens for one question, step by step | Dynamic |
| Where it runs and how many of each | Deployment |

The skill's own reference on placing figures in a document holds the numbering, caption, and
font rules for a set that goes into a report.

## Numbering and captions

- Figures and tables are numbered separately, each in reading order through the whole
  document.
- The text refers to every figure and table by number, lowercase mid-sentence: "figure 3
  shows". A figure nobody refers to is cut.
- The caption says what the reader should see, in one or two sentences, and names the scope.
  It does not repeat the diagram's own title line.
- After a figure is added or removed, every later number and every reference moves; check
  the last reference in the document.

## Reuse

- A figure that exists in another built page is copied as its SVG, never redrawn.
- A figure placed in two documents is the same SVG in both, with each document's own number.
- Fonts and color tokens come from the page, so a copied figure takes the host's style.
