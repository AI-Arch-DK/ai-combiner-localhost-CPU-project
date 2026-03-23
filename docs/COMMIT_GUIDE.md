# Commit Guide — AI Combiner

## Commit Format

```text
<type>: <description> [(issue reference)]
```

## Types

| Type | When to use |
|---|---|
| `feat` | new script, schema, or document |
| `fix` | bug fix in a script or schema |
| `docs` | documentation change |
| `refactor` | restructuring without behavior change |
| `security` | security-related change |
| `db` | schema or seed data change |
| `routing` | qwen_tasks or parallel_config change |
| `chore` | minor maintenance |

## Examples

```bash
feat: add qt_024 — docker container check
fix: cleanup_sessions.sh — handle empty plugin dir
docs: update ROADMAP v0.4.0 tasks
db: add kombain_shared sync_log index
routing: pc_014 git_ops strategy qwen_only
security: gitignore add *.key pattern
```

## Rules

- Description in English
- Maximum 72 characters per line
- **NEVER** commit `.db` files
- **NEVER** commit `claude_desktop_config.json`
- Run security check before every push: `qt_023` or see `SECURITY_CHECKLIST.md`
