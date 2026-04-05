# Night Learning — Overnight Self-Training
Concept

While the user is offline, Qwen processes data accumulated in the network database, enriches the local qwen_knowledge table, and updates the FAQ cache.
Learning Pipeline

## The process is automated via Python and follows these stages:
Plaintext

[02:00 cron]
      |
      ▼
[1] Source: network.db/templates
    Filter: protocol='faq' AND content IS NOT NULL
      |
      ▼
[2] Processing: Ollama API (Model: qwen2.5:7b-instruct-q4_K_M)
    Prompt: "Summarize 3 sentences in English. Text: {content[:400]}"
    Options: num_predict: 200, stream: False
      |
      ▼
[3] Storage: kombain_local.db/qwen_knowledge
    Check: Skip if source (template_id) already exists in local DB
    Record: (topic, subtopic, title, content, source, tags='auto,night,cron', verified=0)
      |
      ▼
[4] Logging: /data/logs/learning.log
    Status recorded: [start], [ok] {name}, and final [done] {count} added

Error Handling

Designed for robust background execution:

    Availability Check: The script connects to the local Ollama API at http://localhost:11434.

    Request Timeouts: curl is configured with --max-time 60 to prevent hanging processes if the LLM is unresponsive.

    Exception Isolation: The request block is wrapped in try...except. Network errors or empty AI responses (if resp:) trigger a skip for the specific record rather than crashing the entire script.

    Data Integrity: loc.commit() is executed after each successfully processed record to ensure partial progress is saved.

Cron Configuration

Current tasks in crontab -l:
Code snippet

# Daily learning cycle (02:00)
0 2 * * * python3 /data/scripts/run_night_learning.py >> /data/logs/learning.log 2>&1

# Weekly verification (Sunday 03:00)
0 3 * * 0 /data/scripts/night_verify.sh >> /data/logs/verify.log 2>&1

Maintenance & Verification

Use these commands to monitor the process:

Check recent activity:
Bash

tail -n 15 /data/logs/learning.log

Verify knowledge base growth:
Bash

sqlite3 /data/kombain/kombain_local.db "SELECT COUNT(*) FROM qwen_knowledge WHERE tags LIKE '%night%';"

Test model availability:
Bash

ollama list | grep "qwen2.5:7b-instruct-q4_K_M"

Last updated: 2026-04-05 based on the current implementation of /data/scripts/run_night_learning.py.
