# Release Process

Full step-by-step guide for cutting a new AI Combiner release.

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

```text
MAJOR.MINOR.PATCH
```

- **MAJOR** — breaking changes (incompatible API or database schema changes)
- **MINOR** — new features (new qwen_tasks, MCP servers, skills)
- **PATCH** — bug fixes, documentation updates, security patches

## Release Steps

### 1. Prepare

```bash
# Make sure main is clean
git checkout main && git pull upstream main

# Run all checks
pre-commit run --all-files
bash scripts/health_check.sh
```

### 2. Update CHANGELOG.md

Add a new section at the top of the file:

```markdown
## [vX.Y.Z] — YYYY-MM-DD

### Added
- ...

### Fixed
- ...

### Changed
- ...
```

### 3. Update VERSION

```bash
echo "vX.Y.Z" > VERSION
git add VERSION CHANGELOG.md
git commit -m "chore: release vX.Y.Z"
```

### 4. Create git tag

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push upstream main --tags
```

### 5. GitHub Release

From the repository page: **Releases → Draft a new release**

- Tag: `vX.Y.Z`
- Title: `AI Combiner vX.Y.Z`
- Body: paste the relevant section from CHANGELOG.md

## Automating VERSION (optional)

To auto-update the VERSION file on tag push, add this workflow:

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
```

## Branches and PRs

- All changes go through a PR into `main`
- Branch naming: `feat/`, `fix/`, `docs/`, `chore/`
- Squash merge to keep history clean

## Issue / PR Labels

| Label | Description |
|---|---|
| `good first issue` | Suitable for first-time contributors |
| `bug` | Something is broken |
| `enhancement` | New feature or improvement |
| `help wanted` | Extra attention needed |
| `documentation` | Documentation only |
| `security` | Security-related change |
