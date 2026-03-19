#!/bin/bash
# cleanup_sessions.sh — очистка устаревших сессий skills-plugin Claude Desktop
# Запускается автоматически из check_resources.sh
# Оставляет только последнюю по дате папку в skills-plugin
# Архивирует старые в /tmp/sessions_archive/

SESSIONS="/home/debai/.config/Claude/local-agent-mode-sessions"
PLUGIN_DIR="$SESSIONS/skills-plugin"
ARCHIVE="/tmp/sessions_archive/$(date +%Y%m%d_%H%M%S)"

# 1. Очистка пустых session-папок
for dir in "$SESSIONS"/*/; do
  name=$(basename "$dir")
  [ "$name" = "skills-plugin" ] && continue
  count=$(find "$dir" -name "*.json" 2>/dev/null | wc -l)
  if [ "$count" -eq 0 ]; then
    echo "REMOVE empty session: $name"
    rm -rf "$dir"
  fi
done

# 2. В skills-plugin — оставить только новейшую папку
NEWEST=$(ls -td "$PLUGIN_DIR"/*/ 2>/dev/null | head -1)
for dir in "$PLUGIN_DIR"/*/; do
  [ "$dir" = "$NEWEST" ] && continue
  mkdir -p "$ARCHIVE"
  echo "ARCHIVE old plugin: $(basename $dir)"
  cp -r "$dir" "$ARCHIVE/" 2>/dev/null
  rm -rf "$dir"
done

echo "DONE. Active: $(basename $NEWEST)"
