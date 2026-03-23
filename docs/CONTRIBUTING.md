# Contributing to AI Combiner

Thanks for your interest in the project! This guide will help you contribute the right way.

## Code of Conduct

By participating, you agree to follow the [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md).

## Quick Start

```bash
# 1. Fork the repository on GitHub

# 2. Clone your fork
git clone git@github.com:<your-username>/ai-combiner-localhost-CPU-project.git
cd ai-combiner-localhost-CPU-project

# 3. Add upstream
git remote add upstream git@github.com:AI-Arch-DK/ai-combiner-localhost-CPU-project.git

# 4. Install pre-commit
pip install pre-commit
pre-commit install

# 5. Create a feature branch
git checkout -b feature/my-feature
```

## Project Structure

```text
scripts/        — shell scripts (init, health, backup, cleanup)
db/schemas/     — SQL database schemas
db/data/        — seed data (qwen_tasks, parallel_config)
docs/           — documentation
config/         — ollama config, systemd services
skills/         — SKILL.md files for Claude Desktop
.github/        — CI/CD, issue/PR templates
```

## Types of Contributions

### Add a new qwen_task

```sql
-- db/data/qwen_tasks.json or routing.db
INSERT INTO qwen_tasks VALUES (
  'qt_NNN',
  'trigger1,trigger2,keyword',
  'category_name',
  'Short prompt for qwen. Max 50 words. Output only.',
  200, 1, 'Task description', 0, 1, 60
);
```

**Prompt rules:**

- Maximum 50 words
- End with: `Output X only.`
- No personal or sensitive data
- Specify output language: `in English`

### Add a parallel_config strategy

```sql
INSERT INTO parallel_config VALUES (
  'pc_NNN', 'task_category',
  1, 0, 0, 1, 30, 'qwen_with_context', 'Description'
);
```

### Add a new skill

1. Create `skills/<skill-name>/SKILL.md`

2. File format:

```yaml
---
name: my-skill
description: |
  Do NOT activate when: "about yourself", "check resources".
  Use ONLY when the user mentions: <triggers>.
---
# My Skill
...
```

3. Copy into the active Claude Desktop session:

```text
$HOME/.config/Claude/local-agent-mode-sessions/skills-plugin/<UUID>/<SESSION>/skills/
```

4. Restart Claude Desktop

## Pre-commit Hooks

After running `pre-commit install`, every commit is automatically checked for:

- Trailing whitespace and missing end-of-file newlines
- YAML and JSON syntax errors
- Merge conflict markers
- Private key detection
- Secret detection (detect-secrets baseline)
- Markdown lint (markdownlint)

Run manually at any time:

```bash
pre-commit run --all-files
```

## Security Rules Before Push

Run the check below, or just let `pre-commit run --all-files` handle it:

```bash
grep -rE "tvly-|github_pat|hf_[a-zA-Z]{20,}|password=|api.key" \
  --include="*.sh" --include="*.json" --include="*.md" --include="*.sql" . \
  && echo "❌ SECRETS FOUND" || echo "✅ Clean"
```

See also: `docs/SECURITY_CHECKLIST.md`

## PR Process

1. Ensure `pre-commit run --all-files` passes clean
2. Ensure `scripts/health_check.sh` reports `STATUS: OK`
3. Open a PR and fill in the template at `.github/pull_request_template.md`
4. CI must pass (security_check + lint)
5. Maintainer review within 7 days

## Release Process

See [docs/RELEASE.md](RELEASE.md) for the full step-by-step process including tagging and CHANGELOG.

## Questions

Open a [GitHub Discussion](https://github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project/discussions)
or create an issue with the `question` label.
