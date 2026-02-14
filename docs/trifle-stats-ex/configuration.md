---
title: Configuration
description: Learn how to configure Trifle.Stats for your Elixir application.
nav_order: 2
---

# Configuration

You can configure Trifle.Stats globally or pass a configuration struct into each call.

## Global configuration

`Trifle.Stats.configure/1` sets a global configuration using application env.

```elixir
{:ok, pid} = Trifle.Stats.Driver.Process.start_link()
driver = Trifle.Stats.Driver.Process.new(pid)

Trifle.Stats.configure(
  driver: driver,
  time_zone: "UTC",
  track_granularities: ["1h", "1d"],
  beginning_of_week: :monday
)
```

## Local configuration

Create a configuration explicitly and pass it into `track`, `values`, etc.

```elixir
{:ok, pid} = Trifle.Stats.Driver.Process.start_link()
driver = Trifle.Stats.Driver.Process.new(pid)

config = Trifle.Stats.Configuration.configure(
  driver,
  time_zone: "Europe/London",
  track_granularities: ["1h", "1d"],
  separator: "::"
)

Trifle.Stats.track("event::uploads", DateTime.utc_now(), %{count: 1}, config)
```

## Key options

- `driver` (required) — driver instance (`Trifle.Stats.Driver.Mongo.new/…`, etc.)
- `time_zone` — TZ string (default: `"GMT"`)
- `time_zone_database` — time zone database module (default: `Tzdata.TimeZoneDatabase`)
- `beginning_of_week` — `:monday` or `:sunday` (default: `:monday`)
- `track_granularities` — list like `["1m", "1h", "1d", "1w"]` (default: all)
- `separator` — key separator for joined identifiers (default: `"::"`)
- `designator` — designator struct for `assort/4` bucketing
- `driver_options` — driver-specific options (see below)
- `buffer_enabled` / `buffer_duration` / `buffer_size` — buffered write controls

## Driver options

You can pass a map of `driver_options:` to override driver-specific behavior:

### MongoDB
- `collection_name` (default: `"trifle_stats"`)
- `joined_identifier` (`:full`, `:partial`, or `nil`)
- `expire_after` (TTL in seconds)

### PostgreSQL
- `table_name` (default: `"trifle_stats"`)
- `ping_table_name` (default: `"trifle_stats_ping"`)
- `joined_identifier` (`:full`, `:partial`, or `nil`)

### MySQL
- `table_name` (default: `"trifle_stats"`)
- `ping_table_name` (default: `"trifle_stats_ping"`)
- `joined_identifier` (`:full`, `:partial`, or `nil`)
- `system_tracking` (default: `true`)

### Redis
- `prefix` (default: `"trfl"`)

### SQLite
- `table_name` / `ping_table_name`
- `joined_identifier`

## Compatibility note

Older code can still use the 6-argument `configure/6` helper:

```elixir
config = Trifle.Stats.Configuration.configure(
  driver,
  "Europe/Bratislava",
  Tzdata.TimeZoneDatabase,
  :monday,
  ["1h", "1d"],
  "::"
)
```
