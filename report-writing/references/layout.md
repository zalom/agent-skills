# The page

Open this when styling a report, adding a page, a table, a figure, or an expander, or when
the print layout matters. The template `assets/report-page.html` carries this style; start a
new document from it.

## Contents

- Structure
- Type and palette
- Tables
- Figures
- Expanders
- Print

## Structure

- One `<main>` column, at most 1,040 pixels wide, padded on the sides.
- Each page is a `<section class="page">` with a `data-page` number and a first line
  `<p class="page-label">Title · n of N</p>`. The count is updated whenever a page is added or
  removed.
- Page 1 holds the header (byline, title, lede, one line of context) and a table that maps
  the sections to their supporting documents when supporting documents exist.
- A section starts with a number line, a heading, and the figure or table that carries it,
  then the prose that the figure needs.
- No cards, no side-by-side columns, no icons, no decoration.
- Every section has an `id`, and in-document links use it. Links to supporting documents are
  relative file names in the source and open in a new tab.

## Type and palette

| Role | Face | Fallback |
|---|---|---|
| Headings, labels, captions, table heads, navigation | Bricolage Grotesque | Helvetica Neue, Arial, sans-serif |
| Body and table cells | Source Serif 4 | Georgia, Times New Roman, serif |
| Code and field names | JetBrains Mono | SFMono-Regular, Consolas, monospace |

Faces are loaded from Google Fonts with `display=swap`. Body text is 18 pixels at 1.65 line
height, paragraphs at most 76 characters wide.

| Token | Value | Used for |
|---|---|---|
| `--ground` | `#F7F6F3` | Page background |
| `--raised` | `#FFFFFF` | Tables and figures |
| `--ink` | `#1A1D23` | Text |
| `--soft` | `#3D434E` | Captions and notes |
| `--muted` | `#6B7285` | Labels, bylines, table heads |
| `--rule` | `#DCD9D2` | Rules and borders |
| `--teal`, `--teal-soft` | `#2E7D76`, `#D7EBE8` | Links, the primary system, chosen items |
| `--amber`, `--amber-soft` | `#B77914`, `#F5E6C9` | Candidates, conditions, steps |
| `--indigo`, `--indigo-soft` | `#5B5FA8`, `#E2E3F4` | People |

The same tokens style the diagrams, so a figure drawn with the `c4-model-diagramming` skill
<!-- lint-ok: shorthand; C4 is the name of the model -->
sits in the page without a second palette.

## Tables

- A table sits in `<div class="table-scroll">` so a wide table scrolls on a narrow screen
  and prints at full width.
- `<caption>` comes first and starts with the number in bold: `<b>Table 3.</b> Release
  decisions and their evidence`.
- Column heads use `scope="col"`. Heads are short; the unit goes in the head, not in every
  cell.
- A status tag is a `<span class="tag yes">` or `<span class="tag condition">`, uppercase,
  used only where a column holds a verdict.
- A cell holds one kind of thing. A row that needs a second paragraph uses `<p>` inside the
  cell.

## Figures

- A figure is `<figure>` holding `<div class="diagram-scroll">` with the inline SVG, then
  `<figcaption>` starting with the number: "Figure 2. The pilot's three containers and what
  each one reads."
- The SVG carries `role="img"`, a `<title>`, and a `<desc>` that says in words what the
  picture shows, for readers without the picture.
- The SVG fills the column width and never crops; the smallest label reads at the column
  width.

## Expanders

- Optional detail goes in `<details>` with a `<summary>` that names what opens. The summary
  is a noun phrase, not "More".
- An expander is closed in the source and prints open.

## Print

- `@page` is the A4 paper size with 15 millimeter margins; the body drops to 10.4 points. <!-- lint-ok: shorthand; A4 is the name of the paper size -->
- A page section breaks before the next page; a figure, a table row, and a heading with its
  first paragraph never break inside.
- Navigation is hidden; links print as text in the body color.
- Tables lose their minimum width and scroll containers lose their borders.
