# DB Schemas

| File | Database | Tables | Purpose |
|---|---|---|---|
| routing_db.sql | routing.db | 3 | qwen_tasks (28) + parallel_config (15) + routing_log |
| project_db.sql | project.db | 3 + FTS | Goals, roadmap, action log |
| network_db.sql | network.db | 3 + FTS | Devices, configs, templates |
| tokens_db.sql | tokens.db | 3 | Token tracking, budget |
| tools_db.sql | tools.db | 2 | MCP tool registry |
| models_db.sql | models.db | 2 | AI model registry |
| kombain_local_db.sql | kombain_local.db | 4 | Workflows, results, feedback, knowledge |

## Shared Database

`/ai/external/sales_manager/kombain_shared.db` — shared database for multi-node synchronization (Office_MAIN concept).
Schema is identical to `kombain_local.db` plus a `sync_log` table.

## Rules

- `.db` files are in `.gitignore` — data is never committed
- Only schemas (structure) are committed — no real data
