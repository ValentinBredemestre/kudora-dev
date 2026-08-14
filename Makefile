ifeq ($(strip $(MAKECMDGOALS)),)
$(error Specify a command: make setup, make sync, make zip, make localnet, make e2e, or make help)
endif

.PHONY: e2e help localnet localnet-accounts localnet-down localnet-logs localnet-reset setup sync zip

e2e:
	@sh scripts/e2e.sh

setup:
	@sh scripts/repositories.sh setup

sync:
	@sh scripts/repositories.sh sync

zip:
	@sh scripts/archive.sh

help:
	@echo "Kudora development workspace"
	@echo ""
	@echo "  make setup   Clone the required repositories"
	@echo "  make sync    Pull the latest changes"
	@echo "  make zip     Create out/kudora-dev.zip for sharing"
	@echo "  make localnet           Start 3 validators and the frontend"
	@echo "  make localnet-accounts  Print disposable local accounts"
	@echo "  make localnet-down      Stop the local environment"
	@echo "  make localnet-logs      Follow validator and frontend logs"
	@echo "  make localnet-reset     Remove generated local state"
	@echo "  make e2e                Run real business E2E scenarios"
	@echo "  make help    Show this help"

localnet:
	@sh scripts/localnet.sh up

localnet-accounts:
	@sh scripts/localnet.sh accounts

localnet-down:
	@sh scripts/localnet.sh down

localnet-logs:
	@sh scripts/localnet.sh logs

localnet-reset:
	@sh scripts/localnet.sh reset
