---
title: Drivers
description: Persist searchable metadata separately from trace payloads.
nav_order: 6
---

# Drivers

Trifle.Traces separates storage into two contracts:

- An **index driver** stores one searchable `TraceRecord` per trace.
- A **data driver** stores numbered payload parts and named artifacts.

```elixir
Trifle.Traces.configure(
  index_driver: Trifle.Traces.Driver.Index.Postgres.new(MyApp.Repo),
  data_driver: Trifle.Traces.Driver.Data.S3.new(
    buckets: ["traces-a", "traces-b"],
    gzip: true
  )
)
```

Available index drivers are Postgres, Mongo, Memory, and Null. Available data
drivers are S3, File, Memory, and Null.

## Write modes

In `:live` mode, liftoff creates the initial index entry and payload part.
Eligible bumps append numbered parts and update metadata. This makes running
traces visible.

In `:deferred` mode, no storage I/O occurs before wrapup. The dispatcher then
writes one payload part and one final index record.

## Failure behavior

- Liftoff and wrapup failures surface to the caller by default.
- A bump failure keeps unflushed entries in memory and retries on the next
  eligible operation.
- Counters advance only after the payload part succeeds, preventing duplicate
  counts on retry.
- Ignored trace deletion is best-effort for payload data after the index entry
  is removed.

## Custom drivers

Implement `Trifle.Traces.Driver.Index` or `Trifle.Traces.Driver.Data` and pass a
driver struct in configuration. Keep search semantics identical across index
backends rather than adding backend-specific filters.

- [Postgres index](/trifle-traces-ex/drivers/postgres)
- [Mongo index](/trifle-traces-ex/drivers/mongo)
- [File and S3 data](/trifle-traces-ex/drivers/data)
