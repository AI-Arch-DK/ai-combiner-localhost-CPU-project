# Ollama Model Config — qwen2.5:7b-instruct-q4_K_M

## Параметры модели

| Параметр | Значение |
|---|---|
| Модель | qwen2.5:7b-instruct-q4_K_M |
| Семейство | qwen2 |
| Параметры | 7.6B |
| Квантизация | Q4_K_M (4-bit, mixed) |
| Размер файла | 4466 MB (~4.4 GB) |
| Context length | 32 768 токенов |
| Embedding length | 3 584 |
| Layers (blocks) | 28 |
| Attention heads | 28 |
| KV heads | 4 (GQA) |
| Порт | 11434 |

## Железо (рабочая node debianAI)

| Параметр | Значение |
|---|---|
| CPU | Intel Core i7-8565U @ 1.80GHz (boost 4.6GHz) |
| Ядра/Потоки | 4 ядра / 8 потоков |
| L3 кэш | 8 MiB |
| RAM | 16 GB (модель занимает ~5-6 GB) |
| Режим | CPU-only (нет GPU) |

## Производительность (CPU-only)

| Задача | Токены | Время |
|---|---|---|
| classify (qt_002) | 10 | ~2 сек |
| extract_ip (qt_003) | 100 | ~8 сек |
| explain_short (qt_013) | 100 | ~8 сек |
| summarize (qt_012) | 150 | ~12 сек |
| network_mikrotik (qt_007) | 200 | ~16 сек |
| system_check (qt_021) | 120 | ~10 сек |

## Настройка в claude_desktop_config.json

```json
"ollama-local": {
  "command": "node",
  "args": ["/path/to/ollama-server/server.js"],
  "env": {
    "OLLAMA_HOST": "http://localhost:11434",
    "OLLAMA_MODEL": "qwen2.5:7b-instruct-q4_K_M"
  }
}
```

## Запуск и управление

```bash
# Статус
systemctl --user status ollama

# Список моделей
curl http://localhost:11434/api/tags

# Тест
curl http://localhost:11434/api/generate -d '{"model":"qwen2.5:7b-instruct-q4_K_M","prompt":"ping","stream":false}'

# Скачать модель
ollama pull qwen2.5:7b-instruct-q4_K_M
```

## Роутинг токенов

- `qwen_only` стратегии: max_tokens 10–200, таймаут 10–60 сек
- `CLAUDE_DIRECT` маркеры (qt_019, qt_020): Qwen не вызывается, экономия ресурсов
- Среднее потребление RAM при работе: +5-6 GB к базовой загрузке
