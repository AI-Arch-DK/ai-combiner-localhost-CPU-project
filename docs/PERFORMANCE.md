# Performance — Qwen 7B CPU benchmarks

## Тестовое железо

| Параметр | Значение |
|---|---|
| CPU | Intel Core i7-8565U @ 1.80GHz (boost 4.6GHz) |
| Ядра/Потоки | 4c / 8t |
| L3 cache | 8 MiB |
| RAM | 16 GB (модель занимает ~5-6 GB) |
| Модель | qwen2.5:7b-instruct-q4_K_M |
| Квантизация | Q4_K_M (4-bit mixed) |

## Замеры по таскам (CPU-only)

| qwen_task | max_tokens | ~время | Токенов/сек |
|---|---|---|---|
| qt_002 classify | 10 | ~2 сек | ~5 t/s |
| qt_006 count | 10 | ~2 сек | ~5 t/s |
| qt_003 extract_ip | 100 | ~8 сек | ~13 t/s |
| qt_013 explain_short | 100 | ~8 сек | ~13 t/s |
| qt_012 summarize | 150 | ~12 сек | ~13 t/s |
| qt_021 check_resources | 120 | ~10 сек | ~12 t/s |
| qt_007 mikrotik | 200 | ~16 сек | ~13 t/s |
| qt_015 validate_config | 200 | ~16 сек | ~13 t/s |

## Сравнение с HF Cerebras

| Модель | Токенов/сек | Стоимость |
|---|---|---|
| Qwen 7B (local) | ~13 t/s | бесплатно |
| Cerebras llama3.1-8b | ~500 t/s | бесплатно (лимит) |
| Claude Sonnet | быстро | $3/1M токенов |

## Стратегия токен-экономии

| Тип задачи | Модель | Обоснование |
|---|---|---|
| Извлечение, подсчёт | Qwen local | Быстро, бесплатно |
| Классификация | Qwen local | 10 токенов, ~2 сек |
| Сеть / исследования | Cerebras + tavily | Быстрый инференс + актуальность |
| bash/sql код | Claude DIRECT | Качество важнее скорости |
| Оркестрация | Claude | Только для сложных задач |

## Память при работе

```text
Базовая система: ~5 GB
Qwen модель:     ~5 GB
BD (все):       ~1 GB
Итого:          ~11 GB / 16 GB
Swap:           14 GB (резерв)

```text
