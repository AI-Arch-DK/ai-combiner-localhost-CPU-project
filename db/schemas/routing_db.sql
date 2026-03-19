-- routing.db — маршрутизация запросов AI-комбайна
-- Стратегии: qwen_only | parallel | external_first | qwen_with_context

CREATE TABLE qwen_tasks (
    task_id                 TEXT PRIMARY KEY,
    trigger                 TEXT NOT NULL,
    category                TEXT NOT NULL,
    prompt_template         TEXT NOT NULL,
    max_tokens              INTEGER DEFAULT 200,
    is_active               INTEGER DEFAULT 1,
    description             TEXT,
    required                INTEGER DEFAULT 0,
    cancel_on_hallucination INTEGER DEFAULT 1,
    max_wait_sec            INTEGER DEFAULT 60
);
CREATE INDEX idx_qt_category ON qwen_tasks(category);
CREATE VIRTUAL TABLE qwen_tasks_fts USING fts5(trigger, description, content='qwen_tasks', content_rowid='rowid');

CREATE TABLE parallel_config (
    config_id        TEXT PRIMARY KEY,
    task_category    TEXT NOT NULL,
    qwen_enabled     INTEGER DEFAULT 1,
    hf_enabled       INTEGER DEFAULT 0,
    browser_enabled  INTEGER DEFAULT 0,
    tavily_enabled   INTEGER DEFAULT 0,
    qwen_timeout_sec INTEGER DEFAULT 15,
    strategy         TEXT DEFAULT 'qwen_first',
    notes            TEXT
);

CREATE TABLE routing_log (
    log_id         TEXT PRIMARY KEY,
    task_type      TEXT,
    selected_model TEXT,
    reason         TEXT,
    tokens_saved   INTEGER,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
