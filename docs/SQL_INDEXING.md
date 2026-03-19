# SQL Indexing — стратегия индексации

## Текущие индексы

### routing.db
```sql
CREATE INDEX idx_qt_category ON qwen_tasks(category);
-- FTS5 для trigger/description
CREATE VIRTUAL TABLE qwen_tasks_fts USING fts5(
  trigger, description, content='qwen_tasks', content_rowid='rowid'
);
```

### project.db
```sql
CREATE INDEX idx_roadmap_phase   ON roadmap(phase);
CREATE INDEX idx_roadmap_status  ON roadmap(status);
CREATE INDEX idx_actions_category ON actions_log(category);
CREATE INDEX idx_actions_flags   ON actions_log(flags);
-- FTS5 для поиска по title/description/tags
CREATE VIRTUAL TABLE project_fts USING fts5(
  title, description, tags, flags,
  content='actions_log', content_rowid='rowid'
);
```

### network.db
```sql
CREATE INDEX idx_tpl_vendor   ON templates(vendor);
CREATE INDEX idx_tpl_protocol ON templates(protocol);
CREATE VIRTUAL TABLE templates_fts USING fts5(name, description, content);
```

## Оптимизация routing_log

```sql
-- Добавить индексы после накопления данных (v0.4.0)
CREATE INDEX idx_rlog_task    ON routing_log(task_type);
CREATE INDEX idx_rlog_model   ON routing_log(selected_model);
CREATE INDEX idx_rlog_date    ON routing_log(created_at);
-- Покрывающий индекс для дашборда
CREATE INDEX idx_rlog_tokens ON routing_log(tokens_saved);
```

## Функция FTS5

```sql
-- Поиск по триггерам максимально быстро
SELECT t.task_id, t.category, t.prompt_template
FROM qwen_tasks_fts f
JOIN qwen_tasks t ON f.rowid = t.rowid
WHERE qwen_tasks_fts MATCH 'mikrotik OR ospf'
ORDER BY rank;
```

## Правила

| Правило | Обоснование |
|---|---|
| FTS5 для trigger | Быстрый матчинг запросов |
| Индекс на category | Срез по qwen_only/parallel |
| Индекс на created_at | Фильтрация за период |
| PRAGMA не злоупотреблять | Индекс на каждое поле = оверхед |

## ANALYZE и VACUUM

```bash
# Выполнять после крупных изменений:
for db in /ai/db/*.db; do
  sqlite3 "$db" "ANALYZE; PRAGMA optimize;"
done
```
