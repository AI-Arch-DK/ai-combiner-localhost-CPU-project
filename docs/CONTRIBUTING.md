# Contributing — добавление скиллов и тасков

## Добавить новый qwen_task

```sql
-- routing.db
INSERT INTO qwen_tasks VALUES (
  'qt_NNN',                    -- уникальный ID
  'триггер1,триггер2,keyword', -- слова для распознавания
  'category_name',             -- категория
  'Short prompt for qwen. Max 50 words. Output only.',
  200,    -- max_tokens
  1,      -- is_active
  'Описание задачи',
  0,      -- required (1 = обязательно ждать)
  1,      -- cancel_on_hallucination
  60      -- max_wait_sec
);
```

### Правила промпта
- Максимум 50 слов
- Всегда заканчивать инструкцией формата: `Output X only.`
- Не использовать личные данные
- Язык вывода указывать явно (`in Russian` / `in English`)

## Добавить стратегию parallel_config

```sql
INSERT INTO parallel_config VALUES (
  'pc_NNN',
  'task_category',
  1, -- qwen_enabled
  0, -- hf_enabled
  0, -- browser_enabled
  1, -- tavily_enabled
  30, -- timeout_sec
  'qwen_with_context',
  'Описание стратегии'
);
```

## Добавить новый скилл

1. Создать папку в skills-plugin актуальной сессии:
```
~/.config/Claude/local-agent-mode-sessions/skills-plugin/
  <АКТУАЛЬНЫЙ_UUID>/
    <SESSION_UUID>/
      skills/
        my-skill/
          SKILL.md
```

2. Формат `SKILL.md`:
```yaml
---
name: my-skill
description: |
  НЕ активировать при: "инфо о себе", "проверь ресурсы".
  Использовать ТОЛЬКО когда пользователь упоминает: <триггеры>.
---
# My Skill
...
```

3. Перезапустить Claude Desktop

## Правила безопасности перед push

См. `docs/SECURITY_CHECKLIST.md`

Обязательная проверка:
```bash
grep -rE "tvly-|github_pat|hf_[a-zA-Z]{20,}|password=|api.key" \
  --include="*.sh" --include="*.json" --include="*.md" --include="*.sql" . \
  && echo "❌ НАЙДЕНЫ СЕКРЕТЫ" || echo "✅ Чисто"
```
