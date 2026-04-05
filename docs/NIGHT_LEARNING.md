# Night Learning — Overnight Self-Training


## Concept


While the user is offline, Qwen processes data accumulated during the day, enriches `qwen_knowledge`, and updates the FAQ cache.


## Learning Pipeline


```text

[02:00 cron]

|

▼

[1] network.db/templates → filter: protocol='faq', created_at > -1day

|

▼

[2] Ollama API → qwen2.5:7b

prompt: "Summarize in 3 sentences in English"

max_tokens: 150

|

▼

[3] Write to kombain_local.db/qwen_knowledge

(topic, subtopic, title, content, source, tags='auto,night', verified=0)

|

▼

[4] Weekly (cron Sunday 03:00):

tavily verifies old records (verified=0, age >7d)

Match → verified=1 | No match → flagged for review

|

▼

[5] routing_log: record result (tokens_saved, model_used='night_qwen')

```


## Error Handling


```bash

# In night_learning.sh:

OLLAMA_STATUS=$(curl -s http://localhost:11434/api/tags 2>/dev/null | python3 -c \

"import json,sys; print('OK' if json.load(sys.stdin).get('models') else 'DOWN')" 2>/dev/null)


if [ "$OLLAMA_STATUS" != "OK" ]; then

echo "[night_learning] ERROR: Ollama unavailable, skipping"

exit 1

fi


# Per-request timeout:

# curl ... --max-time 120


# Skip empty responses:

[ -z "$response" ] && echo " SKIP $name (empty response)" && continue

```


## Cron


```cron

0 2 * * * /ai/scripts/night_learning.sh >> /ai/logs/learning.log 2>&1

0 3 * * 0 /ai/scripts/night_verify.sh >> /ai/logs/verify.log 2>&1

```


## Verify Results


```bash

sqlite3 /ai/kombain/kombain_local.db \

"SELECT COUNT(*), MAX(created_at), SUM(verified) FROM qwen_knowledge WHERE tags LIKE '%night%';"

``` 
