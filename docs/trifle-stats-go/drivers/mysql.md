---
title: MySQL Driver
description: MySQL driver for Trifle Stats (Go).
nav_order: 3
---

# MySQL Driver

The MySQL driver stores packed metric payloads in a native `JSON` column and supports all identifier modes.

## Setup

```go
import (
  "database/sql"

  _ "github.com/go-sql-driver/mysql"
  TrifleStats "github.com/trifle-io/trifle_stats_go"
)

db, _ := sql.Open("mysql", "root:password@tcp(127.0.0.1:3306)/trifle_stats?parseTime=true&loc=UTC")
driver := TrifleStats.NewMySQLDriver(db, "trifle_stats", TrifleStats.JoinedSeparated)
_ = driver.Setup()
```

## Options

- `tableName` — table name (default: `"trifle_stats"`).
- `JoinedFull`, `JoinedPartial`, `JoinedSeparated` — identifier mode.
- `Separator` — key separator for joined modes (default: `"::"`).
- `SystemTracking` — when true, writes are mirrored to `__system__key__`.

## Notes

- MySQL uses `JSON` (not `JSONB`).
- `inc` and `set` are atomic `ON DUPLICATE KEY UPDATE` writes with JSON functions.
- `JoinedPartial` and `JoinedSeparated` require `Key.At`.
