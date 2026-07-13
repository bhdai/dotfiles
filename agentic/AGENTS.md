## Tooling

- Python is managed with **uv only**. Add a package: `uv add <pkg>` — never pip, never
  hand-edit `pyproject.toml`. **Ask before adding any dependency**; prefer the stdlib.

## Working style

Frontier defaults are fine; these two are the ones worth stating because the default drift
runs the other way:

- **Surgical changes.** Touch only what the task needs. Don't refactor, reformat, or
  "improve" adjacent code. Remove only the orphans your change created; flag pre-existing
  dead code rather than deleting it. Match existing style even if you'd do it differently.
- **No speculation.** No abstractions for single-use code, no unrequested config/flexibility,
  no error handling for impossible cases.

## Comments

Comment only what a reader cannot recover from the code or from tooling.
A comment that restates the code, summarizes a body, or maps the repo gets deleted.

- WHY, not WHAT. Non-obvious intent, rejected alternatives, upstream quirks,
  invariants this code silently depends on, non-standard practices. Write these
  in full — do not abbreviate to save tokens; abbreviation costs more in
  reasoning than it saves in input.
- At the seams: exported functions and module boundaries get a contract — what a
  caller must know that the signature doesn't say. Not a paraphrase of the body.
- Near-zero inside bodies. No comments on straightforward control flow.
- Never comment out code. Delete it; git has it. Dead code in the buffer gets
  reasoned over and its defects reproduced.
- Never write changelog comments ("changed from X", "now uses Y"). Describe the
  code as it is, not how it got that shape.
- Register: a reader new to this codebase, fluent in the language, familiar with
  the project's goal. Assume competence, deny familiarity. No jargon that needs
  repo history to parse.
- Don't hand-maintain a repo map or architecture overview for the agent. Overviews
  measurably don't help and cost 20%+. Let tooling derive navigation from source.
