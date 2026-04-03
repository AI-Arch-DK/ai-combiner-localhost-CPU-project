---
name: ai-combiner
description: |
  Do NOT activate when: "about yourself", "check resources", "system info".
  For those requests, run shell:/ai/scripts/check_resources.sh.

  Use ONLY when the user mentions: AI Combiner, orchestrator, routing, qwen_tasks,
  parallel_config, workflows, kombain, Claude skills, MCP servers, night learning,
  hallucination guard, SQLite indexes, GitHub repo, DB backup, health check,
  deploy combiner, node sync, Office_MAIN, night_learning, session cleanup,
  check_resources, claude_desktop_config, knowledge base, ai_combiner_kb,
  FTS index, reindex, индексация баз, update_kb, qwen_index_agent,
  or asks to commit/update something in the DB, scripts, or skills.

  Team Lead for AI Combiner: manages resources, routing, scripts, databases, and documentation.
---

# AI Combiner — Team Lead Skill

## System Configuration

**Config:** `~/.config/Claude/claude_desktop_config.json`
**Scripts:** `/ai/scripts/`
**Databases:** `/ai/db/` + `/ai/kombain/kombain_local.db`
**Knowledge Base:** `~/ai_combiner_kb/ai_combiner_kb.db` (20 tables, FTS5)
**Version:** 0.4.0 | **GitHub:** `AI-Arch-DK/ai-combiner-localhost-CPU-project`
**CATALOG:** `CATALOG.md` in repo root

## Architecture (priority order)

```text
[1] SKILLS → [2] systemPrompt → [3] qwen_dispatch → [4] parallel_config
```

## Routing Strategies

| Strategy | When |
|---|---|
| qwen_only | extract, classify, explain, format, git_check, system_check |
| parallel | network_config, compare |
| external_first | research, orchestration |
| qwen_with_context | validate_config, fact_check |
| CLAUDE_DIRECT | bash/sql (qt_019/020) |

## Scripts (/ai/scripts/)

| Script | Purpose | Trigger |
|---|---|---|
| check_resources.sh | 7-line status summary | "about yourself" |
| health_check.sh | OK/WARN/FAIL check | manual / cron |
| git_sync.sh | commit + push to upstream | manual |
| backup_db.sh | back up all SQLite DBs | cron 3:00 |
| backup_mcp.sh | back up MCP config | before upgrade |
| audit_security.sh | security audit | manual |
| test_qwen_tasks.sh | test Qwen task routing | before deploy |
| claude_memory.sh | persist Claude session memory to DB | on session end |
| cleanup_sessions.sh | remove stale session folders | auto / cron |
| init_db.sh | initialize all databases | first install |
| sync_to_shared.sh | sync validated data to kombain_shared.db | manual / cron |
| rotate_logs.sh | log rotation | cron |
| qwen_index_agent.sh | FTS index all DBs (qt_033) | "переиндексируй базы" |
| update_kb.sh | update ai_combiner_kb.db from repo | after git pull |

## Databases (/ai/db/)

| DB | FTS | Purpose |
|---|---|---|
| routing.db | qwen_tasks_fts (32) | qwen_tasks + parallel_config routing rules |
| kombain_local.db | workflows_fts, qwen_knowledge_fts | workflows, knowledge (101 entries) |
| network.db | templates_fts (20) | network config templates |
| project.db | project_fts (36) | goals, roadmap, actions log |
| models.db | models_fts (5) | AI model registry |
| tools.db | tools_fts (8) | MCP tool registry |
| tokens.db | accounts_fts (2) | token budget tracking |
| git_ops.db | workflows_fts, commands_fts (14) | git workflows + commands |

## Knowledge Base (~/ai_combiner_kb/)

```bash
# Быстрый поиск по всей KB
sqlite3 ~/ai_combiner_kb/ai_combiner_kb.db \
  "SELECT entity_type, content FROM fts_search WHERE fts_search MATCH 'KEYWORD';"

# Обновить KB после git pull
bash ~/ai_combiner_kb/update_kb.sh /home/debai/ai-combiner-localhost-CPU-project

# Переиндексировать все FTS (qt_033)
bash /ai/scripts/qwen_index_agent.sh
```

**KB таблицы:** repo_meta(29) · files(32) · technologies(20) · architecture_nodes(15) ·
databases(8) · mcp_servers(14) · scripts(14) · docs(39) · skills(2) · data_files(10) ·
qwen_tasks(25) · parallel_config(15) · routing_strategies(5) · config_vars(14) ·
model_benchmarks(6) · office_nodes(4) · search_index+FTS5(24) · quick_queries(21)

## Database Quick Access (SQL)

```sql
-- Active Qwen tasks
SELECT task_id, category, description FROM qwen_tasks WHERE is_active=1;

-- Strategies
SELECT config_id, task_type, strategy, timeout_sec FROM parallel_config;

-- Workflows
SELECT workflow_id, name, rating FROM workflows ORDER BY created_at DESC LIMIT 5;

-- Knowledge base
SELECT COUNT(*), SUM(verified), MAX(created_at) FROM qwen_knowledge;

-- FTS search across all KB
SELECT entity_type, content FROM fts_search WHERE fts_search MATCH 'KEYWORD';

-- KB quick queries
SELECT name, query FROM quick_queries WHERE category='routing';
```

## qwen_tasks — Key IDs

| ID | Trigger | Action |
|---|---|---|
| qt_019 | bash скрипт | CLAUDE_DIRECT: bash |
| qt_020 | sql запрос | CLAUDE_DIRECT: SQL |
| qt_021 | кто ты / о себе | check_resources.sh |
| qt_029 | push / запушь | git commit+push upstream |
| qt_030 | sync / подтяни | git fetch+merge upstream |
| qt_031 | релиз / git tag | git release+tag |
| qt_032 | git status | git status+log+diff |
| qt_033 | переиндексируй базы | qwen_index_agent.sh |

## Office_MAIN Concept

```text
[Office_MAIN] ← Central Orchestrator (roadmap)
    ├── [debianAI] ← Worker #1 (active) — /ai/kombain/kombain_local.db
    ├── [sales_manager] ← Worker #2 (active)
    └── kombain_shared.db ← sync point: /ai/external/kali/kombain_shared.db
```

## Security Check Before Push (qt_023)

```bash
grep -rE "tvly-|github_pat|hf_[a-zA-Z]{20,}" \
  --include="*.sh" --include="*.json" --include="*.md" . \
  && echo "❌ BLOCKED" || echo "✅ SAFE"
```

## Active Skills (10)

`ai-combiner` `docx` `pdf` `pptx` `xlsx` `ib-consultant` `mcp-builder` `skill-creator` `schedule` `git-ops`
