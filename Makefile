ifeq ($(strip $(MAKECMDGOALS)),)
$(error Specify a command: make setup, make sync, make zip, or make help)
endif

.PHONY: help setup sync zip

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
	@echo "  make zip     Create kudora-chat.zip for sharing"
	@echo "  make help    Show this help"
