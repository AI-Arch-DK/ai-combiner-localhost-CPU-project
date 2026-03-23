# Contributing to AI Combiner

Спасибо за интерес к проекту! Это руководство поможет тебе внести вклад правильно.

## Кодекс поведения

Участвуя в проекте, ты соглашаешься соблюдать [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md).

## Быстрый старт для контрибьюторов

```bash
# 1. Fork репозитория на GitHub
# 2. Клонировать свой fork
git clone git@github.com:<your-username>/ai-combiner-localhost-CPU-project.git
cd ai-combiner-localhost-CPU-project

# 3. Добавить upstream
git remote add upstream git@github.com:AI-Arch-DK/ai-combiner-localhost-CPU-project.git

# 4. Установить pre-commit
pip install pre-commit
pre-commit install

# 5. Создать ветку для изменений
git checkout -b feature/my-feature
```

## Структура проекта

```
scripts/        — shell-скрипты (init, health, backup, cleanup)
db/schemas/     — SQL схемы баз данных
db/data/        — seed-данные (qwen_tasks, parallel_config)
docs/           — документация
config/         — конфиги ollama, systemd-сервисы
skills/         — SKILL.md файлы для Claude Desktop
.github/        — CI/CD, issue/PR шаблоны
```

## Типы вкладов

### Добавить новый qwen_task

```sql
-- db/data/qwen_tasks.json или routing.db
INSERT INTO qwen_tasks VALUES (
  'qt_NNN',
  'триггер1,триггер2,keyword',
  'category_name',
  'Short prompt for qwen. Max 50 words. Output only.',
  200, 1, 'Описание задачи', 0, 1, 60
);
```

**Правила промпта:**
- Максимум 50 слов
- Заканчивать: `Output X only.`
- Не использовать личные данные
- Указывать язык вывода: `in Russian` / `in English`

### Добавить стратегию parallel_config

```sql
INSERT INTO parallel_config VALUES (
  'pc_NNN', 'task_category',
  1, 0, 0, 1, 30, 'qwen_with_context', 'Описание'
);
```

### Добавить новый скилл

1. Создать `skills/<skill-name>/SKILL.md`
2. Формат файла:

```yaml
---
name: my-skill
description: |
  НЕ активировать при: "инфо о себе", "проверь ресурсы".
  Использовать ТОЛЬКО когда пользователь упоминает: <триггеры>.
---
# My Skill
...
```

3. Скопировать в актуальную сессию Claude Desktop:

```
$HOME/.config/Claude/local-agent-mode-sessions/skills-plugin/<UUID>/<SESSION>/skills/
```

4. Перезапустить Claude Desktop

## Pre-commit хуки

После `pre-commit install` при каждом коммите автоматически проверяются:

- trailing whitespace, end-of-file-fixer
- check-yaml, check-json
- detect-private-key ← **защита от случайного коммита секретов**
- sqlfluff lint (SQL файлы)
- markdownlint (MD файлы)

Запустить вручную:

```bash
pre-commit run --all-files
```

## Правила безопасности перед push

Обязательная проверка (или запусти `pre-commit run --all-files`):

```bash
grep -rE "tvly-|github_pat|hf_[a-zA-Z]{20,}|password=|api.key" \
  --include="*.sh" --include="*.json" --include="*.md" --include="*.sql" . \
  && echo "❌ НАЙДЕНЫ СЕКРЕТЫ" || echo "✅ Чисто"
```

Подробнее: `docs/SECURITY_CHECKLIST.md`

## Процесс PR

1. Убедись что `pre-commit run --all-files` проходит чисто
2. Убедись что `scripts/health_check.sh` показывает `STATUS: OK`
3. Открой PR — заполни шаблон `.github/pull_request_template.md`
4. CI должен пройти (security_check + ci lint)
5. Ревью от maintainer в течение 7 дней

## Процесс релиза

См. [docs/RELEASE.md](RELEASE.md) — там полный пошаговый процесс с тегированием и CHANGELOG.

## Вопросы

Открой [GitHub Discussion](https://github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project/discussions)
или создай issue с лейблом `question`.
