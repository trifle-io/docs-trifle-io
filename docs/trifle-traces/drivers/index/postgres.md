---
title: Postgres
description: Store searchable trace metadata in a PostgreSQL JSONB table.
nav_order: 1
---

# Postgres (index driver)

The Postgres index driver stores one trace per row. Its schema is shared with
Trifle.Traces for Elixir, so both implementations can search and update the
same records.

The `pg` client is injected and is not a runtime dependency of the gem:

```ruby
require 'pg'

client = PG.connect(ENV.fetch('DATABASE_URL'))

Trifle::Traces.configure do |config|
  config.index_driver = Trifle::Traces::Driver::Index::Postgres.new(
    client,
    table_name: 'trifle_traces'
  )
end
```

`table_name` defaults to `trifle_traces` and must be a simple PostgreSQL
identifier.

## Setup

Provision the table and indexes once:

```ruby
Trifle::Traces::Driver::Index::Postgres.setup!(
  client,
  table_name: 'trifle_traces'
)
```

The table uses JSONB for materialized key segments, tags, metadata, context,
and counters; `TIMESTAMPTZ` for trace and expiry times; and integer columns for
duration, payload length, parts, retention, and bucket selection. Setup creates
GIN indexes for segments and tags plus B-tree indexes for state, start time,
duration, and expiry.

## Retention

PostgreSQL has no per-row TTL, so schedule explicit cleanup:

```ruby
deleted = Trifle::Traces.default.index_driver.cleanup!(before: Time.now)
```

`cleanup!` deletes rows with `expires_at <= before` and returns the number of
deleted rows. Payload retention remains the responsibility of the configured
data driver.

## Search and capabilities

Segments and tag groups use indexed JSONB containment. Other filters use exact
state, the inclusive/exclusive `first_at` range, and inclusive minimum
duration. Results sort by `first_at DESC, reference DESC`, including the same
opaque deterministic cursor behavior as the other index drivers.

Capabilities are `{ update: true, delete: true, search: true, ttl: :cleanup }`,
so the driver supports both live and deferred tracing.
