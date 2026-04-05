# 🤖 AI-Комбайн v4+ — Отчёт о борту
> Для разработчиков и соавторов | Обновлён: 2026-04-05

---

## 🖥️ Железо

| Параметр | Значение |
|----------|----------|
| CPU | Intel Core i7-8565U (CoffeeLake, 4C/8T, AVX2) |
| RAM | 15.6GB (16GB - 512MB iGPU shared) |
| GPU | ❌ Нет (iGPU UHD620 — OpenCL недоступен на этом kernel) |
| Диск | 213GB NVMe, 22% занято |
| ОС | Debian Forky (kernel 6.19) |
| Прокси | 127.0.0.1:2080 (обязателен для tavily + HuggingFace) |

**Производительность:**
- Ollama CPU: **6.6 tok/s** (физический предел для 7.6B Q4_K_M)
- Классификация запроса: ~4s
- Генерация 150 токенов: ~29s
- AVX2: ✅ используется автоматически

---

## 🧠 Модели Ollama

| Имя | Размер | Скорость | Назначение |
|-----|--------|----------|------------|
| qwen-optimized:latest | 4.7GB | 6.6 tok/s | Основная |
| qwen2.5:7b-instruct-q4_K_M | 4.7GB | 6.6 tok/s | MCP модель |

**Конфиг** (`/etc/systemd/system/ollama.service.d/optimize.conf`):
```ini
OLLAMA_NUM_THREAD=6
OLLAMA_NUM_PARALLEL=2
OLLAMA_MAX_LOADED_MODELS=1
OLLAMA_KEEP_ALIVE=10m
OLLAMA_FLASH_ATTENTION=1
OOMScoreAdjust=-500
```

---

## 🏗️ Архитектура

```
Пользователь
    ↓
Claude Desktop (Orchestrator)
    ↓ MCP
    ├── ollama-local v4.0  → qwen (локально, бесплатно)
    ├── huggingface        → cerebras/llama3.1-8b (облако, бесплатно)
    ├── tavily             → веб-поиск (прокси 2080)
    ├── browser            → Playwright Chromium
    ├── sqlite             → kombain_local.db
    ├── filesystem         → /home/debai, /ai, /tmp
    ├── shell              → bash команды
    ├── host-report        → состояние системы
    └── github x2          → AI-Arch-DK (public), tehai-arch (private)

Роутинг (router.sh v2):
    Простые/локальные → qwen (~33s, бесплатно)
    Сложные/срочные   → Claude (3-5s, токены)
    Поиск             → tavily + HF параллельно
```

---

## 🔌 MCP Серверы (10 штук)

| Сервер | Версия | Статус | Описание |
|--------|--------|--------|----------|
| ollama-local | v4.0 | ✅ | qwen с детекцией галлюцинаций, 3 сценария таймаута |
| sqlite | — | ✅ | kombain_local.db |
| filesystem | — | ✅ | /home/debai, /ai, /mnt/sda2, /tmp |
| shell | — | ✅ | bash команды |
| host-report | — | ✅ | авто-обновление >60 мин |
| github-public | — | ✅ | AI-Arch-DK аккаунт |
| github-private | — | ✅ | tehai-arch аккаунт |
| huggingface | — | ✅ | cerebras (основной провайдер) |
| tavily | — | ✅ | требует прокси 127.0.0.1:2080 |
| browser | — | ✅ | Playwright, SSL через прокси |

---

## 🗄️ Базы данных

| БД | Таблицы | FTS индексы | Записей | Назначение |
|----|---------|-------------|---------|------------|
| routing.db | 4 | 4 | 43 задачи, 17 стратегий, 10 правил | Роутинг qwen |
| kombain_local.db | 12 | 7 | 120 знаний, workflows | Основная KB |
| tools.db | 2 | 2 | 8 инструментов | Реестр инструментов |
| network.db | 3 | 3 | 20 шаблонов | Сетевые конфиги, FAQ |
| models.db | 2 | 2 | — | Реестр моделей |
| tokens.db | 3 | 3 | — | Учёт токенов |
| git_ops.db | 3 | 3 | — | Git операции |
| project.db | 3 | 3 | — | Цели и роадмап |

---

## 📜 Скрипты

| Скрипт | Путь | Назначение |
|--------|------|------------|
| agent.py v1 | /ai/scripts/ | Нативный Python агент (7 tools, dedup) |
| router.sh v2 | /ai/tools/ | Роутер curl API (4s класс + 29s генерация) |
| backup_gold.sh | /ai/scripts/ | Золотой бэкап системы |
| run_night_learning.py | /ai/scripts/ | Ночное обучение из network.db |
| qwen_index_agent.sh | /ai/scripts/ | Перестройка FTS индексов всех БД |
| check_resources.sh | /ai/scripts/ | Состояние системы (используется MCP) |

---

## 🚀 Быстрый старт для разработчика

```bash
# 1. Клонировать репо
git clone git@github.com:AI-Arch-DK/ai-combiner-localhost-CPU-project.git
cd ai-combiner-localhost-CPU-project

# 2. Установить ollama
curl -fsSL https://ollama.ai/install.sh | sh

# 3. Скачать модель
ollama pull qwen2.5:7b-instruct-q4_K_M

# 4. Применить оптимизации
sudo mkdir -p /etc/systemd/system/ollama.service.d/
sudo cp configs/optimize.conf /etc/systemd/system/ollama.service.d/
sudo systemctl daemon-reload && sudo systemctl restart ollama

# 5. Настроить окружение
cp config.env.example ~/.config/Claude/config.env
echo 'source ~/.config/Claude/config.env' >> ~/.bashrc
source ~/.bashrc

# 6. Проверить
bash /ai/scripts/check_resources.sh
```

---

## ⚠️ Известные ограничения

- **GPU**: iGPU CoffeeLake UHD620 не поддерживает OpenCL для LLM (GuC submission N/A)
- **Скорость**: 6.6 tok/s — физический потолок CPU для 7.6B модели
- **Прокси**: 127.0.0.1:2080 обязателен для tavily/HF curl
- **Browser**: SSL через прокси не работает (ERR_CERT_AUTHORITY_INVALID)
- **cgroup**: только v2 (memory.max), v1 не работает на kernel 6.19
- **ollama CLI**: v0.18.0 требует OLLAMA_HOST=http://localhost:11434 в env

---

## 📁 Структура /ai

```
/ai/
├── db/           # все БД (routing, tools, models, network, tokens, git_ops, project)
├── kombain/      # kombain_local.db + planner_cache
├── scripts/      # Python скрипты и bash утилиты
├── tools/        # router.sh и другие инструменты
├── models/       # ollama модели
├── data/cache/   # кэш классификатора, логи роутера
├── logs/         # agent.log, learning.log
├── backup/       # золотые бэкапы (chmod 444 root:root)
└── workspace/    # рабочее пространство
```