# Prescriptive Documentation

Source: https://developers.google.com/style/prescriptive-documentation

*Prescriptive* (opinionated) documentation recommends a single way to achieve a task/goal, rather than presenting a menu of options. When a task involves multiple possible approaches or products, prescriptive documentation recommends one specific path.

## What prescriptive writing affects
- **Purpose and structure** — a clear, specific purpose; headings/content organized around that purpose.
- **Example scenarios and procedures** — reflect the most likely relevant use cases for readers.
- **Sample commands** — provide commands/arguments that accomplish the task for the most common use case (see Optional arguments in click-to-copy commands).

Best-practice documents (e.g., "Operations best practices") are typically prescriptive.

## Word choice for recommendations and requirements

Choose the auxiliary verb based on whether an action is required vs. optional, an outcome is expected vs. possible, or a state is actual vs. recommended. **Generally avoid "should"** — it's ambiguous, implying an action is recommended but optional, leaving the reader unsure what to actually do.

| Situation | Use | Example |
|---|---|---|
| Action required | *must*, or a clear imperative | "Do the following before you continue." |
| Action recommended | "We recommend..." / "Google recommends..." ("should" OK only for a generally-recognized recommendation) | "You should use a strong password." |
| Action optional | *can* | "You can also use approach B to solve the same problem." |
| Outcome expected | State the outcome directly | "The process returns 10 items." |
| Outcome possible | *might* or *can* | "The process can take about 30 minutes." |
| State (actual) | Clarify who/what sets it — never "should" | "You must set the value to true." / "The server sets the value to true." / "If the value is false, follow these steps to change it to true." |

For clarifying who performs an action, see Active voice.

### Examples
| Recommended | Not recommended |
|---|---|
| "Ensure that the Classroom Share Button conforms to our min-max size guidelines and related color/button templates." | "The Classroom Share Button should conform to our min-max size guidelines and related color and button templates." |
| "The column of the data table that the filter operates on." | "The column of the data table that the filter should operate on." |
| "Whether it's a brand new project or an existing one, perform the following steps." | "Whether it's a brand new project or an existing one, here's what you should do." |

See also: *can*, *could*, *may*, *might*, *must*, *would* in the word list.
