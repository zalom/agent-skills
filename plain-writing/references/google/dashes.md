# Dashes (Em Dashes)
Source: https://developers.google.com/style/dashes

For hyphens, see Hyphens, Ranges of numbers, Ranges of numbers with units.

## Em dashes
Use an em dash (long dash) to indicate a break or interruption in a sentence flow. No space before or after it.

### Typing an em dash
- HTML: `&mdash;`
- macOS: Option+Shift+hyphen
- Linux: enable Compose key, then Compose + three hyphens; or Control+Shift+U, release, type 2014, press Return
- Windows: Num Lock on, hold left Alt, type 0151 on the numeric keypad

## En dashes
Don't use en dashes. Use a hyphen or the word "to" instead (see Ranges of numbers with units, Range of numbers). A spaced en dash as an em-dash substitute is gaining ground elsewhere (mainly Canada, as of early 2016) but isn't standard in US professional publishing — only use the em dash.

## Colons instead of dashes in description lists
Don't use an em dash, en dash, or spaced hyphen to separate an item from its description — use a colon or period instead. For a series of items, use an HTML description list (`<dl>`).
- Recommended: "Example: This is an example." — Not recommended: "Example - This is an example."
- Recommended: "Appendix A: My first appendix" — Not recommended: "Appendix A—My first appendix"
- Recommended:
```html
<dl>
  <dt>Example</dt>
  <dd>This is an example.</dd>
  <dt>Another example</dt>
  <dd>This is another example.</dd>
</dl>
```
