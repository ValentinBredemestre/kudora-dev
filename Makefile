ifeq ($(strip $(MAKECMDGOALS)),)
$(error Specify a command. Run 'make help' to list the available commands)
endif

.PHONY: e2e fund help localnet localnet-accounts localnet-down localnet-fast localnet-logs localnet-reset seed setup sync zip

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
	@echo "  make e2e                Run real business E2E scenarios"
	@echo "  make fund [AMOUNT=100]  Fund Alice, Bob, and Carol with KUD"
	@echo "  make localnet           Start 3 validators and the frontend"
	@echo "  make localnet-accounts  Print disposable local accounts and keys"
	@echo "  make localnet-down      Stop the local environment"
	@echo "  make localnet-fast      Recreate localnet with 5-minute proposal votes"
	@echo "  make localnet-logs      Follow validator and frontend logs"
	@echo "  make localnet-reset     Remove generated local state"
	@echo "  make seed               Create the on-chain demo dataset"
	@echo "  make setup              Clone the required repositories"
	@echo "  make sync               Pull the latest changes"
	@echo "  make zip                Create out/kudora-dev.zip for sharing"
	@echo "  make help               Show this help"

localnet:
	@sh scripts/localnet.sh up

localnet-accounts:
	@sh scripts/localnet.sh accounts

localnet-down:
	@sh scripts/localnet.sh down

localnet-fast:
	@sh scripts/localnet.sh fast "$(VOTING_PERIOD)"

localnet-logs:
	@sh scripts/localnet.sh logs

localnet-reset:
	@sh scripts/localnet.sh reset

fund:
	@sh scripts/localnet.sh fund "$(AMOUNT)"

seed:
	@sh scripts/localnet.sh seed
