# CHANGELOG

## [0.3.0] — 2026-03-19

### Added
- `check_resources.sh` v4 — 7-строчный токен-оптимизированный дашборд
- `cleanup_sessions.sh` — автоочистка устаревших skills-plugin сессий
- Триггер "инфо о себе" → автозапуск check_resources при старте чата
- `qt_021` — системный таск запуска check_resources
- `qt_022` — таск очистки сессий
- `qt_023` — security check перед GitHub push
- `pc_013` — startup_check стратегия (qwen_only, 10 сек)
- `.gitignore` — блокировка секретов и .db файлов
- `SECURITY_CHECKLIST.md` — правила безопасности
- `systemd` user service для автозапуска при логине
- Все схемы БД опубликованы на GitHub
- Routing rules (qwen_tasks + parallel_config) в JSON

### Fixed
- Удалены 3 устаревшие сессионные папки (541ff9cd, c2e09db2, f79feb81)
- cleanup_sessions.sh предотвращает накопление дублей в будущем

### Security
- Проверка всех данных через Qwen (qt_023) перед каждым push
- claude_desktop_config.json добавлен в .gitignore

---

## [0.2.0] — 2026-03-18

### Added
- Скилл `ib-consultant` (ИБ-консультант)
- Скилл `mcp-builder` (построение MCP серверов)
- Актуальная сессия skills-plugin: `1492d8b0...`

---

## [0.1.0] — 2026-03-14

### Added
- Инициализация AI-комбайна на Debian
- Установка Ollama + qwen2.5:7b-instruct-q4_K_M
- Создание структуры `/ai/` (db, scripts, workspace)
- 7 локальных БД: routing, project, network, kombain, models, tokens, tools
- 20 qwen_tasks + 12 parallel_config стратегий
- Claude Desktop конфиг с 12 MCP серверами
- Первые workflows: MikroTik, Keenetic, VLESS
