# Git CLI flow for flute_rc_V1

## Branches

- `main`: tested release candidates and releases only.
- `develop`: integrated development work.
- `feature/<name>`: new features.
- `fix/<name>`: bug fixes.
- `release/<version>`: release stabilization.

## Initial repository setup

```bash
git init
git add .
git commit -m "chore: initialize flute_rc_V1"
git branch -M main
git remote add origin <YOUR_REPOSITORY_URL>
git push -u origin main
git switch -c develop
git push -u origin develop
```

## Daily CLI flow

```bash
./scripts/git-flow.sh start feature playlists
# Make changes.
dart format lib test
flutter analyze
flutter test
git add .
git commit -m "feat: add playlists"
git push -u origin feature/playlists
```

Open a pull request into `develop`. CI must pass before merging.

## Release flow

```bash
./scripts/git-flow.sh start release 1.0.0-rc.1
# Update version, changelog, and release notes.
git add .
git commit -m "chore: prepare 1.0.0-rc.1"
git push -u origin release/1.0.0-rc.1
```

Open a pull request from `release/1.0.0-rc.1` into `main`. After it is reviewed and merged:

```bash
./scripts/git-flow.sh tag 1.0.0-rc.1
```

The tag triggers `.github/workflows/flutter_build.yml`.

## Commit convention

Use concise conventional commits:

```text
feat: add a feature
fix: correct a bug
refactor: restructure without changing behavior
test: add or update tests
docs: update documentation
chore: build, tooling, or release work
```
