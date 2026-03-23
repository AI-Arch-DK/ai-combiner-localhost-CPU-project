# Upgrade Plan v0.4.0

> Based on a deep review across 3 HuggingFace models (Cerebras llama3.1-8b)
> and a Qwen priority evaluation | 2026-03-20

---

## Top 5 Critical Upgrades

### 1. Auto-classification of requests (qt_002)

```sql
-- Every request passes through qt_002 → result is stored
ALTER TABLE routing_log ADD COLUMN auto_category TEXT;
ALTER TABLE routing_log ADD COLUMN confidence REAL DEFAULT 0.0;
```

**Implementation:**

1. `qwen_dispatch(user_query)` → always runs `qt_002` (classification) first
2. Result → auto-selects strategy from `parallel_config`
3. Written to `routing_log.auto_category`

### 2. routing_log dashboard

```sql
-- Dashboard data query
SELECT selected_model, COUNT(*) AS calls,
       SUM(tokens_saved) AS saved,
       AVG(tokens_saved) AS avg_saved
FROM routing_log
GROUP BY selected_model ORDER BY calls DESC;
```

**Implementation:** HTML dashboard via Claude Artifact or `flask --app dashboard.py run`

### 3. Backup restore test (compliance c007/c008)

```bash
# backup_restore_test.sh
BACKUP=$(ls -t /ai/backup/*.db 2>/dev/null | head -1)
[ -z "$BACKUP" ] && echo "FAIL: no backup" && exit 1
sqlite3 "$BACKUP" "SELECT COUNT(*) FROM qwen_tasks;" \
  && echo "PASS: restore OK" || echo "FAIL: restore broken"
```

### 4. Retry logic in night_learning

```python
# Add to run_night_learning.py:
for attempt in range(3):  # 3 attempts
    try:
        r = subprocess.run([...], timeout=90)
        if r.returncode == 0:
            break
    except subprocess.TimeoutExpired:
        time.sleep(10)  # pause before retry
```

### 5. health_check.sh metrics

```bash
# Add to health_check.sh:

# Ollama latency
START=$(date +%s%N)
curl -s http://localhost:11434/api/tags > /dev/null
LAT=$(( ($(date +%s%N) - START) / 1000000 ))
[ "$LAT" -lt 500 ] && ok "Ollama latency: ${LAT}ms" || warn "Ollama slow: ${LAT}ms"

# qwen_knowledge growth
QK=$(sqlite3 /ai/kombain/kombain_local.db "SELECT COUNT(*) FROM qwen_knowledge;" 2>/dev/null)
[ "$QK" -gt 0 ] && ok "qwen_knowledge: $QK" || warn "qwen_knowledge empty"

# routing_log accumulation
RL=$(sqlite3 /ai/db/routing.db "SELECT COUNT(*) FROM routing_log;" 2>/dev/null)
ok "routing_log: $RL records"
```

---

## Quick Wins (< 1 day)

| # | Action | File | Time |
|---|---|---|---|
| 1 | Retry logic in night_learning | `run_night_learning.py` | 30 min |
| 2 | Backup restore test | `scripts/backup_restore_test.sh` | 20 min |
| 3 | Ollama latency metric in health_check | `scripts/health_check.sh` | 15 min |
| 4 | routing_log indexes | `db/schemas/routing_db.sql` | 10 min |
| 5 | Close compliance c007/c008 | `db/data/compliance_checklist.json` | 10 min |

---

## New Ideas from HF Models

### Intelligence Upgrades (CPU-only)

| Option | What it adds | Complexity |
|---|---|---|
| **spaCy NER** (`pip install spacy`) | Entity extraction (IP/host/protocol) before Qwen | Low |
| **sentence-transformers** | Semantic search over qwen_knowledge | Medium |
| **qwen_knowledge ranking** | Verified records injected into Qwen prompt | Low |

### What breaks first when adding 5 more MCP servers

1. **RAM** — each Node.js MCP server uses ~50–100 MB. +5 = +250–500 MB
2. **tool_search slows down** — Claude Desktop scans more servers
3. **Name conflicts** — tools with identical names collide

**Solution:** `tools.db` stores priorities; Claude selects the right ones.

### Highest-impact UX upgrade

**qwen_knowledge in prompt** — before sending a request to Qwen, check if a verified answer already exists in the knowledge base → return it at 0 tokens; otherwise generate.

---

## Full Roadmap

### v0.4.0 (goal: routing intelligence)

- [ ] Auto-classification via qt_002 before every request
- [ ] routing_log: record all decisions + tokens_saved
- [ ] HTML dashboard (Claude Artifact or Flask)
- [ ] confidence_score() integrated into qwen_dispatch
- [ ] Backup restore test (compliance 14/14)
- [ ] Retry in night_learning (3 attempts)
- [ ] Ollama latency in health_check

### v0.5.0 (goal: multi-node)

- [ ] sync_to_shared.sh — full sync_log protocol
- [ ] sales_manager-node connects to kombain_shared.db
- [ ] Conflict resolution in sync_log
- [ ] Semantic search over qwen_knowledge (sentence-transformers)

### v0.6.0 (goal: larger model)

- [ ] GPU or qwen2.5:14b when more RAM is available
- [ ] spaCy NER as pre-processing step
- [ ] qwen_knowledge → prompt (RAG pattern)

---

## v0.4.0 Success Metrics

| Metric | Target | How to measure |
|---|---|---|
| routing_log records | > 100 / week | `SELECT COUNT(*) FROM routing_log;` |
| tokens_saved total | > 10,000 | `SELECT SUM(tokens_saved) FROM routing_log;` |
| qwen_knowledge verified | > 50 | `SELECT SUM(verified) FROM qwen_knowledge;` |
| compliance | 14/14 | `db/data/compliance_checklist.json` |
| night_learning errors | 0 / night | `/ai/logs/learning.log` |
