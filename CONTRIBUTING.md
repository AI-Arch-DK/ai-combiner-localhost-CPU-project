# 🤝 Contributing to AI-Combiner

## Ветки разработки

| Ветка | Назначение | Статус |
|-------|------------|--------|
| `main` | Стабильная версия | ✅ |
| `dev/ollama-cpu-optimized` | Текущая разработка v4+ | 🔶 Активна |
| `dev/gemma4-distill` | Фаза 0: sqlmini дистилляция | 📋 Планируется |
| `dev/async-agent` | Фаза 2: asyncio агент | 📋 Планируется |
| `dev/chroma-vector` | Фаза 3: ChromaDB | 📋 Планируется |

## Как контрибьютить

1. Fork → ветка от `dev/ollama-cpu-optimized`
2. Железо: Linux x86_64, AVX2, 12GB+ RAM
3. Установка: `bash docs/INSTALL_OLLAMA.md`
4. Проверка: `bash /ai/scripts/check_resources.sh`
5. PR → в `dev/ollama-cpu-optimized`

## Соглашения по коду

- **Python**: async-first, sqlmini для записи в БД (не JSON)
- **Bash**: curl вместо ollama CLI
- **Конфиги**: только через `config.env`, не хардкодить ключи
- **Секреты**: `sanitize_before_push()` перед любым коммитом
- **Логи**: append-only, `/ai/logs/`, формат `[YYYY-MM-DD HH:MM:SS] msg`
- **БД**: INSERT через `validate_sqlmini()`, не прямые f-строки

## sqlmini стандарт (обязательно)

```python
# ПРАВИЛЬНО — через validate_sqlmini
from scripts.validate_sqlmini import execute_sqlmini
execute_sqlmini("INSERT INTO qwen_knowledge(topic,title,content) VALUES(?,?,?)", params)

# НЕПРАВИЛЬНО — прямые INSERT с f-строками
con.execute(f"INSERT INTO qwen_knowledge ... '{user_input}'")
```

## Приоритетные задачи для контрибьюторов

См. [ROADMAP.md](ROADMAP.md) раздел **Технический долг**.

Первые задачи (`good-first-issue`):
- `validate_sqlmini.py` — создать общую утилиту (ФАЗА 1)
- `nomic-embed-text` — установить и протестировать throughput на i7-8565U
- ChromaDB — базовая коллекция из `qwen_knowledge`

## Тестирование перед PR

```bash
# Проверка системы
bash /ai/scripts/check_resources.sh

# Проверка enrich pipeline
python3 /ai/scripts/enrich_topic.py mikrotik

# Проверка FTS индексов
bash /ai/scripts/qwen_index_agent.sh

# Ollama benchmark
curl -s -X POST http://localhost:11434/api/generate \
  -d '{"model":"qwen2.5:7b-instruct-q4_K_M","prompt":"test","stream":false}' \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'{d[\"eval_count\"]/d[\"eval_duration\"]*1e9:.1f} tok/s')"
```
