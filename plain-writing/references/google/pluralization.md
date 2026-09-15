# Pluralization

Source: https://developers.google.com/style/pluralization

Follow standard US English pluralization rules; use the regular plural form in most cases. Avoid *'s* for plurals (confusable with possessive/contraction) — see Contractions and Possessives.

## Singular and plural agreement
- Match verb number to the actual subject in long/complex sentences.
  - Recommended: "Confirm that the number of entries listed in the directory is accurate."
  - Recommended: "The workloads with the `app: backend` label represent the traffic source."
  - Not recommended: "The efficiency of algorithms that process data sets depend on memory allocation."
- With multiple subjects joined by *and*/*or*, match number appropriately.
  - Recommended: "The request payload and header information are logged for debugging."
  - Recommended: "Either the API keys or service account wasn't authenticated."
  - Not recommended: "User authentication and authorization is processed and handled by the security module."
- Use plural after "one or more," not singular (reword for clarity if needed).
  - Recommended: "If one or more tests fail, a system warning is triggered."
  - Recommended: "If any one test fails, a system warning is triggered."
- Use singular after "more than one."
  - Recommended: "You can create more than one instance at a time."

## Plural abbreviations
- Treat acronyms/initialisms/abbreviations as regular words when pluralizing; never *'s*.
  - Recommended: "APIs, SKEs, and IDEs"
  - Not recommended: "API's, SKE's, and IDE's"
- If ending in *s*, *sh*, *ch*, or *x*, add *es* (*OSes*, *DISHes*, *DCCHes*, *BMXes*).
- Match plurality between the spelled-out term and its abbreviation.
  - Recommended: "virtual machines (VMs)"
  - Not recommended: "virtual machines (VM)"
- With units of measure: singular only for exactly "1"; plural for zero, decimals, and >1.
  - Recommended: "0 degrees" / "0.5 degrees" / "1 degree" / "15 degrees"
- Never pluralize an abbreviated unit paired with a number.
  - Recommended: "64 GB" — Not recommended: "64 GBs"
- Nonbreaking space between number and unit abbreviation (see Spaces in units of measurement).

## Plural product and feature names
- Never pluralize or make possessive a trademarked product/feature/company name (see Use trademarks only as modifiers, Product, feature, and company names).
- Use singular class names; don't manually pluralize a class name (can break translation) — add a plural noun after it instead.
  - Recommended: "`Intent` objects and `Activity` instances"
  - Not recommended: "`Intent`s and `Activity`s" / "`Intents` and `Activities`"

## Plurals in parentheses
Don't hedge with optional plurals in parentheses — pick plural or singular and stay consistent; use "one or more" if both cases truly need indicating.

| Recommended | Not recommended |
|---|---|
| "To find your API key, visit the **Credentials** page." | "To find your API key(s), visit the **Credentials** page." |
| "The value of the parent depends on the values of its children." | "The value of the parent depends on the value(s) of its child(ren)." |
| "You can use a physical linecard, which can contain one or more ports." | "You can use a physical linecard, which can contain port(s)." |

## Plural pronouns
See Pronouns and Second person and first person for *we*, *you*, *they*.
