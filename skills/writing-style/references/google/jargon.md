# Jargon

Source: https://developers.google.com/style/jargon

Jargon = specialized/figurative terminology of a specific group representing a larger concept (e.g., *camel case*, *swim lane*, *break-glass procedure*, *out-of-the-box*), including vague/overloaded terms like *solution*, *support*, *workload*.

Jargon usually isn't understood outside its group, which conflicts with writing for a global, multi-language, multi-skill-level, inclusive audience (see Write inclusive documentation). But some jargon is widely accepted industry-wide or by a document's specific audience — and can be worth keeping if readers search for those exact terms (SEO value).

## Decision checklist when jargon shows up
1. **Can you write around the term?** If SEO isn't a factor, rewrite in plain language.
   - Instead of "Hold a post-mortem" → "When the project is finished, review what processes worked or didn't work."
   - Instead of "Create a back-of-the-envelope design" → "Use an informal design process."
2. **Can you replace it with a more specific term?** The word list provides many pre-approved replacements (e.g., *affected area*/*spatial impact* for *blast radius*; *import*/*load* for *ingest*; *ready-made*/*pre-built* for *off-the-shelf*). Terms marked "Don't use" on the word list (offensive/violent/non-inclusive) must always be replaced or written around.
3. **Used only once?** Describe it in plain language with the jargon term parenthetical, or link to a trusted definition.
   - Recommended: "You then move the task to an earlier part of the process (also known as *shifting left*)."
4. **Used throughout the document?** Define briefly in parentheses on first use, or link to a trusted definition.
   - Recommended: "The application is in the same state as a *cold standby* (a backup or redundant system that's identical to a primary system)."
5. **Appears in a command or code sample?** Use the term only in direct reference to the actual code item, formatted in code font, and make the reference unambiguous.
   - Recommended: "Add a user to the allowlist (`whitelist`) by entering the following: `whitelist adduser EMAIL_ADDRESS`."
   - Not recommended: "Add a user to the whitelist by entering the following: `whitelist adduser EMAIL_ADDRESS`."
