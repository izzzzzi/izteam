# Decision: team-lead slug is a framework convention

**Date:** 2026-03-01
**Context:** During best practices audit, arena plugin's moderator was identified as using the `team-lead` slug for SendMessage — the same slug used by the team plugin's Tech Lead. A rename to `moderator` was proposed to avoid naming confusion.

**Decision:** Keep `team-lead` as the skill orchestrator slug in all plugins. Do not rename per-plugin.

**Reason:** `team-lead` is a hardcoded framework convention in Claude Agent SDK. The skill orchestrator (the agent spawned by the Skill tool) is always addressable as `team-lead` via SendMessage. This is not configurable per-plugin.

**Alternatives considered:**
- Rename arena moderator to `moderator` — rejected because it would break expert-to-moderator messaging (experts use `SendMessage(recipient="team-lead")`)
- Use a wrapper or alias — not supported by the framework

**Consequences:**
- The `team-lead` slug appears in arena (moderator), team (build lead), think (orchestrator), and audit (scanner lead) — all referring to the skill orchestrator role
- No actual conflict exists: each plugin runs in a separate `TeamCreate` instance with its own team namespace
- Agent documentation should clarify that `team-lead` refers to "the skill orchestrator" not a specific role name
- When reading agent files, `recipient="team-lead"` always means "send to whoever invoked this skill"

## Applies to
- `plugins/*/agents/*.md` — any agent using `SendMessage(recipient="team-lead")`
- `plugins/*/skills/*/SKILL.md` — any skill defining orchestrator behavior
