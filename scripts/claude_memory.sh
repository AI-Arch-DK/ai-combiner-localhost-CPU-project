#!/bin/bash
# claude_memory.sh — механизм вызова памяти Claude
# claude_memory.sh index          → краткий индекс (дёшево, 1 SQL)
# claude_memory.sh session        → действия текущей сессии
# claude_memory.sh full [CAT]     → полный контент по категории
# claude_memory.sh get mem_NNN   → конкретная запись
# claude_memory.sh search СЛОВО  → поиск
# claude_memory.sh stats          → статистика
# claude_memory.sh add CAT TITLE CONTENT  → добавить запись
DB="/ai/kombain/kombain_local.db"
CMD="${1:-index}"
ARG="$2"

case "$CMD" in
  index|память|помни)
    echo "=== CLAUDE MEMORY INDEX ==="
    sqlite3 "$DB" "SELECT printf('%s | %-10s | %-10s | %-35s | %s',
      strftime('%m-%d',ts), category, action, object, result)
      FROM claude_index ORDER BY ts DESC LIMIT 30;" 2>/dev/null
    echo ""
    echo "Всего: $(sqlite3 $DB 'SELECT COUNT(*) FROM claude_index;' 2>/dev/null) записей"
    ;;
  session)
    echo "=== ТЕКУЩАЯ СЕССИЯ ==="
    DATE=$(date '+%Y-%m-%d')
    sqlite3 "$DB" "SELECT printf('[%s] %-10s %-10s %s → %s',
      strftime('%H:%M',ts), category, action, object, result)
      FROM claude_index WHERE ts >= '$DATE' ORDER BY ts;" 2>/dev/null
    ;;
  full)
    if [ -z "$ARG" ]; then
      echo "=== ВСЕ ЗАПИСИ ==="
      sqlite3 "$DB" "SELECT key||' ['||category||'] imp='||importance||' '||title FROM claude_memory ORDER BY category,importance DESC;" 2>/dev/null
    else
      echo "=== ПОЛНЫЙ КОНТЕНТ: $ARG ==="
      sqlite3 "$DB" "SELECT '--- '||key||' ---'||char(10)||title||char(10)||char(10)||content
        FROM claude_memory WHERE upper(category)=upper('$ARG') ORDER BY importance DESC;" 2>/dev/null
    fi
    ;;
  get|mem)
    KEY="$ARG"
    [[ "$KEY" != mem_* ]] && KEY="mem_$ARG"
    echo "=== $KEY ==="
    sqlite3 "$DB" "SELECT title||char(10)||'---'||char(10)||content FROM claude_memory WHERE key='$KEY';" 2>/dev/null
    ;;
  search|найди)
    echo "=== ПОИСК: $ARG ==="
    sqlite3 "$DB" "SELECT key||' | '||category||' | '||title
      FROM claude_memory
      WHERE tags LIKE '%$ARG%' OR title LIKE '%$ARG%' OR content LIKE '%$ARG%'
      ORDER BY importance DESC;" 2>/dev/null
    ;;
  stats)
    echo "=== СТАТИСТИКА ПАМЯТИ ==="
    echo "claude_index:"
    sqlite3 "$DB" "SELECT category, COUNT(*) FROM claude_index GROUP BY category ORDER BY COUNT(*) DESC;" 2>/dev/null
    echo "claude_memory:"
    sqlite3 "$DB" "SELECT category, COUNT(*), MAX(importance) FROM claude_memory GROUP BY category ORDER BY COUNT(*) DESC;" 2>/dev/null
    ;;
  add)
    CAT="$2"; TITLE="$3"; CONTENT="$4"
    KEY="mem_$(sqlite3 $DB 'SELECT COUNT(*)+1 FROM claude_memory;' 2>/dev/null)"
    sqlite3 "$DB" "INSERT INTO claude_memory (key,category,title,content,session_id,importance) VALUES ('$KEY','$CAT','$TITLE','$CONTENT','$(date +%F)',2);" 2>/dev/null
    sqlite3 "$DB" "INSERT INTO claude_index (session_id,category,action,object,result,ref_key) VALUES ('$(date +%F)','$CAT','добавил','$TITLE','OK','$KEY');" 2>/dev/null
    echo "OK: $KEY добавлен"
    ;;
  help|*)
    echo "claude_memory.sh — память Claude"
    echo "  index           → краткий индекс (0 токенов Claude)"
    echo "  session         → только текущая сессия"
    echo "  full [CATEGORY] → полный контент (DB/SCRIPT/GITHUB/PATTERN/FIX/COMMAND/WORKFLOW/SKILL)"
    echo "  get mem_NNN     → конкретная запись"
    echo "  search СЛОВО    → поиск по тегам/заголовкам/контенту"
    echo "  stats           → статистика БД"
    echo "  add CAT TITLE CONTENT → добавить запись"
    ;;
esac
