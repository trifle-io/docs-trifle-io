---
title: Postgres Index
description: Reuse Postgrex or an Ecto Repo for searchable trace metadata.
nav_order: 1
---

# Postgres Index

The Postgres driver accepts either a Postgrex connection or an Ecto Repo that
exports `query!/3`. Reusing your application Repo means Trifle.Traces does not
need a second connection pool:

```elixir
driver = Trifle.Traces.Driver.Index.Postgres.new(MyApp.Repo)

Trifle.Traces.configure(index_driver: driver)
```

Add Postgrex as an optional client dependency if the application does not
already receive it from Ecto SQL:

```elixir
{:postgrex, "~> 0.17"}
```

## Setup

Provision the table and indexes once, rather than on every application boot:

```elixir
Trifle.Traces.Driver.Index.Postgres.setup!(
  MyApp.Repo,
  table_name: "trifle_traces"
)
```

`table_name` defaults to `trifle_traces` and must be a simple PostgreSQL
identifier. The table stores segments, tags, metadata, context, and counters as
JSONB. GIN indexes serve segment and tag containment; B-tree indexes serve
state, start-time, duration, deterministic reference pagination, and expiry.

The schema is identical to the Ruby Postgres driver. Either implementation can
find and search records written by the other.

## Retention

Schedule cleanup with Oban or another scheduler:

```elixir
deleted =
  Trifle.Traces.Driver.Index.Postgres.cleanup!(
    MyApp.Repo,
    before: DateTime.utc_now()
  )
```

It deletes records with `expires_at <= before` and returns the row count.
Payload cleanup remains the responsibility of the data driver.

## Direct Postgrex connections

You may pass a Postgrex connection process instead of a Repo:

```elixir
{:ok, connection} = Postgrex.start_link(database: "my_app", username: "postgres")
driver = Trifle.Traces.Driver.Index.Postgres.new(connection)
```

Capabilities are `%{update: true, delete: true, search: true, ttl: :cleanup}`.
