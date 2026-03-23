#!/bin/bash
# git_sync.sh — быстрая синхронизация с upstream
# Использование: bash scripts/git_sync.sh "commit message"

set -e

MSG="${1:-chore: sync}"

# Запустить ssh-agent если не запущен
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null
  ssh-add /home/debai/.ssh/id_ed25519 2>/dev/null
fi

cd "$(git rev-parse --show-toplevel)"

echo "=== pre-commit check ==="
pre-commit run --all-files || true

echo "=== git add + commit ==="
git add -A
git commit -m "$MSG" 2>/dev/null || echo "(nothing to commit)"

echo "=== push to upstream ==="
git push upstream main

echo "=== DONE ==="
git log --oneline -3
