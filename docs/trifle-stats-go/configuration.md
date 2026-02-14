---
title: Configuration
description: Configure Trifle Stats (Go), drivers, and buffering.
nav_order: 2
---

# Configuration

Trifle Stats for Go uses a `Config` struct. Start with `DefaultConfig()` and override what you need.

```go
cfg := TrifleStats.DefaultConfig()
cfg.Driver = driver
cfg.TimeZone = "UTC"
cfg.BeginningOfWeek = time.Monday
cfg.Granularities = []string{"1m", "1h", "1d"}
cfg.Separator = "::"
cfg.JoinedIdentifier = TrifleStats.JoinedFull

cfg.BufferEnabled = true
cfg.BufferDuration = 1 * time.Second
cfg.BufferSize = 256
cfg.BufferAggregate = true
cfg.BufferAsync = true
```

## Options

- `Driver` (required) — driver instance (`SQLite`, `Postgres`, `MySQL`, `Redis`, `Mongo`).
- `TimeZone` — IANA timezone string (default: `"GMT"`).
- `BeginningOfWeek` — week boundary for `1w` buckets (default: `time.Monday`).
- `Granularities` — list of granularities (default: all standard granularities).
- `Separator` — key separator for joined identifiers (default: `"::"`).
- `JoinedIdentifier` — `JoinedFull`, `JoinedPartial`, or `JoinedSeparated`.
- `BufferEnabled` — enable buffered writes (default: `true`).
- `BufferDuration` — flush interval for async worker (default: `1 * time.Second`).
- `BufferSize` — flush threshold by queued operations (default: `256`).
- `BufferAggregate` — aggregate repeated write operations before flush (default: `true`).
- `BufferAsync` — run background flush ticker (default: `true`).

## Buffer lifecycle

```go
// Flush pending writes immediately.
_ = cfg.FlushBuffer()

// Stop background worker and flush remaining writes.
_ = cfg.ShutdownBuffer()
```

## Driver notes

- **SQLite / Postgres / MySQL / Mongo** support all three identifier modes.
- **Redis** uses joined key mode and prefix+separator key composition.
- `JoinedPartial` and `JoinedSeparated` require `Key.At` to be present for direct driver operations.

## Identifier modes

- **JoinedFull**: a single `key` column including `prefix::key::granularity::unix`.
- **JoinedPartial**: `key` + `at` columns.
- **JoinedSeparated**: `key` + `granularity` + `at` columns.
