# External Connectors — Working with External Integrations

## Active Connectors (URL-based MCP)

| Connector | URL | When to use |
|---|---|---|
| **Miro** | <https://mcp.miro.com> | Architecture visualization, DAGs, diagrams |
| **Clay** | <https://api.clay.com/v3/mcp> | CRM, contact enrichment |
| **Gmail** | <https://gmail.mcp.claude.com/mcp> | Read / send emails |
| **Google Calendar** | <https://gcal.mcp.claude.com/mcp> | Tasks, reminders, scheduling |
| **HuggingFace** | <https://huggingface.co/mcp> | Inference, model search |

## Integration Patterns

### Miro — Architecture Visualization

```text
Trigger: "draw architecture" / "update diagram"
Route: orchestration → external_first
Claude → Miro:diagram_create(data) → board
Or: Claude → Miro:table_sync(data from DB)
```

### Gmail — Notifications

```text
Trigger: "send report" / "write an email"
Route: orchestration → external_first
Claude → Qwen generates text → Gmail:send
Claude → Gmail:search → process replies
```

### Google Calendar — Scheduling

```text
Trigger: "schedule" / "show calendar"
Route: orchestration → external_first
Claude → GCal:list_events → qwen:format_output → summary table
```

### Clay — Enrichment

```text
Trigger: "find contact" / "enrich data"
Route: research → external_first
Claude → Clay:enrich → write to network.db/devices
```

### HuggingFace — Inference

```text
Trigger: Qwen TIMEOUT / compare_options / research
Route: parallel / external_first
Claude → HF:hf_run_inference(cerebras) → merge with Qwen
~500 t/s vs ~13 t/s for Qwen — use for latency-sensitive tasks
```

## Usage Rules

| Rule | Reason |
|---|---|
| Use external connectors only when necessary | Conserve Claude tokens |
| Use Qwen to format results | Free |
| Use orchestration strategy | For multi-tool tasks |
| Write result to DB before responding | Ensures persistence |

## Configuration

See `docs/MCP_SETUP.md` — section "Cloud MCP Servers".
