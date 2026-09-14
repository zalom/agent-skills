# Write for a Global Audience (Translation)

Source: https://developers.google.com/style/translation

Docs are written in US English but often translated or read by non-native speakers — write with localization, translation, and internationalization in mind.

- **Localization** — adapting a product/docs for a specific country (beyond translation: currency, units, etc.).
- **Translation** — converting language to language; may involve localization but isn't synonymous.
- **Internationalization** — designing to minimize localization effort (e.g., isolating UI strings into separate files).

See also: Write accessible documentation, Write inclusive documentation, Voice and tone.

## Use clear, concise, unambiguous language

### Simpler words, shorter sentences
- Use simple words: *start*/*begin* not *commence*; *so* not *consequently*; *use* not *utilize*/*leverage* (unless conveying a special technical sense, e.g. "Cloud Spanner utilizes up to 100% of available CPU").
- Use one word instead of a phrase (*some*/*many* not "a number of").
- Shorter sentences translate better; English can be more compact than other languages, so translated sentences may grow substantially longer.

### Avoid phrasal verbs
- Substitute a simpler single verb where possible (exceptions: *set up*, *log in*, *sign in*).
  - Recommended: "This document uses the following terms."
  - Not recommended: "This document makes use of the following terms."

### Modifiers
- Never stack more than two nouns as modifiers of another noun.
  - Recommended: "A cloud-native DevSecOps pipeline in a hybrid environment."
  - Not recommended: "A hybrid cloud-native DevSecOps pipeline."
- Place modifiers (e.g., "only") immediately next to what they modify; rephrase if still ambiguous.
  - Recommended: "Request only one token." / "Request no more than one token."
  - Not recommended: "Only request one token."

### Active voice, present tense
- Present tense; avoid complex/uncommon verb forms.
- Active voice — passive voice obscures who performs the action.

### Words in their primary sense
- Don't reuse the same word as both noun and verb nearby.
- Avoid directional language (*above*/*below*) in procedures.

### Helper and optional words
- Use qualifying nouns for technical keywords (e.g., "the `example.yaml` file," not "`example.yaml`" alone).
- Repeat words if it improves clarity, even if "redundant."
- Keep helper words like *then*, *that*, *of* — they're often dropped in casual English but prevent ambiguity.
  - Recommended: "If the attribute key is not found, then the default value is returned."
- Don't omit relative pronouns (*that*, *which*).
  - Recommended: "You can programmatically update the rules that you previously defined."

### Abbreviations and pronouns
- Define abbreviations; spell out at least on first use.
- Clarify pronoun antecedents — replace ambiguous pronouns with the actual noun for translators working on isolated text strings.

### Apostrophes
- Don't pluralize with 's; don't pluralize/possessive trademarked names; avoid uncommon contractions.

## Address users and their needs directly
- Use "you," not "the user" or "they" (unless referring to a separate end user of the reader's own software).
- Provide context; don't assume prior knowledge.
- Avoid negative constructions ("what you can't do") when a positive framing works.

## Be consistent
- Use standard phrases for frequently repeated sentences, introductory phrases, and other common tasks.
- Use one exact term per concept throughout — inconsistent terminology raises translation costs (especially with translation memory / machine translation).
- Standard English word order (subject + verb + object); keep subject/verb near the sentence start.
- State the conditional clause before the instruction.
- Parallel, consistently formatted/punctuated list items.
- Consistent typographic formatting (don't switch between italics and underlining for emphasis) and consistent capitalization.

## Be inclusive
- Unambiguous date/time formats.
- Avoid US-centric holidays, cultural practices, sports references.
- Use a diverse set of example names.
- Avoid colloquialisms, idioms, slang (e.g., "ballpark figure," "back burner," "hang in there").
- Avoid humor — culturally specific and hard to translate.
- Avoid geographically specific references like seasons (August isn't summer in the southern hemisphere).

## Accessibility for images
- Use screenshots/figure text sparingly — images aren't translated. Convey new information through text, never only through a figure.
