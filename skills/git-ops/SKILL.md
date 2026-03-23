---
name: git-ops
description: |
  Do NOT activate when: "about yourself", "check resources", "system info".
  Use ONLY when the user mentions:
  git push, push, commit, save to github, send changes,
  sync repo, fetch upstream, git sync, git pull,
  git status, what changed, show commits,
  create release, git tag, new version, release.
---

# Git Ops Skill

Manages git operations for `ai-combiner-localhost-CPU-project` via shell.

## Configuration (from config.env)

```bash
GIT_REPO="/home/debai/ai-combiner-localhost-CPU-project"
GIT_SSH_KEY="/home/debai/.ssh/id_ed25519"
GIT_UPSTREAM="git@github.com:AI-Arch-DK/ai-combiner-localhost-CPU-project.git"
```

## Workflow: commit + push (qt_029)

```bash
# Triggers: push, commit and push, save to github
cd $GIT_REPO
pre-commit run --all-files
git add -A
git commit -m "$MSG"
ssh-agent bash -c 'ssh-add $GIT_SSH_KEY 2>/dev/null && git push upstream main'
```

## Workflow: sync from upstream (qt_030)

```bash
# Triggers: sync repo, update from upstream, fetch upstream
cd $GIT_REPO
git stash 2>/dev/null || true
ssh-agent bash -c 'ssh-add $GIT_SSH_KEY 2>/dev/null && git fetch upstream && git merge upstream/main --no-edit'
git stash pop 2>/dev/null || true
```

## Workflow: release + tag (qt_031)

```bash
# Triggers: create release, git tag, new version
cd $GIT_REPO
pre-commit run --all-files
echo "vX.Y.Z" > VERSION
git add -A && git commit -m "chore: release vX.Y.Z"
git tag -a vX.Y.Z -m "Release vX.Y.Z"
ssh-agent bash -c 'ssh-add $GIT_SSH_KEY 2>/dev/null && git push upstream main --tags'
```

## Workflow: status check (qt_032)

```bash
# Triggers: git status, what changed, show commits
cd $GIT_REPO
git status --short
git log --oneline -5
git diff --stat HEAD
```

## Knowledge Database

```bash
# Full workflows stored in:
sqlite3 /ai/db/git_ops.db "SELECT name, steps FROM git_workflows;"
sqlite3 /ai/db/git_ops.db "SELECT name, command FROM git_commands;"
```

## Rules

- SSH key: `/home/debai/.ssh/id_ed25519` — always use via `ssh-agent`
- Remote: `upstream` → `git@github.com:AI-Arch-DK/ai-combiner-localhost-CPU-project.git`
- Always run `pre-commit run --all-files` before push
- Never push: `*.db`, `config.env`, `claude_desktop_config.json`
- Commit messages: `feat:` / `fix:` / `docs:` / `chore:`
