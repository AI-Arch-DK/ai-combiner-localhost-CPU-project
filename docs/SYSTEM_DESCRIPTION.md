# AI Combiner — System Overview

> Local AI orchestrator built on Claude Desktop + Qwen/Ollama + MCP. CPU-only, localhost.

---

## 🖥 Hardware (Worker Node)

| Parameter | Value |
|---|---|
| CPU | Intel Core i7-8565U @ 1.80GHz (boost 4.6GHz) |
| Cores / Threads | 4 cores / 8 threads |
| L1d/L1i Cache | 128 KiB × 4 |
| L2 Cache | 1 MiB × 4 |
| L3 Cache | 8 MiB |
| Virtualization | VT-x |
| RAM | 16 GB (~10 GB in use, 14 GB swap) |
| Storage | NVMe 953.9 GB (nvme0n1) |
| OS | Debian Linux, kernel 6.19.6+deb14-amd64 |
| Ollama Model | qwen2.5:7b-instruct-q4_K_M |

---

## 📡 MCP Servers (Active)

| ID | MCP Server | Purpose |
|---|---|---|
| sqlite | mcp-server-sqlite | Database: routing / project / kombain_local |
| ollama-local | ollama-server (node) | Qwen local LLM (port 11434) |
| host-report | host-report-server (node) | Host monitoring (system_audit) |
| filesystem | @modelcontextprotocol/server-filesystem | Mount points: /home/sales_manager, /home/debianAI, /ai, /mnt/sda2, /tmp |
| shell | mcp-shell | Shell command execution |
| github-public | github-mcp-server | Public GitHub account (open source) |
| github-private | github-mcp-server | Private GitHub account (private projects) |
| huggingface | huggingface-server (node) | HF API + inference (cerebras/novita/together) |
| miro | mcp.miro.com | DAG / architecture visualization |
| tavily | tavily-mcp | Web search |
| browser | playwright browser-server | Browser automation (Chromium) |
| clay | api.clay.com/v3/mcp | CRM / data enrichment |
| gcal | gcal.mcp.claude.com | Google Calendar |
| gmail | gmail.mcp.claude.com | Gmail |

---

## 🗄 Databases

### Local (`/ai/db/`)

| Database | Tables | Size | Purpose |
|---|---|---|---|
| routing.db | 3 | 56K | qwen_tasks (21 tasks) + parallel_config (13 strategies) + routing_log |
| project.db | 3 | 108K | Projects, templates, full-text search |
| network.db | 3 | 100K | FAQ cache (network + sales tasks) |
| kombain_local.db | 5 | — | Local kombain: workflows, results, feedback, qwen_knowledge |
| models.db | 2 | 28K | Model registry |
| tokens.db | 3 | 36K | Token usage tracking per session |
| tools.db | 2 | 32K | Tool and MCP registry |

### Shared Database

| Database | Path | Purpose |
|---|---|---|
| kombain_shared.db | `/ai/external/sales_manager/kombain_shared.db` | Shared database for the future **Office_MAIN-nodes** — the central hub of the office AI kombain. Currently acts as a shared resource between the localhost node (debianAI) and the sales_manager node. |

> **Office_MAIN** — a concept for a large-scale office AI kombain with a central orchestrator node (Office_MAIN) and peripheral nodes (sales_manager, debianAI, etc.). `kombain_shared.db` is the synchronization point across all nodes.

---

## 🔀 Routing Rules

### parallel_config — Strategies (13)

| ID | Task Type | Strategy | Description |
|---|---|---|---|
| pc_001 | network_config | parallel | Qwen + HF + tavily in parallel — first quality result wins |
| pc_002 | explain_short | qwen_only | Explanations: Qwen only, fast |
| pc_003 | code_bash | qwen_only | Bash: Qwen only |
| pc_004 | code_sql | qwen_only | SQL: Qwen only |
| pc_005 | research | external_first | HF + browser + tavily |
| pc_006 | system_check | qwen_only | System checks: Qwen + host-report only |
| pc_007 | extract_ip | qwen_only | Extraction: Qwen only |
| pc_008 | orchestration | external_first | Claude + all tools |
| pc_009 | validate_config | qwen_with_context | Qwen processes tavily-sourced data |
| pc_010 | format_output | qwen_only | Output formatting: Qwen only |
| pc_011 | compare_options | parallel | Qwen + HF + tavily |
| pc_012 | fact_check | qwen_with_context | Fact-checking: Qwen + tavily |
| pc_013 | startup_check | qwen_only | Startup / resource check: Qwen + host-report, 10s timeout |
| pc_014 | git_ops | qwen_only | Git operations: Qwen + shell, SSH via ssh-agent, 120s timeout |
| pc_015 | git_check | qwen_only | Git status / log: Qwen + shell, no SSH required, 15s timeout |

### qwen_tasks — Active Tasks (28)

| ID | Triggers | Category | Description |
|---|---|---|---|
| qt_001 | check localhost, system status | system_check | Analyze system_audit report |
| qt_002 | classify request, identify type | classification | Classify incoming request |
| qt_003 | find IP, extract IP | extract_ip | Extract IP addresses from text |
| qt_004 | find ports, open ports | extract_ports | Extract ports from network report |
| qt_005 | find errors, error | extract_errors | Extract errors from logs |
| qt_006 | how many, count | count | Count elements |
| qt_007 | mikrotik config, mikrotik cli | network_mikrotik | MikroTik CLI commands |
| qt_008 | cisco config, configure cisco | network_cisco | Cisco configuration |
| qt_011 | translate, translation | translate | Text translation |
| qt_012 | summarize, summary, recap | summarize | Brief text summary |
| qt_013 | what is, explain briefly | explain_short | Brief explanation of a term |
| qt_014 | extract data, parse | extract_data | Extract structured data |
| qt_015 | verify commands, validate config | validate_config | Config validation via tavily |
| qt_016 | structure, make a table | format_output | Format external data |
| qt_017 | compare options, which is better | compare_options | Compare solution options |
| qt_018 | fact-check, find contradictions | fact_check | Fact verification and contradiction detection |
| qt_019 | bash script, shell command | code_direct | ⚡ CLAUDE_DIRECT: code written by Claude directly |
| qt_020 | sql query, write sql | code_direct | ⚡ CLAUDE_DIRECT: SQL written by Claude directly |
| qt_021 | about yourself, who are you, system info | system_check | Session start: run check_resources.sh |
| qt_022 | clean sessions, cleanup sessions | system_check | Clean up stale Claude Desktop session folders |
| qt_023 | security check, check before push | fact_check | Validate data before sending to an external resource |
| qt_029 | push, commit and push, save to github | git_ops | Git commit + push to upstream |
| qt_030 | sync repo, update from upstream, fetch upstream | git_ops | Git sync from upstream |
| qt_031 | create release, new version, git tag | git_ops | Git release + tag |
| qt_032 | what changed, git status, git log | git_check | Git repository status check |

---

## 🏗 Office_MAIN Concept (Roadmap)

```text
[Office_MAIN-node] ← Central Orchestrator
    │
    ├── [Product Manager]  ← Current worker node (localhost#1 CPU)
    │       kombain_local.db
    │
    ├── [sales_manager-node]   ← Sales Manager / Sales node (localhost#2 CPU)
    │       kombain_local.db
    │
    └── kombain_shared.db ← Shared database across all nodes
            /ai/external/sales_manager/kombain_shared.db
```

All nodes synchronize through `kombain_shared.db`. Office_MAIN serves as the chief conductor of the entire network.

---

## ⚙️ Configuration File

`~/.config/Claude/claude_desktop_config.json` — contains MCP server definitions + systemPrompt.

> ⚠️ This file contains API keys and is **not** committed to the repository (see `.gitignore`).
