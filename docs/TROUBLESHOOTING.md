# Troubleshooting — AI Combiner

## Issue: skill intercepts system command triggers

**Symptom:** "about yourself" → skill `ib-consultant` reads a profile instead of running `check_resources.sh`

**Cause:** Skills run before the systemPrompt (priority #1).

**Fix:** Add the following to the top of the skill’s `SKILL.md` description:

```text
Do NOT activate when: "about yourself", "check resources".
```

---

## Issue: shell MCP returns `null` on `rm -rf`

**Cause:** The shell MCP blocks destructive commands.

**Fix:** Run the command manually in a terminal as `debianAI`.

---

## Issue: Ollama is not responding

```bash
# Check status
curl http://localhost:11434/api/tags
systemctl --user status ollama

# Start the service
systemctl --user start ollama
```

---

## Issue: qwen_dispatch returns `NO_MATCH`

**Cause:** The trigger does not match any record in `qwen_tasks`.

**Fix:**

```sql
-- Add a trigger to an existing task:
UPDATE qwen_tasks SET trigger = trigger || ',new trigger'
WHERE task_id = 'qt_XXX';
```

---

## Issue: stale skills-plugin folders accumulate

**Fix:**

```bash
/ai/scripts/cleanup_sessions.sh
# Also runs automatically when you send "about yourself"
```

---

## Issue: MCP server fails to connect

1. Validate `claude_desktop_config.json` for JSON syntax errors
2. Confirm `node` / `npx` / `uvx` are on PATH: `which node npx uvx`
3. Restart Claude Desktop
4. Check logs: `~/.config/Claude/logs/`
