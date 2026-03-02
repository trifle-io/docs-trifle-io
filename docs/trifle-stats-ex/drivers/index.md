---
title: Drivers
description: Learn how drivers persist and retrieve values.
nav_order: 5
---

# Drivers

A driver persists and retrieves values. It must implement:

- `inc(keys, values)` — increment
- `set(keys, values)` — set
- `get(keys)` — fetch
- `ping(key, values)` — status ping (for `beam`)
- `scan(key)` — status lookup (for `scan`)

## Available drivers

- [Mongo](/trifle-stats-ex/drivers/mongo)
- [MySQL](/trifle-stats-ex/drivers/mysql)
- PostgreSQL (`Trifle.Stats.Driver.Postgres`)
- Redis (`Trifle.Stats.Driver.Redis`)
- SQLite (`Trifle.Stats.Driver.Sqlite`)
- Process (`Trifle.Stats.Driver.Process`)

## Timestamp Compatibility

Timestamp format matters for `:partial` and separated (`nil`) identifier modes, and for `ping`/`scan` data.

| Backend | Timestamp storage | Driver write format | Cross-driver compatibility |
|---------|-------------------|---------------------|----------------------------|
| SQLite | `TEXT` | RFC3339 UTC (`2026-02-25T00:00:00Z`) | Compatible across Elixir, Ruby, and Go SQLite drivers when values are RFC3339 UTC. Legacy SQLite rows stored as `YYYY-MM-DD HH:MM:SS` are not matched/read by strict RFC3339 drivers. |
| PostgreSQL | `TIMESTAMPTZ` | Native DB timestamp with timezone | Compatible across Elixir, Ruby, and Go Postgres drivers. |
| MySQL | `DATETIME(6)` | Native DB datetime (normalized to UTC by drivers) | Compatible across Elixir, Ruby, and Go MySQL drivers. |
| MongoDB | BSON DateTime | Native DB datetime | Compatible across Elixir, Ruby, and Go Mongo drivers. |
| Redis / Process | No dedicated `at` column in joined mode | `at` is part of joined key payload for full-joined mode | Keep joined mode + separator aligned when sharing data patterns across apps. |

## Cross-Driver Rules

- Keep identifier mode aligned across services (`:full`, `:partial`, or `nil`).
- Keep separator aligned for joined identifiers (default: `::`).
- In full-joined mode, `at` is encoded as unix seconds in the joined key segment; keep key construction consistent across clients.
- For SQLite `at` fields, use RFC3339 UTC.
- If migrating legacy SQLite text timestamps (`YYYY-MM-DD HH:MM:SS`), rewrite to RFC3339 UTC before cross-language reuse.

## Packer

Some drivers use dot-notation for nested maps. `Trifle.Stats.Packer` can pack/unpack nested values:

```elixir
iex> values = %{ a: 1, b: %{ c: 22, d: 33 } }
iex> packed = Trifle.Stats.Packer.pack(values)
%{"a" => 1, "b.c" => 22, "b.d" => 33}

iex> Trifle.Stats.Packer.unpack(packed)
%{"a" => 1, "b" => %{"c" => 22, "d" => 33}}
```
