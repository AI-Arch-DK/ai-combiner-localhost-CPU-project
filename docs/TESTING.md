# Testing — AI Combiner

## Автоматические тесты

```bash
# Тест Qwen (4 таска)

bash /ai/scripts/test_qwen_tasks.sh

# Health check (все компоненты)

bash /ai/scripts/health_check.sh

# Security check

grep -rE "tvly-|github_pat|hf_[a-zA-Z]{20,}" \
  --include="*.sh" --include="*.json" --include="*.md" . \
  && echo "❌ SECRETS" || echo "✅ CLEAN"

```text

## Тестовая матрица

| Тест | Скрипт | Ожидаемый результат |
|---|---|---|
| Ollama запущен | `health_check.sh` | ✅ ollama отвечает |
| БД доступны | `health_check.sh` | ✅ 7 БД |
| Qwen classify | `test_qwen_tasks.sh` | network_config |
| Qwen count | `test_qwen_tasks.sh` | 3 |
| Qwen explain | `test_qwen_tasks.sh` | содержит OSPF |
| Qwen translate | `test_qwen_tasks.sh` | привет/hello |
| Security | GitHub Actions | ✅ no secrets |
| Ресурсы | `check_resources.sh` | 7 строк |

## CI/CD

При каждом push автоматически запускается:
- `.github/workflows/security_check.yml` — проверка секретов

См. `docs/EVALUATION_CRITERIA.md` для критериев качества Qwen.
