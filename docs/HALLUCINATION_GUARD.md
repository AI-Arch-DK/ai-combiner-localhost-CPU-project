# Hallucination Guard — защита от галлюцинаций

## Уровни защиты

```
[Уровень 1] Промпт
  → Короткие промпты (max 50 слов)
  → "Отвечай только X, нет объяснений"
  → Указание ожидаемого формата

[Уровень 2] Параметры задачи
  → cancel_on_hallucination = 1
  → max_tokens ограничен (нет места для бреда)
  → max_wait_sec = 30–60

[Уровень 3] Детекция системой
  → qwen_dispatch → HALLUCINATION → qwen_cancel
  → Запрос перенаправляется во внешние инструменты

[Уровень 4] Кросс-проверка (validate_config)
  → Сначала tavily получает документацию
  → Qwen сравнивает свой ответ с документацией
  → Несовпадение → используется документация
```

## Признаки галлюцинации

| Симптом | Действие |
|---|---|
| Ответ длиннее max_tokens × 1.5 | qwen_cancel |
| Повторяет вопрос вместо ответа | qwen_cancel |
| Несуществующие команды/IP | qwen_cancel |
| Отвечает не на том языке | qwen_cancel |
| TIMEOUT + required=true | qwen_cancel → внешние |

## Оценка уверенности

```python
# Псевдокод (v0.4.0 plan)
def confidence_score(response, task_category):
    if task_category == 'extract_ip':
        # Проверка regex IP
        ips = re.findall(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', response)
        return 1.0 if ips else 0.0
    if task_category == 'count':
        # Ответ должен быть числом
        return 1.0 if response.strip().isdigit() else 0.0
    if task_category == 'classification':
        valid = ['network_config','code_generation','system_check','database','orchestration']
        return 1.0 if response.strip().lower() in valid else 0.0
    return 0.7  # default
```

## Связанные таски

- `qt_015` (validate_config) — кросс-проверка через tavily уже работает
- `qt_018` (fact_check) — поиск противоречий
- `qt_023` (security check) — проверка перед push
