#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'TXT'
flute_rc_V1 Git CLI helper

Usage:
  ./scripts/git-flow.sh start <feature|fix|release> <short-name>
  ./scripts/git-flow.sh finish <branch-name>
  ./scripts/git-flow.sh sync
  ./scripts/git-flow.sh tag <version>

Examples:
  ./scripts/git-flow.sh start feature playlists
  ./scripts/git-flow.sh start fix permission-dialog
  ./scripts/git-flow.sh finish feature/playlists
  ./scripts/git-flow.sh tag 1.0.0-rc.1
TXT
}

require_clean() {
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "Working tree is not clean. Commit or stash changes first." >&2
    exit 1
  fi
}

command="${1:-}"
case "$command" in
  start)
    kind="${2:-}"
    name="${3:-}"
    [[ "$kind" =~ ^(feature|fix|release)$ ]] || { usage; exit 1; }
    [[ -n "$name" ]] || { usage; exit 1; }
    require_clean
    base="develop"
    [[ "$kind" == "release" ]] && base="develop"
    git fetch origin --prune
    git switch "$base"
    git pull --ff-only origin "$base"
    git switch -c "$kind/$name"
    ;;
  finish)
    branch="${2:-}"
    [[ -n "$branch" ]] || { usage; exit 1; }
    require_clean
    target="develop"
    [[ "$branch" == release/* ]] && target="main"
    git fetch origin --prune
    git switch "$target"
    git pull --ff-only origin "$target"
    git merge --no-ff "$branch"
    git push origin "$target"
    git branch -d "$branch"
    ;;
  sync)
    require_clean
    git fetch origin --prune
    current="$(git branch --show-current)"
    git rebase "origin/$current"
    ;;
  tag)
    version="${2:-}"
    [[ -n "$version" ]] || { usage; exit 1; }
    require_clean
    git switch main
    git pull --ff-only origin main
    git tag -a "v$version" -m "flute_rc_V1 $version"
    git push origin "v$version"
    ;;
  *) usage; exit 1 ;;
esac
