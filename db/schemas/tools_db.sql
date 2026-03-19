-- tools.db — реестр инструментов и MCP-серверов

CREATE TABLE tools (
    tool_id    TEXT PRIMARY KEY,
    name       TEXT NOT NULL,
    category   TEXT,
    description TEXT,
    mcp_server TEXT,
    command    TEXT,
    is_active  INTEGER DEFAULT 1,
    priority   INTEGER DEFAULT 5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_tool_category ON tools(category);
CREATE INDEX idx_tool_active   ON tools(is_active);

CREATE TABLE tool_usage (
    usage_id    TEXT PRIMARY KEY,
    tool_id     TEXT REFERENCES tools(tool_id),
    workflow_id TEXT,
    status      TEXT,
    duration_ms INTEGER,
    error       TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_tu_tool ON tool_usage(tool_id);
