# Write Accessible Documentation

Source: https://developers.google.com/style/accessibility

15% of the world's population (1B+ people) has an accessibility need; accessible writing improves the experience for all readers. See also: Write for a global audience, Write inclusive documentation, Voice and tone.

## General dos and don'ts
- No ableist language (see Inclusive documentation).
- Ensure full keyboard-only navigability (tabs, form buttons, interactive elements) without a mouse.
- Test with a screen reader to self-edit content.
- Use semantic HTML tagging (e.g., `em` only for actual emphasis, not to fake italics); prefer native elements over custom styles.
- Avoid unnecessary font formatting — screen readers explicitly announce text modifications.
- Explicitly document specialized accessibility features (e.g., `gcloud` CLI's percentage progress bars, ASCII box rendering).
- No forced line breaks within sentences/paragraphs (breaks poorly with resized windows/enlarged text).
- Avoid camel case and all caps when possible — some screen readers spell out capitalized letters individually; some languages are unicase.
- Avoid exclamation marks, question marks, and semicolons when possible — not all screen readers/settings read every punctuation mark; meaning must survive without them.
- No `&` instead of "and" in headings/text/nav/TOC (exception: literal UI element names, or table/diagram space constraints; code use is fine).

## Ease of reading
- Break up walls of text: paragraphs, headings, lists.
- Fewer than 26 words per sentence.
- Define acronyms/abbreviations on first use, especially if infrequent.
- Parallel structure for similar items (consistent list formatting).
- Lead each paragraph with its most important/distinguishing information.
- Clear, direct language — avoid double negatives and "exceptions to exceptions."
  - Recommended: "You can continue without a path."
  - Not recommended: "A missing path won't prevent you from continuing."
- Left-align text; never center or fully justify.

## Headings and titles
- Descriptive, unique headings/titles for navigation.
- Use a proper heading hierarchy; never skip levels (h3 only after h2).
- Change visual formatting via CSS, not by picking the "wrong" heading level.
- No empty headings or headings without associated content.
- Tag headings with real heading elements (`h1`, `h2`... or `#`, `##`...).
- One level-1 heading per page, for the page title/main heading.

## Links
- Meaningful link text that makes sense out of context (screen reader users jump link-to-link).
- Never "click here" or "read this document."
- Use "see" for links/cross-references.
- Explain unexpected link behavior (download, new tab, same-page jump).
- Avoid adjacent links; separate with an intervening character if unavoidable.

## Lists
- In a procedure, make each instruction its own list item to aid following steps.

## Images
- Alt attribute on every image; meaningful alt text, or empty alt text if purely decorative.
- Never convey new information in images alone — always provide equivalent text.
- Don't repeat images unnecessarily.
- Never use images of text, code samples, or terminal output — use real text.
- Prefer SVG over PNG (stays sharp when zoomed).

## Videos, recordings, and GIFs
- Provide captions, transcripts, or descriptions for audio/video (e.g., YouTube autocaption).
- Ensure captions can be translated into major languages.
- No flickering/flashing elements (motion sickness/seizure risk).

## Buttons and icons
- Use the native HTML `button` element for form submission.
- See UI elements and interaction → Buttons and icons for icon guidance.

## UI navigation
- When documenting menu paths with `>`, add `aria-label` so screen readers say "and then" rather than "greater than" or "right arrow."

## Tables
- Introduce tables in preceding text (not all screen readers pre-announce tables).
- Use `th` for first row/column headers only.
- Use `scope` attribute if both row and column headings exist.
- Use `headers` attribute with unique IDs if multiple rows of column headings exist.
- Avoid tables mid-procedure when possible.
- Never merge cells; no `colspan`/`rowspan`.
- Use tables only when genuinely the best format — they're hard for screen readers.
- Never convey new info via images/symbols in a table without descriptive alt text.

## Interactive elements
- Introduce interactive elements (e.g., expanders) in preceding text.
  - Recommended (if practical): "To see a list of requirements, expand the **Requirements** section."
  - Recommended: "To see a list of requirements, click the expander arrow."

## Forms
- Label every input with a `label` element, placed outside the field.
- Validation errors must state what's wrong and how to fix it (e.g., "Name is a required field").

## Custom CSS and JavaScript
- Prefer standard site styles/JS.
- Respect 4.5:1 contrast ratio for text.
- Never use `visibility:hidden` or `display:none` (hides content from screen readers).
- Avoid mouseover events; if used, add matching focus/blur events for keyboard users.
- Style-based ordering/positioning must match DOM and natural reading order.

## Document rendering — test your doc under all these conditions
- Without sound; using only sound; without images/animation; without color; using only a keyboard; with screen magnification; without punctuation.
- Never rely on color, size, location, or other visual cues as the *only* way to communicate — pair with a secondary cue (e.g., text label change).
- Refer to elements by their label; for unlabeled visual elements, use their `aria-label`, not a visual description.
  - Recommended: "Click **Save**." / "Click **Notifications**."
  - Not recommended: "Click the bell icon."
- No directional language ("above," "below," "right-hand side") — fails accessibility and localization (RTL languages flip layout). For document position, use "earlier," "preceding," "following."
  - Recommended: "In the preceding diagram..."
  - Not recommended: "In the diagram above..."
- Provide a screenshot if a UI element is hard to find by label alone.

## More resources
Google's accessibility page, WCAG 2.0, WAI, Using ARIA, Web Accessibility Tutorials.
