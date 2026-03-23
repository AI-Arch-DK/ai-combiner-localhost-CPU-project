# Release Process

Полный процесс выпуска новой версии AI Combiner.

## Версионирование

Проект следует [Semantic Versioning](https://semver.org/):

```text
MAJOR.MINOR.PATCH

```text

- **MAJOR** — breaking changes (несовместимые изменения API/схем БД)
- **MINOR** — новые фичи (новые qwen_tasks, MCP-серверы, скиллы)
- **PATCH** — исправления багов, документация, безопасность

## Шаги релиза

### 1. Подготовка

```bash
# Убедиться что main чистый

git checkout main && git pull upstream main

# Прогнать все проверки

pre-commit run --all-files
bash scripts/health_check.sh

```text

### 2. Обновить CHANGELOG.md

Добавить секцию в начало файла:

```markdown
## [vX.Y.Z] — YYYY-MM-DD

### Added

- ...

### Fixed

- ...

### Changed

- ...

```text

### 3. Обновить VERSION

```bash
echo "vX.Y.Z" > VERSION
git add VERSION CHANGELOG.md
git commit -m "chore: release vX.Y.Z"

```text

### 4. Создать git tag

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push upstream main --tags

```text

### 5. GitHub Release

На странице репозитория: **Releases → Draft a new release**

- Tag: `vX.Y.Z`
- Title: `AI Combiner vX.Y.Z`
- Body: скопировать секцию из CHANGELOG.md

## Автоматизация VERSION (опционально)

Для автоматического обновления VERSION при теге можно добавить workflow:

```yaml
# .github/workflows/release.yml

name: Release
on:
  push:
    tags: ['v*']
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Update VERSION file
        run: echo "${GITHUB_REF_NAME}" > VERSION
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          body_path: CHANGELOG.md

```text

## Ветки и PR

- Все изменения через PR в `main`
- Ветки именовать: `feat/`, `fix/`, `docs/`, `chore/`
- Squash merge для чистоты истории

## Labels для Issues/PR

| Label | Описание |
|---|---|
| `good first issue` | Подходит для новичков |
| `bug` | Баг |
| `enhancement` | Новая фича |
| `help wanted` | Нужна помощь |
| `documentation` | Только документация |
| `security` | Связано с безопасностью |
