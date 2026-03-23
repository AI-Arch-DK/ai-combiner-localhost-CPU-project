# CHANGELOG

## [0.3.0] — 2026-03-19

### Added
- `check_resources.sh` v4 — 7-строчный токен-оптимизированный дашборд
- `cleanup_sessions.sh` — автоочистка устаревших skills-plugin сессий
- Триггер "инфо о себе" → автозапуск check_resources при старте чата
- qt_021/022/023 + pc_013
- GitHub Actions security workflow
- Все схемы БД опубликованы
- Routing rules в JSON
- CATALOG.md, NIGHT_LEARNING.md, SQL_INDEXING.md, HALLUCINATION_GUARD.md, EXTERNAL_CONNECTORS.md
- DB_RELATIONS.md, backup_mcp.sh

### Fixed
- Удалены 3 устаревших сессионных папки
- cleanup_sessions.sh предотвращает накопление дублей
- NIGHT_LEARNING: добавлен pipeline + error handling
- SQL_INDEXING: добавлен EXPLAIN + мониторинг
- HALLUCINATION_GUARD: полная реализация confidence_score()

### Security
- Проверка через Qwen (qt_023) перед каждым push
- backup_mcp.sh: бэкап MCP серверов (санитизированный, без токенов)

### Breaking Changes
_v0.3.0 не содержит breaking changes. Файлы обратно совместимы с v0.2.0._

---

## [0.2.0] — 2026-03-18

### Added
- Скилл `ib-consultant` (ИБ-консультант)
- Скилл `mcp-builder` (построение MCP серверов)
- Актуальная сессия skills-plugin: `1492d8b0...`

### Breaking Changes
_v0.2.0 не содержит breaking changes._

---

## [0.1.0] — 2026-03-14

### Added
- Инициализация AI-комбайна на Debian
- Установка Ollama + qwen2.5:7b-instruct-q4_K_M
- 7 локальных БД, 12 MCP, 20 qwen_tasks
- Первые workflows: MikroTik, cisco, L2TP

### Breaking Changes
_Первая версия, breaking changes не применимы._
