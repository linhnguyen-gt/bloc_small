# Automated Release Workflow

## Overview

The CI/CD pipeline automatically handles versioning, CHANGELOG generation, GitHub releases, and pub.dev publishing when code is pushed to `main` or `master`.

## Workflow Steps

### 1. Test Job
- Runs on every push and PR
- Analyzes code with `flutter analyze`
- Runs test suite with coverage
- Uploads coverage to Codecov

### 2. Version Job (Push to main/master only)
- Bumps version based on conventional commits
- Generates CHANGELOG.md entry
- Commits changes back to repository
- Creates GitHub release with tag

### 3. Publish Job (After version bump)
- Publishes package to pub.dev
- Only runs if version was successfully bumped

## Version Bump Rules

Based on commit messages since last tag:

| Commit Type | Version Bump | Example |
|------------|-------------|---------|
| `feat:` | MINOR | 3.1.1 → 3.2.0 |
| `fix:` | PATCH | 3.1.1 → 3.1.2 |
| `BREAKING CHANGE:` or `!` | MAJOR | 3.1.1 → 4.0.0 |
| Other | PATCH | 3.1.1 → 3.1.2 |

## Conventional Commits

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Examples

**Feature (MINOR bump):**
```
feat: add new loading overlay mixin
```

**Fix (PATCH bump):**
```
fix: resolve memory leak in ReactiveSubject
```

**Breaking Change (MAJOR bump):**
```
feat!: refactor base classes API

BREAKING CHANGE: BaseBlocPageState API changed
```

Or with `!`:
```
feat!: remove deprecated methods
```

## Manual Release

To manually trigger a release:

1. **Bump version:**
   ```bash
   NEW_VERSION=$(dart scripts/bump_version.dart)
   ```

2. **Generate CHANGELOG:**
   ```bash
   dart scripts/generate_changelog.dart $NEW_VERSION
   ```

3. **Commit and push:**
   ```bash
   git add pubspec.yaml CHANGELOG.md
   git commit -m "chore: bump version to $NEW_VERSION"
   git push origin main
   ```

4. **Create release manually** (if needed):
   - Go to GitHub Releases
   - Create new release with tag `v$NEW_VERSION`
   - Copy CHANGELOG entry as release notes

## Workflow Triggers

- **Push to main/master**: Full workflow (test → version → release → publish)
- **Pull Request**: Test only
- **Manual dispatch**: Full workflow (via GitHub Actions UI)

## Required Secrets

- `PUB_CREDENTIALS`: pub.dev credentials (JSON format)
- `GITHUB_TOKEN`: Automatically provided by GitHub Actions

## Troubleshooting

### Version not bumping
- Check if commits follow conventional commit format
- Verify commits exist since last tag
- Check workflow logs for errors

### CHANGELOG not generating
- Ensure commits are properly formatted
- Check script has write permissions
- Verify CHANGELOG.md exists

### Release not created
- Check GitHub token permissions
- Verify version job completed successfully
- Check workflow logs for errors

### Package not publishing
- Verify `PUB_CREDENTIALS` secret is set
- Check version was actually bumped
- Ensure package passes validation
