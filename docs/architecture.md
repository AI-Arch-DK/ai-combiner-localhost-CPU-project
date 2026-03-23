# Архитектура AI-комбайна

## Приоритеты обработки запроса

| Порядок | Слой | Управляется |
|---|---|---|
| 1️⃣ | Скиллы (SKILL.md) | `~/.config/Claude/local-agent-mode-sessions/skills-plugin/` |
| 2️⃣ | systemPrompt | `claude_desktop_config.json` |
| 3️⃣ | qwen_dispatch | `routing.db / qwen_tasks` |
| 4️⃣ | Внешние MCP | `routing.db / parallel_config` |

## Логика роутинга

```
запрос → qwen_dispatch
    MATCH   → Qwen отвечает → AS-IS
    NO_MATCH → parallel_config стратегия
    TIMEOUT  → HF+tavily параллельно → qwen_get_late_answer
    HALLUC.  → qwen_cancel → внешние инструменты
```

## Скрипты автостарта

```bash
# Триггер: "инфо о себе"
shell → /ai/scripts/check_resources.sh
# Автоматически вызывает:
shell → /ai/scripts/cleanup_sessions.sh
```

## Структура /ai/

```
/ai/
├── db/           # routing.db, project.db, network.db, tokens.db, tools.db, models.db
├── scripts/      # check_resources.sh, cleanup_sessions.sh
├── logs/         # startup.log
├── backup/       # бэкапы БД
└── workspace/    # рабочие файлы
```

## GitHub аккаунты
- `GitHub public account` — публичные/open source проекты
- `GitHub private account` — приватные проекты
