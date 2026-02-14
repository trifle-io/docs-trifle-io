---
title: PostgreSQL Driver
description: PostgreSQL driver for Trifle Stats (Go).
nav_order: 2
---

# PostgreSQL Driver

The PostgreSQL driver stores packed metric payloads in a JSONB column and supports all identifier modes.

## Setup

```go
import (
  "database/sql"

  _ "github.com/jackc/pgx/v5/stdlib"
  TrifleStats "github.com/trifle-io/trifle_stats_go"
)

db, _ := sql.Open("pgx", "postgres://postgres:password@localhost:5432/postgres?sslmode=disable")
driver := TrifleStats.NewPostgresDriver(db, "trifle_stats", TrifleStats.JoinedSeparated)
_ = driver.Setup()
```

## Options

- `tableName` — table name (default: `"trifle_stats"`).
- `JoinedFull`, `JoinedPartial`, `JoinedSeparated` — identifier mode.
- `Separator` — key separator for joined modes (default: `"::"`).
- `SystemTracking` — when true, writes are mirrored to `__system__key__`.

## Identifier modes

- **JoinedFull**: `key` (single primary key).
- **JoinedPartial**: `key` + `at` (composite primary key).
- **JoinedSeparated**: `key` + `granularity` + `at` (composite primary key).
