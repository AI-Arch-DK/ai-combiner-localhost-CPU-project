# Testing — AI Combiner

## Automated Tests

```bash
# Qwen task tests (4 tasks)
bash /ai/scripts/test_qwen_tasks.sh

# Full component health check
bash /ai/scripts/health_check.sh

# Security check
grep -rE "tvly-|github_pat|hf_[a-zA-Z]{20,}" \
  --include="*.sh" --include="*.json" --include="*.md" . \
  && echo "❌ SECRETS" || echo "✅ CLEAN"
```

## Test Matrix

| Test | Script | Expected result |
|---|---|---|
| Ollama running | `health_check.sh` | ✅ Ollama responds |
| Databases accessible | `health_check.sh` | ✅ 7 databases |
| Qwen classify | `test_qwen_tasks.sh` | network_config |
| Qwen count | `test_qwen_tasks.sh` | 3 |
| Qwen explain | `test_qwen_tasks.sh` | contains OSPF |
| Qwen translate | `test_qwen_tasks.sh` | hello |
| Security | GitHub Actions | ✅ no secrets |
| Resources | `check_resources.sh` | 7 lines |

## CI/CD

Every push automatically runs:

- `.github/workflows/ci.yml` — SQL, JSON, and Markdown lint
- `.github/workflows/security_check.yml` — secret detection

See `docs/EVALUATION_CRITERIA.md` for Qwen output quality criteria.
