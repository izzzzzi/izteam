# Deterministic Teardown FSM

> Roster-driven, bounded retries, safe-fail teardown protocol for Phase 3 completion.

## FSM states

```
TEARDOWN_INIT -> SHUTDOWN_REQUESTED -> WAITING_ACKS -> RETRYING -> READY_TO_DELETE -> TEAM_DELETED | TEARDOWN_FAILED_SAFE
```

## Teardown rules

- Build shutdown target list from ACTIVE roster in `state.md` (never hardcoded by complexity).
- Send `shutdown_request` to all ACTIVE teammates except supervisor first.
- Enter `WAITING_ACKS` and collect acknowledgements.
- Retry constants are fixed: `ACK_RETRY_ROUNDS=3`, `ACK_RETRY_TIMEOUT_SEC=60` between rounds.
- Supervisor tracks ACK progress and writes teardown transitions/events into `state.md`.
- Normal-path preconditions for `READY_TO_DELETE`: no active non-terminal tasks, state consistency, persisted summaries/decisions, and full roster ACK.
- Forced-finalize preconditions (full ACK not required): no active non-terminal tasks, state consistency, persisted summaries/decisions.

## Forced-finalize protocol

- If ACK is still missing after fixed retries, Supervisor emits `FORCED_FINALIZE_CANDIDATE` (with missing roster list) to Lead.
- Lead must explicitly respond with `FORCED_FINALIZE_ACK` to allow bounded forced finalize.
- On `FORCED_FINALIZE_ACK`, Supervisor executes forced-finalize protocol (freeze writes, persist teardown report, mark unresolved ACKs, set `ACK_STATUS=FORCED_FINALIZE_APPROVED`) and then transitions to `READY_TO_DELETE`.
- If `FORCED_FINALIZE_ACK` is not granted, transition to `TEARDOWN_FAILED_SAFE` and block TeamDelete.
- Mandatory ordering: supervisor shutdown happens last, immediately before TeamDelete.

## Final dispatch

- `READY_TO_DELETE` → shutdown supervisor → TeamDelete
- `TEARDOWN_FAILED_SAFE` → escalate to user with blocker summary (no TeamDelete)
