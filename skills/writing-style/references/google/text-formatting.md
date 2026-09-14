# Text-Formatting Summary

Source: https://developers.google.com/style/text-formatting

This page summarizes the general text-formatting conventions covered elsewhere in the style guide. For more detail, see Visual formatting (linked page).

## Bold
- Use bold formatting (`<b>` or `**`) only for UI elements and run-in headings, including at the beginning of notices.
- A double underscore (`__`) can also indicate bold in Markdown, but it's hard to distinguish in a text editor — prefer the double asterisk (`**`) for bold in Markdown.

## Italic
- Use italics sparingly overall.
- When discussing or introducing terms — e.g., defining terms or using "words as words" — use italics (`<i>` or `_`). See also: Use italics to discuss terms; Format abbreviation introductions.
- For emphasis to indicate importance, use italics, not bold or underline — but usually the words themselves can carry the emphasis without any added formatting.
  - In HTML, use the `<em>` element for semantic emphasis (renders as italics in most contexts).
  - In Markdown, use underscores (`_`) to render italics; Markdown has no separate semantic-emphasis tagging.
  - An asterisk (`*`) can also indicate italics in Markdown, but underscores are recommended so italics are easier to visually distinguish from bold in the raw Markdown file.
- Italicize titles of books, movies, web series, and other full-length works — unless the title is part of a link (see Cross-references and linking).
- Italicize mathematical variables, e.g., *x* + *y* = 3. Don't italicize mathematical operators such as the plus sign (see Mathematical notation for more).
- Italicize version variables, e.g., version 1.4.*x*.

## Underline
- Reserve underlining exclusively for link text (see Style link text).

## Code font
- Use `<code>` in HTML or backticks in Markdown to apply a monospace font and related styling to code in text, inline code, and user input.
- Use code blocks (`<pre>` in HTML or triple backticks in Markdown) for code samples or other blocks of code.
- Never override or modify font styles inline outside of these semantic mechanisms.
- Use code font to mark up: filenames, class names, method names, HTTP status codes, console output, and placeholders (see Some specific items to put in code font for the full list).

## Capitalization
- Use American English style for general capitalization.
- Use sentence case in ALL headings, titles, and navigation.
- Use all-capitals for placeholders.

## Quotation marks
- Use American English style when punctuating quotations.
- Put titles of shorter works (articles, episodes in a web series, etc.) in quotation marks — unless the title is part of a link.

## Font type, size, and color
- Never override global site styles for font type, size, or color.
- Use semantic HTML or Markdown to control text style on a page — e.g., `<code>` tags in HTML or backticks in Markdown — instead of manually applying a monospace font or other styling.

## Other punctuation conventions
- Don't use ampersands (`&`) as conjunctions or shorthand for "and," including in headings and navigation — use "and" instead.
  - **Exception**: OK to use `&` when referring to a UI element or a menu name that itself uses `&`.
- Put quotation marks and end punctuation OUTSIDE of link text (see "Punctuation around link text" and "Quotation marks and italics" sections of the Cross-references and linking page).

## More resources
- Mathematical notation (linked page, for formatting math expressions, variables, and operators)
