#!/bin/bash
# setup_all.sh v1.0 — полная настройка AI-комбайна (root)
# Требует: sudo bash setup_all.sh <username>
# Делает: структура /ai, БД, скопирует scripts, создаёт скилл ai-combiner, cron, faq-обучение

set -e
USER="${1:-debai}"
HOME_DIR="/home/$USER"
SKILLS_DIR="$HOME_DIR/.config/Claude/local-agent-mode-sessions/skills-plugin"
SCRIPT_DIR="$(cd \"$(dirname \"${BASH_SOURCE[0]}\")\" && pwd)"

echo "──────────────────────────────"
echo "🤖 AI-комбайн setup_all.sh"
echo "пользователь: $USER"
echo "──────────────────────────────"

# =====================
# 1. Структура /ai/
# =====================
echo "[1/7] Структура /ai/..."
mkdir -p /ai/{db,scripts,logs,backup,workspace,kombain}
mkdir -p /ai/external/sales_manager
chown -R "$USER:$USER" /ai
echo "  OK"

# =====================
# 2. Скрипты
# =====================
echo "[2/7] Скрипты..."
for s in check_resources cleanup_sessions health_check backup_db backup_mcp \
         audit_security test_qwen_tasks rotate_logs init_db sync_to_shared \
         night_learning run_night_learning; do
  [ -f "$SCRIPT_DIR/${s}.sh" ] && cp "$SCRIPT_DIR/${s}.sh" /ai/scripts/ && chmod +x "/ai/scripts/${s}.sh"
  [ -f "$SCRIPT_DIR/${s}.py" ] && cp "$SCRIPT_DIR/${s}.py" /ai/scripts/ && chmod +x "/ai/scripts/${s}.py"
done
[ -f "$SCRIPT_DIR/run_night_learning.py" ] && cp "$SCRIPT_DIR/run_night_learning.py" /ai/scripts/
chown -R "$USER:$USER" /ai/scripts
echo "  OK"

# =====================
# 3. БД (схемы)
# =====================
echo "[3/7] Инициализация БД..."
SCHEMA_DIR="$SCRIPT_DIR/../db/schemas"
for db in routing project network tokens tools models; do
  DB_FILE="/ai/db/${db}.db"
  SQL="$SCHEMA_DIR/${db}_db.sql"
  if [ ! -f "$DB_FILE" ] && [ -f "$SQL" ]; then
    sqlite3 "$DB_FILE" < "$SQL" && echo "  OK ${db}.db"
  else
    echo "  SKIP ${db}.db (exists)"
  fi
done
for db_path in "/ai/kombain/kombain_local.db" "/ai/external/sales_manager/kombain_shared.db"; do
  sql_name=$([ "$db_path" == "/ai/kombain/kombain_local.db" ] && echo "kombain_local_db.sql" || echo "kombain_shared_db.sql")
  [ ! -f "$db_path" ] && sqlite3 "$db_path" < "$SCHEMA_DIR/$sql_name" && echo "  OK $(basename $db_path)"
done
chown -R "$USER:$USER" /ai/db /ai/kombain /ai/external
echo "  OK"

# =====================
# 4. Скилл ai-combiner
# =====================
echo "[4/7] Скилл ai-combiner..."
ACTIVE_PLUGIN=$(ls -td "$SKILLS_DIR"/*/  2>/dev/null | head -1)
if [ -n "$ACTIVE_PLUGIN" ]; then
  ACTIVE_SESSION=$(ls -td "$ACTIVE_PLUGIN"/*/  2>/dev/null | head -1)
  if [ -n "$ACTIVE_SESSION" ]; then
    SKILL_TARGET="${ACTIVE_SESSION}skills/ai-combiner"
    mkdir -p "$SKILL_TARGET"
    cat > "$SKILL_TARGET/SKILL.md" << 'SKILLEOF'
---
name: ai-combiner
description: |
  НЕ активировать при: "инфо о себе", "вспомни о себе", "проверь ресурсы".
  При этих запросах выполнить shell:/ai/scripts/check_resources.sh.

  Использовать ТОЛЬКО когда пользователь упоминает: AI-комбайн, оркестратор, routing, qwen_tasks,
  parallel_config, workflows, kombain, скиллы Claude, MCP серверы, ночное обучение,
  hallucination guard, SQL индексы, GitHub репо комбайна, backup БД, health check,
  скрипты /ai/, синхронизация нод, Office_MAIN, session cleanup, claude_desktop_config,
  или просит зафиксировать/обновить что-то в БД/скриптах/скиллах системы.
  Team Lead AI-комбайна.
---

# AI Combiner — Team Lead скилл

## Конфигурация
**Config:** `/home/debai/.config/Claude/claude_desktop_config.json`
**Scripts:** `/ai/scripts/` | **DB:** `/ai/db/` + `/ai/kombain/kombain_local.db`
**Version:** 0.3.0 | **GitHub:** `AI-Arch-DK/ai-combiner-localhost-CPU-project`

## Архитектура
`[1] SKILLS → [2] systemPrompt → [3] qwen_dispatch → [4] parallel_config`

## Стратегии
| Стратегия | Когда |
|---|---|
| qwen_only | extract, classify, explain, format |
| parallel | network_config, compare |
| external_first | research, orchestration |
| qwen_with_context | validate_config, fact_check |
| CLAUDE_DIRECT | bash/sql (qt_019/020/025) |

## Скрипты
| Скрипт | Зачем | Триггер |
|---|---|---|
| check_resources.sh | 7 строк | "инфо о себе" |
| health_check.sh | OK/WARN/FAIL | cron/ручно |
| backup_db.sh | бэкап БД | cron 3:00 |
| backup_mcp.sh | бэкап MCP | перед апгрейдом |
| audit_security.sh | аудит | ручно |
| test_qwen_tasks.sh | тест Qwen | перед деплоем |
| night_learning.sh | ночное обучение | cron 2:00 |
| cleanup_sessions.sh | удалить дубли | авто |
| sync_to_shared.sh | синх нод | ручно |

## БД SQL
```sql
SELECT task_id, category FROM qwen_tasks WHERE is_active=1;
SELECT config_id, strategy FROM parallel_config;
SELECT COUNT(*), SUM(verified) FROM qwen_knowledge;
```

## Security before push
```bash
grep -rE "tvly-|github_pat|hf_[a-zA-Z]{20,}" \
  --include="*.sh" --include="*.json" --include="*.md" . \
  && echo "❌ BLOCKED" || echo "✅ SAFE"
```
SKILLEOF
    chown -R "$USER:$USER" "$SKILL_TARGET"
    echo "  OK: $SKILL_TARGET"
  else
    echo "  WARN: session dir not found"
  fi
else
  echo "  WARN: skills-plugin not found"
fi

# =====================
# 5. FAQ обучение (kerberoasting/asreproasting)
# =====================
echo "[5/7] Обучение пропущенных FAQ..."
sudo -u "$USER" python3 << 'PYEOF'
import sqlite3, subprocess, json, time, os
LOCAL = '/ai/kombain/kombain_local.db'
NETWORK = '/ai/db/network.db'
OLLAMA = 'http://localhost:11434/api/generate'
MODEL = 'qwen2.5:7b-instruct-q4_K_M'
targets = ['faq_sales_ad_kerberoasting', 'faq_sales_ad_asreproasting']
net = sqlite3.connect(NETWORK)
loc = sqlite3.connect(LOCAL)
for tid in targets:
    row = net.execute("SELECT name, content FROM templates WHERE template_id=?", (tid,)).fetchone()
    if not row: continue
    name, content = row
    if loc.execute('SELECT COUNT(*) FROM qwen_knowledge WHERE source=?',(tid,)).fetchone()[0]:
        print(f"  SKIP {tid}"); continue
    short = tid.replace('faq_sales_','').replace('_',' ')
    payload = json.dumps({"model":MODEL,"prompt":f"Summarize 3 sentences Russian security. Topic: {short}. Text: {content[:400]}","stream":False,"options":{"num_predict":120}})
    try:
        r = subprocess.run(['curl','-s','--max-time','90',OLLAMA,'-d',payload],capture_output=True,text=True,timeout=95)
        resp = json.loads(r.stdout).get('response','').strip()
        if resp:
            loc.execute('INSERT OR IGNORE INTO qwen_knowledge (topic,subtopic,title,content,source,tags,difficulty,verified) VALUES (?,?,?,?,?,?,?,?)',
                ('sales','faq',name,resp,tid,'auto,sales,root_setup','intermediate',0))
            loc.commit(); print(f"  OK: {short}")
    except Exception as e: print(f"  ERR: {e}")
net.close(); loc.close()
PYEOF

# =====================
# 6. Cron
# =====================
echo "[6/7] Cron..."
CRON_NEW=""
CRON_NEW+="0 2 * * * python3 /ai/scripts/run_night_learning.py >> /ai/logs/learning.log 2>&1\n"
CRON_NEW+="0 3 * * * /ai/scripts/backup_db.sh >> /ai/logs/backup.log 2>&1\n"
CRON_NEW+="0 4 * * 0 /ai/scripts/rotate_logs.sh >> /ai/logs/rotate.log 2>&1\n"
CURRENT=$(sudo -u "$USER" crontab -l 2>/dev/null || echo '')
for job in \
  "0 2 * * * python3 /ai/scripts/run_night_learning.py" \
  "0 3 * * * /ai/scripts/backup_db.sh" \
  "0 4 * * 0 /ai/scripts/rotate_logs.sh"; do
  echo "$CURRENT" | grep -qF "$job" || CURRENT+="\n$job >> /ai/logs/$(echo $job|awk '{print $6}'|xargs basename .sh 2>/dev/null||echo out).log 2>&1"
done
echo -e "$CURRENT" | sudo -u "$USER" crontab -
echo "  OK"

# =====================
# 7. Permissions
# =====================
echo "[7/7] Права..."
chmod 600 /home/"$USER"/.config/Claude/claude_desktop_config.json 2>/dev/null || true
chown -R "$USER:$USER" /ai
echo "  OK"

echo "──────────────────────────────"
echo "✅ Готово!"
echo "  Скилл ai-combiner: $SKILL_TARGET"
echo "  Перезапустите Claude Desktop"
echo "──────────────────────────────"
