# Config

| File | Purpose |
|---|---|
| `ollama_model.md` | qwen2.5:7b model parameters, hardware specs, performance benchmarks |
| `ai-check-resources.service` | systemd user service — auto-runs check_resources on login |

## Files NOT in the repository (contain secrets)

| File | Reason |
|---|---|
| `~/.config/Claude/claude_desktop_config.json` | API keys for all MCP servers |
| `~/.config/Claude/config.env` | Environment variables with tokens |

See `.gitignore` and `docs/SECURITY_CHECKLIST.md`.
