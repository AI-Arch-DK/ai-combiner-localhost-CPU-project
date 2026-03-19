#!/bin/bash
# install.sh — автоустановка AI-комбайна с нуля
# ОС: Debian/Ubuntu
# Требует: доступ в интернет, sudo

set -e
USER=${SUDO_USER:-$USER}

echo "──────────────────────────────"
echo "🤖 AI-комбайн install.sh"
echo "──────────────────────────────"

# 1. Зависимости
echo "[1/6] Установка зависимостей..."
apt-get update -qq
apt-get install -y -qq curl sqlite3 nodejs npm python3 python3-pip git
echo "  OK"

# 2. Ollama
echo "[2/6] Установка Ollama..."
if ! command -v ollama &>/dev/null; then
  curl -fsSL https://ollama.ai/install.sh | sh
  echo "  OK ollama установлен"
else
  echo "  SKIP (уже есть: $(ollama --version))"
fi

# 3. Модель
echo "[3/6] Загрузка qwen2.5:7b-instruct-q4_K_M..."
ollama pull qwen2.5:7b-instruct-q4_K_M
echo "  OK"

# 4. Структура /ai/
echo "[4/6] Создание структуры /ai/..."
mkdir -p /ai/{db,scripts,logs,backup,workspace,kombain}
mkdir -p /ai/external/kali
chown -R "$USER:$USER" /ai
echo "  OK"

# 5. Скрипты
echo "[5/6] Копирование скриптов..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR"/*.sh /ai/scripts/ 2>/dev/null || true
chmod +x /ai/scripts/*.sh
echo "  OK"

# 6. БД
echo "[6/6] Инициализация БД..."
bash /ai/scripts/init_db.sh
echo "  OK"

echo "──────────────────────────────"
echo "✅ Установка завершена."
echo "Настройте claude_desktop_config.json"
echo "См. docs/MCP_SETUP.md"
echo "Первое сообщение в Claude Desktop: инфо о себе"
