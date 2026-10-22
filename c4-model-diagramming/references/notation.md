# Notation

The rules below follow the notation page of c4model.com. The shapes, colors, and type
labels are this skill's own choices, drawn by `scripts/c4.rb`; keep them the same in every
diagram of a set.

## Rules from c4model.com

- Every diagram has a title that states the diagram type and the scope.
- Every diagram has a key that explains every shape, color, and line style it uses,
  including icons when icons are used.
- Every element shows its name, its type ([Person], [Software System], [Container],
  [Component]), and a short description.
- Every container and every component names its technology.
- Every relationship is one direction with an explicit label. A specific verb phrase
  ("Sends e-mail using", "Reads orders from") beats "Uses". A line in both directions is
  two lines.
- A relationship between containers names the protocol: [JSON/HTTPS], [SQL], [gRPC].
- Color is free but consistent, and the diagram still reads in gray: shapes and type
  labels carry the meaning for printers and color-blind readers.

## Candidates

- A candidate is drawn in the shape of its kind, dashed and amber, with "candidate" in its
  type bracket: [Component · candidate], [External system · candidate].
- The key lists candidates once per kind the diagram dashes. "Candidate component" and
  "Candidate external system" are two entries; one "Candidate" entry hides which kinds
  are open.
- A candidate's line carries a label that names what settles it: "alternative entry ·
  trial", "same interface", "to confirm with the owner".
- A note under the figure says where every candidate comes from (a named source, a stated
  option) and what keeps it a candidate (a trial, a decision, a missing fact).

## Element shapes

| Element | Shape | Key file | Script call |
|---|---|---|---|
| Person | Head circle over a rounded body with two faint arm lines | `references/keys/person.svg` | `person` |
| Software system | Rounded box, teal | `references/keys/software-system.svg` | `system` |
| External system | Rounded box, gray | `references/keys/external-system.svg` | `external` |
| Container | Box, white | `references/keys/container.svg` | `container` |
| Database container | Cylinder, teal | `references/keys/container-database.svg` | `database` |
| Object store container | Bucket, wider at the top | `references/keys/container-bucket.svg` | `bucket` |
| Directory container | Folder with a tab | `references/keys/container-directory.svg` | `directory` |
| Browser application container | Window with a title bar and three dots | `references/keys/container-web-browser.svg` | `browser` |
| Server-side or console container | Box with a `>_` prompt mark | `references/keys/container-console.svg` | `console` |
| Component | Box with two small tabs on its left edge | `references/keys/component.svg` | `component` |
| Candidate element | The shape of its kind, dashed, amber: not yet decided. The key names the kind: "Candidate component", "Candidate external system" | `references/keys/candidate.svg` | any call with `hue: :candidate, dashed: true` |
| Boundary | Dashed rounded rectangle, labeled at the top left with [Software system] or [Container] | `references/keys/boundary.svg` | `boundary` |
| Group | Dotted rectangle, labeled at the bottom left, for an organization or a department | `references/keys/group.svg` | `group` |
| Deployment node | Solid rounded rectangle, labeled at the bottom left with [Deployment node · technology], an instance count at the top right, nestable | `references/keys/deployment-node.svg` | `node` |
| Infrastructure node | Ellipse, for a load balancer, a firewall, a DNS service | `references/keys/infrastructure-node.svg` | `infra` |
| Relationship | One-direction line with a filled arrowhead, a label, and the technology in brackets | `references/keys/relationship.svg` | `rel`, `path` |
| Numbered relationship | The same line with a numbered step marker on it | `references/keys/relationship-numbered.svg` | `rel` then `step` |

## Colors

| Token | Light | Dark | Used for |
|---|---|---|---|
| `--primary` | `#2E7D76` | `#4FA8A0` | Software system fill and stroke, data stores, boundaries |
| `--person` | `#5B5FA8` | `#9BA0E0` | People |
| `--accent` | `#B77914` | `#E0A33E` | Candidates and step markers |
| `--ink` | `#1A1D23` | `#E8E6E1` | Containers, components, lines, names |
| `--muted` | `#6B7285` | `#8B92A5` | External systems, technology on relationships |
| `--ground` | `#F7F6F3` | `#12151A` | The canvas |

Each SVG declares the tokens in its own `<style>` with a `prefers-color-scheme: dark` set,
so a diagram works on its own and inside any page.

## Layout habits

- Hub and spoke for one focus element: the system in the middle, people on the left,
  external systems in a column on the right.
- Stacked rows for containers: the web layer on top, the API beside it, data stores
  below, workers at the bottom, external systems in a column outside the boundary.
- Route lines orthogonally with `path` when a straight line would cross a box; keep one
  routing lane between rows and columns so labels have room.
- Put a label above its horizontal line and the technology below it, or beside a vertical
  line with `anchor: "start"`. A label never touches a box edge.
- Leave at least 70 pixels between two boxes that a labeled line joins, more when the
  label is long. Shorten the label before shrinking the font.
