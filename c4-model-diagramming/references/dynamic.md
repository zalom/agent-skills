# Dynamic diagram

One scenario, step by step: which elements take part and in what order they call each
other. The static diagrams show what exists; this one shows how one thing happens.

- Scope: one feature, story, or use case, at the system or the container level.
- Primary elements: the people, systems, containers, or components that take part.
- Relationships: numbered in the order they happen. A step carries its number and a
  specific label, such as "3: Loads the order [SQL]".
- Audience: technical people who need to follow one path.
- Recommended: use sparingly. One flow that explains a design decision earns a diagram;
  every flow does not.

## Keys used

`references/keys/relationship-numbered.svg`, plus the element keys of the level drawn:
`references/keys/person.svg`, `references/keys/container.svg`,
`references/keys/container-database.svg`, `references/keys/external-system.svg`.

## Example

`references/examples/dynamic.svg`, drawn by `dynamic` in `scripts/build.rb`: "Is SO-1042
confirmed?" in five steps from the sales agent through the web app, the API, the language
model API, and the orders database, and back.

## Layout

Reuse the geometry of the static diagram at the same level, so a reader finds every element
where it was. Draw each step as its own line in the direction of the call; a reply is a
second line, numbered. Put the step marker on the line itself, near its start, and the label
two lines away from the marker so neither covers the other. When two steps travel the same
line, place both markers on it in order and say so in the caption.
