# AI Combiner — System Overview
# AI Combiner — Полное описание системы

> Local AI orchestrator built on Claude Desktop + Qwen/Ollama + MCP. CPU-only, localhost.
> Локальный AI-оркестратор на базе Claude Desktop + Qwen/Ollama + MCP. CPU-only, localhost.

---

## 🖥 Hardware (Worker Node)
## 🖥 Железо (рабочая node)

| Parameter | Value |
| Параметр | Значение |
|---|---|
| CPU | Intel Core i7-8565U @ 1.80GHz (boost 4.6GHz) |
| Cores / Threads | 4 cores / 8 threads |
| Ядра / Потоки | 4 ядра / 8 потоков |
| L1d/L1i Cache | 128 KiB × 4 |
| Кэш L1d/L1i | 128 KiB × 4 |
| L2 Cache | 1 MiB × 4 |
| Кэш L2 | 1 MiB × 4 |
| L3 Cache | 8 MiB |
| Кэш L3 | 8 MiB |
| Virtualization | VT-x |
| Виртуализация | VT-x |
| RAM | 16 GB (approximately 10 GB in use, 14 GB swap) |
| RAM | 16 GB (используется ~10 GB, swap 14 GB) |
| Storage | NVMe 953.9 GB (nvme0n1) |
| Накопитель | NVMe 953.9 GB (nvme0n1) |
| OS | Debian Linux, kernel 6.19.6+deb14-amd64 |
| ОС | Debian Linux, kernel 6.19.6+deb14-amd64 |
| Ollama Model | qwen2.5:7b-instruct-q4_K_M |
| Ollama модель | qwen2.5:7b-instruct-q4_K_M |

---

## 📡 MCP Servers (Active)
## 📡 MCP-серверы (активные)

| ID | MCP Server | Purpose |
| ID | MCP | Назначение |
|---|---|---|
| sqlite | mcp-server-sqlite | Database: routing / project / kombain_local |
| sqlite | mcp-server-sqlite | БД routing/project/kombain_local |
| ollama-local | ollama-server (node) | Qwen local LLM (port 11434) |
| ollama-local | ollama-server (node) | Qwen локальная LLM (11434) |
| host-report | host-report-server (node) | Host monitoring (system_audit) |
| host-report | host-report-server (node) | Мониторинг хоста (system_audit) |
| filesystem | @modelcontextprotocol/server-filesystem | Mount points: /home/sales_manager, /home/debianAI, /ai, /mnt/sda2, /tmp |
| filesystem | @modelcontextprotocol/server-filesystem | /home/sales_manager, /home/debianAI, /ai, /mnt/sda2, /tmp |
| shell | mcp-shell | Shell command execution |
| shell | mcp-shell | Shell-команды |
| github-public | github-mcp-server | Public GitHub account (open source) |
| github-public | github-mcp-server | Аккаунт GitHub public account (open source) |
| github-private | github-mcp-server | Private GitHub account (private projects) |
| github-private | github-mcp-server | Аккаунт GitHub private account (приватные проекты) |
| huggingface | huggingface-server (node) | HF API + inference (cerebras/novita/together) |
| huggingface | huggingface-server (node) | HF API + inference (cerebras/novita/together) |
| miro | mcp.miro.com | DAG / architecture visualization |
| miro | mcp.miro.com | Визуализация DAG/архитектуры |
| tavily | tavily-mcp | Web search |
| tavily | tavily-mcp | Веб-поиск |
| browser | playwright browser-server | Browser automation (Chromium) |
| browser | playwright browser-server | Браузер (Chromium) |
| clay | api.clay.com/v3/mcp | CRM / data enrichment |
| clay | api.clay.com/v3/mcp | CRM / data enrichment |
| gcal | gcal.mcp.claude.com | Google Calendar |
| gcal | gcal.mcp.claude.com | Google Calendar |
| gmail | gmail.mcp.claude.com | Gmail |
| gmail | gmail.mcp.claude.com | Gmail |

---

## 🗄 Databases
## 🗄 Базы данных

### Local (`/ai/db/`)
### Локальные (`/ai/db/`)

| Database | Tables | Size | Purpose |
| БД | Таблиц | Размер | Назначение |
|---|---|---|---|
| routing.db | 3 | 56K | qwen_tasks (21 tasks) + parallel_config (13 strategies) + routing_log |
| routing.db | 3 | 56K | qwen_tasks (21 задача) + parallel_config (13 стратегий) + routing_log |
| project.db | 3 | 108K | Projects, templates, full-text search |
| project.db | 3 | 108K | Проекты, шаблоны, FTS |
| network.db | 3 | 100K | FAQ cache (network + sales tasks) |
| network.db | 3 | 100K | FAQ кэш (сетевые + sales задачи) |
| kombain_local.db | 5 | — | Local kombain: workflows, results, feedback, qwen_knowledge |
| kombain_local.db | 5 | — | Локальный комбайн: workflows, results, feedback, qwen_knowledge |
| models.db | 2 | 28K | Model registry |
| models.db | 2 | 28K | Реестр моделей |
| tokens.db | 3 | 36K | Token usage tracking per session |
| tokens.db | 3 | 36K | Учёт токенов по сессиям |
| tools.db | 2 | 32K | Tool and MCP registry |
| tools.db | 2 | 32K | Реестр инструментов и MCP |

### Shared Database
### Shared БД

| Database | Path | Purpose |
| БД | Путь | Назначение |
|---|---|---|
| kombain_shared.db | `/ai/external/sales_manager/kombain_shared.db` | Shared database for the future **Office_MAIN-nodes** — the central hub of the office AI kombain. Currently acts as a shared resource between the localhost node (debianAI) and the sales_manager node. |
| kombain_shared.db | `/ai/external/sales_manager/kombain_shared.db` | Общая БД для будущего **Office_MAIN-nodes** — центрального узла офисного AI-комбайна. Сейчас доступна как shared-ресурс между localhost-нодой (debianAI) и sales_manager-нодой. |

> **Office_MAIN** — a concept for a large-scale office AI kombain with a central orchestrator node (Office_MAIN) and peripheral nodes (sales_manager, debianAI, etc.). `kombain_shared.db` is the synchronization point across all nodes.
> **Office_MAIN** — концепция большого офисного AI-комбайна с центральной нодой (Office_MAIN) и периферийными nodes (sales_manager, debianAI и др.). `kombain_shared.db` — точка синхронизации между nodes.

---

## 🔀 Routing Rules
## 🔀 Правила маршрутизации

### parallel_config — Strategies (13)
### parallel_config — стратегии (13)

| ID | Task Type | Strategy | Description |
| ID | Тип задачи | Стратегия | Описание |
|---|---|---|---|
| pc_001 | network_config | parallel | Qwen + HF + tavily in parallel — first quality result wins |
| pc_001 | network_config | parallel | Qwen + HF + tavily параллельно, первый качественный |
| pc_002 | explain_short | qwen_only | Explanations: Qwen only, fast |
| pc_002 | explain_short | qwen_only | Объяснения: только Qwen, быстро |
| pc_003 | code_bash | qwen_only | Bash: Qwen only |
| pc_003 | code_bash | qwen_only | Bash: только Qwen |
| pc_004 | code_sql | qwen_only | SQL: Qwen only |
| pc_004 | code_sql | qwen_only | SQL: только Qwen |
| pc_005 | research | external_first | HF + browser + tavily |
| pc_005 | research | external_first | HF + browser + tavily |
| pc_006 | system_check | qwen_only | System checks: Qwen + host-report only |
| pc_006 | system_check | qwen_only | Система: только Qwen + host-report |
| pc_007 | extract_ip | qwen_only | Extraction: Qwen only |
| pc_007 | extract_ip | qwen_only | Извлечение: только Qwen |
| pc_008 | orchestration | external_first | Claude + all tools |
| pc_008 | orchestration | external_first | Claude + все инструменты |
| pc_009 | validate_config | qwen_with_context | Qwen processes tavily-sourced data |
| pc_009 | validate_config | qwen_with_context | Qwen обрабатывает данные от tavily |
| pc_010 | format_output | qwen_only | Output formatting: Qwen only |
| pc_010 | format_output | qwen_only | Форматирование: только Qwen |
| pc_011 | compare_options | parallel | Qwen + HF + tavily |
| pc_011 | compare_options | parallel | Qwen + HF + tavily |
| pc_012 | fact_check | qwen_with_context | Fact-checking: Qwen + tavily |
| pc_012 | fact_check | qwen_with_context | Проверка: Qwen + tavily |
| pc_013 | startup_check | qwen_only | Startup / resource check: Qwen + host-report, 10s timeout |
| pc_013 | startup_check | qwen_only | Старт/ресурсы: Qwen + host-report, таймаут 10 сек |

### qwen_tasks — Active Tasks (21)
### qwen_tasks — активные задачи (21)

| ID | Triggers | Category | Description |
| ID | Триггеры | Категория | Описание |
|---|---|---|---|
| qt_001 | check localhost, system status | system_check | Analyze system_audit report |
| qt_001 | проверь локалхост, состояние системы | system_check | Анализ system_audit репорта |
| qt_002 | classify request, identify type | classification | Classify incoming request |
| qt_002 | классифицируй запрос, определи тип | classification | Классификация входящего запроса |
| qt_003 | find IP, extract IP | extract_ip | Extract IP addresses from text |
| qt_003 | найди ip, извлеки ip | extract_ip | Извлечение IP адресов из текста |
| qt_004 | find ports, open ports | extract_ports | Extract ports from network report |
| qt_004 | найди порты, открытые порты | extract_ports | Извлечение портов из network отчёта |
| qt_005 | find errors, error | extract_errors | Extract errors from logs |
| qt_005 | найди ошибки, error | extract_errors | Извлечение ошибок из логов |
| qt_006 | how many, count | count | Count elements |
| qt_006 | сколько, посчитай | count | Подсчёт элементов |
| qt_007 | mikrotik config, mikrotik cli | network_mikrotik | MikroTik CLI commands |
| qt_007 | конфиг mikrotik, mikrotik cli | network_mikrotik | MikroTik CLI команды |
| qt_008 | cisco config, configure cisco | network_cisco | Cisco configuration |
| qt_008 | конфиг cisco, настройка cisco | network_cisco | cisco конфигурация |
| qt_011 | translate, translation | translate | Text translation |
| qt_011 | переведи, translate | translate | Перевод текста |
| qt_012 | summarize, summary, recap | summarize | Brief text summary |
| qt_012 | сокращи, summary, итог | summarize | Краткое резюме текста |
| qt_013 | what is, explain briefly | explain_short | Brief explanation of a term |
| qt_013 | что такое, объясни кратко | explain_short | Краткое объяснение термина |
| qt_014 | extract data, parse | extract_data | Extract structured data |
| qt_014 | извлеки данные, распарси | extract_data | Извлечение структурированных данных |
| qt_015 | verify commands, validate config | validate_config | Config validation via tavily |
| qt_015 | проверь команды, валидируй конфиг | validate_config | Валидация конфигов через tavily |
| qt_016 | structure, make a table | format_output | Format external data |
| qt_016 | структурируй, сделай таблицу | format_output | Форматирование внешних данных |
| qt_017 | compare options, which is better | compare_options | Compare solution options |
| qt_017 | сравни варианты, какой лучше | compare_options | Сравнение вариантов решений |
| qt_018 | fact-check, find contradictions | fact_check | Fact verification and contradiction detection |
| qt_018 | проверь факты, найди противоречия | fact_check | Проверка фактов и противоречий |
| qt_019 | bash script, shell command | code_direct | ⚡ CLAUDE_DIRECT: code written by Claude directly |
| qt_019 | bash скрипт, shell команда | code_direct | ⚡ CLAUDE_DIRECT: код пишет Claude напрямую |
| qt_020 | sql query, write sql | code_direct | ⚡ CLAUDE_DIRECT: SQL written by Claude directly |
| qt_020 | sql запрос, напиши sql | code_direct | ⚡ CLAUDE_DIRECT: SQL пишет Claude напрямую |
| qt_021 | about yourself, who are you, system info | system_check | Session start: run check_resources.sh |
| qt_021 | инфо о себе, вспомни о себе, кто ты | system_check | Старт сессии: запуск check_resources.sh |
| qt_022 | clean sessions, cleanup sessions | system_check | Clean up stale Claude Desktop session folders |
| qt_022 | очисти сессии, cleanup sessions | system_check | Очистка устаревших session папок Claude Desktop |
| qt_023 | security check, check before push | fact_check | Validate data before sending to an external resource |
| qt_023 | проверь безопасность, security check | fact_check | Проверка данных перед отправкой на внешний ресурс |

---

## 🏗 Office_MAIN Concept (Roadmap)
## 🏗 Концепция Office_MAIN (будущее)

```text
[Office_MAIN-node] ← Central Orchestrator
[Office_MAIN-node] ← центральный оркестратор
    │
    ├── [debianAI-node]  ← Current worker node (localhost CPU)
    ├── [debianAI-node]  ← текущая рабочая node (localhost CPU)
    │       kombain_local.db
    │
    ├── [sales_manager-node]   ← Security / Sales node
    ├── [sales_manager-node]   ← security/sales node
    │       kombain_local.db
    │
    └── kombain_shared.db ← Shared database across all nodes
    └── kombain_shared.db ← общая БД всех нод
            /ai/external/sales_manager/kombain_shared.db
```

All nodes synchronize through `kombain_shared.db`. Office_MAIN serves as the chief conductor of the entire network.
Все nodes синхронизируются через `kombain_shared.db`. Office_MAIN выступает как главный дирижёр всей сети.

---

## ⚙️ Configuration File
## ⚙️ Конфигурационный файл

`~/.config/Claude/claude_desktop_config.json` — contains MCP server definitions + systemPrompt.
`~/.config/Claude/claude_desktop_config.json` — содержит MCP-серверы + systemPrompt.

> ⚠️ This file contains API keys and is NOT committed to the repository (see `.gitignore`).
> ⚠️ Этот файл содержит API-ключи и НЕ публикуется в репозитории (см. `.gitignore`).
