# Evaluation Criteria — Qwen Output Quality

## Qwen Response Scoring

### 1. Accuracy (0–5)

| Score | Description |
|---|---|
| 5 | Response 100% matches the task |
| 4 | Minor errors, core answer is correct |
| 3 | Half correct, half incorrect |
| 2 | Many errors, use with caution |
| 1 | Incorrect response |
| 0 | Hallucination / cancel_on_hallucination=true |

### 2. Format Compliance

| Category | Expected format | Check |
|---|---|---|
| classification | Single word from a predefined list | regex |
| extract_ip | One IP per line | line count |
| count | Integer | int(response) |
| translate | Translation only, no source words | absence check |
| summarize | 3–5 sentences | text length |
| network_mikrotik | CLI commands | presence of `/` |

### 3. Hallucination Detection

Automatic `qwen_cancel` triggers:

- Response contains non-existent IPs or commands
- Length exceeds `max_tokens * 1.5`
- Response is in the wrong language
- Response repeats the question instead of answering

## Task Rating

After execution, results are written to `user_feedback`:

```sql
INSERT INTO user_feedback VALUES (
  'fb_NNN', 'wf_NNN', 5, 'comment', CURRENT_TIMESTAMP
);
```
