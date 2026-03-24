# Quick Reference — AI Combiner

## Session Start

```text
First message in Claude Desktop: about yourself
```

## Key Triggers

| Phrase | Action |
|---|---|
| `about yourself` | check_resources.sh → 7-line status |
| `clean sessions` | cleanup_sessions.sh |
| `security check` | qt_023 security scan |
| `push` / `commit and push` | qt_029 git commit + push |
| `sync repo` / `fetch upstream` | qt_030 git sync |
| `create release` / `git tag` | qt_031 git release |
| `git status` / `what changed` | qt_032 git status check |

## Scripts

```bash
/ai/scripts/check_resources.sh    # 7-line status summary
/ai/scripts/health_check.sh       # OK/WARN/FAIL for all components
/ai/scripts/backup_db.sh          # back up all databases
/ai/scripts/git_sync.sh           # commit + push to upstream
/ai/scripts/audit_security.sh     # local security audit
/ai/scripts/cleanup_sessions.sh   # remove stale sessions
/ai/scripts/init_db.sh            # initialize databases from scratch
/ai/scripts/sync_to_shared.sh     # sync to kombain_shared.db
/ai/scripts/rotate_logs.sh        # rotate logs
```

## Database Quick Access

```bash
# Qwen tasks
sqlite3 /ai/db/routing.db "SELECT task_id, trigger, category FROM qwen_tasks WHERE is_active=1;"

# Strategies
sqlite3 /ai/db/routing.db "SELECT config_id, task_category, strategy FROM parallel_config;"

# Workflows
sqlite3 /ai/kombain/kombain_local.db "SELECT workflow_id, name, rating FROM workflows ORDER BY created_at DESC LIMIT 5;"

# Git workflows
sqlite3 /ai/db/git_ops.db "SELECT name, steps FROM git_workflows;"
```

## Ollama

```bash
ollama list                           # list models
systemctl --user status ollama        # service status
curl http://localhost:11434/api/tags  # API check
```

## Documentation

| Topic | File |
|---|---|
| Architecture | docs/architecture.md |
| Routing | docs/routing_logic.md |
| MCP Setup | docs/MCP_SETUP.md |
| Troubleshooting | docs/TROUBLESHOOTING.md |
| Roadmap | docs/ROADMAP.md |
| Git ops | skills/git-ops/SKILL.md |
