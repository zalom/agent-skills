# Component diagram

Zoom into one container: the components it is made of, what each one does, and which
technology it is built with.

- Scope: one container.
- Primary elements: the components inside it. A component is a grouping of related
  functions behind one interface: a controller, a model, a service, an adapter.
- Supporting elements: the containers it talks to, plus people and external systems when
  they connect to a component directly.
- Audience: architects and developers of that container.
- Recommended: no, unless the diagram explains a decision. Consider generating it from the
  code when it has to stay current.

## Keys used

`references/keys/component.svg`, `references/keys/boundary.svg`,
`references/keys/container-web-browser.svg`, `references/keys/container-database.svg`,
`references/keys/relationship.svg`; `references/keys/candidate.svg` for a component that
may be added.

## Example

`references/examples/component.svg`, drawn by `component` in `scripts/build.rb`: the
question endpoint, intent reader, order lookup, and answer writer inside the API container,
with the web app and the orders database outside it.

## Layout

A grid inside the container boundary: the entry component at the top left, the components
it calls to its right and below, in the order a request flows. Neighbouring containers stay
outside the boundary. The same grid, with a technology in every bracket, serves as the fill
for each implementation option; keep box positions identical across fills so a reader can
compare them.
