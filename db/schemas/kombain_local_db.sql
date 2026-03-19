-- kombain_local.db — локальный комбайн (workflows, results, feedback, knowledge)
-- MCP SQLite подключён к этой БД

CREATE TABLE workflows (
    workflow_id  TEXT PRIMARY KEY,
    task_type    TEXT,
    name         TEXT,
    description  TEXT,
    last_run     TIMESTAMP,
    rating       INTEGER,
    steps        TEXT,
    run_count    INTEGER DEFAULT 0,
    avg_duration REAL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE workflow_results (
    result_id   TEXT PRIMARY KEY,
    workflow_id TEXT REFERENCES workflows(workflow_id),
    status      TEXT,
    duration_ms INTEGER,
    model_used  TEXT,
    tokens_used INTEGER,
    output      TEXT,
    error       TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_feedback (
    feedback_id TEXT PRIMARY KEY,
    workflow_id TEXT REFERENCES workflows(workflow_id),
    rating      INTEGER,
    comment     TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE qwen_knowledge (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    topic      TEXT NOT NULL,
    subtopic   TEXT,
    title      TEXT NOT NULL,
    content    TEXT NOT NULL,
    source     TEXT,
    tags       TEXT,
    difficulty TEXT CHECK(difficulty IN ('basic','intermediate','advanced')),
    verified   INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
