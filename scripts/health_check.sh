#!/bin/bash
# health_check.sh — проверка всех компонентов AI-комбайна
# Вывод: OK/WARN/FAIL по каждому компоненту

PASS=0; WARN=0; FAIL=0

check() {
  local name="$1" cmd="$2"
  if eval "$cmd" &>/dev/null; then
    echo "  ✅ $name"
    PASS=$((PASS+1))
  else
    echo "  ❌ $name"
    FAIL=$((FAIL+1))
  fi
}

warn() {
  local name="$1" cmd="$2" threshold="$3"
  local val
  val=$(eval "$cmd" 2>/dev/null)
  if [ -n "$val" ] && [ "$val" -lt "$threshold" ]; then
    echo "  ⚠️  $name: $val (< $threshold)"
    WARN=$((WARN+1))
  else
    echo "  ✅ $name: $val"
    PASS=$((PASS+1))
  fi
}

echo "────────────────────────────"
echo "🩺 HEALTH CHECK AI-комбайна"
echo "────────────────────────────"

echo "🔷 Ollama"
check "ollama запущен" "ss -tlnp | grep -q 11434"
check "qwen2.5:7b доступен" "curl -s http://localhost:11434/api/tags | grep -q qwen2.5"

echo "🔷 БД"
for db in routing project network tokens tools models; do
  check "$db.db" "[ -f /ai/db/$db.db ]"
done
check "kombain_local.db" "[ -f /ai/kombain/kombain_local.db ]"
check "kombain_shared.db" "[ -f /ai/external/kali/kombain_shared.db ]"

echo "🔷 Скрипты"
for s in check_resources cleanup_sessions init_db backup_db; do
  check "$s.sh" "[ -x /ai/scripts/$s.sh ]"
done

echo "🔷 routing.db данные"
warn "qwen_tasks" "sqlite3 /ai/db/routing.db 'SELECT COUNT(*) FROM qwen_tasks WHERE is_active=1;'" 20
warn "parallel_config" "sqlite3 /ai/db/routing.db 'SELECT COUNT(*) FROM parallel_config;'" 12

echo "🔷 Система"
warn "RAM доступно MB" "free -m | awk '/Mem:/{print \$7}'" 2000
check "/ai смонтирован" "[ -d /ai/db ]"

echo "────────────────────────────"
echo "✅ $PASS  ⚠️  $WARN  ❌ $FAIL"
[ "$FAIL" -eq 0 ] && echo "STATUS: OK" || echo "STATUS: DEGRADED"
