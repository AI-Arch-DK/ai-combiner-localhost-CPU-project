# ROADMAP — AI Combiner

## Текущее состояние: v0.3.0

---

## ✅ v0.1.0 — Инициализация (2026-03-14)

- [x] Debian + Ollama + qwen2.5:7b-instruct-q4_K_M
- [x] Структура `/ai/` (db, scripts, workspace)
- [x] 7 локальных БД
- [x] 12 MCP серверов
- [x] 20 qwen_tasks + 12 parallel_config
- [x] Первые workflows: MikroTik, cisco, L2TP

## ✅ v0.2.0 — Скиллы (2026-03-18)

- [x] Скилл `sales-consultant`
- [x] Скилл `mcp-builder`
- [x] Актуальная сессия skills-plugin `1492d8b0`

## ✅ v0.3.0 — Автоматизация старта (2026-03-19)

- [x] `check_resources.sh` v4 — 7 строк, ~80 токенов
- [x] `cleanup_sessions.sh` — автоочистка дублей
- [x] Триггер "инфо о себе" → автозапуск
- [x] qt_021/022/023 + pc_013
- [x] security check перед каждым push
- [x] Полная документация проекта

---

## 🔄 v0.4.0 — Улучшение роутинга (plan)

- [ ] Внедрение RAG или легких аналогов в дополнение к SQL(FTS)
- [ ] Автоопределение типа запроса через qt_002
- [ ] Автовыбор стратегии из parallel_config
- [ ] routing_log — запись всех решений и токенов
- [ ] Дашборд эффективности (tokens_saved по стратегиям)

## 🔄 v0.5.0 — Мульти-нодовость (plan)

- [ ] Полная реализация kombain_shared.db sync
- [ ] sales_manager-node: sales задачи → shared
- [ ] Office_MAIN-node: центральный оркестратор
- [ ] Конфликт-резолюшн через sync_log

## 🔄 v0.6.0 — GPU / большая модель (plan)

- [ ] Переход на qwen2.5:14b или 32b
- [ ] Сравнение производительности CPU vs GPU
- [ ] GGUF оптимизация под архитектуру хоста
