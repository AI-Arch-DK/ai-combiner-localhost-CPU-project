# MCP Setup Guide

Инструкция по настройке MCP-серверов для AI Combiner.
Конфиг: `~/.config/Claude/claude_desktop_config.json`

> ⚠️ Файл конфига содержит API-ключи. Никогда не публиковать. Добавлен в `.gitignore`.

## Требования

- Claude Desktop (установлен)
- Node.js >= 18
- Python >= 3.10 + `pip install uvx` или `pipx install uv`
- Ollama (для локальной LLM)

## Структура конфига

```json
{
  "mcpServers": {
    "<server-id>": {
      "command": "...",
      "args": [...],
      "env": { ... }
    }
  }
}
```

## Локальные MCP

### filesystem

```json
"filesystem": {
  "command": "/usr/bin/npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem",
    "/home/<your-username>", "/ai", "/tmp"]
}
```

### shell

```json
"shell": {
  "command": "/usr/bin/npx",
  "args": ["-y", "mcp-shell"]
}
```

### sqlite

```json
"sqlite": {
  "command": "uvx",
  "args": ["mcp-server-sqlite", "--db-path", "/ai/kombain/kombain_local.db"]
}
```

### ollama-local

```json
"ollama-local": {
  "command": "node",
  "args": ["/path/to/ollama-server/server.js"],
  "env": {
    "OLLAMA_HOST": "http://localhost:11434",
    "OLLAMA_MODEL": "qwen2.5:7b-instruct-q4_K_M"
  }
}
```

Установить Ollama:

```bash
curl -fsSL https://ollama.ai/install.sh | sh
ollama pull qwen2.5:7b-instruct-q4_K_M
```

### host-report

```json
"host-report": {
  "command": "node",
  "args": ["/path/to/host-report-server/server.js"]
}
```

### browser (Playwright)

```json
"browser": {
  "command": "node",
  "args": ["/path/to/browser-server/server.js"],
  "env": { "PLAYWRIGHT_BROWSERS_PATH": "~/.cache/ms-playwright" }
}
```

## Облачные MCP (URL-based)

| Сервис | URL | Auth |
|---|---|---|
| Miro | `https://mcp.miro.com` | Miro API token |
| HuggingFace | `https://huggingface.co/mcp` | `HF_TOKEN` |
| Google Calendar | `https://gcal.mcp.claude.com/mcp` | OAuth |
| Gmail | `https://gmail.mcp.claude.com/mcp` | OAuth |
| Clay | `https://api.clay.com/v3/mcp` | Clay API key |
| Tavily | встроен в tavily-mcp | `TAVILY_API_KEY` |

## GitHub (два аккаунта)

```json
"github-public": {
  "command": "github-mcp-server",
  "args": ["stdio"],
  "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "<PAT_PUBLIC>" }
},
"github-private": {
  "command": "github-mcp-server",
  "args": ["stdio"],
  "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "<PAT_PRIVATE>" }
}
```

Права для PAT: `repo`, `read:org`, `read:user`

## Проверка работы MCP

```bash
# Ollama
curl http://localhost:11434/api/tags

# SQLite
sqlite3 /ai/db/routing.db "SELECT COUNT(*) FROM qwen_tasks;"

# Filesystem
ls /ai/db/

# Health check (все компоненты)
bash scripts/health_check.sh
```

## Порядок запуска

1. Запустить Ollama: `systemctl --user start ollama`
2. Запустить Claude Desktop
3. Первое сообщение: **"инфо о себе"** → автоматический `check_resources.sh`

## Troubleshooting

| Симптом | Решение |
|---|---|
| MCP не отвечает | Перезапустить Claude Desktop |
| Ollama не стартует | `systemctl --user status ollama` → проверить логи |
| sqlite ошибка пути | Проверить путь к `kombain_local.db` в конфиге |
| `npx` not found | Установить Node.js, проверить PATH |

Подробнее: `docs/TROUBLESHOOTING.md`
