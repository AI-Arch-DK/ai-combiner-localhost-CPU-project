# 🗺️ ROADMAP — AI-Combiner v4+
> Стратегический план развития | Обновлён: 2026-04-08
> Ветка разработки: `dev/ollama-cpu-optimized`

---

## Статус текущей версии v4.1

| Компонент | Статус | Версия | Коммит |
|-----------|--------|--------|--------|
| Ollama CPU оптимизация | ✅ Готово | systemd drop-in | — |
| router.sh | ✅ Готово | v2 curl API | — |
| agent.py | ✅ Готово | v1 (7 tools) | — |
| FTS индексы всех БД | ✅ Готово | 27 индексов | — |
| CD GitHub Actions | ✅ Готово | tag-based release | — |
| **validate_sqlmini.py** | ✅ Готово | whitelist+batch+FTS | 7c42d9e |
| **hf_sqlmini.py** | ✅ Готово | Llama-3.1-8B cerebras | 7c42d9e |
| **distill_session.py** | ✅ Готово | Фаза 0 базовая | 7c42d9e |
| **enrich_topic.py v2** | ✅ Готово | tavily→sqlmini pipeline | 738fd31 |
| ChromaDB vector layer | ❌ Не начато | — | — |
| Дистилляция чата (полная) | 🔶 Частично | claude_sessions пустые | — |
| bg_worker v2 | 🔶 Частично | нет tick/budget | — |
| **Gemma 4 как дистиллятор** | 🔶 Нужно | сейчас Llama-3.1-8B | — |
| asyncio agent v2 | ❌ Не начато | — | — |
| Dream System | ❌ Не начато | — | — |

---

## 🎯 ФАЗА 0 — Дистилляция чата
> **Статус:** 🔶 Частично (distill_session.py есть, claude_sessions пустые)

### Что сделано
- [x] `distill_session.py` — базовый дистиллятор сессий
- [x] `validate_sqlmini.py` — валидация + execute + batch
- [x] `hf_sqlmini.py` — HF как sqlmini движок

### Что осталось
- [ ] Механизм захвата transcript → `claude_sessions`
- [ ] Добавить `claude_sessions` в `ALLOWED_TABLES` validate_sqlmini.py
- [ ] Переключить `hf_sqlmini.py` на **Gemma 4 E2B** (сейчас Llama-3.1-8B)
- [ ] Добавить прокси `127.0.0.1:2080` в urllib запросы (сейчас нет)
- [ ] `claude_memory.sh` — переписать с вызовом distill_session.py

### Архитектура
```
transcript → чанки 600 токенов
    ↓
hf_sqlmini (Gemma 4 E2B, 128K ctx, 2.3B активных)
    ↓
validate_sqlmini → execute → claude_memory + FTS
```

---

## 🎯 ФАЗА 1 — sqlmini везде
> **Статус:** ✅ Ядро готово | 🔶 Интеграция в агент/роутер не завершена

### Что сделано
- [x] `validate_sqlmini.py` — полноценная утилита с тестами
- [x] `hf_sqlmini.py` — HF distiller
- [x] `enrich_topic.py v2` — полный pipeline tavily→hf_sqlmini→validate→SQLite

### Что осталось
- [ ] `agent.py` v2: `save_result()` → через `execute_sqlmini()`
- [ ] `night_learning_v2.py`: Dream фазы + qwen→sqlmini вместо текста
- [ ] `router.sh` v3: routing_log через sqlmini
- [ ] Переключить `hf_sqlmini.py` с Llama → **Gemma 4 E2B**

### Критический баг — прокси
```python
# hf_sqlmini.py и enrich_topic.py используют urllib без прокси
# На этой системе нужен 127.0.0.1:2080 для внешних запросов
# Fix:
import urllib.request
proxy = urllib.request.ProxyHandler({'https': 'http://127.0.0.1:2080'})
opener = urllib.request.build_opener(proxy)
urllib.request.install_opener(opener)
```

---

## 🎯 ФАЗА 2 — Python asyncio + Coordinator
> **Статус:** ❌ Не начато

### Что нужно сделать
- [ ] `agent_v2.py`: `asyncio.gather()` для независимых tools
- [ ] `bg_worker_v2.py`: tick=300s, budget=15s, brief mode
- [ ] Append-only daily logs: `/ai/logs/worker_YYYY-MM-DD.log`
- [ ] Coordinator паттерн (из claurst): Research → Synthesis → sqlmini

### Параллельная архитектура
```python
# Было (~90s линейно):       # Стало (~35s параллельно):
step1: search_kb              results = await asyncio.gather(
step2: search_net                 search_knowledge(task),
step3: tavily                     search_network(task),
                                  tavily(task)
                              )
```

---

## 🎯 ФАЗА 3 — ChromaDB векторный слой
> **Статус:** ❌ Не начато (папка `/ai/skills/vector/` пустая)

### Что нужно сделать
- [ ] `pip install chromadb --break-system-packages`
- [ ] `ollama pull nomic-embed-text` (274MB, CPU)
- [ ] Перенести `qwen_knowledge` (120 записей) → Chroma
- [ ] Коллекции: `qwen_knowledge`, `claude_memory`, `best_practices`
- [ ] `agent_v2.py`: `search_knowledge` → Chroma semantic search
- [ ] FTS остаётся как keyword fallback

### Чанкинг под Gemma 4
```python
CHUNK_SIZE = 600    # токенов (Gemma 4 держит 128K)
OVERLAP    = 0.15   # 15% = ~90 токенов
# Порядок: заголовки (##/###) → recursive split
```

---

## 🎯 ФАЗА 4 — Dream System
> **Статус:** ❌ Не начато (паттерн из Claude Code claurst)

### Три-гейт триггер
```python
def should_dream():
    return (
        hours_since_last_run() >= 8 and
        sessions_since_last_run() >= 3 and
        acquire_lock("/ai/data/cache/dream.lock")
    )
```

### Четыре фазы
| Фаза | Модель | Задача |
|------|--------|--------|
| Orient | qwen 7b локально | check_resources + FTS статус |
| Gather | qwen 7b локально | новое в network.db + workflows |
| Consolidate | **Gemma 4 26B-A4B** HF | sqlmini INSERT, 4B активных, 256K ctx |
| Prune | qwen 7b локально | дубли удалить, < 150/topic |

---

## 🎯 ФАЗА 5 — System Prompt модуляризация
> **Статус:** ❌ Не начато (паттерн из Claude Code)

```
STATIC  → кэш: роли инструментов, fallback цепочки
DYNAMIC → из БД каждую сессию: check_resources, топ-3 claude_memory, workflows
```

---

## 📊 Матрица моделей

| Задача | Модель | Где | Особенность |
|--------|--------|-----|-------------|
| Классификация/роутинг | qwen2.5:7b | Локально | 6.6 tok/s CPU |
| sqlmini дистилляция | ~~Llama-3.1-8B~~ → **Gemma 4 E2B** | HF cerebras | 2.3B активных, 128K |
| Dream Consolidate | **Gemma 4 26B-A4B** | HF cerebras | MoE 4B из 26B, 256K |
| Оркестрация | Claude Desktop | MCP | — |
| Embeddings | nomic-embed-text | Ollama локально | 274MB CPU |
| Аудио (будущее) | Gemma 4 E4B | HF cerebras | 128K + audio |

---

## 🔧 Технический долг (обновлено 2026-04-08)

| Задача | Приоритет | Фаза | Примечание |
|--------|-----------|------|------------|
| Прокси в hf_sqlmini + enrich_topic | 🔴 | 0,1 | urllib без 127.0.0.1:2080 |
| Gemma 4 E2B вместо Llama-3.1-8B | 🔴 | 0,1 | сменить модель в hf_sqlmini.py |
| claude_sessions захват transcript | 🔴 | 0 | механизм не реализован |
| claude_sessions в ALLOWED_TABLES | 🟡 | 0 | validate_sqlmini.py |
| claude_memory.sh переписать | 🟡 | 0 | вызывать distill_session.py |
| agent.py → execute_sqlmini | 🟡 | 1 | убрать прямой INSERT |
| ChromaDB + nomic-embed-text | 🟡 | 3 | /ai/skills/vector/ пустая |
| bg_worker_v2 tick+budget | 🟢 | 2 | — |
| Dream System | 🟢 | 4 | — |

---

## 📚 Источники

- [Gemma 4 E2B-it](https://huggingface.co/google/gemma-4-E2B-it) — 2.3B активных, 128K, audio
- [Gemma 4 26B-A4B-it](https://huggingface.co/google/gemma-4-26B-A4B-it) — MoE 4B из 26B, 256K
- [claurst](https://github.com/Kuberwastaken/claurst) — Dream, KAIROS, Coordinator паттерны
- [INSTALL_OLLAMA.md](docs/INSTALL_OLLAMA.md) — установка
- [BOARD_REPORT.md](docs/BOARD_REPORT.md) — состояние системы
