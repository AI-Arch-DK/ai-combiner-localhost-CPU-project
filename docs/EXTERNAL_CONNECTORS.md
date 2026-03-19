# External Connectors — работа с внешними подключениями

## Активные коннекторы (URL-based MCP)

| Коннектор | URL | Когда использовать |
|---|---|---|
| **Miro** | https://mcp.miro.com | Визуализация архитектуры, DAG, карты |
| **Clay** | https://api.clay.com/v3/mcp | CRM, enrichment контактов |
| **Gmail** | https://gmail.mcp.claude.com/mcp | Чтение/отправка писем |
| **Google Calendar** | https://gcal.mcp.claude.com/mcp | Задачи, напоминания |
| **HuggingFace** | https://huggingface.co/mcp | Inference, поиск моделей |

## Паттерны интеграции

### Miro — визуализация архитектуры
```
Триггер: "нарисуй архитектуру" / "обнови диаграмму"
Маршрут: orchestration → external_first
Claude → Miro:diagram_create(данные) → борд
Или: Claude → Miro:table_sync(данные из БД)
```

### Gmail — уведомления
```
Триггер: "отправь отчёт" / "напиши письмо"
Маршрут: orchestration → external_first
Claude → qwen генерирует текст → Gmail:send
Claude → Gmail:search → обработка ответов
```

### Google Calendar — планирование
```
Триггер: "запланируй" / "покажи расписание"
Маршрут: orchestration → external_first
Claude → GCal:list_events → qwen:format_output → сводная таблица
```

### Clay — enrichment
```
Триггер: "найди контакт" / "обогати данные"
Маршрут: research → external_first
Claude → Clay:enrich → запись в network.db/devices
```

### HuggingFace — inference
```
Триггер: TIMEOUT Qwen / compare_options / research
Маршрут: parallel / external_first
Claude → HF:hf_run_inference(cerebras) → мерж с Qwen
~500 t/s vs ~13 t/s у Qwen — использовать для быстрых задач
```

## Правила использования

| Правило | Обоснование |
|---|---|
| Внешние только при необходимости | Сечём токены Claude |
| Qwen для форматирования результата | Бесплатно |
| Стратегия orchestration | Для мульти-инструментных задач |
| Запись результата в БД | Перед ответом пользователю |

## Настройка в claude_desktop_config.json

См. `docs/MCP_SETUP.md` — раздел "Облачные MCP".
