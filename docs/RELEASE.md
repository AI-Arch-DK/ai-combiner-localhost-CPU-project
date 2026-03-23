# Release Process

AI Combiner follows [Semantic Versioning](https://semver.org): `MAJOR.MINOR.PATCH`

| Type | When | Example |
|---|---|---|
| PATCH | Bug fixes, docs, minor tweaks | `0.3.0` → `0.3.1` |
| MINOR | New features, new qwen_tasks, new MCP | `0.3.0` → `0.4.0` |
| MAJOR | Breaking changes to routing/DB schema | `0.3.0` → `1.0.0` |

## Step-by-step Release

### 1. Update VERSION

```bash
echo "0.4.0" > VERSION
```

### 2. Update CHANGELOG.md

Add a new section at the top:

```markdown
## [0.4.0] - YYYY-MM-DD
### Added
- ...
### Changed
- ...
### Fixed
- ...
```

### 3. Commit

```bash
git add VERSION CHANGELOG.md
git commit -m "chore: release v0.4.0"
```

### 4. Tag

```bash
git tag -a v0.4.0 -m "Release v0.4.0"
git push upstream main --tags
```

### 5. GitHub Release

Go to **Releases → Draft a new release** → select tag → paste CHANGELOG section → publish.

## Automated VERSION bump (optional)

```bash
# bump_version.sh — increment PATCH automatically
current=$(cat VERSION)
IFS='.' read -r maj min pat <<< "$current"
new_pat=$((pat + 1))
echo "$maj.$min.$new_pat" > VERSION
echo "Bumped: $current → $maj.$min.$new_pat"
```

## Branch Strategy

```
main          ← stable, protected
dev           ← integration branch (optional)
feature/*     ← feature branches
fix/*         ← bugfix branches
```

All PRs target `main`. Direct pushes to `main` are restricted (configure in Settings → Branches).
