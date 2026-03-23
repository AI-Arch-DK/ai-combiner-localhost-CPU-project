# Glossary — AI Combiner

| Term | Description |
|---|---|
| **AI Combiner** | Local orchestrator: Claude + Qwen + MCP |
| **Claude Desktop** | Conductor / orchestrator. Delegates tasks across tools |
| **Qwen / Ollama** | Local LLM worker. Free, CPU-only |
| **MCP** | Model Context Protocol. Standard for connecting tools to Claude |
| **qwen_dispatch** | First tool called for every request. The Qwen router |
| **qwen_tasks** | Table in routing.db. Maps triggers → prompt → Qwen |
| **parallel_config** | Routing strategy table (15 records) |
| **SKILL.md** | Skill file. Intercepts requests before systemPrompt |
| **skills-plugin** | Skills folder inside `local-agent-mode-sessions` |
| **systemPrompt** | Main Claude prompt. Defined in `claude_desktop_config.json` |
| **kombain_local.db** | Local node database (workflows, results, knowledge) |
| **kombain_shared.db** | Shared database across nodes via sync_log |
| **sync_log** | Synchronization table between nodes |
| **Office_MAIN** | Future central node of the office AI combiner |
| **debianAI-node** | Current worker node (localhost CPU, Debian) |
| **sales_manager-node** | Security / sales node |
| **CLAUDE_DIRECT** | Marker in qwen_tasks. Claude executes directly, bypassing Qwen |
| **NO_MATCH** | qwen_dispatch response: no task found. Falls through to strategy |
| **qwen_only** | Strategy: Qwen only, no external calls |
| **parallel** | Strategy: Qwen + HF + tavily simultaneously |
| **external_first** | Strategy: HF + browser + tavily |
| **qwen_with_context** | Strategy: tavily fetches data → Qwen processes it |
| **check_resources.sh** | Startup script. 7 lines, ~80 tokens |
| **cleanup_sessions.sh** | Auto-cleanup of skills-plugin duplicates |
| **health_check.sh** | OK / WARN / FAIL check for all components |
| **Q4_K_M** | 4-bit quantization with mixed precision. Quality/size balance |
| **routing_log** | Table that logs routing decisions and token savings |
| **qt_019/020** | CLAUDE_DIRECT markers. bash/sql → Claude writes directly |
| **git_ops** | Routing category for git operations (qt_029–031, pc_014) |
| **git_check** | Routing category for fast git status checks (qt_032, pc_015) |
