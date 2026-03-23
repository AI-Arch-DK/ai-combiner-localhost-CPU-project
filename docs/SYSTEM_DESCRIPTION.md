# AI Combiner — Полное описание системы

> Локальный AI-оркестратор на базе Claude Desktop + Qwen/Ollama + MCP. CPU-only, localhost.

---

## 🖥 Железо (рабочая node)

| Параметр | Значение |
|---|---|
| CPU | Intel Core i7-8565U @ 1.80GHz (boost 4.6GHz) |
| Ядра / Потоки | 4 ядра / 8 потоков |
| Кэш L1d/L1i | 128 KiB × 4 |
| Кэш L2 | 1 MiB × 4 |
| Кэш L3 | 8 MiB |
| Виртуализация | VT-x |
| RAM | 16 GB (используется ~10 GB, swap 14 GB) |
| Накопитель | NVMe 953.9 GB (nvme0n1) |
| ОС | Debian Linux, kernel 6.19.6+deb14-amd64 |
| Ollama модель | qwen2.5:7b-instruct-q4_K_M |

---

## 📡 MCP-серверы (активные)

| ID | MCP | Назначение |
|---|---|---|
| sqlite | mcp-server-sqlite | БД routing/project/kombain_local |
| ollama-local | ollama-server (node) | Qwen локальная LLM (11434) |
| host-report | host-report-server (node) | Мониторинг хоста (system_audit) |
| filesystem | @modelcontextprotocol/server-filesystem | /home/sales_manager, /home/debai, /ai, /mnt/sda2, /tmp |
| shell | mcp-shell | Shell-команды |
| github-public | github-mcp-server | Аккаунт GitHub public account (open source) |
| github-private | github-mcp-server | Аккаунт GitHub private account (приватные проекты) |
| huggingface | huggingface-server (node) | HF API + inference (cerebras/novita/together) |
| miro | mcp.miro.com | Визуализация DAG/архитектуры |
| tavily | tavily-mcp | Веб-поиск |
| browser | playwright browser-server | Браузер (Chromium) |
| clay | api.clay.com/v3/mcp | CRM / data enrichment |
| gcal | gcal.mcp.claude.com | Google Calendar |
| gmail | gmail.mcp.claude.com | Gmail |

---

## 🗄 Базы данных

### Локальные (`/ai/db/`)

| БД | Таблиц | Размер | Назначение |
|---|---|---|---|
| routing.db | 3 | 56K | qwen_tasks (21 задача) + parallel_config (13 стратегий) + routing_log |
| project.db | 3 | 108K | Проекты, шаблоны, FTS |
| network.db | 3 | 100K | FAQ кэш (сетевые + sales задачи) |
| kombain_local.db | 5 | — | Локальный комбайн: workflows, results, feedback, qwen_knowledge |
| models.db | 2 | 28K | Реестр моделей |
| tokens.db | 3 | 36K | Учёт токенов по сессиям |
| tools.db | 2 | 32K | Реестр инструментов и MCP |

### Shared БД

| БД | Путь | Назначение |
|---|---|---|
| kombain_shared.db | `/ai/external/sales_manager/kombain_shared.db` | Общая БД для будущего **Office_MAIN-nodes** — центрального узла офисного AI-комбайна. Сейчас доступна как shared-ресурс между localhost-нодой (debai) и sales_manager-нодой. |

> **Office_MAIN** — концепция большого офисного AI-комбайна с центральной нодой (Office_MAIN) и периферийными nodes (sales_manager, debai и др.). `kombain_shared.db` — точка синхронизации между nodes.

---

## 🔀 Правила маршрутизации

### parallel_config — стратегии (13)

| ID | Тип задачи | Стратегия | Описание |
|---|---|---|---|
| pc_001 | network_config | parallel | Qwen + HF + tavily параллельно, первый качественный |
| pc_002 | explain_short | qwen_only | Объяснения: только Qwen, быстро |
| pc_003 | code_bash | qwen_only | Bash: только Qwen |
| pc_004 | code_sql | qwen_only | SQL: только Qwen |
| pc_005 | research | external_first | HF + browser + tavily |
| pc_006 | system_check | qwen_only | Система: только Qwen + host-report |
| pc_007 | extract_ip | qwen_only | Извлечение: только Qwen |
| pc_008 | orchestration | external_first | Claude + все инструменты |
| pc_009 | validate_config | qwen_with_context | Qwen обрабатывает данные от tavily |
| pc_010 | format_output | qwen_only | Форматирование: только Qwen |
| pc_011 | compare_options | parallel | Qwen + HF + tavily |
| pc_012 | fact_check | qwen_with_context | Проверка: Qwen + tavily |
| pc_013 | startup_check | qwen_only | Старт/ресурсы: Qwen + host-report, таймаут 10 сек |

### qwen_tasks — активные задачи (21)

| ID | Триггеры | Категория | Описание |
|---|---|---|---|
| qt_001 | проверь локалхост, состояние системы | system_check | Анализ system_audit репорта |
| qt_002 | классифицируй запрос, определи тип | classification | Классификация входящего запроса |
| qt_003 | найди ip, извлеки ip | extract_ip | Извлечение IP адресов из текста |
| qt_004 | найди порты, открытые порты | extract_ports | Извлечение портов из network отчёта |
| qt_005 | найди ошибки, error | extract_errors | Извлечение ошибок из логов |
| qt_006 | сколько, посчитай | count | Подсчёт элементов |
| qt_007 | конфиг mikrotik, mikrotik cli | network_mikrotik | MikroTik CLI команды |
| qt_008 | конфиг cisco, настройка cisco | network_cisco | cisco конфигурация |
| qt_011 | переведи, translate | translate | Перевод текста |
| qt_012 | сокращи, summary, итог | summarize | Краткое резюме текста |
| qt_013 | что такое, объясни кратко | explain_short | Краткое объяснение термина |
| qt_014 | извлеки данные, распарси | extract_data | Извлечение структурированных данных |
| qt_015 | проверь команды, валидируй конфиг | validate_config | Валидация конфигов через tavily |
| qt_016 | структурируй, сделай таблицу | format_output | Форматирование внешних данных |
| qt_017 | сравни варианты, какой лучше | compare_options | Сравнение вариантов решений |
| qt_018 | проверь факты, найди противоречия | fact_check | Проверка фактов и противоречий |
| qt_019 | bash скрипт, shell команда | code_direct | ⚡ CLAUDE_DIRECT: код пишет Claude напрямую |
| qt_020 | sql запрос, напиши sql | code_direct | ⚡ CLAUDE_DIRECT: SQL пишет Claude напрямую |
| qt_021 | инфо о себе, вспомни о себе, кто ты | system_check | Старт сессии: запуск check_resources.sh |
| qt_022 | очисти сессии, cleanup sessions | system_check | Очистка устаревших session папок Claude Desktop |
| qt_023 | проверь безопасность, security check | fact_check | Проверка данных перед отправкой на внешний ресурс |

---

## 🏗 Концепция Office_MAIN (будущее)

```
[Office_MAIN-node] ← центральный оркестратор
    │
    ├── [debai-node]  ← текущая рабочая node (localhost CPU)
    │       kombain_local.db
    │
    ├── [sales_manager-node]   ← security/sales node  
    │       kombain_local.db
    │
    └── kombain_shared.db ← общая БД всех нод
            /ai/external/sales_manager/kombain_shared.db
```

Все nodes синхронизируются через `kombain_shared.db`. Office_MAIN выступает как главный дирижёр всей сети.

---

## ⚙️ Конфигурационный файл

`~/.config/Claude/claude_desktop_config.json` — содержит MCP-серверы + systemPrompt.

> ⚠️ Этот файл содержит API-ключи и НЕ публикуется в репозитории (см. `.gitignore`).
