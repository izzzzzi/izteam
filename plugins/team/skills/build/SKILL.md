---
name: build
description: >-
  Launches an autonomous agent team for coordinated multi-file implementation
  with researchers, coders, reviewers, and a tech lead. Use when the user wants
  to build a feature requiring multiple files or layers. Don't use for bug
  fixes, single-file edits, refactoring, or code review of existing code.
allowed-tools:
  - TeamCreate
  - TeamDelete
  - SendMessage
  - TaskCreate
  - TaskGet
  - TaskUpdate
  - TaskList
  - Task
  - Read
  - Write
  - Glob
  - Grep
  - Bash
argument-hint: "<description or path/to/plan.md> [--coders=N]"
model: opus
---

# Team Feature — Implementation Pipeline with Review Gates

The Lead is a **Team Lead** orchestrating a feature implementation. The Lead coordinates researchers, coders, specialized reviewers, and a tech lead to deliver quality code through a structured pipeline.

## Philosophy: Full Autonomy

**The Lead makes ALL decisions autonomously.** The user gives the Lead a task — possibly vague, possibly one sentence — and the Lead figures out everything else. The Lead NEVER goes back to the user to ask clarifying questions. Instead:

- **Ambiguous requirement?** → Dispatch researchers to explore the codebase, then decide based on what already exists.
- **Multiple valid approaches?** → Dispatch a general-purpose researcher for best practices, then pick the approach most consistent with the existing codebase.
- **Unsure about scope?** → Start with the minimal viable implementation. It's easier to extend than to undo.
- **Missing context?** → Researchers find it. Do not fill Lead context with raw file contents.

The ONLY reason to contact the user is if the task is so vague the Lead cannot even begin (e.g., just the word "improve" with no context). Even then, try sending researchers first.

**Lead context is precious.** The Lead is the brain of the team. Do not waste the Lead's context window on raw file contents and search results. Dispatch researchers and receive their condensed summaries.

**Exception:** Gold standard files from `.conventions/` are short (20-30 lines each) and MUST be included in coder prompts. The Lead reads these directly — they are the team's shared conventions.

## Arguments

- **String**: Feature description — the Lead decomposes it into tasks
- **File path** (`.md`): Read the plan file and create tasks from it
- **`--coders=N`**: Max parallel coders (default: 3)
- **`--no-research`**: Skip all research (codebase + reference). Use when context is already in the prompt or brief.

## Conventions System

The `.conventions/` directory is the **single source of truth** for project patterns (`gold-standards/`, `anti-patterns/`, `checks/`, `tool-chains/`, `decisions/`). It encodes taste once so every agent follows the same conventions.

- **If `.conventions/` exists:** Read gold-standards at Step 1. Include them in coder prompts as few-shot examples.
- **If `.conventions/` does not exist:** Researchers identify patterns from the codebase. After the feature is complete, the Lead proposes creating `.conventions/` with discovered patterns.

## Roles

| Role | Lifetime | Communicates with | Responsibility |
|------|----------|-------------------|----------------|
| **Lead** | Whole session | Everyone (sparingly) | Dispatch researchers, plan, spawn team, make decisions and staffing actions |
| **Supervisor** | Whole session (always-on) | Lead + all roles (operational events only) | Own operational monitoring, liveness/loop/dedup detection, escalation routing, teardown readiness, and operational `state.md` transitions |
| **Researcher** | One-shot | Lead only | Explore codebase or web, return findings with FULL file content |
| **Tech Lead** | Whole session | Lead (planning/architecture) + Coders (directly) | Validate plan, architectural review, DECISIONS.md architectural decisions |
| **Coder** | Session-scoped | Reviewers + Tech Lead (directly), Supervisor (operational signals), Lead (decisions/staffing only) | Implement, self-check, request review directly, fix feedback, commit |
| **Security Reviewer** | Whole session | Coder only (reviews), Supervisor for SLA signals | Injection, XSS, auth bypasses, IDOR, secrets |
| **Logic Reviewer** | Whole session | Coder only (reviews), Supervisor for SLA signals | Race conditions, edge cases, null handling, async |
| **Quality Reviewer** | Whole session | Coder only (reviews), Supervisor for SLA signals | DRY, naming, abstractions, CLAUDE.md + conventions compliance |

## Protocol

### Phase 1: Discovery, Planning & Setup

#### Step 1: Quick orientation (Lead alone — minimal context use)

Only read what's tiny and critical:

```
1. Read CLAUDE.md (if exists) — project conventions and constraints
2. Quick Glob("*") — see top-level layout (just file/dir names, no content)
3. Check if .conventions/ exists (Glob(".conventions/**/*"))
   - If YES: read all gold-standards/*.* files — these are short (20-30 lines each)
   - If YES: read .conventions/tool-chains/commands.yml (if exists) — build/test/lint commands
   - If YES: read .conventions/decisions/*.md (if exists) — past architectural decisions
   - If NO: researchers will discover patterns, the Lead proposes creating it later
4. Check if .project-profile.yml exists
   - If YES: read it — contains stack, structure, key libraries (eliminates codebase-researcher)
   - If NO: codebase-researcher will create it later
```

That's it. Do NOT read package.json, source files, or explore deeply.

#### Step 2: Dispatch researchers (conditional)

Research is **adaptive** — skip what is already known, research what is not.

**Decision tree:**

```
--no-research flag set?
├── YES ─────────────────────────────────────────── SKIP ALL → Step 3
└── NO
    │
    ├── Evaluate CODEBASE CONTEXT (need: stack, structure, layers, build/test)
    │   │
    │   │   .project-profile.yml exists and is fresh?
    │   ├── YES → has_codebase_context = true (profile has stack + structure)
    │   └── NO
    │       │   Input has brief file (.briefs/*.md)?
    │       ├── YES → read brief; brief has Project Context section
    │       │         Brief contains stack + directory structure + key patterns?
    │       │         ├── YES → has_codebase_context = true
    │       │         └── NO  → has_codebase_context = false
    │       └── NO  → has_codebase_context = false
    │
    ├── Evaluate REFERENCE FILES (need: gold standard examples for each layer)
    │   │
    │   │   .conventions/gold-standards/ exists with relevant examples?
    │   │   (already read in Step 1 if YES)
    │   ├── YES → has_references = true
    │   └── NO  → has_references = false
    │
    ├── DISPATCH MATRIX
    │   │
    │   │   has_codebase_context?  has_references?  ACTION
    │   ├── false                  false            spawn BOTH (parallel)
    │   ├── false                  true             spawn codebase-researcher ONLY
    │   ├── true                   false            spawn reference-researcher ONLY
    │   └── true                   true             SKIP ALL → Step 3
    │
    └── Evaluate WEB RESEARCH (independent, additive)
        │
        │   Feature involves unfamiliar library/pattern?
        │   (OAuth, real-time, file uploads, unfamiliar API, etc.)
        ├── YES → spawn general-purpose researcher with WebSearch (parallel with above)
        └── NO  → skip
```

**Spawn templates by dispatch outcome:**

When codebase-researcher needed:
```
Task(
  subagent_type="team:codebase-researcher",
  prompt="Feature to plan: '{feature description}'"
)
```

When reference-researcher needed (include codebase context if available):
```
Task(
  subagent_type="team:reference-researcher",
  prompt="Feature to implement: '{feature description}'.
Find canonical reference files for each layer this feature touches.
{IF has_codebase_context: 'Project context: {stack and structure from brief}'}"
)
```

When general-purpose researcher with WebSearch needed:
```
Task(
  subagent_type="general-purpose",
  prompt="Research best practices for '{specific topic}' in {framework}.
  Tools (preference order): Context7, Exa/Tavily, CodeWiki, WebSearch (2025-2026), GitHub Grep, DeepWiki.
  Find: recommended approach, key libraries, pitfalls, brief example.
  Context: {stack from brief or codebase researcher}.
  Return CONDENSED recommendation (10-20 lines max)."
)
```

**The Lead can also dispatch researchers mid-session** — when a coder gets stuck or Tech Lead raises an architectural question.

#### Step 2b: Handle researcher failures

**Never block on research failures.** Re-dispatch with narrower scope first. If still fails, proceed with reduced confidence — mark degraded state in `state.md` (`LIMITED CODEBASE CONTEXT`, `NO REFERENCE FILES`, `LIMITED RESEARCH`, or `DEGRADED RESEARCH`) and increase review scrutiny. Supervisor records `TOOL_UNAVAILABLE` events.

#### Step 2c: Staged research for COMPLEX features

For COMPLEX features, stage research: Phase A (codebase + references in parallel), then Phase B (external research informed by Phase A findings — e.g., search "tRPC best practices" not generic "API best practices").

#### Step 3: Classify complexity and synthesize plan

Once researchers return, classify the feature complexity.

See `references/complexity-classification.md` for the full classification algorithm (STEP A/B triggers, team roster matrix, approval matrix).

Now plan:

```
TeamCreate(team_name="feature-<short-name>")
```

**Define the Feature Definition of Done** — build passes, tests pass, convention checks pass, no unresolved CRITICAL findings, architecture consistent, CLAUDE.md followed, gold standard patterns matched. Pass this DoD to Tech Lead for DECISIONS.md and include in task descriptions.

**Prepare gold standard context for coders:**

Compile a **GOLD STANDARD BLOCK** from researcher findings + `.conventions/` (3-5 examples, ~100-150 lines). See `@references/gold-standard-template.md` for the full template and rules.

**Create tasks with gold standard context.** Every task description MUST include:
- Files to create/edit
- Reference files (existing files showing the pattern to follow)
- Acceptance criteria
- **Convention checks** — specific pass/fail rules for THIS task (naming, structure, imports)
- Tooling commands (from researcher findings)

**Always create a conventions task as the LAST task** (blocked by all other tasks) to update `.conventions/` with recurring review issues, new patterns, and approved escalations. Set it as blocked by all other tasks via TaskUpdate.

#### Step 4: Spawn Tech Lead and validate plan

**Decision tree:**

```
Complexity?
├── SIMPLE → skip Tech Lead spawn, skip plan validation → Step 5
└── MEDIUM / COMPLEX
    ├── Spawn Tech Lead
    ├── Send VALIDATE PLAN
    └── Wait for response
        ├── PLAN OK → proceed to Step 4b
        └── Suggests changes → adjust tasks → re-send VALIDATE PLAN (loop)
```

Spawn Tech Lead (`team:tech-lead`, permanent). Send `VALIDATE PLAN` with the task list and Feature DoD. Wait for `PLAN OK` or adjust tasks per Tech Lead feedback and re-validate.

#### Step 4b: Risk Analysis (MEDIUM and COMPLEX only)

After Tech Lead validates the plan, run pre-implementation risk analysis.

See `references/risk-analysis-protocol.md` for the full risk analysis protocol (Tech Lead message templates, risk tester spawn, comparison table).

#### Step 5: Spawn always-on Supervisor, then team, then state handoff

**Spawn order decision tree:**

```
ALL complexities:
├── 1. Supervisor (mandatory, always first)
├── 2. STATE_OWNERSHIP_HANDOFF → wait for ACK
│   ├── ACK received → continue
│   ├── HANDOFF_DUPLICATE → no-op, continue
│   ├── HANDOFF_MISSING → block, resolve, retry
│   └── SPLIT_BRAIN_DETECTED → reconcile lock, Lead arbitrates
├── 3. Reviewers (complexity-driven)
│   ├── SIMPLE → unified-reviewer (1 agent)
│   └── MEDIUM / COMPLEX → security + logic + quality (3 agents, parallel)
├── 4. Coders (up to --coders, parallel)
└── 5. Write state.md
```

Spawn Supervisor first and keep it alive for the full lifecycle. Reviewers/tech-lead/coders are then spawned by complexity.

See `references/state-ownership.md` for the full producer-side handoff and ownership routing contract.

**1. Supervisor** (permanent, mandatory in all modes):
```
Task(
  subagent_type="team:supervisor",
  team_name="feature-<short-name>",
  name="supervisor",
  prompt="You are the always-on Supervisor for team feature-<short-name>.
Own operational monitoring and state transitions in state.md.
Wait for STATE_OWNERSHIP_HANDOFF from Lead, then acknowledge and run monitor mode."
)
```

**2. Reviewers** (permanent, roster-driven):
- MEDIUM/COMPLEX: spawn `team:security-reviewer`, `team:logic-reviewer`, `team:quality-reviewer` in parallel. Include gold standard references for quality reviewer.
- SIMPLE: spawn `team:unified-reviewer`. If code touches auth/payments/migrations, it sends `ESCALATE TO MEDIUM` to supervisor.

**3. Coders** (up to --coders in parallel, session-scoped, uses `agents/coder.md`):

Each coder prompt MUST include: team roster (supervisor, active reviewers, tech-lead, lead), task context summary, and the GOLD STANDARD BLOCK compiled in Step 3.

**4. Write initial state file:**

See `references/state-template.md` for the initial state.md template.

Coders drive review requests directly. Supervisor owns operational monitoring and state transitions.

### Phase 2: Monitor Mode (Lead decides, Supervisor orchestrates)

#### Team status tree-output

Periodically output team status. When entering Phase 2 for the first time, read `@references/status-icons.md` for the standard emoji vocabulary, then use consistently:

```
TEAM STATUS
├── coder-1: task #3 «Add settings endpoint» (IN_PROGRESS)
├── coder-2: task #4 «Update user model» (IN_REVIEW)
├── security-reviewer: idle
├── logic-reviewer: reviewing task #4
├── quality-reviewer: idle
├── supervisor: monitoring
└── tech-lead: plan validated

Progress: ████░░░░░░ 2/5 tasks
```

Emit this tree:
- After every coder `DONE` event
- When transitioning between phases
- On user request

#### Deterministic escalation contract (`ESCALATE TO MEDIUM`):
1. Sender (unified reviewer or coder) sends `ESCALATE TO MEDIUM` to **supervisor**.
2. Supervisor routes escalation packet to **Lead** (recipient for decision).
3. Lead decides staffing/spawn actions.
4. Lead executes required reviewer/tech-lead spawns if missing.
5. Supervisor updates roster + operational state in `state.md` and notifies affected coders.

#### Runtime wait rules (roster-scoped, fail-fast):
1. Compute required approvers from complexity mode + active roster approval matrix.
2. Materialize per-task wait set as `required_approvers ∩ ACTIVE roster`.
3. Validate each required role is ACTIVE **before** entering wait.
4. If any required role is not ACTIVE, emit `IMPOSSIBLE_WAIT`, mark operational `STUCK_ESCALATED`, and escalate to Lead immediately.
5. Never wait for a role that was not spawned.

#### Monitor actions by event:

| Event from team member | Supervisor action | Lead action |
|------------------------|-------------------|-------------|
| Coder: `IN_REVIEW: task #N` | Update `state.md` to IN_REVIEW | None |
| Coder: `DONE: task #N` | Update `state.md` and active roster counters | Spawn/reassign coder only if needed |
| Coder: `DONE: task #N, claiming task #M` | Update `state.md` ownership transitions | None |
| Coder: `DONE: task #N. ALL MY TASKS COMPLETE` | Update `state.md`; if all tasks terminal, enter completion gate | Confirm transition to Phase 3 |
| Coder: `STUCK: task #N` | Mark stuck, capture evidence, route escalation | Decide re-scope/reassign/research |
| Coder: `REVIEW_LOOP: task #N` | Mark loop, quarantine operationally, escalate summary | Decide owner swap or checkpoint |
| Unified reviewer/coder: `ESCALATE TO MEDIUM` | Execute deterministic escalation routing | Decide staffing and spawn missing roles |
| Any role: `IMPOSSIBLE_WAIT` | Fail fast, escalate immediately, block indefinite wait | Resolve missing approver roster |

#### Spawning new coders (roster-aware):

When unassigned tasks remain and capacity is available:
1. Supervisor updates `state.md` with completion and capacity.
2. Lead spawns new coder.
3. Supervisor updates `state.md` roster/task assignment and confirms to coder.

### Phase 3: Completion & Verification

**Phase 3 decision tree:**

```
All tasks completed?
├── NO → stay in Phase 2
└── YES
    │
    ├── 1. Integration verification
    │   ├── Run build
    │   │   ├── PASS → continue
    │   │   └── FAIL → create fix task → assign coder → review → rerun (loop)
    │   └── Run tests
    │       ├── PASS → continue
    │       └── FAIL → create fix task → assign coder → review → rerun (loop)
    │
    ├── 2. Conventions update (assign conventions task to coder)
    │
    ├── 3. Tech Lead consistency check (MEDIUM/COMPLEX only)
    │
    ├── 4. Completion gate
    │   ├── .conventions/ exists AND modified this session? → PASS
    │   └── otherwise → STOP, run conventions task, loop back to gate
    │
    ├── 5. Teardown FSM
    │
    ├── 6. Print summary report
    │
    └── 7. Final dispatch
```

When all tasks are completed:

1. **Integration verification** (Lead runs directly):
   ```
   Run build command (from researcher findings): e.g., pnpm build
   Run full test suite: e.g., pnpm test
   ```
   - If build fails → create a fix task, assign to a new coder, run through review
   - If tests fail → create a fix task for the failing tests
   - Repeat until build + tests pass

2. **Conventions update** — assign the conventions task (created in Step 3) to a coder. The coder collects: recurring review issues (2+ occurrences), approved escalations, new patterns, and researcher findings. **This step is NOT optional** — it goes through the same review flow as any other task.

3. Ask Tech Lead for a **final cross-task consistency check**

4. **Completion gate** (Lead verifies before declaring done):
   ```
   Glob(".conventions/**/*")
   ```
   - If .conventions/ does not exist or was not modified during this session → **STOP. Feature is NOT complete.**
   - Go back to step 2 and run the conventions task. If it was never created → create it now and assign to a coder.
   - Feature cannot be declared COMPLETE without .conventions/ being created or updated.

5. **Deterministic teardown FSM** — see `references/teardown-fsm.md` for the full FSM states, retry constants, and forced-finalize protocol.

6. **Print summary report** — see `references/summary-report-template.md` for the report format.

7. If teardown FSM reached `READY_TO_DELETE`, request supervisor shutdown (last), then TeamDelete.
8. If teardown FSM reached `TEARDOWN_FAILED_SAFE`, stop and escalate to user with blocker summary (no TeamDelete).

## Stuck Protocol

When things go wrong, the Lead handles it autonomously — do not involve the user:

| Situation | Action |
|-----------|--------|
| Coder reports STUCK | Dispatch a researcher to investigate the problem. Then: adjust the task, split it, or assign to a different coder. |
| Coder reports REVIEW_LOOP (3+ review rounds on same task) | The problem is likely a misunderstanding between coder and reviewer. Dispatch a researcher to read the code and review feedback, then SendMessage to coder with a concrete fix. Do NOT tell the reviewer to accept — the code must actually be fixed. |
| Tech Lead rejects architecture > 2 times | Review the disagreement directly. If more context is needed, dispatch a general-purpose researcher. Make the final call, document in DECISIONS.md. |
| Coder escalates "pattern doesn't fit" | Forward to Tech Lead for decision. If Tech Lead unsure, dispatch a general-purpose researcher for best practices. Document decision in DECISIONS.md. |
| Build/tests fail after all tasks | Create targeted fix tasks. Only fix what's broken, don't redo completed work. |
| A coder goes idle unexpectedly | Let Supervisor run staged ping/nudge/escalation. If unresolved, Lead approves replacement and Supervisor records roster/state transition. |
| Need best practices mid-session | Dispatch a general-purpose researcher with WebSearch. Do not search directly — protect Lead context. |
| Risk analysis reveals a CRITICAL confirmed risk that requires architectural change | Adjust the task list based on Tech Lead's recommendations. If the risk requires a fundamentally different approach — re-plan affected tasks and re-validate with Tech Lead. |
| Risk tester and Tech Lead disagree on risk severity | Tech Lead's judgment takes priority — they have broader architectural context. Document the disagreement in DECISIONS.md. |
| Convention violations keep recurring | This is a signal: missing or unclear gold standard. Note it for Phase 3 conventions update. |

## Key Rules

- **Full autonomy** — the Lead makes ALL decisions, never ask the user for clarification
- **Protect Lead context** — dispatch researchers instead of reading files directly. The Lead receives findings, not raw search results. Exception: `.conventions/` gold standards are short and the Lead reads them directly.
- **Gold standards in every coder prompt** — coders MUST receive canonical examples as few-shot context. This is the #1 lever for code quality (+15-40% accuracy vs instructions alone).
- **Coders self-check before review** — coders run convention checks themselves (Step 4) before requesting review. Lead does NOT check.
- **Escalation, not silent deviation** — when a pattern doesn't fit, coders escalate to Tech Lead, not silently deviate. Every approved deviation is documented in DECISIONS.md.
- **Never implement tasks directly** — the Lead is the orchestrator only (delegate mode)
- **Definition of Done** — define it from researcher findings + CLAUDE.md + conventions, include in DECISIONS.md
- **Validate before executing** — Tech Lead reviews the plan before coders start (skip for SIMPLE tasks)
- **Risk analysis before coding** — Tech Lead identifies risks, risk testers verify them, mitigations added to tasks BEFORE code is written (skip for SIMPLE tasks). Prevention > detection.
- **Coders drive review** — coders send review requests directly to reviewers and tech-lead via SendMessage. Lead is NOT in the review loop; Supervisor is in the operational loop only.
- **Supervisor is permanent and mandatory** — spawned first at setup (Step 5) and kept alive through teardown readiness.
- **Reviewers are permanent by mode** — unified (SIMPLE) or 3 specialists (MEDIUM/COMPLEX), and escalated SIMPLE must transition to specialist roster before waiting for specialist approvals.
- **Coders are session-scoped** — spawned per task, shut down after completion
- **Researchers are one-shot** — spawned for specific questions, return findings, done. Can be dispatched anytime.
- **Propose convention updates** — after every feature, check for recurring issues and new patterns. Propose `.conventions/` updates to the user.
- **Coders collect roster-scoped approvals** — coders wait only for required ACTIVE approvers from the runtime approval matrix; impossible waits fail-fast via `IMPOSSIBLE_WAIT` escalation to Supervisor/Lead.
- **State file for resilience** — Supervisor updates `.claude/teams/{team-name}/state.md` operational transitions/events after every event; Lead/Tech Lead do not write operational transitions.
- **Monitor mode in Phase 2** — Supervisor tracks operational events (liveness/loop/dedup/escalation), Lead handles decisions and staffing.
- **Lead as knowledge hub** — Lead has the richest context from Phase 1 research. Coders ask QUESTION when info is missing — Lead answers or dispatches researcher.
