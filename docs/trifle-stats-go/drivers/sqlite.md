---
title: SQLite Driver
description: SQLite driver for Trifle Stats (Go).
nav_order: 1
---

# SQLite Driver

The SQLite driver stores metrics in a single table and updates JSON payloads using SQLite JSON1 functions.

## Setup

```go
import (
  "database/sql"
  _ "modernc.org/sqlite"
  TrifleStats "github.com/trifle-io/trifle_stats_go"
)

db, _ := sql.Open("sqlite", "file:stats.db?cache=shared&mode=rwc")
driver := TrifleStats.NewSQLiteDriver(db, "trifle_stats", TrifleStats.JoinedFull)
_ = driver.Setup()
```

## Options

- `tableName` — table name (default: `"trifle_stats"`).
- `JoinedFull`, `JoinedPartial`, `JoinedSeparated` — identifier mode.
- `Separator` — key separator for joined identifiers (default: `"::"`).
- `SystemTracking` — when true, writes are mirrored to `__system__key__` for per-key counts.

```go
driver := TrifleStats.NewSQLiteDriver(db, "trifle_stats", TrifleStats.JoinedSeparated)
driver.SystemTracking = true
```

## Identifier modes

- **JoinedFull**: `key` column stores `prefix::key::granularity::unix`.
- **JoinedPartial**: `key` and `at` columns.
- **JoinedSeparated**: `key`, `granularity`, `at` columns.
