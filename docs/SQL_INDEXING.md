# SQL Indexing — Indexing Strategy

## Current Indexes

### routing.db

```sql
CREATE INDEX idx_qt_category ON qwen_tasks(category);
CREATE VIRTUAL TABLE qwen_tasks_fts USING fts5(
  trigger, description, content='qwen_tasks', content_rowid='rowid'
);
```

### project.db

```sql
CREATE INDEX idx_roadmap_phase    ON roadmap(phase);
CREATE INDEX idx_roadmap_status   ON roadmap(status);
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
CREATE INDEX idx_rlog_task   ON routing_log(task_type);
CREATE INDEX idx_rlog_model  ON routing_log(selected_model);
CREATE INDEX idx_rlog_date   ON routing_log(created_at);
CREATE INDEX idx_rlog_tokens ON routing_log(tokens_saved);
```

## FTS5 Search

```sql
SELECT t.task_id, t.category, t.prompt_template
FROM qwen_tasks_fts f
JOIN qwen_tasks t ON f.rowid = t.rowid
WHERE qwen_tasks_fts MATCH 'mikrotik OR ospf'
ORDER BY rank;
```

## Performance Monitoring

```sql
-- Analyze query plan
EXPLAIN QUERY PLAN
SELECT * FROM qwen_tasks WHERE category = 'system_check';
-- Expected output: SEARCH qwen_tasks USING INDEX idx_qt_category

-- Strategy statistics (v0.4.0 routing_log)
SELECT selected_model, COUNT(*), AVG(tokens_saved), MAX(tokens_saved)
FROM routing_log
GROUP BY selected_model
ORDER BY COUNT(*) DESC;

-- Top 5 most expensive task types
SELECT task_type, COUNT(*), SUM(tokens_saved)
FROM routing_log
GROUP BY task_type
ORDER BY SUM(tokens_saved) DESC
LIMIT 5;
```

## Scheduled ANALYZE + VACUUM

```bash
for db in /ai/db/*.db; do
  sqlite3 "$db" "ANALYZE; PRAGMA optimize;"
done
```

## Rules

| Rule | Reason |
|---|---|
| FTS5 for trigger column | Fast trigger matching |
| Always check with EXPLAIN QUERY PLAN | Verify index is being used |
| Index only columns used in WHERE / JOIN | Indexing every column adds overhead |
| Run ANALYZE after 1000+ routing_log rows | Keeps query planner statistics fresh |
