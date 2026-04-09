#!/usr/bin/env python3
"""
bg_worker_v2.py - KAIROS pattern (from claurst) + ultra-light spectral health.
Tick every 300s, action budget 15s, brief mode, append-only daily log.
Usage: python3 bg_worker_v2.py [--once] [--tick N]
Cron:  */5 * * * * python3 /ai/scripts/bg_worker_v2.py --once >> /ai/logs/worker_$(date +%%Y-%%m-%%d).log 2>&1
"""
import os, sys, sqlite3, subprocess, time, json, urllib.request
import numpy as np
from datetime import datetime

sys.path.insert(0, "/ai/scripts")

DB_KOMBAIN    = "/ai/kombain/kombain_local.db"
DB_ROUTING    = "/ai/db/routing.db"
LOG_DIR       = "/ai/logs"
TICK_SEC      = int(os.environ.get("WORKER_TICK", "300"))
ACTION_BUDGET = 15
OLLAMA_URL    = "http://localhost:11434/api/generate"
MODEL         = "qwen2.5:7b-instruct-q4_K_M"
os.makedirs(LOG_DIR, exist_ok=True)

def load_env():
    cfg = "/home/debai/.config/Claude/config.env"
    if os.path.exists(cfg):
        out = subprocess.run(
            ["bash","-c","set -a; source "+cfg+"; set +a; env"],
            capture_output=True, text=True)
        for line in out.stdout.splitlines():
            if "=" in line:
                k,_,v = line.partition("=")
                os.environ.setdefault(k,v)
load_env()

def daily_log():
    return os.path.join(LOG_DIR, "worker_"+datetime.now().strftime("%Y-%m-%d")+".log")

def log(msg, level="INFO"):
    ts = datetime.now().strftime("%H:%M:%S")
    line = f"[{ts}] {level} {msg}"
    print(line, flush=True)
    with open(daily_log(), "a") as f:
        f.write(line + "\n")

def qwen_brief(prompt, budget_sec=ACTION_BUDGET):
    try:
        payload = json.dumps({"model":MODEL,"prompt":prompt,"stream":False,
            "options":{"num_predict":40,"temperature":0.1}}).encode()
        req = urllib.request.Request(OLLAMA_URL, data=payload,
            headers={"Content-Type":"application/json"})
        with urllib.request.urlopen(req, timeout=budget_sec) as r:
            return json.loads(r.read()).get("response","").strip()
    except Exception as e:
        log(f"qwen_brief err: {e}", "WARN"); return ""

def action_check_ollama():
    try:
        with urllib.request.urlopen("http://localhost:11434/api/tags", timeout=3) as r:
            d = json.loads(r.read())
        log(f"ollama OK: {len(d.get('models',[]))} models"); return True
    except Exception:
        log("ollama DOWN", "WARN"); return False

def action_scan_routing_log():
    try:
        con = sqlite3.connect(DB_ROUTING)
        rows = con.execute(
            "SELECT task_type, COUNT(*) as cnt FROM routing_log "
            "WHERE created_at >= datetime('now','-1 hour') "
            "GROUP BY task_type ORDER BY cnt DESC LIMIT 3").fetchall()
        con.close()
        if rows: log("routing_log 1h: " + ", ".join(f"{r[0]}x{r[1]}" for r in rows))
        return rows
    except Exception as e:
        log(f"routing_log scan err: {e}", "WARN"); return []

def action_scan_workflow_results():
    try:
        state_file = os.path.join(LOG_DIR, ".worker_last_wf")
        last_id = int(open(state_file).read().strip() or "0") if os.path.exists(state_file) else 0
        con = sqlite3.connect(DB_KOMBAIN)
        con.text_factory = lambda b: b.decode("utf-8", errors="replace")
        rows = con.execute(
            "SELECT rowid, status, output FROM workflow_results "
            "WHERE rowid > ? ORDER BY rowid DESC LIMIT 5", (last_id,)).fetchall()
        if rows:
            open(state_file,"w").write(str(max(r[0] for r in rows)))
            log(f"new workflow_results: {len(rows)}")
            summary = "; ".join(f"{r[1]}:{(r[2] or '')[:40]}" for r in rows[:3])
            insight = qwen_brief(f"\u041a\u043e\u0440\u043e\u0442\u043a\u043e (1 \u043f\u0440\u0435\u0434\u043b\u043e\u0436\u0435\u043d\u0438\u0435): \u0447\u0442\u043e \u0432\u0430\u0436\u043d\u043e: {summary}")
            if insight: log(f"qwen insight: {insight}")
        con.close(); return rows
    except Exception as e:
        log(f"workflow scan err: {e}", "WARN"); return []

def action_check_enrich_needed():
    try:
        f = "/ai/logs/enrich.log"
        if not os.path.exists(f):
            log("enrich: never run"); return
        age_h = (time.time() - os.path.getmtime(f)) / 3600
        log(f"enrich: last run {age_h:.1f}h ago {'- OK' if age_h <= 6 else '- cron handles'}")
    except Exception as e:
        log(f"enrich check err: {e}", "WARN")

def action_db_stats():
    try:
        con = sqlite3.connect(DB_KOMBAIN)
        con.text_factory = lambda b: b.decode("utf-8", errors="replace")
        qk = con.execute("SELECT COUNT(*) FROM qwen_knowledge").fetchone()[0]
        cm = con.execute("SELECT COUNT(*) FROM claude_memory").fetchone()[0]
        con.close(); log(f"db: qwen_knowledge={qk} claude_memory={cm}")
    except Exception as e:
        log(f"db_stats err: {e}", "WARN")

def _run_with_budget(cmd, budget_sec):
    t0 = time.time()
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=budget_sec)
        log(f"cmd [{time.time()-t0:.1f}s]: {cmd[:50]} -> exit={r.returncode}")
        return r.returncode == 0
    except subprocess.TimeoutExpired:
        log(f"cmd TIMEOUT [{budget_sec}s]: {cmd[:50]}", "WARN"); return False

# ── Ultra-light spectral health (no eigenvalues, ~0.05s CPU) ────

def _tfidf_embeddings(texts, max_features=128):
    import re
    from collections import Counter
    tokenize = lambda t: re.findall(r"[\u0430-\u044f\u0451a-z]+", t.lower())
    tokenized = [tokenize(t) for t in texts]
    all_words = [w for doc in tokenized for w in doc]
    vocab = [w for w, _ in Counter(all_words).most_common(max_features)]
    word2idx = {w: i for i, w in enumerate(vocab)}
    V = len(vocab); N = len(texts)
    X = np.zeros((N, V), dtype=np.float32)
    for i, doc in enumerate(tokenized):
        if not doc: continue
        tf = Counter(doc); total = len(doc)
        for w, cnt in tf.items():
            if w in word2idx: X[i, word2idx[w]] = cnt / total
    df = np.sum(X > 0, axis=0).astype(np.float32)
    X = X * (np.log((N + 1) / (df + 1)) + 1.0)
    norms = np.linalg.norm(X, axis=1, keepdims=True)
    return X / np.where(norms < 1e-8, 1.0, norms)

def load_embeddings_with_ids(min_len=30):
    con = sqlite3.connect(DB_KOMBAIN)
    con.text_factory = lambda b: b.decode("utf-8", errors="replace")
    rows = con.execute(
        "SELECT id, content FROM qwen_knowledge "
        "WHERE length(content) >= ? AND verified >= 0 ORDER BY id", (min_len,)).fetchall()
    con.close()
    if not rows: return np.zeros((0,1), dtype=np.float32), []
    return _tfidf_embeddings([r[1] for r in rows]), [r[0] for r in rows]

def fast_embedding_health(embeddings):
    """
    Ultra-light analysis: variance + cosine similarity + spread + outliers.
    No eigen decomposition. CPU: ~0.01-0.05s.
    """
    if len(embeddings) < 10:
        return {"status":"skip_small","n":len(embeddings)}
    X = embeddings.astype(np.float32); n = len(X)
    variance = float(np.mean(np.var(X, axis=0)))
    sample = X if n <= 100 else X[np.random.choice(n, 100, replace=False)]
    sim = np.dot(sample, sample.T); ns = len(sample)
    avg_sim = float((np.sum(sim) - ns) / max(ns*(ns-1), 1))
    centroid = np.mean(X, axis=0)
    distances = np.linalg.norm(X - centroid, axis=1)
    spread = float(np.mean(distances))
    p90 = float(np.percentile(distances, 90))
    outliers = int(np.sum(distances > p90))
    return {"n":n, "variance":round(variance,4), "avg_similarity":round(avg_sim,4),
            "spread":round(spread,4), "outlier_ratio":round(outliers/n,3), "p90":round(p90,4)}

def interpret_health(stats):
    if stats.get("status") == "skip_small":
        return f"skip: n={stats.get('n',0)} < 10"
    flags = []
    if stats["variance"] < 0.01:       flags.append("LOW_DIVERSITY")
    if stats["avg_similarity"] > 0.8:  flags.append("HIGH_DUPLICATES")
    if stats["spread"] < 0.1:          flags.append("MEMORY_COLLAPSED")
    if stats["outlier_ratio"] > 0.2:   flags.append("HIGH_NOISE")
    status = "HEALTHY" if not flags else " | ".join(flags)
    return (f"n={stats['n']} var={stats['variance']} sim={stats['avg_similarity']} "
            f"spread={stats['spread']} noise={stats['outlier_ratio']} => {status}")

def simple_prune(embeddings, ids, top_pct=0.10, max_remove=10):
    """Returns list of ids furthest from centroid (outliers/noise)."""
    if len(embeddings) < 20: return []
    X = embeddings.astype(np.float32)
    distances = np.linalg.norm(X - np.mean(X, axis=0), axis=1)
    cutoff = np.percentile(distances, 100*(1-top_pct))
    idx = np.where(distances > cutoff)[0]
    return [ids[i] for i in idx[:max_remove]]

def delete_from_memory(record_id):
    """Soft-delete: sets verified=-1. Parameterized, sqlmini-safe."""
    try:
        assert isinstance(record_id, int)
        con = sqlite3.connect(DB_KOMBAIN)
        con.execute("UPDATE qwen_knowledge SET verified=-1, "
                    "updated_at=datetime('now') WHERE id=? AND verified=0", (record_id,))
        affected = con.execute("SELECT changes()").fetchone()[0]
        con.commit(); con.close(); return affected > 0
    except Exception as e:
        log(f"delete_from_memory err: {e}", "WARN"); return False

def action_embedding_health():
    """Spectral health tick action. CPU: ~0.04s for 150 records."""
    t0 = time.time()
    embeddings, ids = load_embeddings_with_ids()
    if len(embeddings) == 0:
        log("spectral: no data"); return
    stats = fast_embedding_health(embeddings)
    log(f"spectral [{time.time()-t0:.2f}s]: {interpret_health(stats)}")
    should_prune = (stats.get("outlier_ratio",0) > 0.15 or
                    stats.get("avg_similarity",0) > 0.85)
    if should_prune:
        prune_ids = simple_prune(embeddings, ids)
        if prune_ids:
            log(f"spectral: pruning {len(prune_ids)} outliers (soft-delete)")
            removed = sum(1 for rid in prune_ids if delete_from_memory(rid))
            log(f"spectral: pruned {removed}/{len(prune_ids)}")
            try:
                con = sqlite3.connect(DB_KOMBAIN)
                con.execute("INSERT INTO qwen_knowledge_fts(qwen_knowledge_fts) VALUES('rebuild')")
                con.commit(); con.close(); log("spectral: FTS rebuilt")
            except Exception as e:
                log(f"spectral: FTS err: {e}", "WARN")
    else:
        log("spectral: HEALTHY - no pruning")
    log(f"spectral: done [{time.time()-t0:.3f}s]")

def run_tick():
    TICK_ACTIONS = [
        action_check_ollama,
        action_scan_routing_log,
        action_scan_workflow_results,
        action_check_enrich_needed,
        action_db_stats,
        action_embedding_health,
    ]
    log("=== TICK START ===")
    t0 = time.time()
    for action in TICK_ACTIONS:
        at = time.time()
        try:
            action()
        except Exception as e:
            log(f"action {action.__name__} crashed: {e}", "ERR")
        elapsed = time.time() - at
        if elapsed > ACTION_BUDGET:
            log(f"{action.__name__} over budget: {elapsed:.1f}s > {ACTION_BUDGET}s", "WARN")
    log(f"=== TICK DONE [{time.time()-t0:.1f}s] ===")

def main():
    once = "--once" in sys.argv
    tick = TICK_SEC
    for i, arg in enumerate(sys.argv):
        if arg == "--tick" and i+1 < len(sys.argv):
            tick = int(sys.argv[i+1])
    if once:
        run_tick(); return
    log(f"bg_worker_v2 start - tick={tick}s budget={ACTION_BUDGET}s")
    while True:
        run_tick(); time.sleep(tick)

if __name__ == "__main__":
    main()
