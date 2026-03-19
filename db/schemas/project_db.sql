-- project.db — проекты, roadmap, лог действий

CREATE TABLE project_goals (
    goal_id     TEXT PRIMARY KEY,
    title       TEXT NOT NULL,
    description TEXT,
    status      TEXT DEFAULT 'active',
    priority    INTEGER DEFAULT 5,
    tags        TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roadmap (
    task_id      TEXT PRIMARY KEY,
    goal_id      TEXT REFERENCES project_goals(goal_id),
    phase        INTEGER,
    title        TEXT NOT NULL,
    description  TEXT,
    status       TEXT DEFAULT 'pending',
    tags         TEXT,
    depends_on   TEXT,
    completed_at TIMESTAMP,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_roadmap_phase   ON roadmap(phase);
CREATE INDEX idx_roadmap_status  ON roadmap(status);
CREATE INDEX idx_roadmap_tags    ON roadmap(tags);

CREATE TABLE actions_log (
    action_id   TEXT PRIMARY KEY,
    task_id     TEXT REFERENCES roadmap(task_id),
    category    TEXT,
    title       TEXT NOT NULL,
    description TEXT,
    result      TEXT,
    model_used  TEXT,
    tags        TEXT,
    flags       TEXT,
    is_success  INTEGER DEFAULT 1,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_actions_category ON actions_log(category);
CREATE INDEX idx_actions_flags    ON actions_log(flags);
CREATE INDEX idx_actions_success  ON actions_log(is_success);

CREATE VIRTUAL TABLE project_fts USING fts5(
    title, description, tags, flags,
    content='actions_log', content_rowid='rowid'
);
CREATE TRIGGER actions_fts_insert AFTER INSERT ON actions_log BEGIN
    INSERT INTO project_fts(rowid, title, description, tags, flags)
    VALUES (new.rowid, new.title, new.description, new.tags, new.flags);
END;
