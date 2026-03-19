-- kombain_shared.db — общая БД для синхронизации нод AI-комбайна
-- Путь: /ai/external/kali/kombain_shared.db
-- Концепция: Office_MAIN-нода (центральный оркестратор)
-- Ноды: debai-нода (localhost CPU) + kali-нода (security/pentest)
-- Схема идентична kombain_local.db + таблица sync_log

-- === КОПИЯ kombain_local.db ===

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

-- === ТОЛЬКО В SHARED БД ===

CREATE TABLE sync_log (
    sync_id      TEXT PRIMARY KEY,
    node_id      TEXT NOT NULL,        -- 'debai' | 'kali' | 'office_main'
    operation    TEXT NOT NULL,        -- 'INSERT' | 'UPDATE' | 'DELETE' | 'SYNC'
    table_name   TEXT NOT NULL,
    record_id    TEXT,
    payload      TEXT,                 -- JSON
    status       TEXT DEFAULT 'pending', -- 'pending' | 'done' | 'conflict'
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    synced_at    TIMESTAMP
);
CREATE INDEX idx_sync_node    ON sync_log(node_id);
CREATE INDEX idx_sync_status  ON sync_log(status);
CREATE INDEX idx_sync_table   ON sync_log(table_name);

-- === КОНЦЕПЦИЯ OFFICE_MAIN ===
-- Office_MAIN-нода — центральный оркестратор будущей офисной сети
-- Все ноды пишут в sync_log свои изменения
-- Office_MAIN читает sync_log и разрешает конфликты
-- node_id регистрирует кто сделал запись: 'debai' | 'kali' | 'office_main'
