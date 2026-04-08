#!/usr/bin/env python3
"""
enrich_topic.py v2 — atomic enrichment of ONE topic (1-2 queries).
Phase 1: tavily -> hf_sqlmini -> validate_sqlmini -> SQLite (no JSON parsing).
Usage: python3 enrich_topic.py <topic_key>
Topics: mikrotik | pentest | ai-combiner | network | git-ops
Cron: 0 1,5,9,13,17,21 * * * /ai/scripts/enrich_cron_wrapper.sh
"""
import os, sys, json, subprocess, time
import urllib.request

sys.path.insert(0, "/ai/scripts")
from hf_sqlmini import distill_to_sqlmini
from validate_sqlmini import execute_sqlmini

def load_env():
    cfg = "/home/debai/.config/Claude/config.env"
    if os.path.exists(cfg):
        out = subprocess.run(
            ["bash","-c","set -a; source " + cfg + "; set +a; env"],
            capture_output=True, text=True)
        for line in out.stdout.splitlines():
            if "=" in line:
                k,_,v = line.partition("=")
                os.environ.setdefault(k, v)
load_env()

TAVILY_KEY = os.environ.get("TAVILY_API_KEY","")
LOG        = "/ai/logs/enrich.log"
os.makedirs("/ai/logs", exist_ok=True)

TOPICS = {
    "mikrotik": {
        "queries": [
            "MikroTik RouterOS BGP configuration eBGP iBGP 2025",
            "MikroTik firewall filter rules input forward output chain",
        ],
        "table": "qwen_knowledge", "topic": "MikroTik", "subtopic": "external"
    },
    "pentest": {
        "queries": [
            "linux privilege escalation techniques SUID capabilities 2025",
            "nmap NSE scripts service detection network reconnaissance",
        ],
        "table": "qwen_knowledge", "topic": "pentest", "subtopic": "external"
    },
    "ai-combiner": {
        "queries": [
            "ollama CPU inference optimization linux systemd environment",
            "local LLM orchestration MCP Claude Desktop patterns 2025",
        ],
        "table": "qwen_knowledge", "topic": "ai-combiner", "subtopic": "external"
    },
    "network": {
        "queries": [
            "VLAN 802.1q trunking configuration cisco mikrotik switch",
            "prometheus node exporter linux monitoring setup 2025",
        ],
        "table": "qwen_knowledge", "topic": "network", "subtopic": "external"
    },
    "git-ops": {
        "queries": [
            "GitHub Actions workflow CI CD secrets best practices",
            "git branching strategy gitflow trunk-based development",
        ],
        "table": "qwen_knowledge", "topic": "git-ops", "subtopic": "external"
    },
}

def log(msg):
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    line = "[" + ts + "] " + msg
    print(line)
    with open(LOG, "a") as f: f.write(line + "\n")

def tavily_search(query):
    if not TAVILY_KEY:
        log("  [warn] no TAVILY_API_KEY"); return ""
    try:
        p = json.dumps({
            "api_key": TAVILY_KEY, "query": query,
            "search_depth": "basic", "max_results": 3, "include_answer": True
        }).encode()
        req = urllib.request.Request(
            "https://api.tavily.com/search", data=p,
            headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=20) as r:
            d = json.loads(r.read())
        parts = []
        if d.get("answer"): parts.append(d["answer"])
        for item in d.get("results",[])[:2]:
            c = item.get("content","")
            if len(c) > 80: parts.append(c)
        return "\n".join(parts)[:600]
    except Exception as e:
        log("  tavily_err: " + str(e)); return ""

def main():
    topic_key = sys.argv[1].lower() if len(sys.argv) > 1 else "mikrotik"
    plan = TOPICS.get(topic_key)
    if not plan:
        print("Unknown topic: " + topic_key + ". Available: " + str(list(TOPICS.keys())))
        sys.exit(1)

    log("=== enrich_topic v2: " + topic_key + " ===")
    added = 0

    for query in plan["queries"]:
        log("  query: " + query)

        text = tavily_search(query)
        if not text:
            log("  skip: no tavily data")
            continue
        log("  tavily: " + str(len(text)) + " chars")

        context = plan["topic"] + " " + plan["subtopic"] + ": " + query[:60]
        raw_sql = distill_to_sqlmini(
            text,
            table=plan["table"],
            cols="topic,subtopic,title,content,tags,difficulty" if plan["table"] == "qwen_knowledge"
                 else "topic,content,tags",
            context=context
        )

        if not raw_sql:
            log("  skip: hf no response")
            time.sleep(2); continue
        log("  sqlmini: " + raw_sql[:80])

        ok, result = execute_sqlmini(raw_sql)
        if ok:
            added += 1
            log("  SAVED rowid=" + str(result))
        else:
            log("  REJECTED: " + str(result))

        time.sleep(2)

    log("=== DONE: +" + str(added) + " записей ===")

if __name__ == "__main__":
    main()
