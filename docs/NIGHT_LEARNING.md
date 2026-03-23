# Night Learning — ночное самообучение

## Концепция

Пока пользователь спит — Qwen обрабатывает накопленные за день данные, обогащает `qwen_knowledge`, обновляет FAQ.

## Pipeline ночного обучения

```text
[02:00 cron]
      |
      ▼
[1] network.db/templates → фильтр: protocol='faq', created_at > -1day
      |
      ▼
[2] Ollama API → qwen2.5:7b
    промпт: "Summarize 3 sentences in Russian"
    max_tokens: 150
      |
      ▼
[3] Запись в kombain_local.db/qwen_knowledge
    (topic, subtopic, title, content, source, tags='auto,night', verified=0)
      |
      ▼
[4] Еженедельно (cron воскресенье 03:00):
    tavily проверяет старые записи (verified=0, old >7d)
    Совпадает → verified=1 | Не совпадает → помечается на перепроверку
      |
      ▼
[5] routing_log: запись результата (tokens_saved, model_used='night_qwen')

```text

## Обработка ошибок

```bash
# В night_learning.sh:

OLLAMA_STATUS=$(curl -s http://localhost:11434/api/tags 2>/dev/null | python3 -c \
  "import json,sys; print('OK' if json.load(sys.stdin).get('models') else 'DOWN')" 2>/dev/null)

if [ "$OLLAMA_STATUS" != "OK" ]; then
  echo "[night_learning] ERROR: Ollama недоступен, пропускаю"
  exit 1
fi

# Таймаут для каждого запроса Qwen:

# curl ... --max-time 120

# Если response пустой — пропускаем запись

[ -z "$response" ] && echo "  SKIP $name (empty response)" && continue

```text

## Cron

```cron
0 2 * * * /ai/scripts/night_learning.sh >> /ai/logs/learning.log 2>&1
0 3 * * 0 /ai/scripts/night_verify.sh  >> /ai/logs/verify.log 2>&1

```text

## Проверка результата

```bash
sqlite3 /ai/kombain/kombain_local.db \
  "SELECT COUNT(*), MAX(created_at), SUM(verified) FROM qwen_knowledge WHERE tags LIKE '%night%';"

```text
