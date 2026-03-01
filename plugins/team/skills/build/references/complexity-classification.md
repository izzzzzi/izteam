# Complexity Classification Algorithm

> Classify feature complexity as SIMPLE, MEDIUM, or COMPLEX. Follow this algorithm step by step in order. Triggers are MANDATORY and cannot be overridden.

## STEP A: Count MEDIUM triggers (check all 6)

| # | Trigger | How to check |
|---|---------|-------------|
| 1 | **2+ layers** touched (DB, API, UI) | From researcher: which layers does the feature touch? |
| 2 | **Changes existing behavior** (not just adding new code) | Does the feature modify files that already work, or only create new ones? |
| 3 | **Near sensitive areas** — code adjacent to auth, payments, permissions | From researcher: do any touched files import/call auth or billing modules? |
| 4 | **3+ tasks** in decomposition | Count tasks after planning |
| 5 | **Dependencies between tasks** — at least 1 task blocks another | Can all tasks run in parallel, or does order matter? |
| 6 | **5+ files** will be created or edited | Count all files from task descriptions. Do NOT bundle many changes into fewer tasks to dodge this trigger. |

> If **0-1** triggered: **SIMPLE**. Skip to classification result.
> If **2-3** triggered: tentatively MEDIUM. Go to Step B.
> If **4+** triggered: **COMPLEX. STOP.** Do not check Step B. 4+ medium signals = complex task by accumulation.

## STEP B: Count COMPLEX triggers (check all 7 — only if Step A result was 2-3)

| # | Trigger | How to check |
|---|---------|-------------|
| 1 | **3 layers simultaneously** (DB + API + UI all touched) | From researcher |
| 2 | **Changes behavior other features depend on** — shared utils, middleware, core hooks | From researcher: are modified files imported by 3+ other modules? |
| 3 | **Direct changes to auth/payments/billing** — not adjacent, but the actual auth/payment code | From researcher: are auth/billing files in the edit list? |
| 4 | **5+ tasks** in decomposition | Count tasks after planning |
| 5 | **Chain of 3+ dependent tasks** — A blocks B blocks C | Check task dependency graph |
| 6 | **No gold standard exists** for this type of code — new pattern for the project | No matching file in .conventions/ or researcher found no reference files |
| 7 | **10+ files** will be created or edited | Count all files from task descriptions |

> If **0** triggered: **MEDIUM**.
> If **1+** triggered: **COMPLEX**.

## Classification result (MUST follow this format)

```
STEP A — MEDIUM triggers: N/6 fired
  [list which triggered, with evidence]
STEP A result: [SIMPLE / tentatively MEDIUM / COMPLEX by accumulation]

STEP B — COMPLEX triggers: N/7 fired (skip if Step A = SIMPLE or COMPLEX)
  [list which triggered, with evidence]

FINAL: [SIMPLE / MEDIUM / COMPLEX] (mandatory, not overridable)
```

## What each level means

**SIMPLE:**
- Skip Tech Lead plan validation
- Coders get gold standards + automated checks
- Unified Reviewer only (skip separate security/logic/quality)
- Skip risk analysis
- Faster flow

**MEDIUM:**
- Full flow as described below
- Tech Lead validates plan
- Risk analysis (Step 4b)
- 1-3 separate reviewers

**COMPLEX:**
- Full flow + user is notified about key trade-off decisions
- Tech Lead validates architecture BEFORE coding starts
- Full risk analysis with risk testers
- If coder flags "pattern doesn't fit" → Lead decides or escalates to user

## Team Roster by Complexity (Supervisor is mandatory in all modes)

| Complexity | Team Composition | Total Agents |
|-----------|------------------|--------------|
| SIMPLE | Lead + Supervisor + Coder + Unified Reviewer | 4 |
| MEDIUM | Lead + Supervisor + Coder + 1-3 Reviewers + Tech Lead | 5-7 |
| COMPLEX | Lead + Supervisor + Coder(s) + 3 Reviewers + Tech Lead + Researchers + Risk Testers | 6-9+ |

For SIMPLE tasks: spawn `team:unified-reviewer` instead of 3 separate reviewers. The unified reviewer covers security basics, logic, and quality in one pass. If it detects sensitive code, it emits `ESCALATE TO MEDIUM` to Supervisor (not Lead directly).

## Roster-scoped approval matrix (single source of truth)

| Runtime mode | Required approvals to pass task gate |
|---|---|
| SIMPLE (not escalated) | `unified-reviewer` |
| SIMPLE escalated to MEDIUM | `security-reviewer` + `logic-reviewer` + `quality-reviewer` + `tech-lead` |
| MEDIUM | Active reviewer set for this task (subset of `{security-reviewer, logic-reviewer, quality-reviewer}` decided by Lead/Tech Lead) + `tech-lead` |
| COMPLEX | `security-reviewer` + `logic-reviewer` + `quality-reviewer` + `tech-lead` |

Wait rules are roster-scoped at runtime:
- Required approvers are computed from complexity/mode and `Team Roster` in `state.md`.
- Never wait on roles that are not ACTIVE in roster.
- If a required approver is missing from ACTIVE roster, fail fast with `IMPOSSIBLE_WAIT` and escalate/stuck instead of waiting indefinitely.
