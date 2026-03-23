# FAQ — AI Combiner

## What is AI Combiner?

An orchestrator that automatically routes requests between a local LLM (Qwen), cloud APIs, and MCP tools. Claude Desktop acts as the conductor; Qwen is the worker.

---

## Why Qwen instead of Claude for everything?

Qwen runs locally at no cost, saving Claude tokens. The strategy: routine tasks (extract, translate, count) go to Qwen; complex tasks (orchestration, code) go to Claude.

---

## How fast does Qwen respond?

| Task | max_tokens | CPU time |
|---|---|---|
| classify | 10 | ~2 sec |
| extract | 100 | ~8 sec |
| summarize | 150 | ~12 sec |
| network config | 200 | ~16 sec |

---

## How do I run a system check?

Send **"about yourself"** as your first message in Claude Desktop. This triggers `check_resources.sh` and returns a 7-line status summary.

---

## How do I add a new Qwen task?

```sql
INSERT INTO qwen_tasks VALUES ('qt_NNN', 'trigger', 'category',
  'Short prompt. Output only.', 200, 1, 'description', 0, 1, 60);
```

See `docs/CONTRIBUTING.md` for full details.

---

## How do I back up the databases?

```bash
bash /ai/scripts/backup_db.sh
# Backups are saved to /ai/backup/YYYYMMDD_HHMMSS/
# Backups older than 7 days are removed automatically
```

---

## How do I add a new skill?

See `docs/CONTRIBUTING.md` — section "Add a new skill".

---

## What is Office_MAIN?

A concept for a large multi-node network: a central Office_MAIN node plus peripheral nodes (debianAI, sales_manager, etc.), synchronized through `kombain_shared.db`. Status: planned for v0.5.0.

---

## What can and cannot be committed?

| OK ✅ | Never ❌ |
|---|---|
| SQL schemas | .db files |
| Scripts | claude_desktop_config.json |
| Documentation | config.env |
| workflows JSON | API keys |
