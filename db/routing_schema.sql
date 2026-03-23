-- routing.db schema
-- qwen_tasks: active routing tasks
-- parallel_config: routing strategies

CREATE TABLE qwen_tasks (
    task_id TEXT PRIMARY KEY,
    trigger TEXT NOT NULL,
    category TEXT NOT NULL,
    prompt_template TEXT NOT NULL,
    max_tokens INTEGER DEFAULT 200,
    is_active INTEGER DEFAULT 1,
    description TEXT,
    required INTEGER DEFAULT 0,
    cancel_on_hallucination INTEGER DEFAULT 1,
    max_wait_sec INTEGER DEFAULT 60
);

CREATE TABLE parallel_config (
    config_id TEXT PRIMARY KEY,
    task_type TEXT,
    use_qwen INTEGER DEFAULT 1,
    use_hf INTEGER DEFAULT 0,
    use_browser INTEGER DEFAULT 0,
    use_tavily INTEGER DEFAULT 0,
    timeout_sec INTEGER DEFAULT 15,
    strategy TEXT,
    description TEXT
);

CREATE TABLE routing_log (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id TEXT,
    strategy TEXT,
    result TEXT,
    tokens_used INTEGER,
    duration_ms INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
