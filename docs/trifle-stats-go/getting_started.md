---
title: Getting Started
description: Track and fetch metrics with Trifle Stats (Go).
nav_order: 3
---

# Getting Started

## 1. Setup a driver

This example uses SQLite, but you can swap in Postgres, MySQL, Redis, or MongoDB.

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

## 2. Configure Trifle Stats

```go
cfg := TrifleStats.DefaultConfig()
cfg.Driver = driver
cfg.TimeZone = "UTC"
cfg.Granularities = []string{"1h", "1d"}
cfg.BufferEnabled = false // disable buffering for immediate writes in small demos
```

## 3. Track and read values

```go
TrifleStats.Track(cfg, "event::signup", time.Now().UTC(), map[string]any{"count": 1})

from := time.Now().UTC().Add(-24 * time.Hour)
series, _ := TrifleStats.Values(cfg, "event::signup", from, time.Now().UTC(), "1h", false)
```
