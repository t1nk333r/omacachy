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
# Deliberately NOT checked: field counts, status prefixes, blank lines, path
# existence, prose width. Those are review questions, not test questions —
# see plan 050 for the reasoning.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLANS_DIR="$REPO_ROOT/plans"
INDEX="$PLANS_DIR/README.md"
ALLOW="$PLANS_DIR/.known-external-refs"

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

# ---- verdict ---------------------------------------------------------------

if ((fail)); then
  note "docs check FAILED"
  exit 1
fi
note "docs check passed"
