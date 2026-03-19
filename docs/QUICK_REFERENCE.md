# Quick Reference — AI Combiner

## Старт сессии
```
Первое сообщение Claude Desktop: инфо о себе
```

## Ключевые триггеры

| Фраза | Действие |
|---|---|
| `инфо о себе` | check_resources.sh → 7 строк |
| `очисти сессии` | cleanup_sessions.sh |
| `проверь безопасность` | qt_023 security scan |

## Скрипты

```bash
/ai/scripts/check_resources.sh    # 7 строк состояния
/ai/scripts/health_check.sh       # OK/WARN/FAIL всех компонентов
/ai/scripts/backup_db.sh          # бэкап всех БД
/ai/scripts/test_qwen_tasks.sh    # тест 4 тасков Qwen
/ai/scripts/audit_security.sh     # локальный аудит
/ai/scripts/cleanup_sessions.sh   # удалить старые сессии
/ai/scripts/init_db.sh            # инициализация БД с нуля
/ai/scripts/sync_to_shared.sh     # синх в kombain_shared.db
/ai/scripts/rotate_logs.sh        # ротация логов
```

## БД быстрый доступ

```bash
# Таски Qwen
sqlite3 /ai/db/routing.db "SELECT task_id, trigger, category FROM qwen_tasks WHERE is_active=1;"

# Стратегии
sqlite3 /ai/db/routing.db "SELECT config_id, task_category, strategy FROM parallel_config;"

# Воркфлоу
sqlite3 /ai/kombain/kombain_local.db "SELECT workflow_id, name, rating FROM workflows ORDER BY created_at DESC LIMIT 5;"
```

## Ollama

```bash
ollama list                          # список моделей
systemctl --user status ollama       # статус
curl http://localhost:11434/api/tags # проверка API
```

## Документация

| Тема | Файл |
|---|---|
| Архитектура | docs/architecture.md |
| Роутинг | docs/routing_logic.md |
| MCP Setup | docs/MCP_SETUP.md |
| Troubleshooting | docs/TROUBLESHOOTING.md |
| Roadmap | docs/ROADMAP.md |
