#!/usr/bin/env sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

echo "[kudora:e2e] Chain business and validator-fault scenarios"
make --no-print-directory -C "$ROOT/kudora" e2e

echo "[kudora:e2e] Browser business scenarios"
sh "$ROOT/scripts/localnet.sh" reset
sh "$ROOT/scripts/localnet.sh" up
sh "$ROOT/scripts/browser-e2e.sh"

echo "[kudora:e2e] PASS — chain, validator faults, and browser business flows"
