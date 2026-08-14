#!/usr/bin/env sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CHAIN="$ROOT/kudora"
FRONT="$ROOT/kudora-app-front/app"
ASSETS="$FRONT/mirror-assets"
FRONT_COMPOSE="docker compose --project-name kudora-front --file $ROOT/deploy/localnet/docker-compose.yml"

wait_frontend() {
  attempt=0
  while [ "$attempt" -lt 60 ]; do
    if $FRONT_COMPOSE exec --no-TTY frontend wget -q -O /dev/null http://127.0.0.1/ >/dev/null 2>&1; then
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 1
  done
  echo "[kudora-dev] Frontend did not become ready" >&2
  return 1
}

case "${1:-}" in
  up)
    make --no-print-directory -C "$CHAIN" product-build
    make --no-print-directory -C "$CHAIN" product-up
    make --no-print-directory -C "$CHAIN" product-bootstrap
    mkdir -p "$ASSETS/assets"
    make --no-print-directory -C "$CHAIN" product-config >"$ASSETS/kudora-local-config.json"
    make --no-print-directory -C "$CHAIN" product-wallets >"$ASSETS/kudora-local-wallets.json"
    docker run --rm \
      --volume kudora-front-npm-cache:/npm-cache \
      --volume "$FRONT:/app" \
      --workdir /app \
      node:22-alpine \
      sh -c 'npm ci --cache /npm-cache --prefer-offline --no-audit --no-fund && npm run integration:build'
    $FRONT_COMPOSE up --detach --force-recreate --remove-orphans
    wait_frontend
    block=$(make --no-print-directory -C "$CHAIN" product-height)
    router=$(sed -n 's/.*"routerAddress": "\([^"]*\)".*/\1/p' "$ASSETS/kudora-local-config.json")
    printf '\nKudora localnet ready\n\n'
    printf 'Frontend:              http://localhost:3000\n'
    printf 'Cosmos chain:          kudora_12000-1\n'
    printf 'EVM chain:             120001\n'
    printf 'Cosmos REST:           http://localhost:1317\n'
    printf 'Cosmos RPC:            http://localhost:26657\n'
    printf 'EVM RPC:               http://localhost:8545\n'
    printf 'Current block:         %s\n' "${block:-unknown}"
    printf 'Validators:            3\n'
    printf 'Discussion precompile: 0x0000000000000000000000000000000000000900\n'
    printf 'Local swap:            KUD / MockUSDC\n'
    printf 'Router:                %s\n\n' "${router:-unknown}"
    make --no-print-directory -C "$CHAIN" product-accounts
    ;;
  down)
    $FRONT_COMPOSE down --remove-orphans
    make --no-print-directory -C "$CHAIN" product-down
    ;;
  logs)
    $FRONT_COMPOSE logs --tail 100 frontend
    make --no-print-directory -C "$CHAIN" product-logs
    ;;
  reset)
    $FRONT_COMPOSE down --volumes --remove-orphans
    make --no-print-directory -C "$CHAIN" product-reset
    rm -f "$ASSETS/kudora-local-config.json" "$ASSETS/kudora-local-wallets.json"
    ;;
  accounts)
    make --no-print-directory -C "$CHAIN" product-accounts
    ;;
  fund)
    make --no-print-directory -C "$CHAIN" product-fund KUDORA_FUND_AMOUNT="${2:-100}"
    ;;
  seed)
    make --no-print-directory -C "$CHAIN" product-seed
    ;;
  *)
    echo "usage: localnet.sh up|down|logs|reset|accounts|fund|seed" >&2
    exit 1
    ;;
esac
