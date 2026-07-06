---
title: Index Drivers
description: Learn how index drivers store and search trace metadata.
nav_order: 1
---

# Index Drivers

An index driver stores one metadata entry per trace and answers `find`/`search`. It is the authority for trace references and the backend behind the read API (`Trifle::Traces.find`, `Trifle::Traces.search`).

## Available drivers

- [Mongo](/trifle-traces/drivers/index/mongo) — MongoDB collection with compound search indexes and TTL-based retention.
- [Memory](/trifle-traces/drivers/index/memory) — in-process, for tests and development.
- [Null](/trifle-traces/drivers/index/null) — generates references, persists nothing (the default).

## Feature parity

| Driver | update | delete | search | ttl |
|--------|--------|--------|--------|-----|
| Mongo  | YES    | YES    | YES    | native |
| Memory | YES    | YES    | YES    | none |
| Null   | YES    | YES    | NO     | none |

Every driver declares this via `capabilities`. The dispatcher validates them at liftoff: a `:live` tracer requires `update`; a driver without it can still serve `:deferred` tracers, which only ever `create`.

## What gets stored

Each entry carries the [TraceRecord](/trifle-traces/drivers#tracerecord) fields: `reference`, `key`, `segments`, `tags`, `state`, `meta`, `context` (your extracted fields), `length`, `parts`, `first_at`, `last_at`, `retention`, `expires_at` and `bucket_id`. How they map to the backend (document fields, columns) is each driver's choice.

## The search contract

Search is deliberately narrow so it stays fast at high volume:

- `segment` — key-path prefix match (`'jobs'` matches `jobs` and `jobs/import/...`), any-match over a small array.
- `tags` — any-match.
- `state` — exact match.
- Results are newest-first only, paginated with an opaque `cursor`, no counts.

```ruby
Trifle::Traces.search(segment: 'jobs/import', tags: ['tenant:42'], state: :error, limit: 50)
#=> { traces: [TraceRecord, ...], cursor: "..." }
```

## The contract

An index driver is duck-typed and implements:

- `generate_reference` — returns a `String` reference. Must be I/O-free and time-sortable (lexicographic order equals chronological order); this is what makes `:deferred` mode possible.
- `create(record)` — insert the entry. In `:deferred` mode this is the only index write and `record.state` is already final.
- `update(record)` — persist the mutable fields (`state`, `tags`, `context`, `length`, `parts`, `last_at`, `expires_at`). Optional; declare via `capabilities`.
- `delete(reference)` — remove the entry (used by `ignore!` in `:live` mode). Optional.
- `find(reference)` — return a `TraceRecord` or `nil`.
- `search(segment:, tags:, state:, limit:, cursor:)` — return `{ traces: [...], cursor: String | nil }`.
- `capabilities` — return `{ update:, delete:, search:, ttl: }` where `ttl` is `:native`, `:cleanup` (driver provides `cleanup!` for cron) or `:none`.
- `self.setup!(...)` — create indexes; run once.

See `lib/trifle/traces/driver/README.md` in the gem for the full contract and run the shared contract specs (`spec/support/index_driver_contract.rb`) against your implementation.
