# Convention Check: Agent Contracts

## Message routing rules
- Operational signals (IN_REVIEW, DONE, STUCK, REVIEW_LOOP, IMPOSSIBLE_WAIT) -> supervisor
- Decision signals (QUESTION) -> Lead
- Architecture signals (ESCALATION) -> tech-lead
- Escalation routing (ESCALATE TO MEDIUM) -> supervisor -> Lead
- Review requests (REVIEW) -> reviewers + tech-lead directly

## Naming conventions
- Agent file: lowercase-kebab-case.md in `agents/`
- Skill file: SKILL.md in `skills/{skill-name}/`
- Team name: `feature-{short-name}`
- State file: `.claude/teams/{team-name}/state.md`
- Decisions file: `.claude/teams/{team-name}/DECISIONS.md`

## Event contract format
```
| event | producer | consumer | route-owner | state-write-owner | next step |
```

## Terminology consistency
- One canonical name per concept across all plugins (no "web researcher" vs "general-purpose researcher" drift)
- No phantom roles: every role referenced must have an agent definition or documented spawn pattern
- @references/ paths must point to existing files at plugin root (`plugins/{plugin}/references/`)

## Anti-patterns
- Sending operational signals (DONE, STUCK, REVIEW_LOOP) to Lead instead of Supervisor
- Waiting for roles not in active roster (must emit IMPOSSIBLE_WAIT)
- Writing operational state without ownership ACK (only Supervisor writes state.md)
- Hardcoding shutdown targets instead of reading from roster
- Supervisor writing production code or performing code review
- Referencing undefined concepts (e.g., "enabling agents" without implementation)
