# Data Policy — AI Combiner

## Principles

1. **Local first** — all data is stored locally whenever possible
2. **Minimal external** — external APIs are used only when necessary
3. **No secrets in repo** — API keys are never committed
4. **Backup** — daily automated database backups

## What Is Stored Locally

| Data | Location |
|---|---|
| Project databases | `/ai/db/` |
| Backups | `/ai/backup/` |
| Logs | `/ai/logs/` |
| MCP config | `~/.config/Claude/claude_desktop_config.json` |
| Shared database | `/ai/external/sales_manager/kombain_shared.db` |

## What Is Sent to External APIs

| API | What is sent | Why |
|---|---|---|
| Anthropic (Claude) | Request text | Orchestration |
| Ollama (local) | Request text | Inference |
| HuggingFace | Request text | Additional inference |
| Tavily | Request text | Web search |

> Personal data, passwords, and IP addresses are never transmitted.

## Data Retention

```bash
# Logs: MAX_AGE_DAYS=7 (rotate_logs.sh)
# Backups: removed after 7 days (backup_db.sh)
# Sessions: archived to /tmp/sessions_archive/ (auto-removed)
```
