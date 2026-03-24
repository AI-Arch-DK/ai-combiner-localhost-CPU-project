# Data Flow — AI Combiner

## Request Cycle

```text
User sends a message
         │
         ▼
   Claude Desktop receives the message
         │
         ├──► [SKILL] intercepted? ──► yes → SKILL responds
         │ no
         ▼
   qwen_dispatch(user_query)
         │
         ├─ MATCH → Qwen executes → write to workflow_results
         ├─ CLAUDE_DIRECT → Claude executes directly
         ├─ NO_MATCH → strategy from parallel_config
         └─ TIMEOUT → HF + tavily in parallel
                    │
                    ▼
              qwen_get_late_answer
                    │
                    ▼
              Merge responses
         │
         ▼
   Result → workflow_results (kombain_local.db)
         │
         ▼
   Response to user
```

## Data Flows

| Flow | From | To |
|---|---|---|
| Request | Claude Desktop | qwen_dispatch |
| Qwen result | ollama:11434 | Claude |
| External data | HF / tavily / browser | Claude |
| DB write | Claude | kombain_local.db |
| Sync | kombain_local.db | kombain_shared.db |

## Token Costs

```text
Qwen tokens   → free (local)
Cerebras      → free (serverless, rate-limited)
Claude        → paid — minimizing Claude tokens is a core priority
```
