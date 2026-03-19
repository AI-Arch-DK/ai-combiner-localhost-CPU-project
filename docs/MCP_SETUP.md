# MCP Setup Guide

Инструкция по настройке MCP-серверов для AI-комбайна.
Конфиг: `~/.config/Claude/claude_desktop_config.json`

> ⚠️ Файл конфига содержит API-ключи. Никогда не публиковать.

## Локальные MCP (установлены на хосте)

### filesystem
```json
{
  "command": "/usr/bin/npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem",
    "/home/<user>", "/ai", "/tmp"]
}
```

### shell
```json
{ "command": "/usr/bin/npx", "args": ["-y", "mcp-shell"] }
```

### sqlite
```json
{
  "command": "uvx",
  "args": ["mcp-server-sqlite", "--db-path", "/ai/kombain/kombain_local.db"]
}
```

### ollama-local
```json
{
  "command": "node",
  "args": ["/path/to/ollama-server/server.js"],
  "env": {
    "OLLAMA_HOST": "http://localhost:11434",
    "OLLAMA_MODEL": "qwen2.5:7b-instruct-q4_K_M"
  }
}
```

### host-report
```json
{
  "command": "node",
  "args": ["/path/to/host-report-server/server.js"]
}
```

### browser (Playwright)
```json
{
  "command": "node",
  "args": ["/path/to/browser-server/server.js"],
  "env": { "PLAYWRIGHT_BROWSERS_PATH": "~/.cache/ms-playwright" }
}
```

## Облачные MCP (URL-based)

| Сервис | URL | Токен |
|---|---|---|
| Miro | https://mcp.miro.com | в конфиге |
| HuggingFace | https://huggingface.co/mcp | HF_TOKEN |
| Google Calendar | https://gcal.mcp.claude.com/mcp | OAuth |
| Gmail | https://gmail.mcp.claude.com/mcp | OAuth |
| Clay | https://api.clay.com/v3/mcp | Clay API key |

## GitHub (два аккаунта)

```json
"github-public": {
  "command": "github-mcp-server", "args": ["stdio"],
  "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "<PAT_PUBLIC>" }
},
"github-private": {
  "command": "github-mcp-server", "args": ["stdio"],
  "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "<PAT_PRIVATE>" }
}
```

## Проверка работы MCP

```bash
# Ollama
curl http://localhost:11434/api/tags

# SQLite
sqlite3 /ai/db/routing.db "SELECT COUNT(*) FROM qwen_tasks;"

# Filesystem
ls /ai/db/
```

## Порядок перезапуска

1. Остановить Claude Desktop
2. Убедиться что ollama запущена: `systemctl --user status ollama`
3. Запустить Claude Desktop
4. Первое сообщение: **"инфо о себе"** → проверка всех ресурсов
