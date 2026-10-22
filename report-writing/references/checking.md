# Checking before it ships

Open this before a report is published or packaged, and after any edit to an accepted
report.

## Contents

- Lint the prose
- Render every page
- Review with a reviewer model
- Record the review

## Lint the prose

Run the `plain-writing` lint on every changed document and fix every finding:

```sh
ruby PLAIN_WRITING_DIR/hooks/lint.rb path/to/report.html
```

`PLAIN_WRITING_DIR` is the installed `plain-writing` skill directory. A finding that is the
owner's agreed term (a product name, an agreed label) is kept with an inline
`<!-- lint-ok: RULE; REASON -->` comment on that line, never by weakening the rule.

## Render every page

Serve the folder and open the document in a browser:

```sh
ruby -run -e httpd . -p 4779
```

Then, for every page:

- Scroll the page into view and take a screenshot at the design width and at a phone width.
- Check that no figure, table, or code block is wider than its scroll container: compare
  each element's `scrollWidth` with its `clientWidth` from the browser console.
- Check that no label sits over a box, no line crosses an element, and no caption is cut.
- Open the print preview: a page breaks where the section breaks, and no figure or table row
  breaks inside.

Stop the server afterwards, and move the screenshots out of the document folder. A browser
caches the page; add a query string when a render looks stale.

## Review with a reviewer model

Put the document to the reviewer model with the `typesafe-ai` skill when it is available:

- One question per claim the reviewer should test: does the document answer what was asked,
  is each factual conclusion supported by the named evidence, is the emphasis where the
  request put it.
- Primary evidence decides every factual point. A reviewer's doubt about a fact sends the
  writer back to the source, never to a softer sentence.
- Ask independent questions together in one request. Record the input and the answers as
  files beside the review record.

When the reviewer model is not available, review by reading the source against the
evidence, and say in the report to the owner that the reviewer was not asked.

## Record the review

- A review is written to disk before it counts: the findings, what was applied, what was
  left open and why, and the owner's requests verbatim.
- The record lives beside the document in a dated review folder, never inside the document.
