---
title: Drivers
nav_order: 5
---

# Drivers

Trifle Stats (Go) ships with the following drivers:

- [SQLite](/trifle-stats-go/drivers/sqlite)
- [PostgreSQL](/trifle-stats-go/drivers/postgres)
- [MySQL](/trifle-stats-go/drivers/mysql)
- [Redis](/trifle-stats-go/drivers/redis)
- [MongoDB](/trifle-stats-go/drivers/mongo)

## Identifier mode support

| Driver | JoinedFull | JoinedPartial | JoinedSeparated |
|--------|------------|---------------|-----------------|
| SQLite | Yes | Yes | Yes |
| PostgreSQL | Yes | Yes | Yes |
| MySQL | Yes | Yes | Yes |
| Redis | Yes | No | No |
| MongoDB | Yes | Yes | Yes |

## Timestamp Compatibility

Timestamp format matters for `JoinedPartial` and `JoinedSeparated` modes, and for `Ping`/`Scan` data.

| Backend | Timestamp storage | Driver write format | Cross-driver compatibility |
|---------|-------------------|---------------------|----------------------------|
| SQLite | `TEXT` | RFC3339 UTC (`2026-02-25T00:00:00Z`) | Compatible across Go, Ruby, and Elixir SQLite drivers when values are RFC3339 UTC. Legacy SQLite rows stored as `YYYY-MM-DD HH:MM:SS` are not matched/read by strict RFC3339 drivers. |
| PostgreSQL | `TIMESTAMPTZ` | Native DB timestamp with timezone | Compatible across Go, Ruby, and Elixir Postgres drivers. |
| MySQL | `DATETIME(6)` | Native DB datetime (normalized to UTC by drivers) | Compatible across Go, Ruby, and Elixir MySQL drivers. |
| MongoDB | BSON DateTime | Native DB datetime | Compatible across Go, Ruby, and Elixir Mongo drivers. |
| Redis | No dedicated `at` column in full-joined mode | `at` is embedded in joined key payload | Keep joined mode + separator aligned when sharing data patterns across apps. |

## Cross-Driver Rules

- Keep identifier mode aligned across services (`JoinedFull`, `JoinedPartial`, `JoinedSeparated`).
- Keep separator aligned for joined identifiers (default: `::`).
- In `JoinedFull`, `at` is encoded as unix seconds in the joined key segment; keep key construction consistent across clients.
- For SQLite `at` fields, use RFC3339 UTC.
- If migrating legacy SQLite text timestamps (`YYYY-MM-DD HH:MM:SS`), rewrite to RFC3339 UTC before cross-language reuse.
