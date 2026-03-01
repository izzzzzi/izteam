# Status Icons — Unified Visual Language for the Team

> All team agents use these emoji constants for status messages, activeForm, and tree output. Uniformity improves readability and enables quick parsing of team state.

## Agent States

| Icon | State | When to Use |
|------|-------|-------------|
| 🔍 | Research | File search, Glob/Grep, reading code |
| 🔨 | Implementation | Writing/editing code |
| 📝 | Review | Reviewing another agent's code |
| ⏳ | Waiting | Waiting for a response from another agent |
| 🚀 | Start | Claiming a task, beginning work |
| ✅ | Done | Task/review completed |
| ❌ | Blocker | STUCK, IMPOSSIBLE_WAIT, error |
| 🔄 | Retry | Retry, re-check, fix after review |
| 💬 | Escalation | Question to Lead/Tech Lead, ESCALATION |
| 😴 | Idle | Agent is sleeping, waiting for a task |
| 👁 | Monitoring | Supervisor is watching the team |

## Roles (prefix in review)

| Icon | Role |
|------|------|
| 🔒 | Security Review |
| 🧠 | Logic Review |
| 📐 | Quality Review |
| 🔍 | Unified Review |

## Status Message Format

Each agent writes on state change:

```
{icon} [{ROLE}] {action} — {context}
```

Examples:
```
🚀 [CODER-1] Claiming task #3 «Add settings endpoint»
🔍 [CODER-1] Reading gold standards — src/server/routers/profile.ts
🔨 [CODER-1] Implementing — src/server/routers/settings.ts
✅ [CODER-1] Self-check passed — lint ✅ types ✅ tests ✅
⏳ [CODER-1] Requesting review — waiting for 3 reviewers
🔄 [CODER-1] Fixing CRITICAL — src/server/routers/settings.ts:42
✅ [CODER-1] Done — task #3 committed (abc1234)

📝 [SECURITY] Reviewing task #3 — 2 files
✅ [SECURITY] No security issues

❌ [CODER-2] Stuck — task #5, Prisma schema migration fails
💬 [CODER-2] Escalation to tech-lead — pattern doesn't fit

👁 [SUPERVISOR] All healthy — 2 coders active, 3 reviewers idle
```

## activeForm for TaskCreate/TaskUpdate

Use emoji from this table for the `activeForm` spinner:

```
TaskUpdate(taskId="3", status="in_progress", activeForm="🔨 Implementing settings endpoint")
TaskUpdate(taskId="3", activeForm="⏳ Waiting for review")
TaskUpdate(taskId="3", status="completed", activeForm="✅ Done")
```

## Tree Output for Lead (Monitor Mode)

Lead periodically outputs team status tree:

```
📋 TEAM STATUS
├── 🔨 coder-1: task #3 «Add settings endpoint» (IN_PROGRESS)
├── ⏳ coder-2: task #4 «Update user model» (IN_REVIEW)
├── 😴 security-reviewer: idle
├── 📝 logic-reviewer: reviewing task #4
├── 😴 quality-reviewer: idle
├── 👁 supervisor: monitoring
└── ✅ tech-lead: plan validated

Progress: ████░░░░░░ 2/5 tasks
```
