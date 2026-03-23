---
name: git-ops
description: |
  НЕ активировать при: "инфо о себе", "проверь ресурсы", "проверь систему".
  Использовать ТОЛЬКО когда пользователь упоминает:
  git push, запушь, коммит, сохрани на github, отправь изменения,
  синхронизируй репо, fetch upstream, git sync, git pull,
  git status, что изменилось, покажи коммиты,
  создай релиз, git tag, новая версия, release.
---

# Git Ops Skill

Управляю git-операциями для `ai-combiner-localhost-CPU-project` через shell.

## Конфигурация (из config.env)

```bash
GIT_REPO="/home/debai/ai-combiner-localhost-CPU-project"
GIT_SSH_KEY="/home/debai/.ssh/id_ed25519"
GIT_UPSTREAM="git@github.com:AI-Arch-DK/ai-combiner-localhost-CPU-project.git"
```

## Workflow: commit + push (qt_029)

```bash
# Триггеры: запушь, коммит и пуш, сохрани на github, push to github
cd $GIT_REPO
pre-commit run --all-files
git add -A
git commit -m "$MSG"
ssh-agent bash -c 'ssh-add $GIT_SSH_KEY 2>/dev/null && git push upstream main'
```

## Workflow: sync от upstream (qt_030)

```bash
# Триггеры: синхронизируй репо, обнови из upstream, fetch upstream
cd $GIT_REPO
git stash 2>/dev/null || true
ssh-agent bash -c 'ssh-add $GIT_SSH_KEY 2>/dev/null && git fetch upstream && git merge upstream/main --no-edit'
git stash pop 2>/dev/null || true
```

## Workflow: release + tag (qt_031)

```bash
# Триггеры: создай релиз, git tag, новая версия
cd $GIT_REPO
pre-commit run --all-files
echo "vX.Y.Z" > VERSION
git add -A && git commit -m "chore: release vX.Y.Z"
git tag -a vX.Y.Z -m "Release vX.Y.Z"
ssh-agent bash -c 'ssh-add $GIT_SSH_KEY 2>/dev/null && git push upstream main --tags'
```

## Workflow: status check (qt_032)

```bash
# Триггеры: git status, что изменилось, покажи коммиты
cd $GIT_REPO
git status --short
git log --oneline -5
git diff --stat HEAD
```

## БД знаний

```bash
# Полные workflows хранятся в:
sqlite3 /ai/db/git_ops.db "SELECT name, steps FROM git_workflows;"
sqlite3 /ai/db/git_ops.db "SELECT name, command FROM git_commands;"
```

## Правила

- SSH ключ: `/home/debai/.ssh/id_ed25519` — всегда через `ssh-agent`
- Remote: `upstream` → `git@github.com:AI-Arch-DK/ai-combiner-localhost-CPU-project.git`
- Перед push: всегда `pre-commit run --all-files`
- Не пушить: `*.db`, `config.env`, `claude_desktop_config.json`
- Коммит-сообщения: `feat:` / `fix:` / `docs:` / `chore:`
