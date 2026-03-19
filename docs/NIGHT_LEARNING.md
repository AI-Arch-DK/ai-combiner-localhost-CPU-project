# Night Learning — ночное самообучение

## Концепция

Пока пользователь спит — Qwen обрабатывает накопленные за день данные, обогащает `qwen_knowledge`, обновляет FAQ.

## Цикл (запуск cron 02:00)

```
1. Считать network.db/templates — все FAQ за сегодня
2. Новые записи → Qwen (summarize + fact_check)
3. Результат → qwen_knowledge (topic/subtopic/content/verified=0)
4. Раз в неделю: tavily проверяет самые старые FAQ → verified=1
5. Запись в routing_log: сколько обновлено
```

## Cron

```cron
# Ночное самообучение каждую ночь в 2:00
0 2 * * * /ai/scripts/night_learning.sh >> /ai/logs/learning.log 2>&1
```

## Скрипт night_learning.sh

```bash
#!/bin/bash
# night_learning.sh — ночное обновление qwen_knowledge

LOCAL="/ai/kombain/kombain_local.db"
NETWORK="/ai/db/network.db"
OLLAMA="http://localhost:11434/api/generate"
MODEL="qwen2.5:7b-instruct-q4_K_M"
COUNT=0

echo "[night_learning] $(date '+%Y-%m-%d %H:%M')"

# Считать темы FAQ не обработанные за час
sqlite3 "$NETWORK" "
  SELECT template_id, name, content FROM templates
  WHERE created_at > datetime('now', '-1 day')
  AND protocol = 'faq'
  LIMIT 5;
" 2>/dev/null | while IFS='|' read -r tid name content; do
  [ -z "$tid" ] && continue

  # Посылаем Qwen
  response=$(curl -s "$OLLAMA" -d "{
    \"model\": \"$MODEL\",
    \"prompt\": \"Summarize in 3 sentences in Russian. Be concise. Text: $content\",
    \"stream\": false,
    \"options\": {\"num_predict\": 150}
  }" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('response','').strip())")

  [ -z "$response" ] && continue

  # Запись в qwen_knowledge
  sqlite3 "$LOCAL" "
    INSERT OR IGNORE INTO qwen_knowledge
    (topic, subtopic, title, content, source, tags, verified)
    VALUES ('network', 'faq', '$name', '$response', '$tid', 'auto,night', 0);
  " 2>/dev/null

  COUNT=$((COUNT+1))
  echo "  ✓ $name"
done

echo "[night_learning] Добавлено: $COUNT записей"
```

## Проверка результата

```bash
sqlite3 /ai/kombain/kombain_local.db \
  "SELECT COUNT(*), MAX(created_at) FROM qwen_knowledge WHERE source LIKE '%night%';"
```
