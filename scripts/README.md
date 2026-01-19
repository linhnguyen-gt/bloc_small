# Release Scripts

Scripts for automated versioning and release management.

## Scripts

### `bump_version.dart`

Automatically bumps version in `pubspec.yaml` based on conventional commits.

**Version Bump Rules:**
- `feat:` → MINOR bump (3.1.1 → 3.2.0)
- `fix:` → PATCH bump (3.1.1 → 3.1.2)
- `BREAKING CHANGE:` or `!` → MAJOR bump (3.1.1 → 4.0.0)
- Other commits → PATCH bump

**Usage:**
```bash
dart scripts/bump_version.dart
```

**Output:**
- Prints new version to stdout
- Updates `pubspec.yaml`
- Logs bump type to stderr

### `generate_changelog.dart`

Generates CHANGELOG.md entry from conventional commits since last tag.

**Usage:**
```bash
dart scripts/generate_changelog.dart <version>
```

**Example:**
```bash
dart scripts/generate_changelog.dart 3.2.0
```

**Features:**
- Parses commits since last Git tag
- Groups by conventional commit type
- Generates formatted CHANGELOG entry
- Prepend to existing CHANGELOG.md
- Includes links to GitHub commits

## Conventional Commits

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature (MINOR bump)
- `fix`: Bug fix (PATCH bump)
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Test changes
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

**Breaking Changes:**
- Add `!` after type: `feat!: breaking change`
- Or include `BREAKING CHANGE:` in footer

## CI/CD Integration

These scripts are automatically run by GitHub Actions on push to `main`/`master`:

1. **Test** - Runs tests and analysis
2. **Version** - Bumps version and generates CHANGELOG
3. **Release** - Creates GitHub release
4. **Publish** - Publishes to pub.dev

## Manual Usage

To manually bump version and generate CHANGELOG:

```bash
# Bump version
NEW_VERSION=$(dart scripts/bump_version.dart)

# Generate CHANGELOG
dart scripts/generate_changelog.dart $NEW_VERSION

# Commit changes
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to $NEW_VERSION"
```
