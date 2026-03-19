# SQL Indexing — стратегия индексации

## Текущие индексы

### routing.db
```sql
CREATE INDEX idx_qt_category ON qwen_tasks(category);
CREATE VIRTUAL TABLE qwen_tasks_fts USING fts5(
  trigger, description, content='qwen_tasks', content_rowid='rowid'
);
```

### project.db
```sql
CREATE INDEX idx_roadmap_phase   ON roadmap(phase);
CREATE INDEX idx_roadmap_status  ON roadmap(status);
CREATE INDEX idx_actions_category ON actions_log(category);
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

## routing_log (v0.4.0)

```sql
CREATE INDEX idx_rlog_task    ON routing_log(task_type);
CREATE INDEX idx_rlog_model   ON routing_log(selected_model);
CREATE INDEX idx_rlog_date    ON routing_log(created_at);
CREATE INDEX idx_rlog_tokens  ON routing_log(tokens_saved);
```

## FTS5 поиск

```sql
SELECT t.task_id, t.category, t.prompt_template
FROM qwen_tasks_fts f
JOIN qwen_tasks t ON f.rowid = t.rowid
WHERE qwen_tasks_fts MATCH 'mikrotik OR ospf'
ORDER BY rank;
```

## Монитоႈинг производительности

```sql
-- Анализ плана запроса
EXPLAIN QUERY PLAN
SELECT * FROM qwen_tasks WHERE category = 'system_check';
-- Должно вывести: SEARCH qwen_tasks USING INDEX idx_qt_category

-- Статистика по стратегиям (v0.4.0 routing_log)
SELECT selected_model, COUNT(*), AVG(tokens_saved), MAX(tokens_saved)
FROM routing_log
GROUP BY selected_model
ORDER BY COUNT(*) DESC;

-- Топ-5 самых дорогих тасков
SELECT task_type, COUNT(*), SUM(tokens_saved)
FROM routing_log
GROUP BY task_type
ORDER BY SUM(tokens_saved) DESC
LIMIT 5;
```

## ANALYZE + VACUUM по расписанию

```bash
for db in /ai/db/*.db; do
  sqlite3 "$db" "ANALYZE; PRAGMA optimize;"
done
```

## Правила

| Правило | Обоснование |
|---|---|
| FTS5 для trigger | Быстрый матчинг |
| EXPLAIN QUERY PLAN | Проверка использования индекса |
| Индекс только на колонки в WHERE/JOIN | Индекс на каждое поле = оверхед |
| routing_log после 1000+ записей | ANALYZE пересчитывает статистику |
