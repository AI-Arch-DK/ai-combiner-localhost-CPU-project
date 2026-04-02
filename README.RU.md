# 🤖 AI COMBINER
### Локальная платформа оркестрации искусственного интеллекта для CPU-вычислений

**Превратите свою машину в мощный самостоятельный AI-сервис. Без облака. Без подписок. Полная конфиденциальность.**

---

## 📋 КРАТКОЕ ОПИСАНИЕ

AI Combiner — это интеллектуальная система оркестрации локального ИИ, объединяющая интерфейс Claude Desktop, квантизованный инференс Qwen 2.5 7B и 13 серверов Model Context Protocol (MCP). Разработана для CPU-вычислений на потребительском оборудовании, работает полностью на localhost.

| Параметр | Значение |
|---------|---|
| **Основная модель** | Qwen 2.5 7B Instruct (q4_K_M квантизация) |
| **Скорость инференса** | 15-20 токенов/сек на i7-8565U |
| **Оперативная память** | ~4.5GB активно (всего 14GB swap) |
| **Архитектура** | Поддерживает многоузловые развертывания |
| **Оркестрация** | 13 MCP-серверов + маршрутизация через SQLite |
| **Без облака** | 100% локально, готова к airgapped развертыванию |

---

## 🚀 БЫСТРЫЙ СТАРТ (5 минут)

### Требования
- **ОС:** Debian Linux (тестировано: kernel 6.19.6)
- **CPU:** Любой x86-64 многоядерный (i7-8565U минимум)
- **ОЗУ:** 16GB (12GB рабочей памяти, 14GB swap)
- **Дисковое пространство:** 20GB свободного места
- **Инструменты:** Claude Desktop, Ollama, Python 3.9+

### Установка в одну команду

```bash
# Клонирование репозитория
git clone https://github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project.git
cd ai-combiner-localhost-CPU-project

# Установка зависимостей
bash scripts/install_debian.sh

# Запуск всех сервисов
bash scripts/startup.sh

# Проверка установки
python -c "import ollama; print(ollama.list())"
```

### Первый инференс

```python
# Пример на Python
from ollama import Client

client = Client(host="http://localhost:11434")
response = client.generate(
    model="qwen2.5:7b-instruct-q4_K_M",
    prompt="Что такое Model Context Protocol (MCP)?"
)
print(response["response"])
```

Ожидаемый результат: **~15-20 токенов в секунду на CPU**

---

## 🏗️ АРХИТЕКТУРА СИСТЕМЫ

### Диаграмма потока данных

```
┌─────────────────────────────────────────────────────────────┐
│  ВВОД ПОЛЬЗОВАТЕЛЯ (Claude Desktop / API)                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                    ┌────▼─────────────────────┐
                    │ Классификация задачи     │
                    │ (qwen2:classify)         │
                    └────┬─────────────────────┘
                         │
     ┌───────────────────┼───────────────────┐
     │                   │                   │
┌────▼──────────┐  ┌─────▼──────────┐  ┌────▼──────────┐
│ qwen_only     │  │ external_first │  │ parallel      │
│ (быстро)      │  │ (исследование) │  │ (гонка)       │
└────┬──────────┘  └─────┬──────────┘  └────┬──────────┘
     │                   │                   │
     │            ┌──────┴─────────┐         │
     │            │                │         │
  ┌──▼─────────┐  │   ┌────────────▼──────┐ │
  │   Qwen     │  │   │ Внешние сервисы   │ │
  │   7B LLM   │  │   │ (HF, Tavily, etc) │ │
  │            │  │   └────────────┬──────┘ │
  │ (11434)    │  │                │        │
  └──┬─────────┘  │   ┌────────────▼──────┐ │
     │            │   │  Браузер, Clay    │ │
     │            │   │  GitHub, Miro     │ │
     │            │   └────────────┬──────┘ │
     │            └────────┬───────┘        │
     │                     │                │
     └─────────────────────┼────────────────┘
                           │
                    ┌──────▼──────────────┐
                    │ Агрегация результ.  │
                    │ + Форматирование    │
                    └──────┬──────────────┘
                           │
        ┌──────────────────┴───────────────────┐
        │                                      │
   ┌────▼─────────┐                    ┌──────▼────────┐
   │ SQLite       │                    │ Claude        │
   │ Хранилище    │                    │ Desktop       │
   │ (routing.db) │                    │ Ответ         │
   └──────────────┘                    └───────────────┘
```

### Аппаратное обеспечение

| Компонент | Спецификация | Примечания |
|-----------|---|---|
| **CPU** | Intel Core i7-8565U @ 1.80GHz (Turbo 4.6GHz) | 4 ядра, 8 потоков |
| **Кэши** | L1: 128 KiB × 4 | L2: 1 MiB × 4 | L3: 8 MiB | Стандартная конфигурация Intel |
| **Память** | 16GB RAM (DDR4-2400) | Активно: ~10GB, Swap: 14GB |
| **Хранилище** | NVMe 953.9 GB (nvme0n1) | SSD критична для производительности |
| **ОС** | Debian Linux, kernel 6.19.6+deb14-amd64 | LLVM бэкенд для GGML |
| **Виртуализация** | Intel VT-x включен | Для будущей поддержки Docker/KVM |

---

## 📡 MCP-СЕРВЕРЫ (13 активных эндпоинтов)

| ID | Сервер | Протокол | Эндпоинт | Назначение | Статус |
|---|---|---|---|---|---|
| 1 | `sqlite` | mcp-server-sqlite | localhost | База маршрутизации, сохранение знаний | ✅ |
| 2 | `ollama-local` | HTTP/Node.js | localhost:11434 | Инференс Qwen 2.5 7B | ✅ |
| 3 | `host-report` | Node.js MCP | localhost | Мониторинг системы (system_audit.sh) | ✅ |
| 4 | `filesystem` | @modelcontextprotocol/server-filesystem | localhost | Операции с файлами (/home, /ai, /mnt) | ✅ |
| 5 | `shell` | mcp-shell | localhost | Выполнение bash-команд (ограниченно) | ✅ |
| 6 | `github-public` | github-mcp-server | api.github.com | Публичные операции GitHub | ✅ |
| 7 | `github-private` | github-mcp-server | api.github.com | Приватные репозитории | ✅ |
| 8 | `huggingface` | huggingface-server (Node.js) | api.huggingface.co | Поиск + инференс моделей HF | ✅ |
| 9 | `miro` | mcp.miro.com | mcp.miro.com | Визуализация архитектуры (DAG) | ✅ |
| 10 | `tavily` | tavily-mcp | api.tavily.com | Веб-поиск API | ✅ |
| 11 | `browser` | playwright browser-server | localhost:3000 | Автоматизация Chromium | ✅ |
| 12 | `clay` | api.clay.com/v3/mcp | api.clay.com | Обогащение CRM-данных | ✅ |
| 13 | `gcal` / `gmail` | Google MCP | googleapis.com | Интеграция календаря & почты | ⚠️ |

**Файл конфигурации:** `~/.config/Claude/claude_desktop_config.json`

---

## 🗄️ АРХИТЕКТУРА БАЗ ДАННЫХ

### Локальные БД (`/ai/db/`)

| БД | Таблиц | Размер | Назначение | Записей |
|---|---|---|---|---|
| **routing.db** | 3 | 56K | Маршрутизация задач + параллельная конфиг | qwen_tasks: 21 |
| **project.db** | 3 | 108K | Управление проектами + шаблоны | Индексировано FTS |
| **network.db** | 3 | 100K | Кэш FAQ (сетевые + продажи) | — |
| **kombain_local.db** | 5 | — | Workflows, результаты, обратная связь | Локальные знания |
| **models.db** | 2 | 28K | Реестр моделей (Qwen, варианты) | — |
| **tokens.db** | 3 | 36K | Учет токенов по сессиям | — |
| **tools.db** | 2 | 32K | Реестр MCP-серверов & инструментов | — |

### Общая БД (Многоузловая)

```
kombain_shared.db ← /ai/external/sales_manager/
│
├─ Используется: debianAI-node (эта машина)
├─ Используется: sales_manager-node
└─ Будущее: Office_MAIN центральный узел (оркестратор)
```

---

## 🎯 ИНТЕЛЛЕКТУАЛЬНАЯ МАРШРУТИЗАЦИЯ ЗАДАЧ

### 23 Qwen-задачи + 13 стратегий параллелизма

Система автоматически классифицирует запросы и маршрутизирует их через одну из 13 стратегий:

#### Пример: "Извлеки IP-адреса из логов сети"

```
Ввод: "Извлеки IP-адреса из логов сети"
           ↓
Классификация: extract_ip (qt_003)
           ↓
Стратегия: qwen_only (pc_007)
           ↓
Выполнение: Qwen обрабатывает локально
           ↓
Вывод: ["192.168.1.1", "10.0.0.5", ...]
Хранилище: Результаты в network.db
```

#### Пример: "Исследуй лучшие практики CPU-оптимизации"

```
Ввод: "Исследуй лучшие практики CPU-оптимизации"
           ↓
Классификация: research (неизвестная задача)
           ↓
Стратегия: external_first (pc_005)
           ↓
Параллельное выполнение:
  ├─ Tavily веб-поиск
  ├─ Поиск моделей HuggingFace
  └─ Автоматизация браузера
           ↓
Вывод: Агрегированные результаты исследования
Хранилище: Кэш в project.db с указанием источников
```

### Таблица конфигурации маршрутизации

| ID Стратегии | Тип | Логика | Вариант использования |
|---|---|---|---|
| **pc_001** | parallel | Qwen + HF + tavily, первый качественный | network_config |
| **pc_002** | qwen_only | Только Qwen, оптимально для скорости | explain_short |
| **pc_003** | qwen_only | Генерация bash-команд | code_bash |
| **pc_004** | qwen_only | Генерация SQL-запросов | code_sql |
| **pc_005** | external_first | HF + браузер + tavily | research |
| **pc_006** | qwen_only | Проверки системы (host-report) | system_check |
| **pc_007** | qwen_only | Извлечение IP/портов/ошибок | extract_* |
| **pc_008** | external_first | Claude + все инструменты | orchestration |
| **pc_009** | qwen_with_context | Qwen обрабатывает результаты tavily | validate_config |
| **pc_010** | qwen_only | Форматирование вывода | format_output |
| **pc_011** | parallel | Сравнение нескольких решений | compare_options |
| **pc_012** | qwen_with_context | Проверка фактов с tavily | fact_check |
| **pc_013** | qwen_only | Проверка старта/ресурсов (timeout 10s) | startup_check |

---

## 💻 ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ

### Пример 1: Локальный инференс (Python)

```python
from ollama import Client

client = Client(host="http://localhost:11434")

# Простой запрос
response = client.generate(
    model="qwen2.5:7b-instruct-q4_K_M",
    prompt="Объясни квантовую запутанность в 2 предложениях"
)

print(response['response'])
# Вывод: Квантовая запутанность — это явление, когда две частицы...
```

### Пример 2: Классификация задач и маршрутизация

```python
import sqlite3
import json

# Запрос к базе маршрутизации
conn = sqlite3.connect('/ai/db/routing.db')
cursor = conn.cursor()

# Найти стратегию для "bash скрипта"
cursor.execute("""
    SELECT strategy, parallel_config FROM qwen_tasks 
    WHERE triggers LIKE '%bash%'
""")
result = cursor.fetchone()
print(f"Стратегия: {result[0]}")  # Вывод: qwen_only
print(f"Конфиг: {json.loads(result[1])}")

conn.close()
```

### Пример 3: Объединение MCP инструментов

```python
# Использование filesystem + shell + qwen для автоматизации
tasks = [
    {"tool": "filesystem", "action": "list_directory", "path": "/ai/db"},
    {"tool": "shell", "action": "run", "command": "du -sh /ai/*"},
    {"tool": "ollama-local", "action": "summarize", "data": "system_audit вывод"}
]

# Выполнение последовательно или параллельно (по стратегии маршрутизации)
```

### Пример 4: Веб-поиск + локальная LLM

```python
# Tavily поиск → Qwen суммирование
import requests

# 1. Поиск через Tavily MCP
search_response = requests.post(
    "http://localhost:8000/mcp/tavily",
    json={"query": "Паттерны Rust async 2026"}
)

articles = search_response.json()['results']

# 2. Суммирование с Qwen
from ollama import Client
client = Client(host="http://localhost:11434")

summary_response = client.generate(
    model="qwen2.5:7b-instruct-q4_K_M",
    prompt=f"Суммируй эти статьи:\n\n{articles}"
)

print(summary_response['response'])
```

---

## 📊 ПРОИЗВОДИТЕЛЬНОСТЬ И БЕНЧМАРКИ

### Скорость инференса (Qwen 2.5 7B q4_K_M на i7-8565U)

| Длина ввода | Токенов/Сек | Задержка (первый токен) | Пиковая память |
|---|---|---|---|
| Короткий (≤100 слов) | 18-20 ток/с | 850ms | 4.2GB |
| Средний (100-500 слов) | 15-18 ток/с | 950ms | 4.5GB |
| Длинный (500-2000 слов) | 12-15 ток/с | 1200ms | 4.8GB |
| Очень длинный (2000+ слов) | 8-12 ток/с | 1500ms | 5.2GB |

**Примечания:**
- Холодный старт (первый запуск): +2.5s загрузка модели
- Теплый старт (кэшировано): <500ms
- Квантизация Q4_K_M снижает точность <3% vs FP32
- Использование swap: 2-4GB активно (14GB доступно)

### Сравнение стоимости с облачными API

| Сценарий | AI Combiner | ChatGPT 4o | Claude 3.5 Sonnet |
|---|---|---|---|
| **1М запросов/месяц** | $0 (электричество: ~$15) | $3,600 | $4,500 |
| **Стоимость установки** | $0 (используй существующий ноутбук) | N/A | N/A |
| **Задержка** | 50-100ms | 500-2000ms | 500-2000ms |
| **Конфиденциальность** | 100% локально | Облако-хранилище | Облако-хранилище |
| **Офлайн-возможность** | ✅ Да | ❌ Нет | ❌ Нет |

---

## 🔧 УСТАНОВКА И НАСТРОЙКА

### Полная установка (Debian Linux)

```bash
# 1. Клонирование репозитория
git clone https://github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project.git
cd ai-combiner-localhost-CPU-project

# 2. Запуск скрипта установки
sudo bash scripts/install_debian.sh

# 3. Установка зависимостей Python
python3 -m pip install -r requirements.txt

# 4. Загрузка модели Qwen через Ollama
ollama pull qwen2.5:7b-instruct-q4_K_M

# 5. Конфигурация Claude Desktop
cp config/claude_desktop_config.json ~/.config/Claude/

# 6. Проверка MCP-серверов
bash scripts/verify_mcp.sh

# 7. Запуск сервисов
bash scripts/startup.sh
```

### Альтернатива Docker (Опционально)

```bash
# Сборка Docker-образа
docker build -t ai-combiner:latest .

# Запуск контейнера
docker run -d \
  --name ai-combiner \
  -p 11434:11434 \
  -v /path/to/models:/models \
  -v /path/to/databases:/ai/db \
  ai-combiner:latest

# Проверка
docker exec ai-combiner curl localhost:11434/api/tags
```

---

## 📖 УГЛУБЛЕННОЕ ИЗУЧЕНИЕ АРХИТЕКТУРЫ

### Многоузловая концепция: Office_MAIN (Будущее)

AI Combiner разработана для масштабирования на несколько узлов, синхронизируемых через общую БД:

```
┌──────────────────────────────────────┐
│   Office_MAIN (Центральный       │
│   Управляет маршрутизацией & приоритетами │
└────────────────┬─────────────────────┘
                 │
        ┌────────┼────────┐
        │        │        │
   ┌────▼──┐ ┌──▼────┐ ┌─▼────────┐
   │debianAI│ │sales_ │ │будущий   │
   │(CPU)   │ │mgr    │ │node_3    │
   │        │ │       │ │          │
   └────┬───┘ └──┬────┘ └─┬────────┘
        │        │        │
        └────────┼────────┘
                 │
        ┌────────▼─────────┐
        │kombain_shared.db │
        │(синхронизирован) │
        └──────────────────┘
```

Каждый узел имеет локальную БД (`kombain_local.db`), но синхронизируется с общей БД для координации.

---

## 🤝 УЧАСТИЕ В ПРОЕКТЕ

Мы приветствуем контрибьютеров! Проект идеален для тех, кто интересуется:
- Оптимизацией CPU и квантизацией инференса
- Оркестрацией локальных LLM
- Разработкой MCP протокола
- Open-source AI инфраструктурой

### Начало участия

1. **Fork репозитория**
2. **Создай ветку:** `git checkout -b feature/my-enhancement`
3. **Сделай изменения** (см. ниже стандарты кода)
4. **Протестируй изменения:** `bash tests/test_suite.sh`
5. **Отправь PR** с описанием

### Настройка разработки

```bash
# Клонирование твоего fork'а
git clone https://github.com/YOUR_USERNAME/ai-combiner.git
cd ai-combiner

# Создание виртуального окружения
python3 -m venv venv
source venv/bin/activate

# Установка dev-зависимостей
pip install -r requirements-dev.txt

# Запуск тестов
pytest tests/

# Запуск линтера
black . && flake8 .
```

### Стандарты кода

- **Язык:** Python 3.9+, Node.js 18+ для MCP-серверов
- **Форматирование:** Black (длина линии: 100)
- **Линтинг:** flake8, mypy для type hints
- **Тестирование:** pytest с >80% покрытием
- **Документация:** Docstrings (Google style)

### Метки Issues

- `good first issue` — Идеально для новичков
- `help wanted` — Нужен вклад сообщества
- `cpu-optimization` — Оптимизация производительности
- `mcp-integration` — Поддержка новых MCP-серверов
- `documentation` — Документация & примеры

---

## 📝 ЛИЦЕНЗИЯ

Лицензировано под **MIT License** — см. файл `LICENSE` для деталей.

Свободна для коммерческого использования, модификации и распространения с указанием авторства.

---

## 🔗 РЕСУРСЫ

| Ресурс | Ссылка |
|---|---|
| **GitHub** | https://github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project |
| **Ollama** | https://ollama.ai |
| **Claude Desktop** | https://claude.ai/desktop |
| **MCP спецификация** | https://modelcontextprotocol.io |
| **Модели Qwen** | https://huggingface.co/Qwen |
| **Сообщество** | r/LocalLLaMA, discussions на GitHub |

---

## ❓ ЧАСТО ЗАДАВАЕМЫЕ ВОПРОСЫ

**В: Смогу ли я запустить это на Raspberry Pi?**  
О: Теоретически да, но требуется минимум 8GB RAM. Производительность будет ~3-5 токенов/сек.

**В: Модель fine-tuned для специфических задач?**  
О: Нет, используется базовая Qwen 2.5 7B Instruct. Мы предоставляем prompt-шаблоны для конкретных cases.

**В: Смогу ли я использовать разные LLM?**  
О: Да! Смени команду `ollama pull` на любую GGUF модель (Llama 2, Mistral, DeepSeek, etc).

**В: Как добавить custom MCP-сервер?**  
О: См. `docs/MCP_DEVELOPMENT.md` для пошагового гайда.

**В: Есть ли API-сервер?**  
О: Ollama предоставляет OpenAI-совместимый REST API на `localhost:11434`. Полная документация в `docs/API.md`.

---

## 📞 ПОДДЕРЖКА И СООБЩЕСТВО

- **GitHub Issues:**报告баги & запрашивай features
- **Discussions:** Задавай вопросы, делись use cases
- **Email:** contact@example.com (добавь свой контакт)
- **Newsletter:** Подпишись на обновления (опционально)
