# AI Combiner Architecture

## Request Processing Priorities

| Order | Layer | Managed by |
|---|---|---|
| 1️⃣ | Skills (SKILL.md) | `~/.config/Claude/local-agent-mode-sessions/skills-plugin/` |
| 2️⃣ | systemPrompt | `claude_desktop_config.json` |
| 3️⃣ | qwen_dispatch | `routing.db / qwen_tasks` |
| 4️⃣ | External MCP | `routing.db / parallel_config` |

## Routing Logic

```text
request → qwen_dispatch
    MATCH    → Qwen responds → return as-is
    NO_MATCH → parallel_config strategy
    TIMEOUT  → HF + tavily in parallel → qwen_get_late_answer
    HALLUC.  → qwen_cancel → external tools
```

## Auto-start Scripts

```bash
# Trigger: "about yourself"
shell → /ai/scripts/check_resources.sh
# Automatically calls:
shell → /ai/scripts/cleanup_sessions.sh
```

## /ai/ Directory Structure

```text
/ai/
├── db/           # routing.db, project.db, network.db, tokens.db, tools.db, models.db
├── scripts/      # check_resources.sh, cleanup_sessions.sh, git_sync.sh
├── logs/         # startup.log
├── backup/       # database backups
└── workspace/    # working files
```

## GitHub Accounts

- `GitHub public account` — public / open source projects
- `GitHub private account` — private projects
