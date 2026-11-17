---
name: simple-architecture-designing
description: >
  Designs code and application architecture in any language for the least
  complexity: the simplest design that fits, dependencies that point one way,
  no cycles between packages, the platform's own features before custom code,
  and names that say what a thing does. Use when designing a feature, module,
  package layout, data model or migration; choosing between two designs;
  reviewing a change for coupling, naming or dead code; reading architecture
  findings such as cycles, god classes or layer breaks; or when a solution is
  growing larger than the problem it solves.
license: MIT
metadata:
  author: Zlatko Alomerovic
---

# Simple architecture designing

Do more with less. The best design is the smallest one that fits, and every line has to earn its place.

## Rules

- Compare the options on fit and complexity before choosing. The simpler option wins unless the other one fits much better.
- A remembered rule or ruling is an input, not a constraint. When it forces the more complex design, say so and challenge it.
- Say early what raises complexity and what would lower it. After an agreement, keep looking for a simpler form of it.
- Use the force already there: the database's own SQL for data, the standard library, the framework's conventions. Never loop over rows in code to do what one SQL statement does.
- Name a thing after what it does or holds, never after its order or its history.
- Dependencies point toward what changes less. Pass collaborators in, depend on an interface rather than a concrete class, and talk only to immediate neighbors.
- Layers depend downward only: the shell (command line, web, hooks) on the use cases, the use cases on the domain and storage, never the reverse. Packages form no cycle.
- Keep decisions in a pure core and side effects (files, database, network, process) in a thin shell around it.
- Delete before adding. Code that only tests call is dead: remove it or give it a real caller.
- Test behavior at the public boundary, not the implementation behind it.
- Fix a smell where it is found. Leave no follow-up work behind.

## Tasks

Paths in this file start at the skill directory, the directory that holds this `SKILL.md`. `SKILL_DIR` is the absolute path of that directory; find it before running a script. Run a script by its full path, `SKILL_DIR/scripts/...`, and read its real output. Never predict or invent what a script prints.

| When | Open |
|---|---|
| Breaking a cycle, a layer break or a god class, or choosing where a dependency points | `references/dependencies.md` |
| Deciding what to test, at which layer | `references/testing.md` |
| Writing Ruby | the `ruby-designing` skill, which applies these rules to Ruby |
