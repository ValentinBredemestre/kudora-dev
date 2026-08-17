# Kudora development workspace

Kudora is a Cosmos SDK chain with EVM support. This workspace groups the
blockchain and application repositories without merging their Git histories.

Requirements: Docker, Docker Compose, Make, and Git.

## Local product

```sh
make localnet
```

Open the printed frontend URL, normally <http://localhost:3000>. The command
starts three validators, the conventional Cosmos and EVM endpoints, the static
frontend, three funded disposable accounts, and the local-only KUD/MockUSDC
swap fixture. No application backend or database is used.

The frontend offers four signing paths:

- MetaMask and Local MetaMask for EVM transactions.
- Keplr and Local Keplr for native Cosmos transactions.

Both wallet families read and modify the same chain state. Quick interactions
authorize a browser-local session key for discussion posts and reactions only;
Zap, governance, transfers, and swaps still use the primary wallet.

Useful commands:

```sh
make localnet-accounts  # Print disposable local keys and both address forms
make localnet-fast      # Recreate localnet with five-minute proposal votes
make localnet-logs      # Follow frontend and validator logs
make localnet-down      # Stop the environment and keep its state
make localnet-reset     # Stop it and delete generated local state
make e2e                # Run chain, validator-fault, and browser business E2E
```

Local keys are deterministic, disposable, and must never be used on mainnet.
The swap contracts are a test fixture, not a production DEX.

## Workspace setup

```sh
make setup
make sync
make zip
```

`make setup` clones missing repositories, `make sync` fast-forwards repositories
already present, and `make zip` creates `out/kudora-dev.zip` without Git metadata,
caches, generated state, or build output. Run `make help` for the command list.
