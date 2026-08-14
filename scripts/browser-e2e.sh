#!/usr/bin/env sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
APP="$ROOT/kudora-app-front/app"

docker run --rm \
  --add-host host.docker.internal:host-gateway \
  --volume kudora-front-npm-cache:/npm-cache \
  --volume "$APP:/app" \
  --workdir /app \
  --env KUDORA_EVM_RPC_URL=http://host.docker.internal:8545 \
  --env KUDORA_FRONTEND_URL=http://host.docker.internal:3000 \
  --env KUDORA_REST_URL=http://host.docker.internal:1317 \
  mcr.microsoft.com/playwright:v1.55.0-noble \
  sh -c 'npm ci --cache /npm-cache --prefer-offline --no-audit --no-fund && npx playwright test'
