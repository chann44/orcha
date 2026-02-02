# Database Setup

This directory contains the database schema, migrations, and SQL queries for the Orcha protocol implementation.

## Structure

```
db/
├── migrations/     # SQL migration files
├── queries/       # SQL queries for sqlc code generation
└── README.md      # This file
```

## Setup

### 1. Start PostgreSQL

```bash
cd deploy
docker-compose -f compose.dev.yml up -d postgres
```

This will start a PostgreSQL container with:
- **User**: `orcha`
- **Password**: `orcha`
- **Database**: `orcha`
- **Port**: `5432`

### 2. Run Migrations

We use [goose](https://github.com/pressly/goose) for database migrations. You can use the Makefile commands:

```bash
# Install goose (if not already installed)
go install github.com/pressly/goose/v3/cmd/goose@latest

# Run all migrations
make db-up

# Or manually with goose
goose -dir db/migrations postgres "postgres://orcha:orcha@localhost:5432/orcha?sslmode=disable" up
```

**Available Makefile commands:**
- `make docker-up` - Start PostgreSQL container
- `make docker-down` - Stop PostgreSQL container
- `make docker-logs` - Show PostgreSQL logs
- `make db-status` - Show migration status
- `make db-up` - Run all pending migrations
- `make db-down` - Rollback one migration
- `make db-reset` - Reset database (rollback all, then run all)
- `make db-create NAME=migration_name` - Create a new migration file
- `make sqlc-generate` - Generate Go code from SQL queries
- `make setup` - Full setup (start DB, run migrations, generate code)

### 3. Generate Go Code with sqlc

```bash
# Install sqlc
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest

# Generate code
sqlc generate
```

This will generate Go code in `pkg/db/` based on your queries in `db/queries/`.

## Connection String

For local development:
```
postgres://orcha:orcha@localhost:5432/orcha?sslmode=disable
```

## Environment Variables

Create a `.env` file in the project root:

```env
DATABASE_URL=postgres://orcha:orcha@localhost:5432/orcha?sslmode=disable
```

## Database Schema

The schema includes tables for:

- **publishers** - Content publishers
- **feeds** - Data feeds
- **events** - Orcha protocol events
- **entities** - Extracted entities from events
- **metrics** - Quantitative data from events
- **licenses** - License definitions
- **license_agreements** - Consumer license agreements
- **subscriptions** - Feed subscriptions
- **affordances** - Available actions for events
- **temporal_metadata** - Time-related metadata
- **geographic_metadata** - Location-related metadata

See `db/migrations/20250202000000_initial_schema.up.sql` for the complete schema.

## Creating New Migrations

Use the Makefile to create new migrations:

```bash
make db-create NAME=add_user_table
```

This will create two files:
- `db/migrations/YYYYMMDDHHMMSS_add_user_table.up.sql`
- `db/migrations/YYYYMMDDHHMMSS_add_user_table.down.sql`

Goose uses timestamped filenames to ensure migrations run in order.

## Adding New Queries

1. Add SQL queries to files in `db/queries/`
2. Use sqlc query annotations (e.g., `-- name: GetEventByID :one`)
3. Run `sqlc generate` to regenerate Go code

## Query Annotations

sqlc uses special comments to generate Go code:

- `-- name: FunctionName :one` - Returns a single row
- `-- name: FunctionName :many` - Returns multiple rows
- `-- name: FunctionName :exec` - Executes without returning rows
- `-- name: FunctionName :execrows` - Executes and returns affected rows
