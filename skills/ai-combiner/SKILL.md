---
name: ai-combiner
description: |
  НЕ активировать при: "инфо о себе", "вспомни о себе", "проверь ресурсы", "инфо о системе".
  При этих запросах выполнить shell:/ai/scripts/check_resources.sh.

  Использовать ТОЛЬКО когда пользователь упоминает: AI-комбайн, оркестратор, routing, qwen_tasks, parallel_config, workflows, kombain, скиллы Claude, MCP серверы, ночное обучение, hallucination guard, SQLite индексы, GitHub репо комбайна, backup БД, health check, деплой комбайна, синхронизация нод, Office_MAIN, night_learning, session cleanup, check_resources, claude_desktop_config, или просит зафиксировать/обновить что-то в БД/скриптах/скиллах системы.

  Team Lead AI-комбайна: управляет ресурсами, роутингом, скриптами, БД и документацией системы.
---

# AI Combiner — Team Lead скилл

## Конфигурация системы

**Config:** `/home/debai/.config/Claude/claude_desktop_config.json`
**Скрипты:** `/ai/scripts/`
**БД:** `/ai/db/` + `/ai/kombain/kombain_local.db`
**Версия:** 0.3.0 | **GitHub:** `AI-Arch-DK/ai-combiner-localhost-CPU-project`
**CATALOG:** `CATALOG.md` в корне репо

## Архитектура (приоритеты)

```
[1] SKILLS → [2] systemPrompt → [3] qwen_dispatch → [4] parallel_config
```

## Стратегии роутинга

| Стратегия | Когда |
|---|---|
| qwen_only | extract, classify, explain, format |
| parallel | network_config, compare |
| external_first | research, orchestration |
| qwen_with_context | validate_config, fact_check |
| CLAUDE_DIRECT | bash/sql (qt_019/020/025) |

## Скрипты (/ai/scripts/)

| Скрипт | Назначение | Триггер |
|---|---|---|
| check_resources.sh | 7 строк состояния | "инфо о себе" |
| health_check.sh | OK/WARN/FAIL | вручную/cron |
| backup_db.sh | бэкап БД | cron 3:00 |
| backup_mcp.sh | бэкап MCP | перед апгрейдом |
| audit_security.sh | security аудит | вручную |
| test_qwen_tasks.sh | тест 4 задач Qwen | перед деплоем |
| night_learning.sh | ночное обучение | cron 2:00 |
| cleanup_sessions.sh | удалить дубли skills | авто |
| init_db.sh | создать БД с нуля | первая установка |
| sync_to_shared.sh | синхронизация нод | вручную/cron |

## БД быстрый доступ (SQL)

```sql
-- Активные задачи Qwen
SELECT task_id, category, description FROM qwen_tasks WHERE is_active=1;

-- Стратегии
SELECT config_id, task_category, strategy FROM parallel_config;

-- Workflows
SELECT workflow_id, name, rating FROM workflows ORDER BY created_at DESC LIMIT 5;

-- qwen_knowledge
SELECT COUNT(*), SUM(verified), MAX(created_at) FROM qwen_knowledge;
```

## Безопасность перед push (qt_023/024)

```bash
grep -rE "tvly-|github_pat|hf_[a-zA-Z]{20,}" \
  --include="*.sh" --include="*.json" --include="*.md" . \
  && echo "❌ BLOCKED" || echo "✅ SAFE"
```

## Скиллы системы (9)

`ai-combiner` `docx` `pdf` `pptx` `xlsx` `ib-consultant` `mcp-builder` `skill-creator` `schedule`
