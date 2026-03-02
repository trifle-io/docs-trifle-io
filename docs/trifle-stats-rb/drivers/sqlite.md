---
title: Sqlite
description: Learn in depth about Sqlite driver implementation.
nav_order: 4
---

# Sqlite

Sqlite driver uses `sqlite3` client gem to talk to database. It uses `INSERT` with `ON CONFLICT` resolution and regular `SELECT` to interact with database.

## Configuration

You can configure driver directly using `sqlite3` gem.

```ruby
require 'sqlite3'

Trifle::Stats.configure do |config|
  config.driver = Trifle::Stats::Driver::Sqlite.new(
    SQLite3::Database.new('stats.db')
  )
end
```

## Setup

Sqlite driver requires `trifle_stats` table to be present. You can override `table_name` when creating an instance of a driver.

You can create table and index on your own, but there is a `setup!` class method that does this for you. It creates a table and adds an unique index on a `key` column.

Below is a setup and configuration for a custom database and a table name.

```ruby
Trifle::Stats::Driver::Sqlite.setup!(
  SQLite3::Database.new('my_custom.db'), table_name: 'my_stats'
)

Trifle::Stats.configure do |config|
  config.driver = Trifle::Stats::Driver::Sqlite.new(
    SQLite3::Database.new('my_custom.db'), table_name: 'my_stats'
  )
end
```

## Timestamp Format

For `joined_identifier: :partial` and separated mode (`joined_identifier: nil`), SQLite stores `at` as RFC3339 UTC text.

- Example stored value: `2026-02-25T00:00:00Z`
- This keeps SQLite compatible across Ruby, Elixir, and Go drivers.
- Legacy SQLite rows stored as `YYYY-MM-DD HH:MM:SS` should be migrated to RFC3339 UTC before cross-driver reuse.

## Driver

Driver defaults to `stats.db`, but you can provide custom database name above.

```ruby
irb(main):001:0> client = SQLite3::Database.new('stats.db')
=> #<SQLite3::Database:0x00005595920d6678 @tracefunc=nil, @authorizer=nil, @encoding=nil, @busy_handler=nil, @collations={}, @functions={}, @results_as_hash=ni...
irb(main):002:0> driver = Trifle::Stats::Driver::Sqlite.new(client)
=> #<Trifle::Stats::Driver::Sqlite:0x0000559591d260c8 @client=#<SQLite3::Database:0x00005595920d6678 @tracefunc=nil, @authorizer=nil, @encoding=nil, @busy_hand...
```

## Interaction

Once you create an instance of a driver, you can use it to `set`, `inc` or `get` your data.

```ruby
irb(main):003:0> driver.get(keys: [['test', 'now']])
=> [{}]

irb(main):004:0> driver.inc(keys: [['test', 'now']], count: 1, success: 1, error: 0)
=> true
irb(main):005:0> driver.get(keys: [['test', 'now']])
=> [{"count"=>1, "success"=>1, "error"=>0}]

irb(main):006:0> driver.inc(keys: [['test', 'now']], count: 1, success: 0, error: 1, account: { count: 1 })
=> true
irb(main):007:0> driver.get(keys: [['test', 'now']])
=> [{"count"=>2, "success"=>1, "error"=>1, "account"=>{"count"=>1}}]
```

## Performance

`inc` and `set` operations are executed for each key/pair value in a single query. Queries for each key in `key` is executed in a single transaction. It also queries data in a single query for each key in `keys`.
