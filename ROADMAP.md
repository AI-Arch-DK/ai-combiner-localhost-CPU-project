# 🗺️ ROADMAP — AI-Combiner v4+
> Стратегический план развития | Обновлён: 2026-04-06
> Ветка разработки: `dev/ollama-cpu-optimized`

---

## Статус текущей версии v4.0

| Компонент | Статус | Версия |
|-----------|--------|--------|
| Ollama CPU оптимизация | ✅ Готово | systemd drop-in |
| router.sh | ✅ Готово | v2 curl API |
| agent.py | ✅ Готово | v1 (7 tools) |
| Night learning enrich | ✅ Готово | enrich_topic.py atomic |
| FTS индексы | ✅ Готово | 27 индексов по всем БД |
| CD GitHub Actions | ✅ Готово | .github/workflows/cd-release.yml |
| ChromaDB vector layer | ❌ Не начато | — |
| Дистилляция чата | 🔶 Частично | index_chat_context.py |
| bg_worker | 🔶 Частично | v1 примитивный |
| sqlmini везде | 🔶 Частично | validate_sqlmini.py pending |
| Gemma 4 интеграция | ❌ Не начато | — |

---

## 🎯 ФАЗА 0 — Дистилляция чата (ПРИОРИТЕТ)
> **Цель:** Claude Desktop помнит предыдущие сессии через sqlmini

### Что нужно сделать
- [ ] Изучить и переписать `claude_memory.sh` с sqlmini выводом
- [ ] Реализовать захват `claude_sessions` по завершении сессии
- [ ] Создать `validate_sqlmini.py` — общая утилита валидации SQL
- [ ] Интегрировать Gemma 4 E2B как дистиллятор (HF cerebras)
- [ ] Чанкинг сессий (500-800 токенов, Gemma 4 поддерживает 128K ctx)

### Архитектура дистилляции
```
Завершение сессии Claude Desktop
    ↓
claude_memory.sh: собрать transcript → чанки 600 токенов
    ↓
Gemma 4 E2B (HF cerebras, 2.3B активных, БЫСТРО):
  SYSTEM: "Ответь ТОЛЬКО SQL:
  INSERT INTO claude_memory(key,category,title,content,tags,importance)
  VALUES(...); — max 60 токенов"
    ↓
validate_sqlmini.py → execute → FTS rebuild
```

### Модели для дистилляции
| Задача | Модель | Ctx | Скорость |
|--------|--------|-----|----------|
| Быстрая дистилляция | Gemma 4 E2B-it | 128K | Быстро |
| Мета-дистилляция (еженедельно) | Gemma 4 26B-A4B-it | 256K | 4B активных MoE |

---

## 🎯 ФАЗА 1 — sqlmini везде
> **Цель:** уйти от JSON к структурированным SQL командам

### Что нужно сделать
- [ ] `validate_sqlmini.py`: parse → schema_check → execute → fts_rebuild
- [ ] `night_learning_v2.py`: Dream фазы + sqlmini вывод от qwen
- [ ] `agent.py` v2: save_result через sqlmini вместо прямого INSERT
- [ ] `router.sh` v3: routing_log через sqlmini утилиту

### Экономия токенов
```
Сейчас:  qwen → 150-250 токенов JSON текста → парсинг → INSERT
Цель:    Gemma 4 E2B → 60 токенов SQL → validate → execute
Экономия: ~70% токенов на запись в KB
```

### sqlmini промпт шаблон
```python
SQLMINI_SYSTEM = """Ответь ТОЛЬКО одной SQL командой. Без текста. Без markdown.
Формат: INSERT INTO kb_facts(topic,fact,tags,confidence) VALUES('...','...','...', 0.9);
Максимум 2 строки. ~60 токенов."""

def validate_sqlmini(response: str) -> bool:
    return response.strip().upper().startswith("INSERT INTO")
```

---

## 🎯 ФАЗА 2 — Python asyncio + Coordinator
> **Цель:** параллельные workers вместо линейного агента (паттерн из Claude Code)

### Что нужно сделать
- [ ] `agent_v2.py`: `asyncio.gather()` для независимых tools
- [ ] `bg_worker_v2.py`: tick=300s, budget=15s, brief mode (num_predict=30)
- [ ] Append-only daily logs: `/ai/logs/worker_YYYY-MM-DD.log`
- [ ] Coordinator паттерн: Research → Synthesis → sqlmini Execute

### Параллельная архитектура
```python
# Было (линейно, ~90s):    # Стало (параллельно, ~35s):
step1: search_kb           results = await asyncio.gather(
step2: search_net              search_knowledge(task),
step3: tavily                  search_network(task),
                               tavily(task)
                           )
```

---

## 🎯 ФАЗА 3 — ChromaDB векторный слой
> **Цель:** семантический поиск вместо keyword FTS

### Что нужно сделать
- [ ] `pip install chromadb --break-system-packages`
- [ ] `ollama pull nomic-embed-text` (274MB, CPU efficient)
- [ ] Перенести `qwen_knowledge` → Chroma коллекция
- [ ] Коллекции: `qwen_knowledge`, `claude_memory`, `best_practices`
- [ ] Обновить `agent_v2.py`: `search_knowledge` → Chroma semantic

### Чанкинг под Gemma 4
```python
CHUNK_SIZE = 600    # токенов (Gemma4 держит 128K → большие чанки)
OVERLAP    = 0.15   # 15% перекрытие
# Сначала по заголовкам (## / ###), потом recursive split
```

---

## 🎯 ФАЗА 4 — Dream System
> **Цель:** автоматическая консолидация памяти (паттерн из Claude Code claurst)

### Три-гейт триггер
```python
def should_dream():
    return (
        hours_since_last_run() >= 8 and
        sessions_since_last_run() >= 3 and
        acquire_lock("/ai/data/cache/dream.lock")
    )
```

### Четыре фазы с матрицей моделей
| Фаза | Модель | Задача |
|------|--------|--------|
| Orient | qwen 7b локально | check_resources + FTS статус БД |
| Gather | qwen 7b локально | новое в network.db + workflows |
| Consolidate | Gemma 4 26B-A4B HF | sqlmini INSERT, 4B активных, высокое качество |
| Prune | qwen 7b локально | дубли удалить, < 150/topic, MEMORY.md < 25KB |

---

## 🎯 ФАЗА 5 — System Prompt модуляризация
> **Цель:** статический кэш + динамический контекст из БД (паттерн из Claude Code)

### Static/Dynamic boundary
```
STATIC (кэш, редко меняется):
  - Роли инструментов и алгоритм роутинга
  - Fallback цепочки
  - Undercover patterns для git (sanitize_before_push)

DYNAMIC (загружается из БД каждую сессию):
  - check_resources результат (30 слов)
  - Топ-3 claude_memory факта из дистилляции
  - Активные workflows
```

### Undercover Mode (из claurst)
```python
UNDERCOVER_PATTERNS = [
    r'tvly-[a-zA-Z0-9]+',       # Tavily ключи
    r'hf_[a-zA-Z0-9]+',         # HF токены
    r'github_pat_[a-zA-Z0-9]+', # GitHub PAT
    r'192\.168\.\d+\.\d+',     # внутренние IP
]
```

---

## 📊 Матрица моделей

| Задача | Модель | Где | Особенность |
|--------|--------|-----|-------------|
| Классификация/роутинг | qwen2.5:7b | Локально | 6.6 tok/s CPU |
| sqlmini дистилляция | Gemma 4 E2B-it | HF cerebras | 2.3B активных, быстро |
| Сложный анализ / Consolidate | Gemma 4 26B-A4B-it | HF cerebras | MoE 4B активных из 26B, 256K ctx |
| Оркестрация | Claude Desktop | MCP | Все инструменты |
| Embeddings | nomic-embed-text | Локально Ollama | 274MB, CPU |
| Аудио input (будущее) | Gemma 4 E4B-it | HF cerebras | 128K + AUDIO |

---

## 🔧 Технический долг

| Задача | Приоритет | Фаза |
|--------|-----------|------|
| `claude_memory.sh` — переписать с sqlmini | 🔴 | 0 |
| `validate_sqlmini.py` — создать утилиту | 🔴 | 0, 1 |
| `claude_sessions` — механизм захвата | 🔴 | 0 |
| Gemma 4 E2B — протестировать как sqlmini дистиллятор | 🟡 | 0 |
| `nomic-embed-text` в ollama | 🟡 | 3 |
| ChromaDB установка | 🟡 | 3 |
| `bg_worker_v2.py` tick+budget+brief | 🟡 | 2 |
| System prompt модуляризация | 🟢 | 5 |

---

## 📚 Источники и ссылки

- [Gemma 4 E2B-it](https://huggingface.co/google/gemma-4-E2B-it) — быстрый дистиллятор
- [Gemma 4 26B-A4B-it](https://huggingface.co/google/gemma-4-26B-A4B-it) — MoE, 4B активных
- [claurst](https://github.com/Kuberwastaken/claurst) — Claude Code паттерны (Dream, KAIROS, Coordinator)
- [INSTALL_OLLAMA.md](docs/INSTALL_OLLAMA.md) — установка и оптимизация
- [BOARD_REPORT.md](docs/BOARD_REPORT.md) — текущее состояние системы
