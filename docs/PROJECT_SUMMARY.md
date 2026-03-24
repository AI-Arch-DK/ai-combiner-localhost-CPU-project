# Project Summary — AI Combiner

## What It Is

**AI Combiner** is a local AI orchestrator built on **Claude Desktop** + **Qwen 7B (Ollama)** + **13 MCP servers**. Runs entirely on CPU, no GPU required.

## By the Numbers

| Parameter | Value |
|---|---|
| Model | qwen2.5:7b-instruct-q4_K_M |
| Model size | 4.4 GB |
| Context | 32,768 tokens |
| CPU | i7-8565U 4c/8t, boost 4.6 GHz |
| RAM | 16 GB |
| Databases | 7 local + 1 shared |
| qwen_tasks | 28 active tasks |
| parallel_config | 15 strategies |
| Skills | 9 |
| Repo files | 65+ |

## Key Components

```text
Claude Desktop  →  conductor / orchestrator
Qwen 7B (local) →  worker (free)
Cerebras llama  →  fast external inference
Tavily / browser→  real-time data
routing.db      →  routing rules
```

## Token Economy Strategy

```text
Routine tasks   → Qwen (local, free)
Research        → Cerebras (serverless, free)
bash / sql code → Claude DIRECT (quality > speed)
Orchestration   → Claude (complex tasks only)
```

## Version

`v0.3.1` (2026-03-23) — see [CHANGELOG.md](../CHANGELOG.md) and [ROADMAP.md](ROADMAP.md)

## Repository

`github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project`
