# Office_MAIN — Multi-node AI Combiner Concept

## Goal

Expand the single-node AI Combiner (debianAI localhost) into a centralized node network with a shared database and a central orchestrator.

## Topology

```text
                    [Office_MAIN-node]
                    Central Orchestrator
                    Claude + Qwen (primary)
                    kombain_shared.db
                           |
              ┌─────────────┬───────────┐
              │            │           │
    [debianAI-node]  [sales_manager-node]  [other-nodes]
    localhost CPU   security / sales       ...
    kombain_local   kombain_local
    .db             .db
```

## Nodes

| Node | Role | Status |
|---|---|---|
| **debianAI** | Primary localhost CPU node | ✅ active |
| **sales_manager** | Security / sales node | ✅ active |
| **Office_MAIN** | Central orchestrator | 🚧 planned for v0.5.0 |

## Office_MAIN Components

### Each node has

- `kombain_local.db` — local database (workflows, results, knowledge)
- Its own Ollama / Qwen instance
- A set of MCP servers tailored to its tasks

### Shared across all nodes

- `kombain_shared.db` (path: `/ai/external/sales_manager/kombain_shared.db`)
- `sync_log` — change journal from all nodes

## Synchronization Protocol

```text
Node executes a task
    │
    ├── Write to kombain_local.db
    └── INSERT into sync_log (node_id, operation, table_name, payload, status='pending')
              │
              ▼
    Office_MAIN reads sync_log WHERE status='pending'
              │
              ├── No conflict → status='done'
              └── Conflict → status='conflict' → manual resolution
```

## Request Routing

```text
Request arrives at a node
    │
    ├── Local task → local Qwen
    ├── Shared task → Office_MAIN orchestrates
    └── Specialized task → routed to specialist node (sales_manager)
```

## Current State

- `kombain_shared.db` is already created and accessible at `/ai/external/sales_manager/`
- Schema ready: `db/schemas/kombain_shared_db.sql`
- Sync implementation: planned for v0.5.0 (issue #4)
