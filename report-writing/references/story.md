# The story

Open this when ordering a report's argument, deciding what counts as a fact, or writing the
questions that remain.

## Contents

- Order of the argument
- Facts, interpretations, and unknowns
- Rules and examples
- Questions that advance the work
- Terminology and attribution
- Solutions follow evidence
- Length and the accepted original

## Order of the argument

| Part | Holds | Comes from |
|---|---|---|
| Context | Who asks, what they ask, what the document answers, what it does not | The request and the interviews |
| Source data | The tables, fields, documents, and systems the answers rest on | The data as received, named by its real fields |
| Business rules | The general rules that turn data into an answer, each with its source and its owner | Documents, interviews, confirmed statements |
| Sample analysis | What the rules say about the sample at hand, worked through | The sample, under the rules |
| Answers | The concrete answer to each question, under stated assumptions, with its caveat beside it | The analysis |
| Remaining questions | What must be settled, by whom, and what changes when it is | The rules, the sample, and the answers |
| Proposal | What to build or do, justified by the parts above | The evidence |

A reader who stops after any part has a complete picture up to that part. Nothing in a later
part is needed to understand an earlier one.

## Facts, interpretations, and unknowns

- A fact has a source: a field value, a document, a named statement. It is written as a fact.
- An interpretation is written as one, with the assumption that makes it hold: "Under the
  assumption that PLANNED means a date was set, the order is late."
- An unknown is written as unknown and becomes a question in the questions part. It is never
  filled with a plausible value.
- A caveat sits beside the result it qualifies, in the same row or the next sentence. A
  caveats section at the end separates the reader from the warning.

## Rules and examples

- A general business rule and a finding about one sample live in different tables. A sample
  finding never becomes a rule by repetition.
- Field names are the database's own, in code font. An identifier, a quantity, a status, and
  a conclusion each have their own column.
- A worked example shows the rule applied to one real record, with the record's identifier,
  so a reader can repeat it.

## Questions that advance the work

Each question names one of these and says what changes when it is answered:

| Kind | Example |
|---|---|
| Definition | What does status PLANNED mean when no date is set? |
| Source | Which system holds the confirmed delivery date? |
| Owner | Who may change a confirmed quantity? |
| Update frequency | How often does the order copy refresh? |
| Condition | Under what condition is a partial shipment reported as complete? |

Group the questions by what raised them: a rule, a sample, or an answer. A question with no
effect on an answer is cut.

## Terminology and attribution

- The user's exact question is kept verbatim, in quotation marks, with who asked it.
- An agreed label (a status name, a department name, a document title) is used as agreed,
  never paraphrased.
- Every external figure carries its source and its date. A figure without a source is not
  written.
- No operational problem, impact metric, or condition is invented to make a case. A case
  without evidence is written as a hypothesis to test.

## Solutions follow evidence

- The problem is established, with its evidence, before any implementation is proposed.
- A proposal is justified by the parts above it. Where the evidence is thin, the proposal is a
  pilot or a trial that produces the missing evidence.
- A change to an accepted proposal is justified by feedback or validation, and the document
  says which.

## Length and the accepted original

- An accepted report is a reference for shape and style. It sets no page limit and no
  template; each report is as long as its evidence needs.
- When editing an accepted report, keep its structure and styling, apply each concrete
  finding, and check the whole document after the edit.
