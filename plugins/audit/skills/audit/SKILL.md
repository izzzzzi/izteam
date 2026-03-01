---
name: audit
description: >-
  Conducts an interactive feature audit to find dead code, abandoned
  experiments, and unused features, then asks the user about each one. Use when
  the user wants to clean up the codebase, find unused code, or review
  experimental features. Don't use for security audits, performance profiling,
  dependency scanning, or code quality reviews.
allowed-tools:
  - Task
  - Read
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
argument-hint: "[scope: features | server | ui | stores | all]"
model: opus
---

# Vibe Audit — Interactive Feature Cleanup

The audit skill finds potentially dead or experimental code and **asks the user** whether it's still needed.

## Philosophy

In vibe-coding, lots of experimental code gets created. Some becomes core features, some gets abandoned. This skill identifies what's what through **conversation**, not assumptions.

## Workflow

### Step 1: Discovery

Run the appropriate agent based on scope (see "Scope Options" below):

```
# Default or "all"
Task(audit:feature-scanner) - "Scan codebase for potentially unused features"

# Specific scopes
Task(audit:features-auditor) - "Audit src/features/ for unused exports"
Task(audit:server-auditor) - "Audit src/server/ for unused procedures"
Task(audit:ui-auditor) - "Audit src/design-system/ for orphan components"
Task(audit:stores-auditor) - "Audit src/stores/ for dead Zustand slices"
```

### Step 2: Interactive Review

For EACH suspicious item found, use AskUserQuestion:

```
AskUserQuestion with options:
- "🗑️ Delete — this is dead code"
- "⚠️ Deprecated — remove soon"
- "✅ Keep — this is an active feature"
- "🤔 Not sure — needs investigation"
```

**Important:** Ask ONE feature at a time. Wait for answer before proceeding.

### Step 3: Generate Report

After all questions answered, create action plan:

```markdown
# 🧹 Vibe Audit Report

## Decisions

### 🗑️ To Delete
- [feature] — reason: [user's answer]

### ⚠️ Deprecated
- [feature] — remove by: [date]

### ✅ Keep
- [feature] — document: [what it does]

## Next Steps
1. [ ] Delete [X] files
2. [ ] Add @deprecated to [Y]
3. [ ] Update documentation for [Z]
```

## Question Templates

When asking about a feature, provide context:

```
📦 **{feature_name}**

What was found:
- Files: {file_count} ({file_list})
- Usage: {usage_description}
- Last commit: {last_commit_date}
- Dependencies: {dependencies}

Is this needed?
```

## Scope Options

| Scope | Agent | Target |
|-------|-------|--------|
| **features** | `features-auditor` | `src/features/` — unused exports, dead code |
| **server** | `server-auditor` | `src/server/` — unused tRPC procedures, services |
| **ui** | `ui-auditor` | `src/design-system/` — orphan components |
| **stores** | `stores-auditor` | `src/stores/` — dead Zustand slices |
| **all** | `feature-scanner` | Full codebase scan |

### Agent Selection

```
Scope argument?
├── (empty) or "all"
│   └── Task(audit:feature-scanner) — full codebase scan
├── "features"
│   └── Task(audit:features-auditor) — src/features/ analysis
├── "server"
│   └── Task(audit:server-auditor) — src/server/ analysis
├── "ui"
│   └── Task(audit:ui-auditor) — src/design-system/ analysis
├── "stores"
│   └── Task(audit:stores-auditor) — src/stores/ analysis
└── "all" (explicit)
    └── Run ALL auditors in parallel:
        ├── Task(audit:feature-scanner)
        ├── Task(audit:features-auditor)
        ├── Task(audit:server-auditor)
        ├── Task(audit:ui-auditor)
        └── Task(audit:stores-auditor)
```

## Error Handling

| Situation | Action |
|-----------|--------|
| Scanner agent fails or returns empty | Inform user: "Scan returned no results. Try narrowing scope." Suggest specific directories. |
| Partial scan results | Report what was found. Note which areas were not scanned. |
| Git operations fail in cleanup | Stop cleanup immediately. Report error. Do not proceed with further deletions. |
| TypeScript check fails after deletion | Report which deletion caused the failure. Suggest rollback via git. |
| Project does not use expected stack (no tRPC, no Zustand, etc.) | Adapt scanning patterns to the actual stack. Skip inapplicable auditors. |

## Important Rules

1. **Never delete without confirmation** — the cleanup-executor agent enforces this with git backup
2. **One question at a time** — don't overwhelm with batch questions
3. **Provide context** — show findings before asking
4. **Accept "not sure"** — some things need more investigation
5. **Track decisions** — remember what user said for the report
