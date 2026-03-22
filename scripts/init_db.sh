#!/bin/bash
# init_db.sh — инициализация всех БД AI-комбайна с нуля
# Используй: при первой установке или полном ресете

DB_DIR="/ai/db"
SCHEMA_DIR="$(dirname "$0")/../db/schemas"

mkdir -p "$DB_DIR"

echo "[init_db] Создание БД..."

# Создаём каждую БД из схемы
for schema in routing project network tokens tools models; do
  DB="$DB_DIR/${schema}.db"
  SQL="$SCHEMA_DIR/${schema}_db.sql"
  if [ -f "$DB" ]; then
    echo "  SKIP $schema.db (уже существует)"
  elif [ -f "$SQL" ]; then
    sqlite3 "$DB" < "$SQL" && echo "  OK $schema.db"
  else
    echo "  WARN: схема $SQL не найдена"
  fi
done

# kombain_local.db (через MCP SQLite)
if [ ! -f "/ai/kombain/kombain_local.db" ]; then
  mkdir -p /ai/kombain
  sqlite3 /ai/kombain/kombain_local.db < "$SCHEMA_DIR/kombain_local_db.sql" && \
    echo "  OK kombain_local.db"
fi

# kombain_shared.db
if [ ! -f "/ai/external/sales_manager/kombain_shared.db" ]; then
  mkdir -p /ai/external/sales_manager
  sqlite3 /ai/external/sales_manager/kombain_shared.db < "$SCHEMA_DIR/kombain_shared_db.sql" && \
    echo "  OK kombain_shared.db"
fi

echo "[init_db] Готово. БД в $DB_DIR:"
ls -lh "$DB_DIR"/*.db 2>/dev/null | awk '{print "  ", $5, $9}'
