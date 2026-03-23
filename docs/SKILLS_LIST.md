# Skills List — AI Combiner

Skills are located in:
`~/.config/Claude/local-agent-mode-sessions/skills-plugin/<UUID>/<SESSION>/skills/`

Current active session: `1492d8b0-9be6-4a0c-9849-4678886b68d1`

---

## Active Skills (9)

| Skill | Type | Trigger | Purpose |
|---|---|---|---|
| `docx` | public | Word doc, .docx, report, memo | Create / edit Word documents |
| `pdf` | public | .pdf, PDF form, fill PDF | Work with PDF files |
| `pptx` | public | deck, slides, presentation | Create presentations |
| `xlsx` | public | spreadsheet, .xlsx, Excel | Work with spreadsheets |
| `product-consultant` | user experience | project manager, sales team, product manager | Personal sales consultant |
| `mcp-builder` | public | MCP server, FastMCP, mcp tool | Build MCP servers |
| `skill-creator` | public | create skill, skill eval | Create / optimize skills |
| `schedule` | public | schedule, planning | Task scheduling |
| `git-ops` | public | push, commit, sync repo, git tag, git status | Git workflow operations |

---

## Skill Priority Rule

⚠️ Skills intercept requests **before** the systemPrompt. Always include in `SKILL.md`:

```yaml
description: |
  Do NOT activate when: "about yourself", "check resources".
  Use ONLY when the user mentions: <triggers>.
```

See `docs/CONTRIBUTING.md` for the full guide on adding skills.

---

## Auto-cleanup

`cleanup_sessions.sh` keeps only the most recent `skills-plugin` folder and archives older ones to `/tmp/sessions_archive/`.
