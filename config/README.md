# Config

| Файл | Назначение |
|---|---|
| `ollama_model.md` | Параметры модели qwen2.5:7b + железо + производительность |
| `ai-check-resources.service` | systemd user service — автозапуск check_resources при логине |

## Файлы НЕ в репо (содержат секреты)

| Файл | Причина |
|---|---|
| `~/.config/Claude/claude_desktop_config.json` | API ключи всех MCP серверов |
| `~/.config/Claude/config.env` | Переменные окружения с токенами |

См. `.gitignore` и `docs/SECURITY_CHECKLIST.md`.
