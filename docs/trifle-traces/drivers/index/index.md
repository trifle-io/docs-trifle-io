---
title: Index Drivers
description: Learn how index drivers store and search trace metadata.
nav_order: 1
---

# Index Drivers

An index driver stores one metadata entry per trace and answers `find`/`search`. It is the authority for trace references and the backend behind the read API (`Trifle::Traces.find`, `Trifle::Traces.search`).

## Available drivers

- [Postgres](/trifle-traces/drivers/index/postgres) — PostgreSQL JSONB table shared with the Elixir implementation.
- [Mongo](/trifle-traces/drivers/index/mongo) — MongoDB collection with compound search indexes and TTL-based retention.
- [Memory](/trifle-traces/drivers/index/memory) — in-process, for tests and development.
- [Null](/trifle-traces/drivers/index/null) — generates references, persists nothing (the default).

## Feature parity

| Driver | update | delete | search | ttl |
|--------|--------|--------|--------|-----|
| Postgres | YES  | YES    | YES    | cleanup |
| Mongo  | YES    | YES    | YES    | native |
| Memory | YES    | YES    | YES    | none |
| Null   | YES    | YES    | NO     | none |

Every driver declares this via `capabilities`. The dispatcher validates them at liftoff: a `:live` tracer requires `update`; a driver without it can still serve `:deferred` tracers, which only ever `create`.

## What gets stored

Each entry carries the [TraceRecord](/trifle-traces/drivers#tracerecord) fields: `reference`, `key`, `segments`, `tags`, `state`, `meta`, `context` (stored metadata), `duration`, `counters`, `length`, `parts`, `first_at`, `last_at`, `retention`, `expires_at` and `bucket_id`. How they map to the backend (document fields, columns) is each driver's choice.

## The search contract

Search is deliberately narrow so it stays fast at high volume:

- `segment` — exact match against a materialized key-path prefix (`'jobs'` matches `jobs` and `jobs/import/...`).
- `tags` — `{ any: [...], all: [...] }`; any values are ORed, all values are ANDed, and the groups are ANDed together.
- `state` — exact match.
- `from` / `to` — trace start time, inclusive lower bound and exclusive upper bound.
- `duration_min` — inclusive minimum duration in integer milliseconds.
- Results are ordered by `first_at DESC, reference DESC`, paginated with an opaque cursor, with no count query.

All supplied filters are combined. Empty tag groups are ignored. `context`
remains retrievable metadata but is not part of the search contract.

```ruby
Trifle::Traces.search(
  segment: 'jobs/import',
  tags: { any: ['tenant:42', 'tenant:43'], all: ['failed'] },
  state: :error,
  from: Time.utc(2026, 8, 30),
  to: Time.utc(2026, 8, 31),
  duration_min: 5_000,
  limit: 50
)
#=> { traces: [TraceRecord, ...], cursor: "..." }
```

## The contract

An index driver is duck-typed and implements:

- `generate_reference` — returns a `String` reference. Must be I/O-free and time-sortable (lexicographic order equals chronological order); this is what makes `:deferred` mode possible.
- `create(record)` — insert the entry. In `:deferred` mode this is the only index write and `record.state` is already final.
- `update(record)` — persist the mutable fields (`state`, `tags`, `context`, `duration`, `counters`, `length`, `parts`, `last_at`, `expires_at`). Optional; declare via `capabilities`.
- `delete(reference)` — remove the entry (used by `ignore!` in `:live` mode). Optional.
- `find(reference)` — return a `TraceRecord` or `nil`.
- `search(segment:, tags:, state:, from:, to:, duration_min:, limit:, cursor:)` — return `{ traces: [...], cursor: String | nil }`.
- `capabilities` — return `{ update:, delete:, search:, ttl: }` where `ttl` is `:native`, `:cleanup` (driver provides `cleanup!` for cron) or `:none`.
- `self.setup!(...)` — create indexes; run once.

See `lib/trifle/traces/driver/README.md` in the gem for the full contract and run the shared contract specs (`spec/support/index_driver_contract.rb`) against your implementation.
