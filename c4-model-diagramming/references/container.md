# Container diagram

Zoom into one system: the applications and data stores it is made of, the technology of
each, and how they talk to each other and to the outside.

- Scope: one software system.
- Primary elements: the containers inside it. A container is a separately runnable or
  deployable unit: a web app, a single-page app, a mobile app, an API, a worker, a
  database, a file store, a message bus.
- Supporting elements: the people and external systems connected to the containers.
- Audience: technical people inside and outside the team: developers, architects,
  operations.
- Recommended: yes, for every system.
- Not here: deployment detail (clusters, replication, instances) belongs in the deployment
  diagram.

## Keys used

`references/keys/container.svg`, `references/keys/container-database.svg`,
`references/keys/container-web-browser.svg`, `references/keys/container-console.svg`,
`references/keys/boundary.svg`, `references/keys/person.svg`,
`references/keys/external-system.svg`, `references/keys/relationship.svg`,
`references/keys/candidate.svg`; add `references/keys/container-bucket.svg` and
`references/keys/container-directory.svg` when files are stored.

## Example

`references/examples/container.svg`, drawn by `container` in `scripts/build.rb`: a web app,
an API, an orders database, a sync worker, and a dashed candidate answer service inside the
order desk boundary, with the sign-in and ERP systems outside it.

## Layout

The boundary holds the containers in rows: the client and the API on top, data stores in
the middle, workers at the bottom. People stand left of the boundary, external systems in a
column to its right. Every line between containers names its protocol. When the system has
implementation options, draw this diagram once from the base and put each option's
technology in the component fills instead of redrawing the containers.
