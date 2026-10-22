---
name: c4-model-diagramming
description: "Draws C4 model diagrams of a software system as standalone SVG with a title and a key: system context, container, component, system landscape, dynamic, and deployment. Use when asked for a C4 diagram, an architecture diagram, a context or container diagram, a system landscape, a deployment view, or to show how a system's parts, people, and external systems connect. Also use when a design proposal, a review deck, or a take-home needs a picture of the architecture and no diagram style was named." # lint-ok: shorthand; C4 is the name of the model
license: MIT
metadata:
  author: Zlatko Alomerovic
---

# C4 model diagramming <!-- lint-ok: shorthand; C4 is the name of the model -->

Draw the architecture as a set of C4 diagrams. Each diagram is one standalone SVG with a <!-- lint-ok: shorthand; C4 is the name of the model -->
title and a key, drawn by the bundled Ruby script. This body holds the rules every diagram
follows; the references hold each diagram type, the notation, the key elements, and one
example per type.

Paths in this file start at the skill directory, the directory that holds this `SKILL.md`. `SKILL_DIR` is the absolute path of that directory; find it before running a script. Run a script by its full path, `SKILL_DIR/scripts/...`, and read its real output. Never predict or invent what a script prints.

## Rules (hold even when no reference is opened)

- Every diagram has a title that names the type and the scope, such as "Container
  diagram · Order desk", and a key that shows every element kind and line style it uses.
- Every element carries its name, its type in brackets ([Person], [Software system],
  [Container · Rails], [Component · Rails model]), and a short description. A container
  or component without a technology is not finished.
- Every line is one direction and labeled with a specific verb phrase ("Reads orders
  from", never "Uses" alone). A line between containers also carries the protocol in
  brackets, such as [JSON/HTTPS] or [SQL].
- Name only what the source names. A technology, protocol, or system the code or the
  design does not name is drawn as a dashed candidate marked "to confirm", never guessed.
  A candidate keeps the shape of its kind and the key lists it once per kind it dashes:
  "Candidate component", "Candidate external system". A candidate's line is labeled with
  what settles it ("alternative entry · trial", "same interface"), and a note under the
  figure says where each candidate comes from and what keeps it a candidate.
- Colors are free but consistent across the set: one hue per element kind, the same in
  every diagram. The shape and the type label carry the meaning, so every diagram still
  reads in gray and for color-blind readers.
- One base. When options or phases exist, draw the base once and make each option a fill
  of the same boxes with a technology in each bracket. An option never redraws the base,
  and a phase adds elements but never changes existing ones. A fill's title ends with the
  fill's name after a middle dot ("Component diagram · Order desk API · Rails fill"), and a
  fill may hold no chosen technology at all, only candidates attached to the base, when it
  shows what could attach.
- Lines route around elements, never through them. A crossing gets a hop or a reroute,
  and a label sits beside its line and overlaps nothing.
- Start with the context, then the containers. Draw components only where they explain a
  decision, a dynamic view for one flow worth following step by step, and a deployment
  view when the environment matters.

## Route the diagram to its reference

| Diagram to draw | Open |
|---|---|
| Any diagram: the shapes, the colors, the type labels, and the full notation rules | `references/notation.md` |
| Who uses one system and what it talks to: people and external systems | `references/system-context.md` |
| What runs inside the system: applications and data stores with their technology | `references/container.md` |
| What is inside one container: its parts and their responsibilities | `references/component.md` |
| The systems of one organization and how they connect, with no focus system | `references/system-landscape.md` |
| The order of calls in one scenario, numbered step by step | `references/dynamic.md` |
| Where the containers run: nodes, infrastructure, instance counts, one per environment | `references/deployment.md` |
| Placing a set's figures in a document: numbering, captions, fills, and fonts | `references/placing-figures.md` |

## Draw with the script

`scripts/c4.rb` draws every shape, line, boundary, step number, and key as SVG, with the
palette as CSS tokens and a dark set. Write a short Ruby file that requires it and calls
`C4.draw`; `scripts/build.rb` is the worked example that draws every key element and every
example diagram. Run `ruby SKILL_DIR/scripts/build.rb OUT_DIR` to write that set into
`OUT_DIR/keys` and `OUT_DIR/examples`. Open the result in a browser before it ships: a
label over a box and a line through an element are the two faults a read of the source
never catches.
