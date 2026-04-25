## General best practices

- Run shell scripts through shellcheck.
- Use `tmp/` (project-local) for intermediate files and comparison
  artifacts, not `/tmp`. This keeps outputs discoverable and
  project-scoped, and avoids requesting permissions for `/tmp`.

### SESSION.md

While working, if you come across any bugs, missing features, or other
oddities about the implementation, structure, or workflow, **add a
concise description of them to SESSION.md** to defer solving such
incidental tasks until later. You do not need to fix them all straight
away unless they block your progress; writing them down is often
sufficient. **Do not write your accomplishments into this file.**

## Python Guidelines (using `uv`)

- **Managing Dependencies**: Use `uv add` to add dependencies to your project. This ensures your `pyproject.toml` and lockfile are updated efficiently.
- **Error Handling**: When using libraries like `pydantic` or custom exception wrappers, consistently wrap calls that might fail in a `try/except` block and raise a custom exception with a clear message.
  - Context messages should be in the **simple present tense** to complete the sentence "while attempting to...".
  - _Example_: `raise RuntimeError("fetch user data") from e`
- **Invariants and Assertions**: Prefer `assert` with a descriptive message over raw indexing or risky lookups. The assertion message should be concise and explain **why** the condition must hold true (e.g., `assert user_id is not None, "user must be authenticated before checkout"`).
- **API Design**: When designing public or internal APIs, follow the standards in [PEP 8](https://peps.python.org/pep-0008/) and utilize [Type Hints (PEP 484)](https://peps.python.org/pep-0484/) to ensure clear interfaces and better IDE support.
- **Ad-hoc Debugging**: For temporary testing or debugging, create a script in a `scripts/` or `examples/` directory. Run it using `uv run scripts/debug_task.py`. Delete the script once the issue is resolved.

## Git workflow

Use the `commit-writer` skill, if available, to draft commit messages.
It reads the current diff and produces a message following the
conventions below.

Make sure you use git mv to move any files that are already checked into
git.

When writing commit messages, ensure that you explain any non-obvious
trade-offs we've made in the design or implementation.

Wrap any prose (but not code) in the commit message to match git commit
conventions, including the title. Also, follow semantic commit
conventions for the commit title.

When you refer to types or very short code snippets, place them in
backticks. When you have a full line of code or more than one line of
code, put them in indented code blocks.

## Documentation preferences

### Documentation examples

- Use realistic names for types and variables.

## Code style preferences

Document when you have intentionally omitted code that the reader might
otherwise expect to be present.

Add TODO comments for features or nuances that were deemed not important
to add, support, or implement right away.

### Literate Programming

Apply literate programming principles to make code self-documenting and maintainable across all languages:

#### Core Principles

1. **Explain the Why, Not Just the What**: Focus on business logic, design decisions, and reasoning rather than describing what the code obviously does.

2. **Top-Down Narrative Flow**: Structure code to read like a story with clear sections that build logically:

   ```python
   # ==============================================================================
   # Plugin Configuration Extraction
   # ==============================================================================
   #
   # First, we extract plugin metadata from Cargo.toml to determine
   # what files we need to build and where to put them.
   ```

3. **Inline Context**: Place explanatory comments immediately before relevant code blocks, explaining the purpose and any important considerations:

   ```python
   # Convert timestamps to UTC for consistent comparison across time zones.
   # This prevents edge cases where local time changes affect rebuild detection.
   utc_timestamp = datetime.utcfromtimestamp(file_stat.st_mtime)
   ```

4. **Avoid Over-Abstraction**: Prefer clear, well-documented inline code over excessive function decomposition when logic is sequential and context-dependent. Functions should serve genuine reusability, not just file organization.

5. **Self-Contained When Practical**: Reduce dependencies on external shared utilities when the logic is straightforward enough to inline with good documentation.

#### Implementation Benefits

- **Maintainability**: Future developers can quickly understand both implementation and design rationale
- **Debugging**: When code fails, documentation helps identify which logical step failed and why
- **Knowledge Transfer**: Code serves as documentation of the problem domain, not just the solution
- **Reduced Cognitive Load**: Readers don't need to mentally reconstruct the author's reasoning

#### When to Apply

Use literate programming for:

- Complex algorithms with multiple phases or decision points
- Code implementing business logic rather than simple plumbing
- Code where the "why" is not immediately obvious from the "what"
- Integration points between systems where context matters

Avoid over-documenting:

- Simple utility functions where intent is clear from the signature
- Trivial getters/setters or obvious wrapper code
- Code that's primarily syntactic sugar over well-known patterns

## Github Copilot run command in fish shell insights

Github copilot have a problem running multiple lines command in fish shell

For example:

```bash

uv run python -c "
import sys
sys.stdout.flush()
import torch
import torch.nn as nn
from src.losses import DiceFocalLoss
from src.models.attention_unet import ConvBlock, UpConv, AttentionGate
print('step 1', flush=True)
filters = [64, 128, 256, 512, 1024]
c1 = ConvBlock(3, filters[0])
print('step 2', flush=True)
c5 = ConvBlock(filters[3], filters[4])
print('step 3', flush=True)
up5 = UpConv(filters[4], filters[3])
print('step 4', flush=True)
att5 = AttentionGate(F_g=filters[3], F_l=filters[3], F_int=filters[2])
print('step 5', flush=True)
loss = DiceFocalLoss(alpha=0.75, gamma=2.0, dice_weight=0.5, focal_weight=0.5)
print('step 6 all done', flush=True)
"
```

This will not work in fish shell if run this through github copilot interface it will split the lines and run each lines as separate command in vscode github copilot terminal

If you need to run the multiple lines commands please write to a file in tmp/ folder and run the file from there

### Prefer temp files over pipes for sub-agent CLI testing

When testing a CLI with ad-hoc input, write the input to a temp file
in `tmp/` using the Write tool (not `cat`/`echo` with heredoc + `>`),
then pass it by path rather than piping. This avoids interactive
permission prompts in sub-agents.

# Common failure modes when helping

## The XY Problem

The XY problem occurs when someone asks about their attempted solution (Y) instead of their actual underlying problem (X).

### The Pattern

1. User wants to accomplish goal X
2. User thinks Y is the best approach to solve X
3. User asks specifically about Y, not X
4. Helper becomes confused by the odd/narrow request
5. Time is wasted on suboptimal solutions

### Warning Signs to Watch For

- Focus on a specific technical method without explaining why
- Resistance to providing broader context when asked
- Rejecting alternative approaches outright
- Questions that seem oddly narrow or convoluted
- "How do I get the last 3 characters of a filename?" (when they want file extension)

### How to Avoid It (As Helper)

- **Ask probing questions**: "What are you trying to accomplish overall?"
- **Request context**: "Can you explain the bigger picture?"
- **Challenge assumptions**: "Why do you think this approach will work?"
- **Offer alternatives**: "Have you considered...?"

### Red Flags in User Requests

- Very specific technical questions without motivation
- Unusual or roundabout approaches to common problems
- Dismissal of "why do you want to do that?" questions
- Focus on implementation details before problem definition

### Key Principle

Always try to understand the fundamental problem (X) before helping with the proposed solution (Y). The user's approach may not be optimal or may indicate they're solving the wrong problem entirely.
