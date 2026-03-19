# Hallucination Guard — защита от галлюцинаций

## Уровни защиты

```
[Уровень 1] Промпт-ограничения
  → max 50 слов в prompt_template
  → "Отвечай только X, нет объяснений"
  → Указание ожидаемого формата

[Уровень 2] Параметры задачи
  → cancel_on_hallucination = 1
  → max_tokens ограничен
  → max_wait_sec = 30–60

[Уровень 3] Детекция системой
  → qwen_dispatch → HALLUCINATION → qwen_cancel
  → Запрос перенаправляется во внешние инструменты

[Уровень 4] Кросс-проверка (validate_config)
  → tavily получает документацию
  → Qwen сравнивает свой ответ с документацией
```

## Признаки галлюцинации

| Симптом | Действие |
|---|---|
| Ответ > max_tokens × 1.5 | qwen_cancel |
| Повторяет вопрос вместо ответа | qwen_cancel |
| Несуществующие команды/IP | qwen_cancel |
| Отвечает не на том языке | qwen_cancel |

## confidence_score() — реализация по категоႈиям

```python
import re

def confidence_score(response: str, task_category: str) -> float:
    """0.0 = галлюцинация, 1.0 = надёжный ответ"""
    r = response.strip()

    if task_category == 'extract_ip':
        ips = re.findall(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', r)
        return 1.0 if ips else 0.0

    if task_category == 'extract_ports':
        ports = re.findall(r'\b\d{1,5}\s*[-—]\s*\w+', r)
        return min(1.0, len(ports) / 3) if ports else 0.0

    if task_category == 'count':
        return 1.0 if r.isdigit() else 0.0

    if task_category == 'classification':
        valid = {'network_config','code_generation','system_check',
                 'database','orchestration','simple_query'}
        return 1.0 if r.lower() in valid else 0.0

    if task_category == 'translate':
        # Ответ не должен содержать исходных слов prompt
        return 0.8 if len(r) > 5 else 0.0

    if task_category in ('summarize', 'explain_short'):
        sentences = r.count('.') + r.count('!')
        return 1.0 if 2 <= sentences <= 6 else 0.5

    if task_category in ('network_mikrotik', 'network_keenetic'):
        # CLI команды должны содержать '/'
        return 1.0 if '/' in r else 0.3

    return 0.7  # default for other categories

# Использование:
# score = confidence_score(qwen_response, task.category)
# if score < 0.5: qwen_cancel(query_id, reason='hallucination')
```

## Связанные таски

- `qt_015` (validate_config) — кросс-проверка через tavily
- `qt_018` (fact_check) — поиск противоречий
- `qt_023` (security check) — проверка перед push
