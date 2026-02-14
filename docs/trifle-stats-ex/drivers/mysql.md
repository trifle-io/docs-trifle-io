---
title: MySQL
description: Learn how to use the MySQL driver.
nav_order: 7
---

# MySQL Driver

The MySQL driver stores metrics in a native `JSON` column and supports joined or separated identifier modes.

## Setup

```elixir
{:ok, conn} =
  MyXQL.start_link(
    hostname: "localhost",
    username: "root",
    password: "password",
    database: "trifle_stats"
  )

# Create tables
Trifle.Stats.Driver.Mysql.setup!(conn)

# Build driver
driver = Trifle.Stats.Driver.Mysql.new(conn)
```

## Options

- `table_name` (default: `"trifle_stats"`)
- `ping_table_name` (default: `"trifle_stats_ping"`)
- `joined_identifier` (`:full`, `:partial`, or `nil`)
- `system_tracking` (default: `true`)

## Notes

- MySQL uses `JSON` (not `JSONB`).
- `inc` and `set` are atomic `INSERT ... ON DUPLICATE KEY UPDATE` operations.
- Separated mode (`joined_identifier: nil`) enables `ping`/`scan` storage in the ping table.
