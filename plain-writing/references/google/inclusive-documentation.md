# Write Inclusive Documentation

Source: https://developers.google.com/style/inclusive-documentation

Writing inclusively makes content more precise and clear for all readers. Avoid idiomatic/figurative language that can be misinterpreted or distracting. See also: Write for a global audience, Write accessible documentation, Voice and tone.

## Avoid unnecessarily gendered language
| Recommended | Not recommended |
|---|---|
| "Equipment installation takes around 16 person-hours to complete." | "...16 man-hours..." |
| "Build AI that benefits humanity." | "Build AI that benefits mankind." |

## Avoid figurative language
- Avoid idiomatic/figurative language — hard to understand, distracting, or untranslatable.
- Avoid jargon (see Jargon page); use terms that are established industry standards and widely understood.
- Don't use metaphors, or a term in its metaphorical sense — use words in their primary sense (e.g., avoid *pets versus cattle* for on-prem/stateful vs. stateless cloud systems).

### Avoid ableist language
Words like *crazy*, *insane*, *blind to*/*blind eye to*, *cripple*, *dumb* — choose accurate alternatives.

| Recommended | Not recommended |
|---|---|
| "Before launch, give everything a final check for completeness and clarity." | "...a final sanity-check." |
| "There are some baffling outliers in the data." | "There are some crazy outliers in the data." |
| "It slows down the service, causing a poor user experience until the queue clears." | "It cripples the service..." |
| "Replace the placeholder in this example with the appropriate value." | "Replace the dummy variable..." |

### Avoid graphic or metaphorical language
Use precise terms instead of graphic metaphors (e.g., not *STONITH* — use "fence failed nodes"; mention the jargon term once, de-emphasized, if needed: "...(sometimes referred to as *STONITH*)"). Some industry terms (e.g., *terminate*, *execute*) have no accurate synonym and are fine as-is.

| Recommended | Not recommended |
|---|---|
| "If the connection doesn't respond, check for errors." | "If the connection hangs, check for errors." |
| "Point to **File**, and then click **New**." | "Hover over **File**, and hit **New**." |

## Write diverse and inclusive examples
- Follow gender-neutral pronoun guidance.
- Avoid being culturally specific to the US (holidays, cultural practices, sports, figures of speech).
- Use a diverse set of names in examples (see Example domains and names / Further notes about example people).
- For older adults, avoid *the elderly*, *the aged*, *seniors*, *senior citizens*, *80 years young* — use *older adults*, *aging population*, or mention relative age only when relevant.

## Write about features and users inclusively
- Avoid divisive framing (e.g., *native speakers*/*non-native speakers* of English) — reframe around the feature itself if language proficiency isn't actually relevant.
- Avoid socially charged terms for technical concepts (*blacklist*, *native feature*, *first-class citizen*) even if still widely used.

### Replace established terms
If replacing a well-established non-inclusive term risks confusing readers, state the legacy term parenthetically on first use, then use the inclusive term throughout.
- Recommended: "...add them to an allowlist (sometimes called a *whitelist*)..."
- Recommended: "...a Jenkins controller (master) handles HTTP requests..."
- Prefer rewriting over direct word-swaps when possible (e.g., rewrite around "allowlist" as a verb rather than using it as one).
  - Recommended: "You can allow requests from a range of IP addresses by entering a CIDR block..."
  - Not recommended: "You can allowlist a range of IP addresses..."

### Write around non-inclusive code terms
When a non-inclusive term is embedded in actual code/config/keywords (e.g., a cluster named `master`, or SQL's `SLAVE` keyword), you can't ignore it — but minimize its use and never use it unformatted.
- On first mention, name the code item in code font, parenthetically: "The configuration file helps you create a parent node (which is named `master` in the file)." / "Start the replica by using the `START SLAVE` statement."
- On subsequent mentions, use the preferred term (*parent node*, *replica*); only reintroduce the raw keyword in code font when strictly necessary.

## Avoid bias and harm — disability and accessibility
- Never call non-disabled people *normal* or *healthy* (implies disabled = abnormal/sick). Use *nondisabled person*, *sighted person*, *hearing person*, *person without disabilities*, *neurotypical person*.
- Research each community's preferred identification. Generally avoid personhood-erasing terms (*the disabled*, *a quadriplegic*) in favor of person-first phrasing (*people with disabilities*, *a quadriplegic person*) — BUT many communities (autistic, blind, Deaf) prefer identity-first language; capitalization conventions vary by community. Always research and match community preference.
- Use "see" for links/cross-references (sight-related language is broadly acceptable).
- Avoid terms projecting pity/judgment (*victim of*, *suffering from*, *wheelchair-bound*) — use neutral terms (*experiencing*, *living with*, *uses a wheelchair*).
- Avoid euphemisms/patronizing terms (*physically challenged*, *special*, *differently abled*, *handi-capable*).
