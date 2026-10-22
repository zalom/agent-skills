# Deployment diagram

Where the containers run: the deployment nodes, the infrastructure between them, and how
many instances of each container exist. One diagram per environment.

- Scope: one software system in one environment (development, staging, production).
- Primary elements: deployment nodes (a laptop, a server, a virtual machine, a container
  runtime, a cloud account, a database service) and the container instances inside them.
- Supporting elements: infrastructure nodes (load balancer, firewall, DNS) and the
  relationships between instances, with the protocol.
- Audience: technical people inside and outside the team, operations first.
- Recommended: yes, for every environment that differs from the others.
- Icons: allowed for a node's technology when the key explains them.

## Keys used

`references/keys/deployment-node.svg`, `references/keys/infrastructure-node.svg`,
`references/keys/container.svg`, `references/keys/container-database.svg`,
`references/keys/container-web-browser.svg`, `references/keys/container-console.svg`,
`references/keys/relationship.svg`.

## Example

`references/examples/deployment.svg`, drawn by `deployment` in `scripts/build.rb`: the web
app in the agent's browser, and the load balancer, two application servers, a worker, and a
managed database inside the company's cloud account.

## Layout

Nodes nest: the cloud account holds the servers, a server holds its container instances.
Leave 45 pixels at the bottom of every node for its label and keep instances above that
line. Put the instance count at the top right of the node. Keep each environment on its own
diagram instead of annotating one with differences.
