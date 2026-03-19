#!/bin/bash
# backup_mcp.sh — бэкап конфигурации MCP серверов
# [HIGH] риск: без бэкапа невозможно восстановить настройку MCP
# Запуск: cron 3:30 / перед апгрейдом

BACKUP_DIR="/ai/backup/mcp_$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="/home/debai/.config/Claude"
MCP_DIR="/home/debai/.config/claude-mcp"

mkdir -p "$BACKUP_DIR"

echo "[backup_mcp] Цель: $BACKUP_DIR"

# 1. claude_desktop_config.json (без секретов)
if [ -f "$CONFIG_DIR/claude_desktop_config.json" ]; then
  # Копируем без значений API ключей
  python3 -c "
import json, sys
with open('$CONFIG_DIR/claude_desktop_config.json') as f:
  cfg = json.load(f)
# Убираем env секреты
for srv in cfg.get('mcpServers', {}).values():
  if 'env' in srv:
    srv['env'] = {k: 'REDACTED' for k in srv['env']}
if 'systemPrompt' in cfg:
  del cfg['systemPrompt']
with open('$BACKUP_DIR/claude_desktop_config.SANITIZED.json', 'w') as f:
  json.dump(cfg, f, indent=2, ensure_ascii=False)
" 2>/dev/null && echo "  OK claude_desktop_config (sanitized)"
fi

# 2. MCP серверы: только package.json и server.js (metadata, no secrets)
if [ -d "$MCP_DIR" ]; then
  for srv_dir in "$MCP_DIR"/*/; do
    name=$(basename "$srv_dir")
    mkdir -p "$BACKUP_DIR/mcp/$name"
    [ -f "$srv_dir/package.json" ] && cp "$srv_dir/package.json" "$BACKUP_DIR/mcp/$name/" 2>/dev/null
    echo "  OK mcp/$name"
  done
fi

# 3. skills-plugin актуальная сессия
SKILL_DIR=$(find /home/debai/.config/Claude/local-agent-mode-sessions/skills-plugin -name "SKILL.md" 2>/dev/null | sed 's|/SKILL.md||' | head -1 | xargs dirname 2>/dev/null)
if [ -n "$SKILL_DIR" ]; then
  cp -r "$SKILL_DIR" "$BACKUP_DIR/skills-plugin/" 2>/dev/null && echo "  OK skills-plugin"
fi

# Удаляем бэкапы старше 14 дней
find /ai/backup -maxdepth 1 -name "mcp_*" -type d -mtime +14 -exec rm -rf {} + 2>/dev/null

SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
echo "[backup_mcp] Готово. Размер: $SIZE"
