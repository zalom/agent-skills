# Jev review

Read when requesting a Jev assessment.

## Prepare an independent judgment

Use typesafe-ai for live documentation and the API contract when available.
If that skill is absent, consult the official TypeSafe documentation directly.
Use an existing authorized connection. If Jev is unavailable, say that it was
not asked and continue the editorial review; do not invent scores or silently
substitute another service. Respect a request to keep text local.

Send only the source text, necessary context, and the candidate revision when
judging an edit. Exclude unrelated private work-history files. State the genre
and whether factual claims are independently verified or merely supplied.
Do not give Jev the preferred conclusion before its first assessment.

## Ask narrow questions

Batch independent judgments. Evaluate every paragraph when reviewing the whole
draft; use explicit passage text or stable field names to avoid index ambiguity.
Keep these judgments separate:

- Formulaic wording: how much does a passage rely on interchangeable language?
- Specificity: does the passage describe an identifiable action or experience?
- Redundancy: does the closing repeat what the preceding text establishes?
- Fidelity: does the revision preserve the source claims and qualifications?
- Voice: does the revision fit the author's supplied writing samples?

Ask about unsupported additions and lost operational conditions separately
from fluency. When there is no independent voice sample, limit the claim to
consistency with the supplied draft rather than authenticating the author.

For a formulaic-wording Score, use these ordered levels:

0. Concrete, individual prose with no noticeable reliance on interchangeable formulas.
1. Mostly individual prose with occasional conventional wording.
2. A mixture of concrete material and conspicuous generic wording.
3. Mostly interchangeable wording; concrete detail plays a minor role.
4. Almost entirely boilerplate with little individual detail.

Use Noul for a narrow yes/no judgment, such as whether a proposed edit loses a
specific source condition. These are style and fidelity judgments, not a
validated detector or hiring probability.

## Interpret without overclaiming

Report the returned language model version when useful. Name the scale beside
any score. Do not call a normalized score the percentage written by AI.
Treat confidence as concentration of the answer distribution, not proof that
the judgment is correct.

Preserve disagreement between Jev and the editorial assessment. Return to the
source to resolve factual questions. Do not repeatedly rephrase a question
until Jev agrees. A second call is useful when a revised draft or new evidence
needs review, not to select a more convenient score.

Keep the visible summary short. Retain request and response details in the
working context; save them only when the requested deliverable includes files
or an audit record.
