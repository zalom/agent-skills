# System context diagram

The starting point: one software system, the people who use it, and the other systems it
talks to. Technology and internals stay out.

- Scope: one software system.
- Primary elements: the system in scope.
- Supporting elements: people (users, actors, roles) and external software systems that
  connect to it directly.
- Audience: everybody, technical or not, inside and outside the team.
- Recommended: yes, for every system.

## Keys used

`references/keys/person.svg`, `references/keys/software-system.svg`,
`references/keys/external-system.svg`, `references/keys/relationship.svg`; add
`references/keys/candidate.svg` when a connection is not yet decided.

## Example

`references/examples/system-context.svg`, drawn by `system_context` in `scripts/build.rb`:
an order desk, its sales agent, and the ERP, sign-in, and e-mail systems it depends on.

## Layout

Hub and spoke. The system sits in the middle, people on the left, external systems in one
column on the right, each with its own line and verb. Include the sign-in provider when
users sign in through it, because the audience asks who may use the system. When a later
phase adds a system, draw a second context diagram and change nothing in the first.
