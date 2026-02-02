.PHONY: help db-up db-down db-reset db-status db-create db-migrate db-rollback sqlc-generate docker-up docker-down docker-logs

# Database connection string
DB_URL ?= postgres://orcha:orcha@localhost:5432/orcha?sslmode=disable

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

docker-up: ## Start PostgreSQL container
	cd deploy && docker-compose -f compose.dev.yml up -d postgres
	@echo "Waiting for PostgreSQL to be ready..."
	@sleep 3

docker-down: ## Stop PostgreSQL container
	cd deploy && docker-compose -f compose.dev.yml down

docker-logs: ## Show PostgreSQL logs
	cd deploy && docker-compose -f compose.dev.yml logs -f postgres

db-status: ## Show migration status
	@goose -dir db/migrations postgres "$(DB_URL)" status

db-up: ## Run all migrations
	@goose -dir db/migrations postgres "$(DB_URL)" up

db-down: ## Rollback one migration
	@goose -dir db/migrations postgres "$(DB_URL)" down

db-reset: ## Reset database (rollback all migrations, then run all)
	@goose -dir db/migrations postgres "$(DB_URL)" reset
	@goose -dir db/migrations postgres "$(DB_URL)" up

db-create: ## Create a new migration file (usage: make db-create NAME=migration_name)
	@if [ -z "$(NAME)" ]; then \
		echo "Error: NAME is required. Usage: make db-create NAME=migration_name"; \
		exit 1; \
	fi
	@goose -dir db/migrations postgres "$(DB_URL)" create $(NAME) sql

db-migrate: db-up ## Alias for db-up

db-rollback: db-down ## Alias for db-down

sqlc-generate: ## Generate Go code from SQL queries
	@sqlc generate

sqlc-validate: ## Validate sqlc configuration
	@sqlc compile

setup: docker-up db-up sqlc-generate ## Full setup: start DB, run migrations, generate code
	@echo "Setup complete!"

clean: ## Clean generated files
	@rm -rf pkg/db/*.go
	@echo "Cleaned generated files"

test-db: ## Run database tests (placeholder)
	@echo "Database tests not yet implemented"
