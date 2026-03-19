# Skills List — AI Combiner

Скиллы расположены в:
`~/.config/Claude/local-agent-mode-sessions/skills-plugin/<UUID>/<SESSION>/skills/`

Текущая активная сессия: `1492d8b0-9be6-4a0c-9849-4678886b68d1`

---

## Скиллы (8 активных)

| Скилл | Тип | Триггер | Назначение |
|---|---|---|---|
| `docx` | публичный | Word doc, .docx, report, memo | Создание/редактирование Word документов |
| `pdf` | публичный | .pdf, PDF form, fill PDF | Работа с PDF файлами |
| `pptx` | публичный | deck, slides, presentation | Создание слайдов |
| `xlsx` | публичный | spreadsheet, .xlsx, Excel | Работа с таблицами |
| `ib-consultant` | пользовательский | OSINT, Red Team, пентест, SOC, умный город | Персональный ИБ-консультант |
| `mcp-builder` | публичный | MCP server, FastMCP, mcp tool | Построение MCP серверов |
| `skill-creator` | публичный | create skill, skill eval | Создание/оптимизация скиллов |
| `schedule` | публичный | schedule, планирование | Планирование задач |

---

## Правило приоритетов скиллов

⚠️ Скиллы перехватывают запросы **до** systemPrompt. Обязательно указывайте в `SKILL.md`:

```yaml
description: |
  НЕ активировать при: "инфо о себе", "проверь ресурсы", "вспомни о себе".
  Использовать ТОЛЬКО когда пользователь упоминает: <триггеры>.
```

См. `docs/CONTRIBUTING.md` — подробная инструкция добавления скиллов.

---

## Авточистка

`cleanup_sessions.sh` — оставляет только последнюю по дате папку `skills-plugin`,
архивирует старые в `/tmp/sessions_archive/`.
