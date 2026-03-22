# Data Policy — AI Combiner

## Принципы

1. **Local first** — все данные по возможности хранятся локально
2. **Minimal external** — внешние API только при необходимости
3. **No secrets in repo** — ключи никогда не пабликуются
4. **Backup** — ежедневное резервное копирование БД

## Что хранится локально

| Данные | Место |
|---|---|
| БД проекта | `/ai/db/` |
| Бэкапы | `/ai/backup/` |
| Логи | `/ai/logs/` |
| Конфиг MCP | `~/.config/Claude/claude_desktop_config.json` |
| БД Shared | `/ai/external/sales_manager/kombain_shared.db` |

## Что передаётся во внешние API

| API | Что передаётся | Зачем |
|---|---|---|
| Anthropic (Claude) | Текст запроса | Оркестрация |
| Ollama (local) | Текст запроса | Генерация |
| HuggingFace | Текст запроса | Доп. inference |
| Tavily | Текст запроса | Поиск |

> Личные данные, пароли, IP никогда не передаются.

## Удаление данных

```bash
# Логи хранятся MAX_AGE_DAYS=7 (rotate_logs.sh)
# Бэкапы удаляются старше 7 дней (backup_db.sh)
# Сессии архивируются в /tmp/sessions_archive/ (авто-удаление)
```
