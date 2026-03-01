# State Ownership — Producer-Side Handoff and Routing Contract

> Defines how operational state ownership transfers from Lead to Supervisor at team setup.

## Handoff protocol (Lead -> Supervisor)

| Event | Producer | Consumer | Route-owner | State-write-owner | Next step |
|---|---|---|---|---|---|
| `STATE_OWNERSHIP_HANDOFF` | Lead | Supervisor | Lead -> Supervisor | Supervisor | Supervisor validates monotonic epoch and emits `STATE_OWNERSHIP_ACK(epoch)` |
| `STATE_OWNERSHIP_ACK` | Supervisor | Lead | Supervisor -> Lead | Supervisor | Activate `Supervisor@epoch` as single operational writer |
| `HANDOFF_DUPLICATE` | Supervisor | Lead | Supervisor -> Lead | Supervisor | Idempotent no-op; keep current owner/epoch |
| `HANDOFF_MISSING` | Supervisor | Lead | Supervisor -> Lead | Supervisor | Block transfer until valid handoff is received |
| `SPLIT_BRAIN_DETECTED` | Supervisor | Lead | Supervisor -> Lead | Supervisor | Enter reconcile lock and request Lead arbitration |
| `ESCALATE TO MEDIUM` | Unified reviewer or coder | Supervisor (routing), then Lead (staffing decision) | Source -> Supervisor -> Lead | Supervisor | Lead decides staffing; Supervisor applies roster/state updates |

## Lead producer sequence (mandatory)

1. Spawn Supervisor.
2. Emit `STATE_OWNERSHIP_HANDOFF(epoch)` exactly once for the transfer.
3. Wait for `STATE_OWNERSHIP_ACK(epoch)` before allowing monitor-mode operational writes.
4. If `HANDOFF_DUPLICATE`, `HANDOFF_MISSING`, or `SPLIT_BRAIN_DETECTED` occurs, stop transfer and resolve first.

## Ownership rules

- Supervisor is the **single writer** of operational state transitions/events in `.claude/teams/{team-name}/state.md` only after `STATE_OWNERSHIP_ACK(epoch)`.
- Tech Lead owns architectural decisions in `DECISIONS.md`.
- Supervisor may append only operational escalation/orchestration notes in dedicated operational sections of `DECISIONS.md`.
- Lead does not write operational transitions after ownership ACK; Lead issues decisions and spawn/shutdown commands.
