#!/bin/bash
# audit_security.sh — локальный аудит безопасности AI-комбайна
# Проверяет: секреты, права, защищённые файлы, открытые порты

PASS=0; WARN=0; FAIL=0

ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
warn() { echo "  ⚠️  $1"; WARN=$((WARN+1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL+1)); }

echo "────────────────────────────"
echo "🔒 SECURITY AUDIT"
echo "────────────────────────────"

echo "🔷 Секреты в /ai/scripts/"
if grep -rqE "tvly-[a-zA-Z0-9]{10,}|github_pat_|hf_[a-zA-Z]{20,}" /ai/scripts/ 2>/dev/null; then
  fail "Найдены секреты в /ai/scripts/"
else
  ok "/ai/scripts/ чисты"
fi

echo "🔷 Права на файлы БД"
for db in /ai/db/*.db; do
  perms=$(stat -c "%a" "$db" 2>/dev/null)
  if [ "$perms" = "600" ] || [ "$perms" = "640" ] || [ "$perms" = "644" ]; then
    ok "$(basename $db): $perms"
  else
    warn "$(basename $db): $perms (рекомендуется 640)"
  fi
done

echo "🔷 Открытые порты"
WORRY=$(ss -tlnp 2>/dev/null | grep -vE "11434|22|631|:1" | grep -c LISTEN)
if [ "$WORRY" -gt 3 ]; then
  warn "Неожиданных портов: $WORRY"
else
  ok "Открытых портов: OK"
fi

echo "🔷 Сенситивные файлы"
for f in "/home/debai/.config/Claude/claude_desktop_config.json" \
         "/home/debai/.config/Claude/config.env"; do
  if [ -f "$f" ]; then
    perms=$(stat -c "%a" "$f" 2>/dev/null)
    [ "$perms" = "600" ] && ok "$(basename $f): 600" || warn "$(basename $f): $perms — реком. chmod 600"
  fi
done

echo "🔷 Ollama только localhost"
if ss -tlnp 2>/dev/null | grep 11434 | grep -q "127.0.0.1\|\*"; then
  ok "Ollama доступен локально"
else
  warn "Ollama не найден / не запущен"
fi

echo "────────────────────────────"
echo "✅ $PASS  ⚠️  $WARN  ❌ $FAIL"
[ "$FAIL" -eq 0 ] && [ "$WARN" -eq 0 ] && echo "STATUS: SECURE" || \
[ "$FAIL" -eq 0 ] && echo "STATUS: WARN" || echo "STATUS: VULNERABLE"
