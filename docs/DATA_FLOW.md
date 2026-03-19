# Data Flow — AI Combiner

## Цикл запроса

```
Пользователь пишет запрос
         │
         ▼
   Claude Desktop получает сообщение
         │
         ├───► [SKILL] перехватил? ──► да → SKILL отвечает
         │ нет
         ▼
   qwen_dispatch(user_query)
         │
         ├─► MATCH → qwen выполняет → запись в workflow_results
         ├─► CLAUDE_DIRECT → Claude выполняет
         ├─► NO_MATCH → стратегия из parallel_config
         └─► TIMEOUT → HF+tavily параллельно
                    │
                    ▼
              qwen_get_late_answer
                    │
                    ▼
              Мерж ответов
         │
         ▼
   Результат → workflow_results (kombain_local.db)
         │
         ▼
   Ответ пользователю
```

## Потоки данных

| Поток | Откуда | Куда |
|---|---|---|
| Запрос | Claude Desktop | qwen_dispatch |
| Результат Qwen | ollama:11434 | Claude |
| Внешние данные | HF/tavily/browser | Claude |
| Запись в БД | Claude | kombain_local.db |
| Синх | kombain_local.db | kombain_shared.db |

## Токены

```
Qwen токены → бесплатные (локальные)
Cerebras → бесплатные (serverless, лимит)
Claude → платные — экономия ключевой приоритет
```
