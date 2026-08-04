#!/bin/bash
#
# Regenerate the paste-by-hand copy of check.sh inside README.md.
#
#   tools/sync-readme.sh          rewrite README.md in place
#   tools/sync-readme.sh --check  exit 1 if it is out of date (for CI)
#
# The README carries check.sh verbatim so a buyer whose seller refuses the
# curl fetch still has a second delivery route. Two copies of the same script
# drift the moment anyone hand-edits one, so this generates it and nothing
# else is allowed to touch that block.

set -eu

cd "$(dirname "$0")/.."

SRC=check.sh
DOC=README.md
BEGIN='<!-- BEGIN GENERATED check.sh -->'
END='<!-- END GENERATED check.sh -->'
MODE="${1:-write}"

for f in "$SRC" "$DOC"; do
    [ -f "$f" ] || { echo "sync-readme: $f not found" >&2; exit 2; }
done
for m in "$BEGIN" "$END"; do
    grep -qF "$m" "$DOC" || { echo "sync-readme: marker missing in $DOC: $m" >&2; exit 2; }
done

TMP="$(mktemp -t sync-readme)"
trap 'rm -f "$TMP" "$TMP.body"' EXIT

{
    printf '%s\n\n' "$BEGIN"
    printf '```bash\n'
    cat "$SRC"
    printf '```\n\n'
    printf '%s\n' "$END"
} > "$TMP.body"

awk -v begin="$BEGIN" -v end="$END" -v bodyfile="$TMP.body" '
    $0 == begin { inblock = 1; while ((getline line < bodyfile) > 0) print line; next }
    $0 == end   { inblock = 0; next }
    !inblock    { print }
' "$DOC" > "$TMP"

if [ "$MODE" = "--check" ]; then
    if cmp -s "$TMP" "$DOC"; then
        echo "sync-readme: README.md is up to date"
        exit 0
    fi
    echo "sync-readme: README.md is STALE — run tools/sync-readme.sh" >&2
    exit 1
fi

cat "$TMP" > "$DOC"
echo "sync-readme: embedded $(wc -l < "$SRC" | tr -d ' ') lines of $SRC into $DOC"
