#!/bin/bash
# backup_db.sh — бэкап всех БД AI-комбайна
# Запуск: вручную или через cron

BACKUP_DIR="/ai/backup/$(date +%Y%m%d_%H%M%S)"
DB_DIR="/ai/db"

mkdir -p "$BACKUP_DIR"

echo "[backup_db] Цель: $BACKUP_DIR"

# Бэкап локальных БД
for db in "$DB_DIR"/*.db; do
  name=$(basename "$db")
  sqlite3 "$db" ".backup '$BACKUP_DIR/$name'" 2>/dev/null && \
    echo "  OK $name" || echo "  FAIL $name"
done

# Бэкап kombain_local.db
if [ -f "/ai/kombain/kombain_local.db" ]; then
  sqlite3 /ai/kombain/kombain_local.db ".backup '$BACKUP_DIR/kombain_local.db'" && \
    echo "  OK kombain_local.db"
fi

# Бэкап shared БД
if [ -f "/ai/external/sales_manager/kombain_shared.db" ]; then
  sqlite3 /ai/external/sales_manager/kombain_shared.db ".backup '$BACKUP_DIR/kombain_shared.db'" && \
    echo "  OK kombain_shared.db"
fi

# Удаляем бэкапы старше 7 дней
find /ai/backup -maxdepth 1 -type d -mtime +7 -exec rm -rf {} + 2>/dev/null

SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
echo "[backup_db] Готово. Размер: $SIZE"
