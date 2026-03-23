# Deployment Strategy — AI Combiner

## Окружения

| Среда | Требования |
|---|---|
| OS | Debian 12+ / Ubuntu 22.04+ |
| CPU | x86_64, мин. 4 ядра |
| RAM | мин. 8 GB (реком. 16 GB) |
| Disk | мин. 20 GB свободно |
| Сеть | интернет (для первой установки) |

## Процедура деплоя (Production)

```text
[1] Бэкап текущего состояния
    bash /ai/scripts/backup_db.sh

[2] Пулл нового кода
    cd /path/to/repo && git pull origin main

[3] Обновление скриптов
    cp scripts/*.sh /ai/scripts/ && chmod +x /ai/scripts/*.sh

[4] Миграция БД (если есть изменения схем)
    sqlite3 /ai/db/routing.db < db/schemas/routing_db.sql

[5] Перезапуск Claude Desktop

[6] Проверка
    bash /ai/scripts/health_check.sh

```text

## Процедура Rollback

```bash
# 1. Найти последний бэкап

ls /ai/backup/ | sort | tail -3

# 2. Восстановить БД

BACKUP="/ai/backup/20260319_030000"
for db in routing project network tokens tools models; do
  cp "$BACKUP/$db.db" "/ai/db/$db.db"
done

# 3. Вернуться на предыдущий коммит

git checkout <previous-commit-sha> -- scripts/ db/schemas/

# 4. Проверка

bash /ai/scripts/health_check.sh

```text

## Версионирование БД

Перед каждым изменением схемы:

```bash
# Сохранить версию

sqlite3 /ai/db/routing.db ".backup '/ai/backup/routing_pre_migration.db'"

```text
