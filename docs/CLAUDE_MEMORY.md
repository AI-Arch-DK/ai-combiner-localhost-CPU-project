# Claude Memory — персональная память Claude

## Архитектура

```
Пользователь: "память" / "mem 009" / "что делал"
         │
         ▼
  qt_028 → bash /ai/scripts/claude_memory.sh index
         │
         ├─ КРАТКО (индекс): claude_index → 1 SQL → ~20 строк
         └─ ПОЛНО (по запросу): claude_memory WHERE key=mem_NNN
```

## Три таблицы в kombain_local.db

| Таблица | Содержимое | Токены |
|---|---|---|
| `claude_index` | Категория + действие + объект + результат | минимальные |
| `claude_memory` | Полный контент: код, SQL, описания | только по запросу |
| `claude_triggers` | Слова-триггеры для вызова | не используются |

## Команды

```bash
# Краткий индекс — 0 токенов Claude:
bash /ai/scripts/claude_memory.sh index

# Полный контент по категории:
bash /ai/scripts/claude_memory.sh full SCRIPT

# Конкретная запись:
bash /ai/scripts/claude_memory.sh get mem_009

# Поиск:
bash /ai/scripts/claude_memory.sh search curl

# Добавить знание:
bash /ai/scripts/claude_memory.sh add FIX "заголовок" "полный контент"
```

## Триггеры в чате

| Фраза | Действие | Токены |
|---|---|---|
| `память` | краткий индекс | ~30 токенов вывода |
| `mem 009` | полное содержание записи | ~100-300 токенов |
| `покажи память SCRIPT` | все скрипты полностью | ~500+ токенов |
| `найди в памяти curl` | поиск | ~50 токенов |
| `запомни катег заголовок` | записать | 0 токенов |

## Категории

`DB` `SCRIPT` `SKILL` `GITHUB` `WORKFLOW` `COMMAND` `PATTERN` `FIX`

## Автоматический режим

Концепция: при новом чате Claude сам не читает память автоматически — только после команды "память" или "mem NNN".
Индекс — дёшево (один SQL-запрос). Полное содержание — только если нужно.

v0.4.0: авто-запись по завершению каждого значимого действия (check_resources+result INSERT INTO claude_index).
