---
title: Configuration
description: Configure the Trifle CLI drivers and connection settings.
nav_order: 2
---

# Configuration

## Config file (YAML)

Trifle CLI reads a YAML config file by default. You can define multiple named sources and pick one with `--source`.

- Default path (varies by OS):
  - macOS: `~/Library/Application Support/trifle/config.yaml`
  - Linux: `~/.config/trifle/config.yaml`
  - Windows: `%AppData%\\trifle\\config.yaml`
- Override with `--config` or `TRIFLE_CONFIG`
- Precedence: flags -> env vars -> config file -> defaults

Example:

```yaml
source: app-production

auth:
  url: https://app.trifle.io
  # One organization token can be reused across permitted sources.
  user_token: trf_oat_xxx
  email: user@example.com
  organization_id: org-uuid
  user_id: user-uuid

sources:
  app-production:
    driver: api
    url: https://app.trifle.io
    source_type: project
    # Required for every source-bound API request.
    source_id: project-uuid
    timeout: 30s

  app-warehouse:
    driver: api
    url: https://app.trifle.io
    source_type: database
    # Uses the same auth.user_token with a different request header.
    source_id: database-uuid

  sqlite:
    driver: sqlite
    db: ./stats.db
    table: trifle_stats
    joined: full
    separator: "::"
    timezone: GMT
    week_start: monday
    granularities: [1m, 5m, 1h, 1d]
    buffer_mode: on
    buffer_duration: 2s
    buffer_size: 500
    buffer_aggregate: true
    buffer_async: true

  postgres:
    driver: postgres
    host: 127.0.0.1
    port: "5432"
    user: postgres
    password: password
    database: trifle_stats
    table: trifle_stats
    joined: full
    separator: "::"
    timezone: GMT
    week_start: monday
    granularities: [1m, 5m, 1h, 1d]
    buffer_mode: auto
    buffer_drivers: [postgres, mysql]
    buffer_duration: 2s
    buffer_size: 500
    buffer_aggregate: true
    buffer_async: true

  mysql:
    driver: mysql
    host: 127.0.0.1
    port: "3306"
    user: root
    password: password
    database: trifle_stats
    table: trifle_stats
    joined: full
    separator: "::"
    timezone: GMT
    week_start: monday
    granularities: [1m, 5m, 1h, 1d]

  redis:
    driver: redis
    host: 127.0.0.1
    port: "6379"
    prefix: trifle:metrics
    joined: full
    separator: "::"
    timezone: GMT
    week_start: monday
    granularities: [1m, 5m, 1h, 1d]
    buffer_mode: off

  mongo:
    driver: mongo
    dsn: mongodb://127.0.0.1:27017
    database: trifle_stats
    collection: trifle_stats
    joined: full
    separator: "::"
    timezone: GMT
    week_start: monday
    granularities: [1m, 5m, 1h, 1d]
```

Each named source must set `driver` and the matching settings (`api`, `sqlite`, `postgres`, `mysql`, `redis`, `mongo`). Legacy API profiles with their own `token` remain supported, but new profiles should use the global organization token under `auth.user_token`.

## Driver matrix

| Driver | Required settings | Optional settings |
|--------|-------------------|-------------------|
| `api` | `url`, `source_id`; plus a global token from `auth.user_token` or `TRIFLE_TOKEN` | `timeout`, `source_type`, legacy per-source `token` |
| `sqlite` | `db` | `table`, `joined`, `separator`, `timezone`, `week_start`, `granularities`, `buffer_*` |
| `postgres` | `dsn` or (`host`, `port`, `user`, `password`, `database`) | `table`, `joined`, `separator`, `timezone`, `week_start`, `granularities`, `buffer_*` |
| `mysql` | `dsn` or (`host`, `port`, `user`, `password`, `database`) | `table`, `joined`, `separator`, `timezone`, `week_start`, `granularities`, `buffer_*` |
| `redis` | `dsn` or (`host`, `port`) | `user`, `password`, `database` (DB index), `prefix`, `joined`, `separator`, `timezone`, `week_start`, `granularities`, `buffer_*` |
| `mongo` | `dsn` (or `host`), `database` | `collection`, `joined`, `separator`, `timezone`, `week_start`, `granularities`, `buffer_*` |

## Environment variables

- `TRIFLE_CONFIG` (optional): path to YAML config file.
- `TRIFLE_SOURCE` (optional): source name from the config file.
- `TRIFLE_DRIVER` (optional): `api`, `sqlite`, `postgres`, `mysql`, `redis`, `mongo` (default: `api`).
- `TRIFLE_URL` (api): Base URL for Trifle App (required when using the `api` driver).
- `TRIFLE_TOKEN` (api): global organization API token. The same token can be reused with every source it is permitted to access.
- `TRIFLE_SOURCE_ID` (api): required source UUID sent as `X-Trifle-Source-Id` by source-bound API commands.
- `TRIFLE_USER_TOKEN` (auth/management): organization API token input for `trifle auth` / `trifle source` / `trifle token` commands. It may be the same value as `TRIFLE_TOKEN`.
- `TRIFLE_DB` (sqlite): SQLite database path (or database-name fallback for non-sqlite drivers).
- `TRIFLE_DSN` (postgres/mysql/redis/mongo): full DSN/URI.
- `TRIFLE_HOST` (postgres/mysql/redis/mongo): host.
- `TRIFLE_PORT` (postgres/mysql/redis): port.
- `TRIFLE_USER` (postgres/mysql/redis): username.
- `TRIFLE_PASSWORD` (postgres/mysql/redis): password.
- `TRIFLE_DATABASE` (postgres/mysql/mongo): database name.
- `TRIFLE_TABLE` (sqlite/postgres/mysql): table name (default: `trifle_stats`).
- `TRIFLE_COLLECTION` (mongo): collection name.
- `TRIFLE_PREFIX` (redis): key prefix.
- `TRIFLE_JOINED` (local drivers): `full`, `partial`, `separated`.
- `TRIFLE_SEPARATOR` (local drivers): key separator (default: `::`).
- `TRIFLE_TIMEZONE` (local drivers): timezone (default: `GMT`).
- `TRIFLE_WEEK_START` (local drivers): week start (`monday`..`sunday`).
- `TRIFLE_GRANULARITIES` (local drivers): comma-separated granularities.
- `TRIFLE_BUFFER_MODE` (local drivers): `auto`, `on`, `off`.
- `TRIFLE_BUFFER_DRIVERS` (local drivers): comma-separated allowlist (`postgres,mysql`).
- `TRIFLE_BUFFER_DURATION` (local drivers): flush interval (for example `2s`).
- `TRIFLE_BUFFER_SIZE` (local drivers): queue size.
- `TRIFLE_BUFFER_AGGREGATE` (local drivers): aggregate buffered writes (`true`/`false`).
- `TRIFLE_BUFFER_ASYNC` (local drivers): async flush (`true`/`false`).

## Flags (override env vars and config)

:::signature Common flags
--config | String | optional |  | YAML config path.
--source | String | optional |  | Source name from the config file.
--url | String | optional |  | Trifle base URL (fallback: `TRIFLE_URL`).
--token | String | optional |  | Global organization API token (fallback: `TRIFLE_TOKEN` / `auth.user_token`).
--source-id | String | required for API |  | Source UUID sent as `X-Trifle-Source-Id` (fallback: `TRIFLE_SOURCE_ID` / profile `source_id`).
--user-token | String | optional |  | Organization token used by auth/source/token-management commands (fallback: `TRIFLE_USER_TOKEN` / `auth.user_token`).
--timeout | Duration | optional | `30s` | HTTP timeout.
--driver | String | optional | `api` | Driver: `api`, `sqlite`, `postgres`, `mysql`, `redis`, `mongo`.
--db | String | optional |  | SQLite DB path or database-name fallback.
--dsn | String | optional |  | DSN/URI for postgres/mysql/redis/mongo.
--host | String | optional |  | Driver host.
--port | String | optional |  | Driver port.
--user | String | optional |  | Driver user.
--password | String | optional |  | Driver password.
--database | String | optional |  | Database name.
--table | String | optional | `trifle_stats` | Table name (`sqlite`/`postgres`/`mysql`).
--collection | String | optional |  | Collection name (`mongo`).
--prefix | String | optional |  | Key prefix (`redis`).
--joined | String | optional | `full` | Identifier mode: `full`, `partial`, `separated`.
--separator | String | optional | `::` | Key separator.
--timezone | String | optional | `GMT` | Time zone.
--week-start | String | optional | `monday` | Week start.
--granularities | String | optional |  | Comma-separated granularities.
--buffer-mode | String | optional | `auto` | Buffer mode: `auto`, `on`, `off`.
--buffer-drivers | String | optional |  | Comma-separated driver allowlist for buffering.
--buffer-duration | Duration | optional |  | Buffer flush interval.
--buffer-size | Integer | optional |  | Buffer queue size.
--buffer-aggregate | Bool | optional |  | Aggregate buffered writes.
--buffer-async | Bool | optional |  | Flush buffered writes asynchronously.
:::

:::callout note "SaaS vs self-hosted"
- SaaS: `TRIFLE_URL=https://app.trifle.io`
- Self-hosted: `TRIFLE_URL=https://<your-host>`
:::

:::callout warn "URL scheme matters"
- If you omit the scheme, the CLI assumes `http://`.
- Use `https://` for SaaS and most self-hosted deployments.
:::

:::callout warn "Token scopes"
- Organization tokens are global credentials and can contain grants for multiple sources or wildcard access.
- Every source-bound request still identifies exactly one source with `X-Trifle-Source-Id`.
- Read-only tokens work for all `metrics` read commands and `transponders list`.
- Write tokens are required for `metrics push` and MCP `write_metric`.
:::

:::callout note "Interactive prompt"
- If no token is provided, the CLI prompts on stdin.
- MCP mode skips prompting (token required upfront).
:::
