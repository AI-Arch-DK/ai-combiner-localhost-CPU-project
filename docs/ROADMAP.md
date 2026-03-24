# ROADMAP — AI Combiner

## Current Status: v0.3.1

---

## ✅ v0.1.0 — Initialization (2026-03-14)

- [x] Debian + Ollama + qwen2.5:7b-instruct-q4_K_M
- [x] `/ai/` directory structure (db, scripts, workspace)
- [x] 7 local databases
- [x] 12 MCP servers
- [x] 20 qwen_tasks + 12 parallel_config strategies
- [x] First workflows: MikroTik, Cisco, L2TP

## ✅ v0.2.0 — Skills (2026-03-18)

- [x] Skill `sales-consultant`
- [x] Skill `mcp-builder`
- [x] Active skills-plugin session `1492d8b0`

## ✅ v0.3.0 — Startup Automation (2026-03-19)

- [x] `check_resources.sh` v4 — 7 lines, ~80 tokens
- [x] `cleanup_sessions.sh` — auto-cleanup of duplicate sessions
- [x] Trigger "about yourself" → auto-start
- [x] qt_021/022/023 + pc_013
- [x] Security check before every push
- [x] Full project documentation

## ✅ v0.3.1 — Open Source Readiness (2026-03-23)

- [x] Full open-source community setup (CI, pre-commit, SECURITY, CODEOWNERS)
- [x] All documentation translated to English
- [x] `git-ops` skill + routing rules (qt_029–qt_032, pc_014–pc_015)
- [x] SSH-based git push via ssh-agent
- [x] `git_ops.db` for git workflow knowledge
- [x] 8 pre-commit hooks — all passing

---

## 🔄 v0.4.0 — Routing Improvements (planned)

- [ ] RAG or lightweight FTS augmentation
- [ ] Auto request-type detection via qt_002
- [ ] Auto strategy selection from parallel_config
- [ ] routing_log — record all decisions and token usage
- [ ] Efficiency dashboard (tokens_saved by strategy)

## 🔄 v0.5.0 — Multi-node (planned)

- [ ] Full kombain_shared.db sync implementation
- [ ] sales_manager-node: sales tasks → shared DB
- [ ] Office_MAIN-node: central orchestrator
- [ ] Conflict resolution via sync_log

## 🔄 v0.6.0 — GPU / Larger Model (planned)

- [ ] Upgrade to qwen2.5:14b or 32b
- [ ] CPU vs GPU performance benchmarks
- [ ] GGUF optimization for host architecture
