---
title: Mongo Index
description: Configure searchable trace metadata in MongoDB.
nav_order: 2
---

# Mongo Index

```elixir
{:ok, mongo} = Mongo.start_link(url: "mongodb://localhost:27017/trifle")
driver = Trifle.Traces.Driver.Index.Mongo.new(mongo)

Trifle.Traces.Driver.Index.Mongo.setup!(mongo)
```

`setup!/2` creates compound indexes for segments, tags, state, start time,
duration, and a native TTL index on `expires_at`. Run it during provisioning,
not per application boot.

Mongo uses BSON ObjectIds as references and stores the same document shape as
the Ruby driver.

## Search

```elixir
Trifle.Traces.search(
  segment: "jobs/import",
  tags: %{any: ["tenant:1", "tenant:2"], all: ["billing"]},
  state: :error,
  from: ~U[2026-08-01 00:00:00Z],
  to: ~U[2026-09-01 00:00:00Z],
  duration_min: 5_000,
  limit: 50,
  cursor: nil
)
```

All filters combine. Time is `first_at >= from` and `first_at < to`; minimum
duration is inclusive. Results sort by start time and reference descending.
