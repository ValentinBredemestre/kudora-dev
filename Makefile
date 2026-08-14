ifeq ($(strip $(MAKECMDGOALS)),)
$(error Specify a command: make setup, make sync, or make help)
endif

.PHONY: setup sync help

setup:
	@sh scripts/repositories.sh setup

sync:
	@sh scripts/repositories.sh sync

help:
	@echo "Kudora development workspace"
	@echo ""
	@echo "  make setup   Clone the required repositories"
	@echo "  make sync    Pull the latest changes"
	@echo "  make help    Show this help"
