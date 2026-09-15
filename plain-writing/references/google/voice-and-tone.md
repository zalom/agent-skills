# Voice and Tone

Source: https://developers.google.com/style/tone

Aim for a voice that's conversational, friendly, and respectful — without slang or being overly colloquial/frivolous. Casual, natural, approachable — not pedantic or pushy. Sound like a knowledgeable friend who understands what the developer wants to do.

Don't write exactly as you'd speak (too colloquial/verbose for developer docs) — but aim conversational, not formal. Don't be super-entertaining or super-dry; let personality show while remembering the primary purpose is delivering information to someone who may be in a hurry.

Readers come from many cultures with varying English proficiency — avoid culturally specific references. Simple, consistent writing also eases translation (see Write for a global audience). See also: Write accessible documentation, Write inclusive documentation.

## Avoid where possible
- Buzzwords or technical jargon.
- Being too cutesy.
- Figurative language (metaphors, ableist language).
- Placeholder phrases like *please note* and *at this time*.
- Choppy or long-winded sentences.
- Starting every sentence with the same phrase (*You can*, *To do*).
- Current pop-culture references.
- Exclamation marks (see the specific exclamation-point guidance page).
- Wackiness, zaniness, goofiness.
- Phrasing that denigrates or insults any group of people.
- "Let's do X" phrasing.
- *Simply*, *It's that simple*, *It's easy*, *quickly* in a procedure (minimizes reader effort inappropriately).
- Internet slang/abbreviations (*tl;dr*, *ymmv*).

## Techniques to consider
- Ask "What am I trying to say?" when phrasing feels stuck — the honest answer often reveals the right wording.
- Ask a colleague to review phrasing/tone if uncertain.
- Read sections aloud (or mouth the words) — if a sentence sounds awkward spoken, consider a more conversational rephrase (not every sentence must sound spoken-natural, though).
- Use transitions (*Though*, *This way*) to de-stiffen paragraphs — but overusing *However*/*Nonetheless* can have the opposite effect.
- Above all, prioritize communicating useful information clearly and directly — that matters more than nailing the "voice."

## Politeness and "please"
Using *please* in instructions overdoes politeness.

| Recommended | Not recommended |
|---|---|
| "To view the document, click **View**." | "To view the document, please click **View**." |
| "For more information, see [link]." | "For more information, please see [link]." |

## Calibration examples

| Too informal | Just about right | Too formal |
|---|---|---|
| "Dude! This API is totally awesome!" | "This API lets you collect data about what your users like." | "The API documented by this page may enable the acquisition of information pertaining to user preferences." |
| "Just like a certain pop star, this call gets your *telephone* number. The easy way to ask for someone's digits!" | "To get the user's phone number, call `user.phoneNumber.get`." | "The telephone number can be retrieved by the developer via the simple expedient of using the `get` method on the `user` object's `phoneNumber` property." |
| "Then—BOOM—just garbage-collect, and you're golden." | "To clean up, call the `collectGarbage` method." | "Please note that completion of the task requires the following prerequisite: executing an automated memory management function." |
