#!/usr/bin/env python3
"""
hf_sqlmini.py — HF router.huggingface.co as sqlmini distiller.
distill_to_sqlmini(text, table, cols, context) -> str | None

Endpoint: router.huggingface.co/v1/chat/completions
Provider: cerebras (fastest), fallback novita
Token: HUGGINGFACE_TOKEN from env or config.env
"""
import os, sys, json, subprocess, urllib.request, urllib.error

HF_URL      = "https://router.huggingface.co/v1/chat/completions"
HF_MODEL    = "meta-llama/Llama-3.1-8B-Instruct"
HF_PROVIDER = "cerebras"

def _get_token():
    t = os.environ.get("HUGGINGFACE_TOKEN", "")
    if t: return t
    cfg = "/home/debai/.config/Claude/config.env"
    if os.path.exists(cfg):
        out = subprocess.run(
            ["bash","-c","set -a; source " + cfg + "; set +a; echo $HUGGINGFACE_TOKEN"],
            capture_output=True, text=True)
        return out.stdout.strip()
    return ""

SYSTEM = (
    "You are a database distiller. "
    "Respond with EXACTLY ONE SQL INSERT statement and nothing else. "
    "No explanation, no markdown, no comments. "
    "The response must start with INSERT INTO."
)

def distill_to_sqlmini(text,
                        table="qwen_knowledge",
                        cols="topic,subtopic,title,content,tags,difficulty",
                        context=""):
    """Distills text -> single SQL line. Returns str or None."""
    token = _get_token()
    if not token:
        print("  [hf_sqlmini] no HF token", file=sys.stderr)
        return None

    user_msg = (
        "Distill into ONE SQL INSERT. Keep each value under 50 chars.\n"
        "Table: " + table + "\nColumns: " + cols + "\n"
        "difficulty: basic/intermediate/advanced\n"
        "Context: " + context + "\n\n"
        "Text (summarize key fact):\n" + text[:300] + "\n\n"
        "Write ONLY: INSERT INTO " + table + "(" + cols + ") VALUES(short_val1,short_val2,...);"
    )

    payload = json.dumps({
        "model":    HF_MODEL,
        "provider": HF_PROVIDER,
        "messages": [
            {"role": "system", "content": SYSTEM},
            {"role": "user",   "content": user_msg}
        ],
        "max_tokens":  200,
        "temperature": 0.1
    }).encode()

    try:
        req = urllib.request.Request(
            HF_URL, data=payload,
            headers={
                "Authorization": "Bearer " + token,
                "Content-Type":  "application/json",
                "User-Agent":    "python-requests/2.31.0"
            }
        )
        with urllib.request.urlopen(req, timeout=25) as r:
            data = json.loads(r.read())
        raw = data["choices"][0]["message"]["content"].strip()
        return _extract_insert(raw)
    except urllib.error.HTTPError as e:
        print("  [hf_sqlmini] HTTP " + str(e.code), file=sys.stderr)
        return None
    except Exception as e:
        print("  [hf_sqlmini] err: " + str(e), file=sys.stderr)
        return None

def _extract_insert(raw):
    """Extracts first INSERT INTO ... ; from LLM response (handles multiline)."""
    if not raw: return None
    import re
    raw = raw.replace("```sql","").replace("```","").strip()
    joined = " ".join(raw.splitlines())
    m = re.search(r"(INSERT\s+INTO\s+\w+\s*\([^)]+\)\s*VALUES\s*\(.+?\)\s*;?)", joined, re.IGNORECASE)
    if m:
        result = m.group(1).strip()
        if not result.endswith(";"): result += ";"
        return result
    return None

if __name__ == "__main__":
    text = (sys.argv[1] if len(sys.argv) > 1 else
            "nomic-embed-text 274MB embedding model for Ollama CPU. "
            "ollama pull nomic-embed-text. ChromaDB collection qwen_knowledge on i7-8565U.")
    result = distill_to_sqlmini(text, context="ai-combiner embeddings")
    print("Result:", result)
    if result:
        sys.path.insert(0, "/ai/scripts")
        from validate_sqlmini import validate_sqlmini, execute_sqlmini
        ok, msg = validate_sqlmini(result)
        print("Validate: ok=" + str(ok) + " msg=" + msg)
        if ok:
            ok2, rowid = execute_sqlmini(result)
            print("Execute:  ok=" + str(ok2) + " rowid=" + str(rowid))
