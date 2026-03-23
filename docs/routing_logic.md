# Routing Logic — AI Combiner

## Приоритеты обработки запроса

```text
ЗАПРОС ПОЛЬЗОВАТЕЛЯ
       │
       ▼
┌─────────────────────────────────────────┐
│  [1] СКИЛЛЫ (SKILL.md)                  │  ← перехватывают ПЕРВЫМИ
│  ~/.config/Claude/local-agent-mode-     │
│  sessions/skills-plugin/1492d8b0.../    │
│  Триггер совпал? → отвечает скилл       │
└──────────────┬──────────────────────────┘
               │ нет совпадения
               ▼
┌─────────────────────────────────────────┐
│  [2] systemPrompt                       │  ← claude_desktop_config.json
│  Приоритет №1: "инфо о себе" →         │
│  shell → /ai/scripts/check_resources.sh │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  [3] qwen_dispatch(user_query)          │  ← ВСЕГДА первым из инструментов
│                                         │
│  MATCH   → Qwen отвечает → AS-IS       │
│  NO_MATCH → переход к стратегии         │
│  TIMEOUT + required=false →             │
│     параллельно HF+tavily               │
│     → qwen_get_late_answer              │
│  HALLUCINATION → qwen_cancel            │
│     → внешние инструменты               │
└──────────────┬──────────────────────────┘
               │ NO_MATCH
               ▼
┌─────────────────────────────────────────┐
│  [4] parallel_config стратегия          │
│                                         │
│  qwen_only       → только Qwen          │
│  parallel        → Qwen+HF+tavily       │
│  external_first  → HF+browser+tavily    │
│  qwen_with_context → tavily→Qwen        │
└──────────────┬──────────────────────────┘
               │
               ▼
         РЕЗУЛЬТАТ → БД → пользователь

```text

## Матрица стратегий

| Тип задачи | Стратегия | Qwen | HF | Tavily | Browser |
|---|---|---|---|---|---|
| network_config | parallel | ✅ | ✅ | ✅ | ✅ |
| explain_short | qwen_only | ✅ | ❌ | ❌ | ❌ |
| code_bash | qwen_only | ✅ | ❌ | ❌ | ❌ |
| code_sql | qwen_only | ✅ | ❌ | ❌ | ❌ |
| research | external_first | ❌ | ✅ | ✅ | ✅ |
| system_check | qwen_only | ✅ | ❌ | ❌ | ❌ |
| extract_ip | qwen_only | ✅ | ❌ | ❌ | ❌ |
| orchestration | external_first | ❌ | ✅ | ✅ | ✅ |
| validate_config | qwen_with_context | ✅ | ❌ | ✅ | ❌ |
| format_output | qwen_only | ✅ | ❌ | ❌ | ❌ |
| compare_options | parallel | ✅ | ✅ | ✅ | ❌ |
| fact_check | qwen_with_context | ✅ | ❌ | ✅ | ❌ |
| startup_check | qwen_only | ✅ | ❌ | ❌ | ❌ |

## CLAUDE_DIRECT маркеры

`qt_019` (bash) и `qt_020` (sql) — специальные маркеры.
Когда qwen_dispatch возвращает `code_direct` → Claude выполняет задачу напрямую без Qwen.
Экономия: не тратим локальные ресурсы на задачи где Claude лучше справляется сам.

## Токен-экономия

| Модель | Роль | Токены/запрос |
|---|---|---|
| Qwen 7b (local) | воркер | 10–200 (бесплатно) |
| Claude Sonnet | дирижёр | минимум (только решения) |
| HF Cerebras | внешний | параллельно, только при нужде |
| Tavily | поиск | только external/context стратегии |
