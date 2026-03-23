# MCP Setup Guide

How to configure MCP servers for AI Combiner.
Config file: `~/.config/Claude/claude_desktop_config.json`

> ⚠️ This file contains API keys. Never commit it. It is listed in `.gitignore`.

## Requirements

- Claude Desktop (installed)
- Node.js >= 18
- Python >= 3.10 + `pip install uvx` or `pipx install uv`
- Ollama (for local LLM)

## Config Structure

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

## Local MCP Servers

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

Install Ollama:

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

## Cloud MCP Servers (URL-based)

| Service | URL | Auth |
|---|---|---|
| Miro | `https://mcp.miro.com` | Miro API token |
| HuggingFace | `https://huggingface.co/mcp` | `HF_TOKEN` |
| Google Calendar | `https://gcal.mcp.claude.com/mcp` | OAuth |
| Gmail | `https://gmail.mcp.claude.com/mcp` | OAuth |
| Clay | `https://api.clay.com/v3/mcp` | Clay API key |
| Tavily | built into tavily-mcp | `TAVILY_API_KEY` |

## GitHub (two accounts)

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

Required PAT scopes: `repo`, `read:org`, `read:user`

## Verifying MCP Servers

```bash
# Ollama
curl http://localhost:11434/api/tags

# SQLite
sqlite3 /ai/db/routing.db "SELECT COUNT(*) FROM qwen_tasks;"

# Filesystem
ls /ai/db/

# Full health check
bash scripts/health_check.sh
```

## Startup Order

1. Start Ollama: `systemctl --user start ollama`
2. Launch Claude Desktop
3. First message: **"about yourself"** → triggers `check_resources.sh` automatically

## Troubleshooting

| Symptom | Fix |
|---|---|
| MCP not responding | Restart Claude Desktop |
| Ollama won’t start | `systemctl --user status ollama` → check logs |
| SQLite path error | Verify path to `kombain_local.db` in config |
| `npx` not found | Install Node.js, check PATH |

See also: `docs/TROUBLESHOOTING.md`
