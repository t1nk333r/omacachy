#!/bin/bash
set -uo pipefail

# check-docs.sh — assert that the plan record is internally consistent.
# Read-only: it reports, it never edits.
#
# Two checks only, both objective, both catching failures this repo has
# actually had:
#
#   1. Every plan file has exactly one row in the index, and every index row
#      has a file. Nine executed plans once sat outside the index entirely
#      (see plan 046), so the "authoritative" index under-reported the work.
#
#   2. Every short commit hash cited in a plan or in the index resolves to a
#      real commit, unless it is listed in plans/.known-external-refs with a
#      reason. Index rows are sometimes written by delegated agents, and a
#      plausible-looking invented hash is a real failure mode.
#
#   3. Every repo-relative path the agent docs assert actually exists, unless
#      listed in plans/.known-absent-paths with a reason. The shipped domain
#      doc once described a src/ordering tree this repo has never had, and an
#      agent following it read nothing (see plan 047).
#
# Deliberately NOT checked: field counts, status prefixes, blank lines, prose
# width. Those are review questions, not test questions — see plan 050.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLANS_DIR="$REPO_ROOT/plans"
INDEX="$PLANS_DIR/README.md"
ALLOW="$PLANS_DIR/.known-external-refs"
ALLOW_PATHS="$PLANS_DIR/.known-absent-paths"

fail=0
note() { printf '%s\n' "$*"; }
bad()  { printf 'FAIL: %s\n' "$*"; fail=1; }

cd "$REPO_ROOT" || exit 2
[[ -f $INDEX ]] || { bad "no plan index at plans/README.md"; exit 1; }

# ---- 1. plan files and index rows agree, both directions -------------------

mapfile -t files < <(
  find "$PLANS_DIR" -maxdepth 1 -name '[0-9][0-9][0-9]-*.md' -printf '%f\n' |
    sed 's/^\([0-9]\{3\}\)-.*/\1/' | sort
)
mapfile -t rows < <(
  grep -oE '^\| ([0-9]{3}) \|' "$INDEX" | grep -oE '[0-9]{3}' | sort
)

for n in "${files[@]}"; do
  c=$(printf '%s\n' "${rows[@]}" | grep -cx "$n")
  case $c in
    1) ;;
    0) bad "plan $n has a file but no index row" ;;
    *) bad "plan $n has $c index rows (expected 1)" ;;
  esac
done

for n in "${rows[@]}"; do
  printf '%s\n' "${files[@]}" | grep -qx "$n" ||
    bad "index row $n has no plans/$n-*.md file"
done

note "plan files: ${#files[@]}  index rows: ${#rows[@]}"

# ---- 2. every cited commit hash resolves -----------------------------------

# Hashes appear as bare 7-12 hex words, often in backticks. Words that are all
# digits are plan numbers or dates, not hashes, so they are skipped; so is
# anything git does not know, which is reported rather than assumed benign.
cited=0
allowed=0
is_allowed() {
  [[ -f $ALLOW ]] || return 1
  grep -vE '^\s*(#|$)' "$ALLOW" | awk '{print $1}' | grep -qx "$1"
}
while read -r file hash; do
  # A 7+ hex string that is entirely decimal is a number, not a hash.
  [[ $hash =~ ^[0-9]+$ ]] && continue
  cited=$((cited + 1))
  git cat-file -e "${hash}^{commit}" 2>/dev/null && continue
  if is_allowed "$hash"; then
    allowed=$((allowed + 1))
    continue
  fi
  bad "$file cites '$hash', which is not a commit in this repo" \
    "(if it belongs to another project, add it to plans/.known-external-refs)"
done < <(
  grep -ohnE '\b[0-9a-f]{7,12}\b' "$INDEX" "$PLANS_DIR"/[0-9][0-9][0-9]-*.md \
    --with-filename 2>/dev/null |
    sed -E 's|^.*/||; s/:[0-9]+:/ /' |
    awk '{print $1, $2}' | sort -u
)

note "commit hashes cited: $cited  (known-external, skipped: $allowed)"

# ---- 3. asserted paths exist ----------------------------------------------

# Only backticked tokens under a real top-level directory of this repo are
# treated as assertions. That excludes bare basenames, GitHub slugs, git refs,
# system paths and env assignments, which are prose rather than claims about
# this tree. Globs and brace sets are skipped: they name a shape, not a file.
paths=0
while read -r file path; do
  paths=$((paths + 1))
  [[ -e ${path%/} ]] && continue
  if [[ -f $ALLOW_PATHS ]] &&
     grep -vE '^\s*(#|$)' "$ALLOW_PATHS" | awk '{print $1}' | grep -qx "$path"
  then
    continue
  fi
  bad "$file asserts path '$path', which does not exist" \
    "(if the mention is a denial, add it to plans/.known-absent-paths)"
done < <(
  for f in AGENTS.md handoff.md docs/agents/*.md; do
    [[ -f $f ]] || continue
    # shellcheck disable=SC2016  # backticks are markdown, not expansion
    grep -oE '`[^`]+`' "$f" | tr -d '`' |
      grep -E '^(bin|docs|share|tests|plans|src)/' |
      grep -vE '[ *{]' |
      while read -r p; do printf '%s %s\n' "$f" "$p"; done
  done | sort -u
)

note "paths asserted in agent docs: $paths"

# ---- verdict ---------------------------------------------------------------

if ((fail)); then
  note "docs check FAILED"
  exit 1
fi
note "docs check passed"
