# Security Checklist — перед каждым push на GitHub

## ❌ НИКОГДА не пушить

| Тип | Примеры |
|---|---|
| API ключи | `tvly-*`, `hf_*`, `sk-*` |
| GitHub PAT | `github_pat_*` |
| HuggingFace токены | `hf_*` |
| Пароли | любые строки `password=` |
| `claude_desktop_config.json` | содержит все токены MCP |
| `config.env` | переменные окружения |
| Реальные `.db` файлы | содержат данные пользователя |
| Пути `/home/debai/` | раскрывают имя пользователя |

## ✅ Что можно пушить

| Тип | Примеры |
|---|---|
| Скрипты без секретов | `check_resources.sh`, `cleanup_sessions.sh` |
| SQL схемы | `routing_schema.sql` (без данных) |
| Архитектурные доки | `architecture.md`, `README.md` |
| Workflows JSON | без токенов и паролей |
| `.gitignore` | всегда |

## 🔍 Проверка перед push (команда)

```bash
# Запусти перед каждым git push:
grep -rE "tvly-|github_pat|hf_[a-zA-Z]{20,}|password|api.key|secret" \
  --include="*.sh" --include="*.json" --include="*.md" --include="*.sql" \
  . 2>/dev/null && echo "❌ НАЙДЕНЫ СЕКРЕТЫ" || echo "✅ Чисто"
```

## 🤖 Автоматическая проверка

Claude проверяет данные через Qwen перед каждым push:
1. Qwen сканирует контент на секреты
2. При обнаружении — блокирует push
3. Предлагает замену на `$ENV_VAR` плейсхолдеры
