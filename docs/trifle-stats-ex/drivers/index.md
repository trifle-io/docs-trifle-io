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

## Packer

Some drivers use dot-notation for nested maps. `Trifle.Stats.Packer` can pack/unpack nested values:

```elixir
iex> values = %{ a: 1, b: %{ c: 22, d: 33 } }
iex> packed = Trifle.Stats.Packer.pack(values)
%{"a" => 1, "b.c" => 22, "b.d" => 33}

iex> Trifle.Stats.Packer.unpack(packed)
%{"a" => 1, "b" => %{"c" => 22, "d" => 33}}
```
