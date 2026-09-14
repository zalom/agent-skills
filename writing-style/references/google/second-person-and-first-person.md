# Second Person and First Person

Source: https://developers.google.com/style/person

## Address the reader as "you"
Use *you*/*your* instead of *we*/*our*/*us*. Assume the reader performs the tasks/makes the decisions. Reserve *user* only for the end user of software your reader is developing.

| Recommended | Not recommended |
|---|---|
| "The following sections describe how you can create a website." | "...how we can create a website." |
| "Consider adding a description to your table." | "Let's add a description to our table." |
| "This document shows you how to develop an app for your organization." | "This document shows the user how to develop an app for their organization." |

Use the imperative for instructions (implied "you"): "Click **Submit**." OK in running text once the audience is established, but consider whether it should instead be formatted as a numbered procedure.

- Recommended: "You can obtain the IP address for the appliance from your network administrator. Store the address in a variable for future use in the runbook."
- Not recommended (should be a procedure): "To hold the backup data, create a storage bucket. In the Google Cloud console, go to the **Buckets** page. Click **Create bucket**."

Use third person for what software/an end user does; use "you" only for what the reader themself does — e.g., in API docs, state facts about programming elements in third person, but address the reader as "you" for instructions.

## First-person plural pronouns — use carefully
OK to use *we*/*our*/*us* for the authoring organization, but the antecedent must be unambiguous.
- Recommended: "Example Organization provides A and B, but we don't provide C and D."
- Recommended: "For more information, contact our sales organization."
- Recommended: "The example.org support team regularly reviews tickets. Expect to hear from us in 2-3 business days."

## Address your audience consistently
Identify who "you" refers to (developer? sysadmin? someone else?) and stay consistent — an explicit audience-defining sentence near the document's start helps.
