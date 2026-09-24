# Agent skills

Skills for Claude Code, published as the `zalom-skills` plugin marketplace. Each skill is a
directory at the repository root with a `SKILL.md`, its `references/`, and where needed its
`hooks/` and `scripts/`. `.claude-plugin/marketplace.json` lists the skills and their versions.

## Stack

- Ruby for every hook body, script, and test. Hook entry points are shell files, because Claude
  Code and Codex run them without a Ruby on the path.
- Minitest. The full suite is `rake test`, which loads `test/`, `plain-writing/hooks/test/`,
  and `ruby-quality-checking/assets/test/`.
- Remote: `git@github.com:zalom/agent-skills.git`. The `main` branch is what the marketplace
  serves, so every push to `main` is a release.

## Work

- Every change goes through a Plastic intent. Arm it before editing, so the record hook
  commits only that intent's work.
- Run each change's tests once, on the changed files only. Run `rake test` once before a
  commit that touches more than one skill.
- Bump the skill's `version` in `.claude-plugin/marketplace.json` in the same commit as the
  change. The installed copy updates only when that number moves.
- After a push, run `claude plugin marketplace update zalom-skills` and
  `claude plugin update <skill>@zalom-skills`, then restart Claude Code.
- Every text in this repository follows the `plain-writing` skill. Run
  `ruby plain-writing/hooks/lint.rb FILE` on a document before it ships.

## Commits

- Conventional Commits: `feat(plain-writing):`, `fix(ruby-testing):`, `docs:`, `chore:`.
- Never add AI attribution to a commit, tag, or release note. No `Co-Authored-By`, no
  `Generated with`, no robot footer. The commit belongs to the repository owner.
- A commit carries one finished change. A half-edited file is never committed.
