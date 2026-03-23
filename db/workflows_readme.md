# Workflows — AI Combiner

## Структура

| Поле | Описание |
|---|---|
| workflow_id | уникальный ID |
| task_type | system_check / network_config / system_init |
| name | человекочитаемое название |
| steps | шаги выполнения (shell / qwen / hf / tavily) |
| rating | оценка 0-5 |
| result | краткий результат последнего запуска |

## Триггеры system_check

| Workflow | Триггер | Скрипт |
|---|---|---|
| wf_check_resources | "инфо о себе" / "проверь ресурсы" | `/ai/scripts/check_resources.sh` |
| wf_session_cleanup | автозапуск из check_resources | `/ai/scripts/cleanup_sessions.sh` |

## qwen_tasks (routing.db)

| ID | Триггер | Категория |
|---|---|---|
| qt_021 | инфо о себе / проверь ресурсы | system_check |
| qt_022 | очисти сессии | system_check |
| qt_001–020 | система / сети / код / валидация | разные |

## Обновление
После каждого `фиксируем` — workflows.json обновляется на внешние ресурсы.
