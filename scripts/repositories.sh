#!/usr/bin/env sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEV_REPOSITORY_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKSPACE_ROOT=${WORKSPACE_ROOT:-$DEV_REPOSITORY_DIR}
REPOSITORIES="kudora"
ACTION=${1:-}

info() {
    printf '%s\n' "[kudora-dev] $*"
}

fail() {
    printf '%s\n' "[kudora-dev] Error: $*" >&2
    exit 1
}

command -v git >/dev/null 2>&1 || fail "Git is required. Install it from https://git-scm.com/downloads."

case "$ACTION" in
    setup | sync) ;;
    *) fail "Unknown action. Use 'make setup' or 'make sync'." ;;
esac

mkdir -p "$WORKSPACE_ROOT"
info "Workspace: $WORKSPACE_ROOT"

if [ "$ACTION" = "setup" ]; then
    github_user=${GITHUB_USER:-}

    if [ -z "$github_user" ] && command -v gh >/dev/null 2>&1; then
        github_user=$(gh api user --jq .login 2>/dev/null || true)
    fi

    if [ -z "$github_user" ]; then
        origin_url=$(git -C "$DEV_REPOSITORY_DIR" remote get-url origin 2>/dev/null || true)
        case "$origin_url" in
            git@github.com:*) github_user=${origin_url#git@github.com:} ;;
            https://github.com/*) github_user=${origin_url#https://github.com/} ;;
            ssh://git@github.com/*) github_user=${origin_url#ssh://git@github.com/} ;;
        esac
        github_user=${github_user%%/*}
    fi

    [ -n "$github_user" ] || fail "Could not detect your GitHub user. Authenticate with 'gh auth login' or set GITHUB_USER."
    info "GitHub user: $github_user"

    for repository in $REPOSITORIES; do
        target="$WORKSPACE_ROOT/$repository"

        if [ -d "$target/.git" ]; then
            info "$repository is already set up."
        elif [ -e "$target" ]; then
            fail "$target already exists but is not a Git repository."
        else
            info "Cloning $github_user/$repository..."
            if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
                gh repo clone "$github_user/$repository" "$target"
            else
                git clone "https://github.com/$github_user/$repository.git" "$target"
            fi
        fi
    done

    info "Setup complete."
    exit 0
fi

for repository in $REPOSITORIES; do
    target="$WORKSPACE_ROOT/$repository"

    if [ ! -d "$target/.git" ]; then
        fail "$repository is not set up. Run 'make setup' first."
    fi
done

for repository in $REPOSITORIES; do
    target="$WORKSPACE_ROOT/$repository"
    info "Updating $repository..."
    git -C "$target" pull --ff-only
done

info "Sync complete."
