# Routing Logic — AI Combiner

## Request Processing Order

```text
USER REQUEST
       │
       ▼
┌─────────────────────────────────────────┐
│  [1] SKILLS (SKILL.md)                  │  ← intercept FIRST
│  ~/.config/Claude/local-agent-mode-     │
│  sessions/skills-plugin/1492d8b0.../    │
│  Trigger matched? → skill responds      │
└──────────────┬──────────────────────────┘
               │ no match
               ▼
┌─────────────────────────────────────────┐
│  [2] systemPrompt                       │  ← claude_desktop_config.json
│  Priority #1: "about yourself" →        │
│  shell → /ai/scripts/check_resources.sh │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  [3] qwen_dispatch(user_query)          │  ← always called first among tools
│                                         │
│  MATCH   → Qwen responds → return as-is │
│  NO_MATCH → fall through to strategy    │
│  TIMEOUT + required=false →             │
│     HF + tavily in parallel             │
│     → qwen_get_late_answer              │
│  HALLUCINATION → qwen_cancel            │
│     → external tools                    │
└──────────────┬──────────────────────────┘
               │ NO_MATCH
               ▼
┌─────────────────────────────────────────┐
│  [4] parallel_config strategy           │
│                                         │
│  qwen_only       → Qwen only            │
│  parallel        → Qwen + HF + tavily   │
│  external_first  → HF + browser + tavily│
│  qwen_with_context → tavily → Qwen      │
└──────────────┬──────────────────────────┘
               │
               ▼
         RESULT → DB → user
```

## Strategy Matrix

| Task type | Strategy | Qwen | HF | Tavily | Browser |
|---|---|---|---|---|---|
| network_config | parallel | ✅ | ✅ | ✅ | ✅ |
| explain_short | qwen_only | ✅ | ❌ | ❌ | ❌ |
| code_bash | qwen_only | ✅ | ❌ | ❌ | ❌ |
| code_sql | qwen_only | ✅ | ❌ | ❌ | ❌ |
| research | external_first | ❌ | ✅ | ✅ | ✅ |
| system_check | qwen_only | ✅ | ❌ | ❌ | ❌ |
| extract_ip | qwen_only | ✅ | ❌ | ❌ | ❌ |
| orchestration | external_first | ❌ | ✅ | ✅ | ✅ |
| validate_config | qwen_with_context | ✅ | ❌ | ✅ | ❌ |
| format_output | qwen_only | ✅ | ❌ | ❌ | ❌ |
| compare_options | parallel | ✅ | ✅ | ✅ | ❌ |
| fact_check | qwen_with_context | ✅ | ❌ | ✅ | ❌ |
| startup_check | qwen_only | ✅ | ❌ | ❌ | ❌ |
| git_ops | qwen_only | ✅ | ❌ | ❌ | ❌ |
| git_check | qwen_only | ✅ | ❌ | ❌ | ❌ |

## CLAUDE_DIRECT Markers

`qt_019` (bash) and `qt_020` (sql) are special markers.
When qwen_dispatch returns `code_direct` → Claude executes the task directly, bypassing Qwen.
This saves local resources for tasks where Claude produces better results on its own.

## Token Economy

| Model | Role | Tokens / request |
|---|---|---|
| Qwen 7B (local) | worker | 10–200 (free) |
| Claude Sonnet | conductor | minimal (decisions only) |
| HF Cerebras | external | parallel, only when needed |
| Tavily | search | only for external / context strategies |
