# Deployment Strategy — AI Combiner

## Environments

| Parameter | Requirement |
|---|---|
| OS | Debian 12+ / Ubuntu 22.04+ |
| CPU | x86_64, minimum 4 cores |
| RAM | minimum 8 GB (16 GB recommended) |
| Disk | minimum 20 GB free |
| Network | internet access (required for initial setup) |

## Production Deployment

```text
[1] Back up current state
    bash /ai/scripts/backup_db.sh

[2] Pull new code
    cd /path/to/repo && git pull upstream main

[3] Update scripts
    cp scripts/*.sh /ai/scripts/ && chmod +x /ai/scripts/*.sh

[4] Migrate databases (if schema changes exist)
    sqlite3 /ai/db/routing.db < db/schemas/routing_db.sql

[5] Restart Claude Desktop

[6] Verify
    bash /ai/scripts/health_check.sh
```

## Rollback Procedure

```bash
# 1. Find the latest backup
ls /ai/backup/ | sort | tail -3

# 2. Restore databases
BACKUP="/ai/backup/20260319_030000"
for db in routing project network tokens tools models; do
  cp "$BACKUP/$db.db" "/ai/db/$db.db"
done

# 3. Revert to a previous commit
git checkout <previous-commit-sha> -- scripts/ db/schemas/

# 4. Verify
bash /ai/scripts/health_check.sh
```

## Database Versioning

Before any schema change:

```bash
sqlite3 /ai/db/routing.db ".backup '/ai/backup/routing_pre_migration.db'"
```
