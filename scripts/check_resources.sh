#!/bin/bash
# check_resources.sh v4 — токен-оптимизированный дашборд AI-комбайна
# Триггер: "инфо о себе" | "проверь ресурсы" | старт сессии

# ХОСТ
UPTIME=$(uptime -p | sed 's/up //')
CPU=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs | sed 's/Intel(R) Core(TM) //;s/ CPU.*//')
RAM=$(free -h | awk '/Mem:/{printf "%s/%s", $3, $2}')
DISK=$(df -h / | awk 'NR==2{printf "%s(%s)", $5, $4}')
PORTS=$(ss -tlnp 2>/dev/null | grep -c LISTEN)
OLLAMA=$(ss -tlnp 2>/dev/null | grep -q 11434 && echo "✅" || echo "❌")
echo "HOST $UPTIME | $CPU | RAM $RAM | / $DISK | ports:$PORTS | ollama:$OLLAMA"

# БД
echo -n "DB "
for db in /ai/db/*.db; do
  N=$(basename "$db" .db)
  T=$(sqlite3 "$db" "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name NOT LIKE '%_fts%';" 2>/dev/null)
  S=$(du -h "$db" 2>/dev/null | cut -f1)
  echo -n "$N(${T}t/${S}) "
done
echo ""

# CONFIG
echo "CFG /home/debianAI/.config/Claude/claude_desktop_config.json"

# MCP
echo "MCP sqlite|ollama|host-report|filesystem|github-pub|github-priv|huggingface|miro|tavily|shell|browser|clay|gcal|gmail"

# РОУТИНГ
PC=$(sqlite3 /ai/db/routing.db "SELECT COUNT(*) FROM parallel_config;" 2>/dev/null)
QT=$(sqlite3 /ai/db/routing.db "SELECT COUNT(*) FROM qwen_tasks WHERE is_active=1;" 2>/dev/null)
echo "ROUTING pc:$PC qt:$QT"

# СКИЛЛЫ
SKILL_DIR=$(find /home/debianAI/.config/Claude/local-agent-mode-sessions/skills-plugin -name "SKILL.md" 2>/dev/null \
  | sed 's|.*/skills/||;s|/SKILL.md||' | sort -u | tr '\n' '|' | sed 's/|$//')
echo "SKILLS $SKILL_DIR"

# CLEANUP PIDs
KILLED=0
for pid in $(pgrep -f "ollama runner" 2>/dev/null); do
  e=$(ps -o etimes= -p "$pid" 2>/dev/null | xargs)
  [ -n "$e" ] && [ "$e" -gt 120 ] && kill "$pid" 2>/dev/null && KILLED=$((KILLED+1))
done
for pid in $(pgrep sqlite3 2>/dev/null); do
  e=$(ps -o etimes= -p "$pid" 2>/dev/null | xargs)
  [ -n "$e" ] && [ "$e" -gt 60 ] && kill "$pid" 2>/dev/null && KILLED=$((KILLED+1))
done
echo "CLEANUP killed:$KILLED"
/ai/scripts/cleanup_sessions.sh 2>/dev/null
