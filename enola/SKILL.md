---
name: enola
description: >
  Uses Enola, the code-graph tool, through its command line to map a
  repository, answer structure questions from the snapshot files, and check
  what a change did to the architecture. Use before grep or find when the
  question is about modules, dependencies, callers, layers, cycles, routes, or
  the reach of a change; before and after a refactor; when setting Enola up on
  a repository; or when another tool has to load Enola's snapshot. Works
  through the `enola` command only, never through its MCP server.
license: MIT
compatibility: Needs the `enola` binary on the path and a git repository.
metadata:
  author: Zlatko Alomerovic
---

# Using Enola

Enola reads a repository and writes a snapshot of its architecture as plain files. Use the `enola` command and those files. Do not use the MCP server.

## Rules

- Always give `enola` a command or a flag. `enola` with no arguments starts the MCP server.
- Read the snapshot before you search by hand. Use grep, find, or a broad file read only for what the snapshot does not hold.
- Say what Enola covered and what it did not. Enola reads only the languages that its extractors detect. Templates, CSS, and deployment configuration still need direct reading.
- Ask the person before you run `enola install`, `enola uninstall`, or `enola upgrade`. Each one changes files outside the repository's snapshot.
- In a script, set `ENOLA_NO_UPDATE_CHECK=1` and `ENOLA_NO_PROMPTS=1`.

## Set up a repository

1. Run `GOMEMLIMIT=4GiB enola --generate <repo>`. It writes the snapshot to `<repo>/.enola/`.
1. Add `.enola/` to the repository's `.gitignore`.

Setup is complete only when both steps are done. Run `--generate` again after the repository changes. A refresh parses only the languages whose files changed.

## Read the snapshot

Three files in `.enola/` are a stable contract:

| File | Contents |
|---|---|
| `receipt.json` | The format version, the snapshot id, how the snapshot was built, the counts, and the extraction quality |
| `facts.jsonl` | The graph: nodes and relations, one fact per line |
| `insights.json` | The findings and the evidence for each |

Read `receipt.json` first. Its quality block shows which files were parsed and which were skipped, and that tells you how far to trust an answer.

`llm_context.md` is a rendered summary. Read it for a first overview, and take facts from the three contract files. Do not depend on any other file in `.enola/`.

For a report with nothing written to disk, run `enola --explain <repo>`.

## Check a change

1. Before the edit, run `enola baseline pin`. It records the architecture as it is now.
1. To see what the edit will reach, run `enola plan --paths <path>`. It prints the constraints that govern those paths and what depends on them.
1. After the edit, run `enola check`. It reports only what changed since the pin.

`enola check` exits with one of four codes:

| Code | Meaning |
|---|---|
| 0 | Nothing that the policy enforces. With no policy, every result is 0. |
| 1 | The change broke the policy. |
| 2 | The check could not run, for example because no baseline is pinned. |
| 3 | The baseline cannot be compared, so the check declined to grade. |

Nothing fails by default. Name what must fail, for example `enola check --fail-on=layers,cycles`. Add `--json` for data, `--focus=<path>` to narrow the report, and `--baseline=previous` to compare with the last snapshot written and not with the pin.

When the report shows a regression, fix it before you report the work as done. When it shows a finding that no policy enforces, show the finding to the person and let them decide.

## Other questions

| Question | Command |
|---|---|
| What does a change to this HTTP endpoint reach? | `enola endpoint "GET /v1/users"` |
| Which links between repositories were resolved, and which were missed? | `enola coverage` |
| How did the architecture change over time? | `enola log` |
| When did a module or a symbol enter or leave? | `enola blame <pattern>` |
| Are the session hooks running? | `enola doctor` |

## Load the snapshot into another tool

1. Pin one Enola release that you have tested. Do not follow the latest release.
1. Run `enola --generate <repo>` as a child process, with the two environment variables from the rules.
1. Read `receipt.json` and stop when its `format_version` is one that your tool does not know.
1. Load `facts.jsonl` and `insights.json` into your own store.
1. Keep the receipt's `snapshot_id`, and skip the load when the id has not changed.

Cognee builds its code search this way, and that search needs no model key. The full description is in Enola's `docs/INTEGRATING.md`.
