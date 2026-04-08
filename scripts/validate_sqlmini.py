#!/usr/bin/env python3
"""
validate_sqlmini.py - Phase 1: sqlmini pattern utility.
validate_sqlmini(raw) -> (bool, msg)
execute_sqlmini(raw, db_path) -> (bool, rowid|msg)
execute_batch(responses, db_path) -> {ok, rejected, errors}
"""
import re, sqlite3, os, logging

os.makedirs("/ai/logs", exist_ok=True)
logging.basicConfig(filename="/ai/logs/sqlmini.log",
    format="[%(asctime)s] %(levelname)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S", level=logging.INFO)
log = logging.getLogger("sqlmini")

ALLOWED_TABLES = {"qwen_knowledge","claude_memory","claude_knowledge_base","kb_facts","routing_log","workflow_results"}
TABLE_REQUIRED = {
    "qwen_knowledge":       {"topic","title","content"},
    "claude_memory":        {"key","category","title","content"},
    "claude_knowledge_base":{"topic","content"},
    "kb_facts":             {"topic","fact"},
    "routing_log":          set(),
    "workflow_results":     set(),
}

_INSERT_RE = re.compile(
    r"INSERT\s+INTO\s+(\w+)\s*\(([^)]+)\)\s*VALUES\s*\((.+)\)\s*;?\s*$",
    re.IGNORECASE | re.DOTALL)

def _split_values(raw):
    vals, buf, in_q, q_char = [], [], False, None
    i = 0
    while i < len(raw):
        c = raw[i]
        if not in_q and c in ("'",'"'):
            in_q, q_char = True, c; buf.append(c)
        elif in_q and c == q_char:
            if i+1 < len(raw) and raw[i+1] == q_char:
                buf.append(c*2); i+=2; continue
            in_q = False; buf.append(c)
        elif not in_q and c == ',':
            vals.append(''.join(buf).strip()); buf = []
        else:
            buf.append(c)
        i += 1
    if buf: vals.append(''.join(buf).strip())
    return vals

def _unquote(v):
    v = v.strip()
    if len(v)>=2 and v[0] in ("'",'"') and v[-1]==v[0]:
        return v[1:-1].replace("''","'").replace('""','"')
    return v

def parse_sqlmini(raw):
    clean = re.sub(r'```[a-z]*','',raw).replace('```','').strip()
    for line in clean.splitlines():
        line = line.strip()
        if line.upper().startswith("INSERT"):
            clean = line; break
    m = _INSERT_RE.match(clean)
    if not m: return None
    table = m.group(1).strip().lower()
    cols  = [c.strip().lower() for c in m.group(2).split(',')]
    vals_r = _split_values(m.group(3))
    if len(cols) != len(vals_r): return None
    values = [_unquote(v) for v in vals_r]
    return {"table":table,"columns":cols,"values":values,"params":dict(zip(cols,values))}

def validate_sqlmini(raw):
    if not raw or not raw.strip(): return False,"empty response"
    p = parse_sqlmini(raw)
    if p is None: return False, f"not a valid INSERT: {raw[:80]!r}"
    if p["table"] not in ALLOWED_TABLES: return False, f"table '{p['table']}' not in whitelist"
    req = TABLE_REQUIRED.get(p["table"],set())
    missing = req - set(p["columns"])
    if missing: return False, f"missing required cols: {missing}"
    for col in req:
        if col in p["columns"]:
            idx = p["columns"].index(col)
            if not p["values"][idx].strip(): return False, f"empty value for '{col}'"
    return True, "OK"

def execute_sqlmini(raw, db_path="/ai/kombain/kombain_local.db", fts_rebuild=True):
    ok, msg = validate_sqlmini(raw)
    if not ok:
        log.warning("REJECT %s | %s", raw[:60], msg)
        return False, msg
    p = parse_sqlmini(raw)
    sql = "INSERT OR IGNORE INTO {} ({}) VALUES ({})".format(
        p["table"], ", ".join(p["columns"]), ", ".join("?"*len(p["columns"])))
    try:
        con = sqlite3.connect(db_path)
        cur = con.execute(sql, p["values"])
        rowid = cur.lastrowid
        con.commit()
        if fts_rebuild and rowid:
            try: con.execute(f"INSERT INTO {p['table']}_fts({p['table']}_fts) VALUES('rebuild')")
            except: pass
            con.commit()
        con.close()
        log.info("OK table=%s rowid=%s", p["table"], rowid)
        return True, rowid
    except sqlite3.Error as e:
        log.error("SQLITE ERROR %s | %s", e, sql)
        return False, str(e)

def execute_batch(responses, db_path="/ai/kombain/kombain_local.db"):
    stats = {"ok":0,"rejected":0,"errors":0}
    for raw in responses:
        ok, result = execute_sqlmini(raw, db_path, fts_rebuild=False)
        if ok: stats["ok"] += 1
        elif any(x in str(result) for x in ["not a valid","whitelist","missing","empty"]):
            stats["rejected"] += 1
        else: stats["errors"] += 1
    if stats["ok"] > 0:
        try:
            con = sqlite3.connect(db_path)
            for t in ALLOWED_TABLES:
                try: con.execute(f"INSERT INTO {t}_fts({t}_fts) VALUES('rebuild')")
                except: pass
            con.commit(); con.close()
        except: pass
    return stats

if __name__ == "__main__":
    import sys
    cmd = sys.argv[1] if len(sys.argv)>1 else "test"
    if cmd == "test":
        cases = [
            ("INSERT INTO qwen_knowledge(topic,subtopic,title,content,tags,difficulty) VALUES('test','unit','Test title','Test content','test','basic');", True),
            ("INSERT INTO qwen_knowledge(topic,title,content) VALUES('net','BGP','Border Gateway Protocol');", True),
            ("SELECT * FROM qwen_knowledge;", False),
            ("INSERT INTO evil_table(x) VALUES('y');", False),
            ("`"`json\n{\"key\": \"val\"}\n`"`", False),
            ("INSERT INTO qwen_knowledge(topic,title,content) VALUES('','','');", False),
            ("Sure!\nINSERT INTO claude_knowledge_base(topic,content) VALUES('AI','LLM orchestration');", True),
        ]
        passed = 0
        for raw, expected in cases:
            ok, msg = validate_sqlmini(raw)
            s = "OK" if ok==expected else "FAIL"
            if ok==expected: passed+=1
            print(f"[{s}] expected={expected} got={ok} | {raw[:55]!r}")
            if ok!=expected: print(f"     reason: {msg}")
        print(f"\n{passed}/{len(cases)} passed")
    elif cmd == "validate":
        raw = " ".join(sys.argv[2:])
        ok, msg = validate_sqlmini(raw)
        print(f"{'VALID' if ok else 'INVALID'}: {msg}")
    elif cmd == "execute":
        raw = " ".join(sys.argv[2:])
        ok, result = execute_sqlmini(raw)
        print(f"{'EXECUTED rowid='+str(result) if ok else 'REJECTED: '+str(result)}")
