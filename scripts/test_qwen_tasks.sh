#!/bin/bash
# test_qwen_tasks.sh — тестирование всех активных qwen_tasks
# Вывод: PASS/FAIL для каждого таска + время ответа

OLLAMA="http://localhost:11434/api/generate"
MODEL="qwen2.5:7b-instruct-q4_K_M"
PASS=0; FAIL=0

run_test() {
  local id="$1" prompt="$2" expect="$3" max_t="$4"
  local start end elapsed response
  start=$(date +%s%3N)
  response=$(curl -s "$OLLAMA" -d "{
    \"model\": \"$MODEL\",
    \"prompt\": \"$prompt\",
    \"stream\": false,
    \"options\": {\"num_predict\": $max_t}
  }" 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('response','').strip()[:100])")
  end=$(date +%s%3N)
  elapsed=$((end - start))

  if echo "$response" | grep -qi "$expect"; then
    echo "  ✅ $id (${elapsed}ms): $response"
    PASS=$((PASS+1))
  else
    echo "  ❌ $id (${elapsed}ms): ожидал '$expect', получил: $response"
    FAIL=$((FAIL+1))
  fi
}

echo "────────────────────────────"
echo "🧠 QWEN TASKS TEST"
echo "────────────────────────────"

# qt_002: классификация
run_test "qt_002" \
  "Classify this request into ONE: [network_config, code_generation, simple_query, orchestration, system_check, database]. Reply with one word only. Request: настрой MikroTik OSPF" \
  "network_config" 10

# qt_006: подсчёт
 run_test "qt_006" \
  "Count occurrences as requested. Reply with NUMBER only. Count: how many 'a' in 'banana'" \
  "3" 5

# qt_013: объяснение
run_test "qt_013" \
  "Explain in 2-3 sentences in Russian. Be very concise. Term: OSPF" \
  "OSPF" 80

# qt_011: перевод
run_test "qt_011" \
  "Translate the following text. Output translation only. Text: Hello world" \
  "\u043fривет\|hello\|world" 30

echo "────────────────────────────"
echo "✅ $PASS PASS | ❌ $FAIL FAIL"
[ "$FAIL" -eq 0 ] && echo "STATUS: ALL PASS" || echo "STATUS: DEGRADED"
