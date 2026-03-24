# Claude Memory — Persistent Session Memory

## Architecture

```text
User: "memory" / "mem 009" / "what did you do"
         │
         ▼
  qt_028 → bash /ai/scripts/claude_memory.sh index
         │
         ├─ BRIEF (index): claude_index → 1 SQL query → ~20 lines
         └─ FULL (on demand): claude_memory WHERE key=mem_NNN
```

## Three Tables in kombain_local.db

| Table | Contents | Tokens |
|---|---|---|
| `claude_index` | Category + action + object + result | minimal |
| `claude_memory` | Full content: code, SQL, descriptions | on-demand only |
| `claude_triggers` | Trigger words for activation | not currently used |

## Commands

```bash
# Brief index — 0 Claude tokens:
bash /ai/scripts/claude_memory.sh index

# Full content by category:
bash /ai/scripts/claude_memory.sh full SCRIPT

# Specific record:
bash /ai/scripts/claude_memory.sh get mem_009

# Search:
bash /ai/scripts/claude_memory.sh search curl

# Add a knowledge entry:
bash /ai/scripts/claude_memory.sh add FIX "title" "full content"
```

## Chat Triggers

| Phrase | Action | Tokens |
|---|---|---|
| `memory` | brief index | ~30 output tokens |
| `mem 009` | full record content | ~100–300 tokens |
| `show memory SCRIPT` | all scripts in full | ~500+ tokens |
| `find in memory curl` | search | ~50 tokens |
| `remember category title` | write entry | 0 tokens |

## Categories

`DB` `SCRIPT` `SKILL` `GITHUB` `WORKFLOW` `COMMAND` `PATTERN` `FIX`

## Automatic Mode

Claude does not read memory automatically at session start — only when triggered by "memory" or "mem NNN". The index is cheap (one SQL query). Full content is fetched only when needed.

v0.4.0 plan: auto-write on completion of every significant action (check_resources + result INSERT INTO claude_index).
