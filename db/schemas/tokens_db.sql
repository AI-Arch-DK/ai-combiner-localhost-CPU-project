-- tokens.db — учёт токенов и бюджета

CREATE TABLE token_accounts (
    account_id    TEXT PRIMARY KEY,
    service       TEXT NOT NULL,
    model         TEXT,
    monthly_limit INTEGER,
    used_total    INTEGER DEFAULT 0,
    reset_date    DATE,
    priority      INTEGER DEFAULT 5,
    is_active     INTEGER DEFAULT 1,
    notes         TEXT,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE token_usage (
    usage_id    TEXT PRIMARY KEY,
    account_id  TEXT REFERENCES token_accounts(account_id),
    workflow_id TEXT,
    task_type   TEXT,
    tokens_in   INTEGER DEFAULT 0,
    tokens_out  INTEGER DEFAULT 0,
    tokens_total INTEGER DEFAULT 0,
    cost_usd    REAL DEFAULT 0,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_tu_account ON token_usage(account_id);
CREATE INDEX idx_tu_date    ON token_usage(created_at);

CREATE TABLE token_budget (
    budget_id       TEXT PRIMARY KEY,
    period          TEXT,
    total_budget    REAL,
    spent           REAL DEFAULT 0,
    saved_by_local  INTEGER DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
