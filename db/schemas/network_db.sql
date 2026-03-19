-- network.db — сетевые устройства, конфиги, шаблоны

CREATE TABLE devices (
    device_id  TEXT PRIMARY KEY,
    name       TEXT NOT NULL,
    type       TEXT,
    vendor     TEXT,
    model      TEXT,
    ip_mgmt    TEXT,
    location   TEXT,
    is_active  INTEGER DEFAULT 1,
    notes      TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_dev_type   ON devices(type);
CREATE INDEX idx_dev_vendor ON devices(vendor);

CREATE TABLE configs (
    config_id   TEXT PRIMARY KEY,
    device_id   TEXT REFERENCES devices(device_id),
    config_type TEXT,
    content     TEXT,
    version     INTEGER DEFAULT 1,
    is_current  INTEGER DEFAULT 1,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_cfg_device ON configs(device_id);

CREATE TABLE templates (
    template_id TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    vendor      TEXT,
    protocol    TEXT,
    description TEXT,
    content     TEXT,
    tags        TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_tpl_vendor   ON templates(vendor);
CREATE INDEX idx_tpl_protocol ON templates(protocol);
CREATE VIRTUAL TABLE templates_fts USING fts5(name, description, content);
