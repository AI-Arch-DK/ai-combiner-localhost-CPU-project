# DB Schemas

| Файл | БД | Таблиц | Назначение |
|---|---|---|---|
| routing_db.sql | routing.db | 3 | qwen_tasks (21) + parallel_config (13) + routing_log |
| project_db.sql | project.db | 3+FTS | Цели, roadmap, лог действий |
| network_db.sql | network.db | 3+FTS | Устройства, конфиги, шаблоны |
| tokens_db.sql | tokens.db | 3 | Учёт токенов, бюджет |
| tools_db.sql | tools.db | 2 | Реестр MCP-инструментов |
| models_db.sql | models.db | 2 | Реестр AI-моделей |
| kombain_local_db.sql | kombain_local.db | 4 | Workflows, results, feedback, knowledge |

## Shared БД

`/ai/external/sales_manager/kombain_shared.db` — общая БД для синхронизации между node (Office_MAIN концепция).
Схема идентична `kombain_local.db` + таблица `sync_log`.

## Правила

- `.db` файлы в `.gitignore` — данные не публикуются
- Только схемы (структура) — без реальных данных
