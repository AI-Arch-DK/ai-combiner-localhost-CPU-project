# AI Combiner — localhost CPU project

> Локальный AI-оркестратор: Claude Desktop + Qwen/Ollama + 13 MCP. CPU-only, localhost.

## Быстрый старт

```bash
# 1. Установить Ollama и модель
curl -fsSL https://ollama.ai/install.sh | sh
ollama pull qwen2.5:7b-instruct-q4_K_M

# 2. Создать структуру
mkdir -p /ai/{db,scripts,logs,backup,workspace,external/sales_manager,kombain}

# 3. Инициализировать БД
bash scripts/init_db.sh

# 4. Скопировать скрипты
cp scripts/*.sh /ai/scripts/ && chmod +x /ai/scripts/*.sh

# 5. Настроить claude_desktop_config.json (см. docs/MCP_SETUP.md)
# 6. Запустить Claude Desktop
# 7. Первое сообщение: "инфо о себе"
```

## Архитектура

```
Пользователь → [SKILLS] → [systemPrompt] → qwen_dispatch → parallel_config → Результат
                 ↑перехват     ↑claude_desktop    ↑routing.db         ↑routing.db
```

**Модели:** Qwen 7B (local, бесплатно) | Claude Sonnet (дирижёр) | Cerebras llama3.1-8b (external) | Tavily (search)

## Структура репозитория

```
ai-combiner-localhost-CPU-project/
├── README.md
├── .gitignore
├── CHANGELOG.md
├── config/
│   ├── ollama_model.md          # параметры qwen2.5:7b
│   └── ai-check-resources.service
├── docs/
│   ├── architecture.md          # архитектура и приоритеты
│   ├── SYSTEM_DESCRIPTION.md    # железо, MCP, БД, routing rules
│   ├── routing_logic.md         # ASCII схема + матрица стратегий
│   ├── MCP_SETUP.md             # настройка MCP серверов
│   ├── SKILLS_LIST.md           # 8 скиллов
│   ├── ROADMAP.md               # v0.1–v0.6
│   ├── CONTRIBUTING.md          # добавление тасков/скиллов
│   ├── TROUBLESHOOTING.md       # частые проблемы
│   ├── FAQ.md                   # вопросы/ответы
│   └── SECURITY_CHECKLIST.md    # правила перед push
├── scripts/
│   ├── check_resources.sh       # старт чата (триггер: "инфо о себе")
│   ├── cleanup_sessions.sh      # автоочистка skills-plugin
│   ├── init_db.sh               # инициализация БД с нуля
│   ├── backup_db.sh             # бэкап всех БД
│   └── health_check.sh          # проверка всех компонентов
└── db/
    ├── workflows.json
    ├── schemas/                 # 8 SQL схем
    └── data/                    # qwen_tasks, parallel_config, models_seed
```

## Железо

| CPU | RAM | NVMe | OS | Ollama |
|---|---|---|---|---|
| i7-8565U 4c/8t 4.6GHz | 16 GB | 954 GB | Debian 6.19.6 | qwen2.5:7b-q4_K_M |

## MCP серверы (13)

`sqlite` `ollama-local` `host-report` `filesystem` `github-pub` `github-priv` `huggingface` `miro` `tavily` `shell` `browser` `clay` `gcal` `gmail`

## Ссылки

- [📖 Архитектура](docs/architecture.md)
- [🔀 Роутинг](docs/routing_logic.md)
- [📡 MCP Setup](docs/MCP_SETUP.md)
- [🚧 Roadmap](docs/ROADMAP.md)
- [❓ FAQ](docs/FAQ.md)
- [🔧 Troubleshooting](docs/TROUBLESHOOTING.md)
