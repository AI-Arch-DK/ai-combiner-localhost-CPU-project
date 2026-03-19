# Monitoring — AI Combiner

## Ключевые метрики

| Метрика | Порог WARN | Порог FAIL | Команда |
|---|---|---|---|
| RAM доступно | < 3 GB | < 1 GB | `free -h` |
| Disk / свободно | < 30 GB | < 10 GB | `df -h /` |
| Ollama порт | не слушает | не слушает | `ss -tlnp \ grep 11434` |
| qwen_tasks активных | < 15 | < 10 | `sqlite3 routing.db` |
| Лог старта | > 5 MB | > 10 MB | `du -sh /ai/logs/` |

## Автоматическая проверка

```bash
# Полная проверка всех компонентов
bash /ai/scripts/health_check.sh

# Быстрая проверка ресурсов (7 строк)
bash /ai/scripts/check_resources.sh
```

## Cron расписание (debai)

```cron
# Бэкап БД ежедневно в 3:00
0 3 * * * /ai/scripts/backup_db.sh >> /ai/logs/backup.log 2>&1

# Ротация логов еженедельно
0 4 * * 0 /ai/scripts/rotate_logs.sh >> /ai/logs/rotate.log 2>&1

# Health check ежечасно
0 * * * * /ai/scripts/health_check.sh >> /ai/logs/health.log 2>&1
```

## Алерты

| Событие | Действие |
|---|---|
| Ollama не запущен | `systemctl --user start ollama` |
| health_check FAIL | Проверить компонент, см. TROUBLESHOOTING.md |
| RAM < 1 GB | Kill завиших процессов: `check_resources.sh` |
| БД повреждена | `backup_db.sh` → восстановить из `/ai/backup/` |
