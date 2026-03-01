# Gold Standard Block Template

> Gold standards are the #1 lever for code quality (+15-40% accuracy vs instructions alone).
> Coders MUST receive canonical examples as few-shot context.

## Format

Lead compiles this block from researcher findings + `.conventions/` (if exists):

```
GOLD STANDARD BLOCK (compiled by Lead):

--- GOLD STANDARD: [layer] — [file path] ---
[Full file content or .conventions/ snippet]
[Note: pay attention to X, Y naming]

--- GOLD STANDARD: [layer] — [file path] ---
[Full file content]

--- CONVENTIONS ---
[Key rules from .conventions/checks/ or CLAUDE.md — naming patterns, import rules, etc.]
```

## Rules

- 3-5 examples, ~100-150 lines total
- Prioritize by relevance to the feature
- Include FULL file content (not summaries) — coders need to see the actual pattern
- Add notes pointing to specific patterns to match (naming, error handling, imports)

## Briefing File Pattern (write once, read many)

Instead of duplicating the GOLD STANDARD BLOCK inline in each coder's spawn prompt (~3000 tokens x N coders), the Lead writes it to a shared briefing file that all coders read:

**Step 1: Lead writes the briefing file** (once, after compiling the block in Step 3):

```
Write(.claude/teams/{team-name}/briefing.md, content="""
# Briefing: {feature name}

## Team Roster
- supervisor: operational monitoring
- tech-lead: architectural review (if spawned)
- security-reviewer / logic-reviewer / quality-reviewer (or unified-reviewer for SIMPLE)
- lead: decisions and staffing

## Gold Standard Examples

--- GOLD STANDARD: [layer] — [file path] ---
[Full file content]

--- GOLD STANDARD: [layer] — [file path] ---
[Full file content]

--- CONVENTIONS ---
[Key rules]
""")
```

**Step 2: Coder spawn prompts reference the file** (minimal tokens per coder):

```
Task(
  subagent_type="team:coder",
  team_name="feature-<name>",
  name="coder-<N>",
  prompt="You are Coder #{N}. Team: feature-<name>.

Read .claude/teams/{team-name}/briefing.md for gold standard examples and team roster.

Claim your first task from the task list and start working."
)
```

This saves ~3000 tokens per additional coder (only 1 write + N reads instead of N inline copies).

## Task Description First

When providing context to coders, put the task description FIRST, then the briefing reference:

```
prompt="You are Coder #{N}. Team: feature-<name>.

YOUR TASK CONTEXT:
{Brief summary of what this coder will work on}

Read .claude/teams/{team-name}/briefing.md for gold standard examples and team roster.

Claim your first task from the task list and start working."
```

This ensures the coder reads what they need to DO before seeing examples of HOW.
