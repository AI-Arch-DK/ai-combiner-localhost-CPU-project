# Monitoring — AI Combiner

## Key Metrics

| Metric | WARN threshold | FAIL threshold | Command |
|---|---|---|---|
| Available RAM | < 3 GB | < 1 GB | `free -h` |
| Free disk space | < 30 GB | < 10 GB | `df -h /` |
| Ollama port | not listening | not listening | `ss -tlnp \| grep 11434` |
| Active qwen_tasks | < 15 | < 10 | `sqlite3 routing.db` |
| Startup log size | > 5 MB | > 10 MB | `du -sh /ai/logs/` |

## Automated Checks

```bash
# Full check of all components
bash /ai/scripts/health_check.sh

# Quick resource summary (7 lines)
bash /ai/scripts/check_resources.sh
```

## Cron Schedule (debianAI)

```cron
# Daily DB backup at 3:00
0 3 * * * /ai/scripts/backup_db.sh >> /ai/logs/backup.log 2>&1

# Weekly log rotation
0 4 * * 0 /ai/scripts/rotate_logs.sh >> /ai/logs/rotate.log 2>&1

# Hourly health check
0 * * * * /ai/scripts/health_check.sh >> /ai/logs/health.log 2>&1
```

## Alerts

| Event | Action |
|---|---|
| Ollama not running | `systemctl --user start ollama` |
| health_check FAIL | Investigate component, see TROUBLESHOOTING.md |
| RAM < 1 GB | Kill hanging processes via `check_resources.sh` |
| Database corrupted | Run `backup_db.sh` → restore from `/ai/backup/` |
