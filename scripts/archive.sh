#!/usr/bin/env sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEV_REPOSITORY_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
BLOCKCHAIN_REPOSITORY_DIR="$DEV_REPOSITORY_DIR/kudora"
BACKEND_REPOSITORY_DIR="$DEV_REPOSITORY_DIR/kudora-app-backend"
FRONTEND_REPOSITORY_DIR="$DEV_REPOSITORY_DIR/kudora-app-front"
OUTPUT_DIR="$DEV_REPOSITORY_DIR/out"
OUTPUT_PATH="$OUTPUT_DIR/kudora-dev.zip"

fail() {
    printf '%s\n' "[kudora-dev] Error: $*" >&2
    exit 1
}

command -v git >/dev/null 2>&1 || fail "Git is required."
[ -d "$BLOCKCHAIN_REPOSITORY_DIR/.git" ] || fail "Run 'make setup' first."
[ -d "$BACKEND_REPOSITORY_DIR/.git" ] || fail "Run 'make setup' first."
[ -d "$FRONTEND_REPOSITORY_DIR/.git" ] || fail "Run 'make setup' first."

TEMPORARY_DIR=$(mktemp -d "${TMPDIR:-/tmp}/kudora-archive.XXXXXX") || fail "Could not create a temporary directory."
COMBINED_REPOSITORY="$TEMPORARY_DIR/combined.git"
trap 'rm -rf "$TEMPORARY_DIR"' EXIT HUP INT TERM

worktree_tree() {
    repository_dir=$1
    temporary_index=$2

    GIT_INDEX_FILE="$temporary_index" git -C "$repository_dir" read-tree HEAD
    GIT_INDEX_FILE="$temporary_index" git -C "$repository_dir" add -A -- .
    GIT_INDEX_FILE="$temporary_index" git -C "$repository_dir" write-tree
}

import_tree() {
    repository_dir=$1
    tree=$2

    printf '%s\n' "$tree" \
        | git -C "$repository_dir" pack-objects --stdout --revs \
        | git --git-dir="$COMBINED_REPOSITORY" index-pack --stdin --fix-thin >/dev/null
}

BLOCKCHAIN_TREE=$(worktree_tree "$BLOCKCHAIN_REPOSITORY_DIR" "$TEMPORARY_DIR/blockchain.index")
BACKEND_TREE=$(worktree_tree "$BACKEND_REPOSITORY_DIR" "$TEMPORARY_DIR/backend.index")
FRONTEND_TREE=$(worktree_tree "$FRONTEND_REPOSITORY_DIR" "$TEMPORARY_DIR/frontend.index")

git init --bare --quiet "$COMBINED_REPOSITORY"
import_tree "$BLOCKCHAIN_REPOSITORY_DIR" "$BLOCKCHAIN_TREE"
import_tree "$BACKEND_REPOSITORY_DIR" "$BACKEND_TREE"
import_tree "$FRONTEND_REPOSITORY_DIR" "$FRONTEND_TREE"

COMBINED_TREE=$(
    {
        printf '040000 tree %s\tkudora\n' "$BLOCKCHAIN_TREE"
        printf '040000 tree %s\tkudora-app-backend\n' "$BACKEND_TREE"
        printf '040000 tree %s\tkudora-app-front\n' "$FRONTEND_TREE"
    } | git --git-dir="$COMBINED_REPOSITORY" mktree
)

mkdir -p "$OUTPUT_DIR"
git --git-dir="$COMBINED_REPOSITORY" archive \
    --format=zip \
    --output="$OUTPUT_PATH" \
    "$COMBINED_TREE" \
    -- \
    . \
    ':(exclude,glob)**/.cache/**' \
    ':(exclude,glob)**/.localnet/**' \
    ':(exclude,glob)**/.next/**' \
    ':(exclude,glob)**/build/**' \
    ':(exclude,glob)**/coverage/**' \
    ':(exclude,glob)**/dist/**' \
    ':(exclude,glob)**/node_modules/**' \
    ':(exclude,glob)**/out/**' \
    ':(exclude,glob)**/tmp/**'

printf '%s\n' "[kudora-dev] Archive ready: $OUTPUT_PATH"
