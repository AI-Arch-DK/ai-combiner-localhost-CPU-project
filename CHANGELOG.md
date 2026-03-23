# CHANGELOG

## [0.3.1] — 2026-03-23

### Added

- `git-ops` skill and routing rules (qt_029–qt_032, pc_014–pc_015)
- SSH key for GitHub push via ssh-agent
- `git_ops.db` — dedicated database for git operation workflows
- Full open-source community setup: CI, pre-commit (8 hooks passing), SECURITY.md, CODEOWNERS, MAINTAINERS.md
- `.vscode/` workspace config and extension recommendations
- `scripts/git_sync.sh` — one-command commit and push helper
- All documentation translated to English

### Fixed

- Hardcoded `/home/debianAI/` path in `cleanup_sessions.sh` replaced with `$HOME/`
- `pull_request_template.md` — removed escaped pipe characters
- `CODEOWNERS` moved to `.github/` (correct GitHub location)
- Markdownlint errors across 29 files (MD022, MD031, MD032, MD040)
- `SKILLS_LIST.md` table column count mismatch
- `db/routing_schema.sql` normalized for sqlfluff compatibility

---

## [0.3.0] — 2026-03-19

### Added

- `check_resources.sh` v4 — 7-line token-optimized startup dashboard
- `cleanup_sessions.sh` — automatic cleanup of stale skills-plugin sessions
- Session start trigger: "about yourself" → auto-runs check_resources.sh
- qt_021/022/023 + pc_013
- GitHub Actions security workflow
- All database schemas published
- Routing rules in JSON
- CATALOG.md, NIGHT_LEARNING.md, SQL_INDEXING.md, HALLUCINATION_GUARD.md, EXTERNAL_CONNECTORS.md
- DB_RELATIONS.md, backup_mcp.sh

### Fixed

- Removed 3 stale session directories
- cleanup_sessions.sh prevents accumulation of duplicate sessions
- NIGHT_LEARNING: added pipeline + error handling
- SQL_INDEXING: added EXPLAIN + monitoring queries
- HALLUCINATION_GUARD: full confidence_score() implementation

### Security

- Pre-push validation via Qwen (qt_023)
- backup_mcp.sh: sanitized MCP server backup (no tokens)

### Breaking Changes

_v0.3.0 has no breaking changes. All files are backward compatible with v0.2.0._

---

## [0.2.0] — 2026-03-18

### Added

- Skill `ib-consultant` (security consultant)
- Skill `mcp-builder` (MCP server builder)
- Active skills-plugin session: `1492d8b0...`

### Breaking Changes

_v0.2.0 has no breaking changes._

---

## [0.1.0] — 2026-03-14

### Added

- AI Combiner initialized on Debian
- Ollama + qwen2.5:7b-instruct-q4_K_M installed
- 7 local databases, 12 MCP servers, 20 qwen_tasks
- First workflows: MikroTik, Cisco, L2TP

### Breaking Changes

_First release, no breaking changes apply._
