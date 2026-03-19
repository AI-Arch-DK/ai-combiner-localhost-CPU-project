#!/bin/bash
# rotate_logs.sh — ротация логов AI-комбайна
# Запуск: вручную или через cron

LOG_DIR="/ai/logs"
MAX_SIZE_MB=10
MAX_AGE_DAYS=7

mkdir -p "$LOG_DIR"

echo "[ротация] $(date '+%Y-%m-%d %H:%M:%S')"

# Ротация больших логов
for log in "$LOG_DIR"/*.log; do
  [ -f "$log" ] || continue
  size_mb=$(du -m "$log" 2>/dev/null | cut -f1)
  if [ "$size_mb" -ge "$MAX_SIZE_MB" ]; then
    mv "$log" "${log}.$(date +%Y%m%d_%H%M%S)"
    echo "  ROTATED: $(basename $log) (${size_mb}MB)"
  fi
done

# Удаление старых логов
DELETED=$(find "$LOG_DIR" -name "*.log.*" -mtime +$MAX_AGE_DAYS -delete -print 2>/dev/null | wc -l)
[ "$DELETED" -gt 0 ] && echo "  DELETED: $DELETED старых логов"

# Текущий размер
echo "  Каталог: $(du -sh $LOG_DIR 2>/dev/null | cut -f1)"
echo "[ротация] Готово"
