-- models.db — реестр AI-моделей и их производительность

CREATE TABLE models (
    model_id      TEXT PRIMARY KEY,
    name          TEXT NOT NULL,
    provider      TEXT,
    type          TEXT,
    context_len   INTEGER,
    cost_per_1k   REAL DEFAULT 0,
    speed_tps     REAL,
    quality_score INTEGER,
    is_local      INTEGER DEFAULT 0,
    is_active     INTEGER DEFAULT 1,
    notes         TEXT,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_model_provider ON models(provider);
CREATE INDEX idx_model_type     ON models(type);

CREATE TABLE model_performance (
    perf_id      TEXT PRIMARY KEY,
    model_id     TEXT REFERENCES models(model_id),
    task_type    TEXT,
    avg_tokens   INTEGER,
    avg_duration REAL,
    success_rate REAL,
    measured_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
