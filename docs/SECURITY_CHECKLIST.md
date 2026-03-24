# Security Checklist — Before Every Push to External Resources

## ❌ NEVER commit

| Type | Examples |
|---|---|
| API keys | `tvly-*`, `hf_*`, `sk-*` |
| GitHub PAT | `github_pat_*` |
| HuggingFace tokens | `hf_*` |
| Passwords | any string containing `password=` |
| `claude_desktop_config.json` | contains all MCP tokens |
| `config.env` | environment variables with secrets |
| Real `.db` files | contain user data |
| Hardcoded user paths | e.g. `/home/debianAI/` |

## ✅ Safe to commit

| Type | Examples |
|---|---|
| Scripts without secrets | `check_resources.sh`, `cleanup_sessions.sh` |
| SQL schemas | `routing_schema.sql` (no data) |
| Architecture docs | `architecture.md`, `README.md` |
| Workflow JSON | without tokens or passwords |
| `.gitignore` | always |

## 🔍 Pre-push verification command

```bash
# Run before every git push:
grep -rE "tvly-|github_pat|hf_[a-zA-Z]{20,}|password|api.key|secret" \
  --include="*.sh" --include="*.json" --include="*.md" --include="*.sql" \
  . 2>/dev/null && echo "❌ SECRETS FOUND" || echo "✅ Clean"
```

## 🤖 Automated Check

Claude validates content via Qwen before every push:

1. Qwen scans content for secrets
2. If detected — push is blocked
3. Suggests replacing with `$ENV_VAR` placeholders
