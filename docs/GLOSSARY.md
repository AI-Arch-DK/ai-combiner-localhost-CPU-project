# Glossary — AI Combiner

| Термин | Описание |
|---|---|
| **AI-комбайн** | Локальный оркестратор: Claude + Qwen + MCP |
| **Claude Desktop** | Дирижёр/оркестратор. Раздаёт задачи между инструментами |
| **Qwen / Ollama** | Локальная LLM-воркер. Бесплатно, CPU-only |
| **MCP** | Model Context Protocol. Стандарт подключения инструментов к Claude |
| **qwen_dispatch** | Первый инструмент для каждого запроса. Роутер Qwen |
| **qwen_tasks** | Таблица в routing.db. Матчинг триггеров → промпт → Qwen |
| **parallel_config** | Таблица стратегий маршрутизации (13 записей) |
| **SKILL.md** | Файл скилла. Перехватывает запросы до systemPrompt |
| **skills-plugin** | Папка скиллов в `local-agent-mode-sessions` |
| **systemPrompt** | Главный промпт Claude. В `claude_desktop_config.json` |
| **kombain_local.db** | Локальная БД ноды (workflows, results, knowledge) |
| **kombain_shared.db** | Общая БД нод через sync_log |
| **sync_log** | Таблица синхронизации между нодами |
| **Office_MAIN** | Будущая центральная нода офисного AI-комбайна |
| **debai-нода** | Текущая рабочая нода (localhost CPU, Debian) |
| **kali-нода** | Security/pentest нода |
| **CLAUDE_DIRECT** | Маркер в qwen_tasks. Claude выполняет без Qwen |
| **NO_MATCH** | Ответ qwen_dispatch: задача не найдена. Идёт к стратегии |
| **qwen_only** | Стратегия: только Qwen, нет внешних запросов |
| **parallel** | Стратегия: Qwen + HF + tavily одновременно |
| **external_first** | Стратегия: HF + browser + tavily |
| **qwen_with_context** | Стратегия: tavily даёт данные → Qwen обрабатывает |
| **check_resources.sh** | Скрипт старта. 7 строк, ~80 токенов |
| **cleanup_sessions.sh** | Автоочистка skills-plugin |
| **health_check.sh** | OK/WARN/FAIL по всем компонентам |
| **Q4_K_M** | 4-bit квантизация с mixed precision. Баланс качество/размер |
| **routing_log** | Таблица истории решений и экономии токенов |
| **qt_019/020** | CLAUDE_DIRECT маркеры. bash/sql → Claude напрямую |
