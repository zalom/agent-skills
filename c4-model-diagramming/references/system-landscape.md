# System landscape diagram

A context diagram without a focus system: every system of one organization, the people
who use them, and the lines between them.

- Scope: an organization, a division, or a department.
- Primary elements: the software systems inside that scope, with their people.
- Supporting elements: external systems outside the scope.
- Audience: everybody who needs the enterprise view.
- Recommended: yes, for an organization with several systems; one system alone needs only
  its context diagram.

## Keys used

`references/keys/person.svg`, `references/keys/software-system.svg`,
`references/keys/external-system.svg`, `references/keys/group.svg`,
`references/keys/relationship.svg`.

## Example

`references/examples/system-landscape.svg`, drawn by `system_landscape` in
`scripts/build.rb`: the sales agent and operations planner, the order desk, the shipment
planner, and the ERP inside the trading firm group, with the carrier portal and the bank
outside it.

## Layout

A dotted group encloses the organization: people on the left, internal systems in the
middle, shared systems at the right edge of the group. External systems stand in a column
outside the group, and lines to them leave through one routing lane.
