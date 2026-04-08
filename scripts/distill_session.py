#!/usr/bin/env python3
"""
distill_session.py — Phase 0: distill session text via HF -> sqlmini -> SQLite.
Usage:
  echo "text" | python3 distill_session.py
  python3 distill_session.py --text "session text"
  python3 distill_session.py --file /path/chat.txt

Pipeline: text -> chunks(400 words) -> HF cerebras sqlmini -> validate_sqlmini -> SQLite
"""
import os, sys, time

sys.path.insert(0, "/ai/scripts")
from hf_sqlmini import distill_to_sqlmini
from validate_sqlmini import execute_sqlmini

LOG = "/ai/logs/distill.log"
os.makedirs("/ai/logs", exist_ok=True)

def log(msg):
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    line = "[" + ts + "] " + msg
    print(line)
    with open(LOG,"a") as f: f.write(line+"\n")

def chunk_text(text, size=400, overlap=80):
    words = text.split()
    chunks, i = [], 0
    while i < len(words):
        chunk = " ".join(words[i:i+size])
        if len(chunk.strip()) > 30:
            chunks.append(chunk)
        i += size - overlap
    return chunks

def main():
    if len(sys.argv) >= 3 and sys.argv[1] == "--file":
        text = open(sys.argv[2]).read()
    elif len(sys.argv) >= 3 and sys.argv[1] == "--text":
        text = " ".join(sys.argv[2:])
    else:
        text = sys.stdin.read()

    if not text.strip():
        print("No text provided"); sys.exit(1)

    log("=== distill_session: " + str(len(text)) + " chars ===")
    chunks = chunk_text(text)
    log("  chunks: " + str(len(chunks)))

    ok_count = 0
    reject_count = 0

    for i, chunk in enumerate(chunks):
        log("  [" + str(i+1) + "/" + str(len(chunks)) + "] distilling...")
        raw = distill_to_sqlmini(chunk, context="AI combiner session knowledge")
        if not raw:
            log("  skip: no HF response")
            continue
        log("  hf: " + raw[:80])
        ok, result = execute_sqlmini(raw)
        if ok:
            ok_count += 1
            log("  SAVED rowid=" + str(result))
        else:
            reject_count += 1
            log("  REJECTED: " + str(result))
        time.sleep(1)

    log("=== DONE: +" + str(ok_count) + " saved, " + str(reject_count) + " rejected ===")
    print("\nResult: +" + str(ok_count) + " records saved to qwen_knowledge")

if __name__ == "__main__":
    main()
