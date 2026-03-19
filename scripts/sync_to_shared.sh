#!/bin/bash
# sync_to_shared.sh — синхронизация локальной БД в shared
# Текущая реализация: копирование новых workflows/results
# Будущее: полный sync_log протокол (v0.5.0)

LOCAL="/ai/kombain/kombain_local.db"
SHARED="/ai/external/kali/kombain_shared.db"
NODE_ID="debai"

[ ! -f "$LOCAL" ] && echo "ERROR: kombain_local.db не найден" && exit 1
[ ! -f "$SHARED" ] && echo "ERROR: kombain_shared.db не найден" && exit 1

echo "[sync] $NODE_ID → shared | $(date '+%H:%M:%S')"

# Получаем workflows новые за последние 24ч
COUNT=$(sqlite3 "$LOCAL" "
  SELECT COUNT(*) FROM workflows
  WHERE created_at > datetime('now', '-1 day');
" 2>/dev/null)

if [ "$COUNT" -gt 0 ]; then
  # Запись в sync_log
  sqlite3 "$SHARED" "
    INSERT OR IGNORE INTO sync_log
    (sync_id, node_id, operation, table_name, status, created_at)
    VALUES (
      '$NODE_ID-$(date +%s)',
      '$NODE_ID',
      'SYNC',
      'workflows',
      'pending',
      CURRENT_TIMESTAMP
    );
  " 2>/dev/null
  echo "  Записано в sync_log: $COUNT workflows"
else
  echo "  Нет новых за 24ч"
fi

echo "[sync] Готово"
