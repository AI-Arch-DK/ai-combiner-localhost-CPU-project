# Commit Guide — AI Combiner

## Формат коммитов

```
<тип>: <описание> [(ссылка на issue)]
```

## Типы

| Тип | Когда использовать |
|---|---|
| `feat` | новый скрипт/схема/документ |
| `fix` | исправление ошибки в скрипте/схеме |
| `docs` | изменение документации |
| `refactor` | переработка без изменения поведения |
| `security` | изменения связанные с безопасностью |
| `db` | изменение схем или seed данных |
| `routing` | изменение qwen_tasks / parallel_config |
| `chore` | незначительные обслуживание |

## Примеры

```bash
feat: add qt_024 — docker container check
fix: cleanup_sessions.sh — handle empty plugin dir
docs: update ROADMAP v0.4.0 tasks
db: add kombain_shared sync_log index
routing: pc_014 docker_check strategy qwen_only
security: gitignore add *.key pattern
```

## Правила

- Описание на русском или английском
- Максимум 72 символа в строке
- **НИКОГДА** не коммитить `.db` файлы
- **НИКОГДА** не коммитить `claude_desktop_config.json`
- Security check перед каждым push: `qt_023` или см. `SECURITY_CHECKLIST.md`
