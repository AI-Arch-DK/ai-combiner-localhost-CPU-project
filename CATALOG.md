# CATALOG — AI Combiner Repository Index

> Quick navigation: find any file in under 3 seconds.

---

## 📦 Root Files

| File | Purpose |
|---|---|
| [README.md](README.md) | Overview, quick start, hardware, MCP |
| [CHANGELOG.md](CHANGELOG.md) | Version history v0.1–v0.3 |
| [VERSION](VERSION) | Current version (0.3.0) |
| [.gitignore](.gitignore) | Blocks secrets and .db files |

---

## 📖 docs/ — Documentation

### Architecture

| File | Purpose |
|---|---|
| [architecture.md](docs/architecture.md) | Layer priorities, orchestration logic |
| [routing_logic.md](docs/routing_logic.md) | ASCII diagram + 13-strategy matrix |
| [DATA_FLOW.md](docs/DATA_FLOW.md) | Data flows, tokens, database writes |
| [SYSTEM_DESCRIPTION.md](docs/SYSTEM_DESCRIPTION.md) | Hardware, all MCPs, all DBs, routing rules |
| [OFFICE_MAIN_CONCEPT.md](docs/OFFICE_MAIN_CONCEPT.md) | Multi-node design, kombain_shared.db sync |
| [PERFORMANCE.md](docs/PERFORMANCE.md) | Qwen CPU benchmarks vs Cerebras |

### Setup

| File | Purpose |
|---|---|
| [MCP_SETUP.md](docs/MCP_SETUP.md) | Configuring all 13 MCP servers |
| [SKILLS_LIST.md](docs/SKILLS_LIST.md) | 8 skills: triggers, exclusions, rules |
| [CONTRIBUTING.md](docs/CONTRIBUTING.md) | How to add qwen_task / skill / strategy |
| [COMMIT_GUIDE.md](docs/COMMIT_GUIDE.md) | Commit message conventions |

### Reference

| File | Purpose |
|---|---|
| [GLOSSARY.md](docs/GLOSSARY.md) | 25 system-specific terms |
| [FAQ.md](docs/FAQ.md) | 8 frequently asked questions |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | 5 common issues + solutions |
| [QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) | Cheat sheet: all commands in one place |
| [NETWORK_TEMPLATES.md](docs/NETWORK_TEMPLATES.md) | 20 FAQ entries: MikroTik / Cisco / sales |
| [PROJECT_SUMMARY.md](docs/PROJECT_SUMMARY.md) | High-level project summary |

### Development

| File | Purpose |
|---|---|
| [ROADMAP.md](docs/ROADMAP.md) | v0.1–v0.6: completed and planned work |
| [EVALUATION_CRITERIA.md](docs/EVALUATION_CRITERIA.md) | Qwen output quality criteria |
| [TESTING.md](docs/TESTING.md) | Test matrix, CI/CD |
| [MONITORING.md](docs/MONITORING.md) | Metrics, thresholds, cron jobs |
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | Deployment + rollback procedure |

### Security

| File | Purpose |
|---|---|
| [SECURITY_CHECKLIST.md](docs/SECURITY_CHECKLIST.md) | Rules + pre-push verification command |
| [DATA_POLICY.md](docs/DATA_POLICY.md) | What is stored and what is transmitted |

---

## 🛠 scripts/ — Shell Scripts

| Script | Purpose | Trigger |
|---|---|---|
| [check_resources.sh](scripts/check_resources.sh) | 7 lines: HOST│DB│MCP│ROUTING│SKILLS│CLEANUP | `about yourself` |
| [health_check.sh](scripts/health_check.sh) | OK/WARN/FAIL for all components | manual / cron |
| [install.sh](scripts/install.sh) | 6 steps: apt→ollama→model→/ai/→scripts→DB | first install |
| [init_db.sh](scripts/init_db.sh) | Initialize 8 databases from schemas | reset / first install |
| [backup_db.sh](scripts/backup_db.sh) | Back up all DBs, remove backups older than 7 days | manual / cron 3:00 |
| [cleanup_sessions.sh](scripts/cleanup_sessions.sh) | Remove stale skills-plugin sessions | auto via check_resources |
| [audit_security.sh](scripts/audit_security.sh) | Secrets, permissions, ports, files | manual |
| [git_sync.sh](scripts/git_sync.sh) | Commit + push to upstream in one command | manual |
| [sync_to_shared.sh](scripts/sync_to_shared.sh) | Sync to kombain_shared.db | manual / v0.5 auto |

---

## 🗄 db/ — Databases

### schemas/

| File | Database | Key tables |
|---|---|---|
| routing_db.sql | routing.db | qwen_tasks (28) + parallel_config (15) |
| project_db.sql | project.db | goals, roadmap, actions_log + FTS |
| network_db.sql | network.db | devices, configs, templates + FTS |
| tokens_db.sql | tokens.db | accounts, usage, budget |
| tools_db.sql | tools.db | tools (8), tool_usage |
| models_db.sql | models.db | models (5), performance |
| kombain_local_db.sql | kombain_local.db | workflows, results, feedback, knowledge |
| kombain_shared_db.sql | kombain_shared.db | same + sync_log (multi-node) |

### data/ — Seed Data

| File | Contents |
|---|---|
| qwen_tasks.json | 28 active tasks, prompts, categories |
| parallel_config.json | 15 routing strategies |
| models_seed.json | 5 models (Qwen / Claude / Cerebras / Tavily) |
| tools_seed.json | 8 MCP tools |
| token_budget_seed.json | 4 accounts + local_first strategy |
| model_performance_seed.json | 10 performance benchmarks |
| compliance_checklist.json | 14 items, 14/14 completed |

---

## ⚙️ config/

| File | Purpose |
|---|---|
| [ollama_model.md](config/ollama_model.md) | qwen2.5:7b parameters + CPU benchmarks |
| [ai-check-resources.service](config/ai-check-resources.service) | systemd user service for auto-start |
| [environment.example](config/environment.example) | Environment variable template (no secrets) |

---

## 🐛 .github/

| File | Purpose |
|---|---|
| ISSUE_TEMPLATE/bug_report.md | Bug report template |
| ISSUE_TEMPLATE/new_task.md | New qwen_task template |
| ISSUE_TEMPLATE/new_skill.md | New skill template |
| ISSUE_TEMPLATE/feature_request.md | Feature request template |
| pull_request_template.md | Security checklist for merge |
| workflows/ci.yml | CI: SQL, JSON, Markdown lint |
| workflows/security_check.yml | CI: blocks push if secrets detected |

---

## 📈 Repository Stats

| Parameter | Value |
|---|---|
| Total files | ~65 |
| Current version | 0.3.1 |
| qwen_tasks | 28 |
| parallel_config strategies | 15 |
| Pre-commit hooks | 8 (all passing) |
