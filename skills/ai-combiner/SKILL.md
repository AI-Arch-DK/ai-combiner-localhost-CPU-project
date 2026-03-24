---
name: ai-combiner
description: |
  Do NOT activate when: "about yourself", "check resources", "system info".
  For those requests, run shell:/ai/scripts/check_resources.sh.

  Use ONLY when the user mentions: AI Combiner, orchestrator, routing, qwen_tasks,
  parallel_config, workflows, kombain, Claude skills, MCP servers, night learning,
  hallucination guard, SQLite indexes, GitHub repo, DB backup, health check,
  deploy combiner, node sync, Office_MAIN, night_learning, session cleanup,
  check_resources, claude_desktop_config, or asks to commit/update something
  in the DB, scripts, or skills.

  Team Lead for AI Combiner: manages resources, routing, scripts, databases, and documentation.
---

# AI Combiner — Team Lead Skill

## System Configuration

**Config:** `~/.config/Claude/claude_desktop_config.json`
**Scripts:** `/ai/scripts/`
**Databases:** `/ai/db/` + `/ai/kombain/kombain_local.db`
**Version:** 0.3.1 | **GitHub:** `AI-Arch-DK/ai-combiner-localhost-CPU-project`
**CATALOG:** `CATALOG.md` in repo root

## Architecture (priority order)

```text
[1] SKILLS → [2] systemPrompt → [3] qwen_dispatch → [4] parallel_config
```

## Routing Strategies

| Strategy | When |
|---|---|
| qwen_only | extract, classify, explain, format, git_check |
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
| backup_db.sh | back up databases | cron 3:00 |
| backup_mcp.sh | back up MCP config | before upgrade |
| audit_security.sh | security audit | manual |
| test_qwen_tasks.sh | test 4 Qwen tasks | before deploy |
| night_learning.sh | overnight learning | cron 2:00 |
| cleanup_sessions.sh | remove duplicate sessions | auto |
| init_db.sh | initialize databases | first install |
| sync_to_shared.sh | node sync | manual / cron |

## Database Quick Access (SQL)

```sql
-- Active Qwen tasks
SELECT task_id, category, description FROM qwen_tasks WHERE is_active=1;

-- Strategies
SELECT config_id, task_category, strategy FROM parallel_config;

-- Workflows
SELECT workflow_id, name, rating FROM workflows ORDER BY created_at DESC LIMIT 5;

-- Knowledge base
SELECT COUNT(*), SUM(verified), MAX(created_at) FROM qwen_knowledge;
```

## Security Check Before Push (qt_023/024)

```bash
grep -rE "tvly-|github_pat|hf_[a-zA-Z]{20,}" \
  --include="*.sh" --include="*.json" --include="*.md" . \
  && echo "❌ BLOCKED" || echo "✅ SAFE"
```

## Active Skills (9)

`ai-combiner` `docx` `pdf` `pptx` `xlsx` `ib-consultant` `mcp-builder` `skill-creator` `schedule` `git-ops`
