---
title: Drivers
description: Learn how drivers persist trace metadata and payloads.
nav_order: 5
---

# Drivers

`Trifle::Traces` persists traces through two pluggable drivers, each with its own responsibility:

- **[Index drivers](/trifle-traces/drivers/index)** store one searchable metadata entry per trace — key, segments, tags, state, timestamps, retention — and answer `find`/`search`. This is the small, hot dataset your trace browser queries.
- **[Data drivers](/trifle-traces/drivers/data)** store the trace payload — the actual trace lines, as numbered parts, plus named artifacts. This is the large, append-heavy dataset that is only read when someone opens a single trace.

Configure one of each and the gem handles the whole lifecycle for you — creating the entry, flushing payload parts as the trace runs, finalizing on `wrapup`, and deleting ignored traces. Without configured drivers nothing persists and trace data stays on the tracer for your [callbacks](/trifle-traces/callbacks).

```ruby
Trifle::Traces.configure do |config|
  config.index_driver = Trifle::Traces::Driver::Index::Mongo.new(mongo_client)
  config.data_driver = Trifle::Traces::Driver::Data::S3.new(
    client: s3_client, buckets: %w[traces-a traces-b], gzip: true
  )
end
```

Database and storage clients are always injected — `trifle-traces` has zero runtime dependencies.

## Why two drivers?

Metadata and payload have opposite storage profiles. Metadata is small, queried by many dimensions, and benefits from a database with indexes. Payload is large, written once per flush, read rarely, and benefits from cheap object or file storage. Splitting them lets each live where it is cheapest and fastest — for example Mongo for the index and S3 for the payload.

## Write modes

Every tracer runs in one of two modes:

- `:live` (default) — the index entry is created at liftoff and updated on every bump and wrapup; payload flushes as numbered parts along the way. You see traces while they run.
- `:deferred` — zero I/O until `wrapup`, then exactly one index write and one payload part. Use it for fast, line-heavy, high-volume jobs where per-trace write count matters.

Mode is a per-tracer setting, not global configuration. Set it where the job is defined:

```ruby
class Commodity::PollJob
  include Sidekiq::Job
  sidekiq_options tracer_key: 'commodity/poll', tracer_mode: :deferred
end
```

or pass `mode: :deferred` to the tracer constructor. `config.default_mode` sets the fallback.

## TraceRecord

Drivers exchange `Trifle::Traces::TraceRecord` value objects with these fields: `reference`, `key`, `state`, `tags`, `meta`, `context`, `length`, `parts`, `first_at`, `last_at`, `retention`, `expires_at`, `bucket_id`. `record.segments` derives cumulative key-path prefixes (`"a/b/c"` → `["a", "a/b", "a/b/c"]`) used for prefix search.

## Retention

Retention travels as data on every record — `retention` (days) plus a computed `expires_at`. Each driver maps it to whatever its backend does best: the Mongo index driver relies on a native TTL index, the S3 data driver expires payloads with one bucket lifecycle rule per retention class, the File driver ships a `cleanup!` method for cron.

Resolve retention per trace in configuration:

```ruby
Trifle::Traces.configure do |config|
  config.retention = ->(tracer) { tracer.key.start_with?('commodity/') ? 3 : 180 }
end
```

## Error handling

Persistence failures are never swallowed:

- `liftoff` and `wrapup` failures raise by default.
- `bump` failures re-queue the drained entries; the next flush retries them, so a transient storage error degrades into fewer, larger parts instead of losing data.

Override `config.error_handler` (receives `error, tracer, phase`) to report to your error tracker instead.

## Next steps

- [Index drivers](/trifle-traces/drivers/index) — contract, capabilities, and available implementations.
- [Data drivers](/trifle-traces/drivers/data) — contract, storage layout, and available implementations.
