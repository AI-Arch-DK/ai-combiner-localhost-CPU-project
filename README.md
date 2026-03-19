# AI Combiner — localhost CPU project

Локальный AI-оркестратор на базе Claude Desktop + Qwen (Ollama) + MCP.

## Архитектура

```
Пользователь
    │
    ▼
[СКИЛЛЫ] ← перехватывают первыми
    │
    ▼
[CLAUDE DESKTOP] — дирижёр/оркестратор
    │
    ├─ qwen_dispatch → routing.db (qwen_tasks / parallel_config)
    ├─ Стратегии: qwen_only | parallel | external_first | qwen_with_context
    └─ Результат → БД → пользователь
```

## MCP серверы
`sqlite | ollama-local | host-report | filesystem | github-pub | github-priv | huggingface | miro | tavily | shell | browser | clay | gcal | gmail`

## БД (`/ai/db/`)
| БД | Назначение |
|---|---|
| routing.db | qwen_tasks (22 задачи) + parallel_config (13 стратегий) |
| project.db | проекты, шаблоны |
| network.db | FAQ кэш |
| kombain_local.db | локальный комбайн |
| models.db | реестр моделей |
| tokens.db | учёт токенов |
| tools.db | реестр инструментов |

## Скрипты (`/ai/scripts/`)
- `check_resources.sh` — 7-строчный дашборд системы (триггер: "инфо о себе")
- `cleanup_sessions.sh` — автоочистка устаревших sessions Claude Desktop

## Конфиг
`/home/debai/.config/Claude/claude_desktop_config.json`

## Старт сессии
Первое сообщение: **"инфо о себе"** → запускает `check_resources.sh` → 7 строк состояния системы.
