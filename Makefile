.DEFAULT_GOAL := setup

.PHONY: setup sync help

setup sync:
	@sh scripts/sync-repositories.sh

help:
	@echo "Kudora development workspace"
	@echo ""
	@echo "  make         Clone missing repositories and update existing ones"
	@echo "  make setup   Same as make"
	@echo "  make sync    Same as make"
	@echo "  make help    Show this help"
