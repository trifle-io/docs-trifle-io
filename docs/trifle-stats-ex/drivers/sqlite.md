---
title: SQLite
description: Learn how to use the SQLite driver.
nav_order: 6
---

# SQLite Driver

The SQLite driver stores metrics in a local SQLite database using JSON1.

## Setup

```elixir
{:ok, conn} = Exqlite.Sqlite3.open("trifle_stats.sqlite")

# Create tables
Trifle.Stats.Driver.Sqlite.setup!(conn)

# Build driver
driver = Trifle.Stats.Driver.Sqlite.new(conn)
```

## Options

- `table_name` (default: "trifle_stats")
- `ping_table_name` (default: "trifle_stats_ping")
- `joined_identifier` (`:full`, `:partial`, or `nil`)
- `system_tracking` (default: true)

## Timestamp format

For `joined_identifier: :partial` and separated mode (`joined_identifier: nil`), SQLite stores `at` as RFC3339 UTC text.

- Example stored value: `2026-02-25T00:00:00Z`
- This keeps SQLite compatible across Elixir, Ruby, and Go drivers.
- Legacy SQLite rows stored as `YYYY-MM-DD HH:MM:SS` should be migrated to RFC3339 UTC before cross-driver reuse.

## Example usage

```elixir
config = Trifle.Stats.Configuration.configure(driver)
Trifle.Stats.track("event::logs", DateTime.utc_now(), %{count: 1}, config)
```
