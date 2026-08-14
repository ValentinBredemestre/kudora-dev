#!/usr/bin/env sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEV_REPOSITORY_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
REPOSITORY_DIR="$DEV_REPOSITORY_DIR/kudora"
OUTPUT_DIR="$DEV_REPOSITORY_DIR/out"
OUTPUT_PATH="$OUTPUT_DIR/kudora-dev.zip"

fail() {
    printf '%s\n' "[kudora-dev] Error: $*" >&2
    exit 1
}

command -v git >/dev/null 2>&1 || fail "Git is required."
[ -d "$REPOSITORY_DIR/.git" ] || fail "Run 'make setup' first."

TEMPORARY_DIR=$(mktemp -d "${TMPDIR:-/tmp}/kudora-archive.XXXXXX") || fail "Could not create a temporary directory."
TEMPORARY_INDEX="$TEMPORARY_DIR/index"
trap 'rm -f "$TEMPORARY_INDEX" "$TEMPORARY_INDEX.lock"; rmdir "$TEMPORARY_DIR" 2>/dev/null || true' EXIT HUP INT TERM

export GIT_INDEX_FILE="$TEMPORARY_INDEX"
git -C "$REPOSITORY_DIR" read-tree HEAD
git -C "$REPOSITORY_DIR" add -A -- .
TREE=$(git -C "$REPOSITORY_DIR" write-tree)
unset GIT_INDEX_FILE

mkdir -p "$OUTPUT_DIR"
git -C "$REPOSITORY_DIR" archive \
    --format=zip \
    --prefix=kudora/ \
    --output="$OUTPUT_PATH" \
    "$TREE"

printf '%s\n' "[kudora-dev] Archive ready: $OUTPUT_PATH"
