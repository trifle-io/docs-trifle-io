---
title: MySQL
description: Learn in depth about MySQL driver implementation.
nav_order: 5
---

# MySQL

MySQL driver uses `mysql2` client gem and stores metrics in a native `JSON` column.  
It performs atomic `INSERT ... ON DUPLICATE KEY UPDATE` writes with `JSON_SET` / `JSON_EXTRACT` for high-write workloads.

## Configuration

```ruby
require 'mysql2'

Trifle::Stats.configure do |config|
  config.driver = Trifle::Stats::Driver::Mysql.new(
    Mysql2::Client.new(
      host: 'localhost',
      port: 3306,
      username: 'root',
      password: 'password',
      database: 'trifle_stats'
    )
  )
end
```

## Setup

Use `setup!` to create required schema for your identifier mode.

```ruby
client = Mysql2::Client.new(
  host: 'localhost',
  username: 'root',
  password: 'password',
  database: 'trifle_stats'
)

Trifle::Stats::Driver::Mysql.setup!(
  client,
  table_name: 'trifle_stats',
  joined_identifier: :full # :full, :partial, or nil (separated)
)
```

For separated mode (`joined_identifier: nil`) an additional ping table is created for `beam` / `scan`.

## Options

- `table_name` (default: `"trifle_stats"`)
- `ping_table_name` (default: `"#{table_name}_ping"`)
- `joined_identifier` (`:full`, `:partial`, or `nil`)
- `system_tracking` (default: `true`)

## Notes

- MySQL uses `JSON` (not `JSONB`).
- Nested values are packed to dot-notation keys (same as other SQL drivers).
- `inc` updates are atomic and operate directly in SQL without read-modify-write in Ruby.
