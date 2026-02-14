---
title: MongoDB Driver
description: MongoDB driver for Trifle Stats (Go).
nav_order: 5
---

# MongoDB Driver

The MongoDB driver stores values under a `data` field and updates paths with `$inc`/`$set`.

## Setup

```go
import (
  "context"
  "time"

  "go.mongodb.org/mongo-driver/mongo"
  "go.mongodb.org/mongo-driver/mongo/options"
  TrifleStats "github.com/trifle-io/trifle_stats_go"
)

client, _ := mongo.Connect(context.Background(), options.Client().ApplyURI("mongodb://localhost:27017"))
collection := client.Database("metrics").Collection("trifle_stats")

driver := TrifleStats.NewMongoDriver(collection, TrifleStats.JoinedSeparated)
driver.BulkWrite = true
driver.ExpireAfter = 24 * time.Hour
_ = driver.Setup(context.Background())
```

## Options

- `JoinedFull`, `JoinedPartial`, `JoinedSeparated` — identifier mode.
- `Separator` — key separator for joined modes (default: `"::"`).
- `SystemTracking` — when true, writes are mirrored to `__system__key__`.
- `BulkWrite` — batch write operations into a single Mongo write call.
- `ExpireAfter` — optional TTL duration. When set, `expire_at` is written and TTL index is created.

## Identifier modes

- **JoinedFull**: `key`.
- **JoinedPartial**: `key` + `at`.
- **JoinedSeparated**: `key` + `granularity` + `at`.
