---
title: Redis Driver
description: Redis driver for Trifle Stats (Go).
nav_order: 4
---

# Redis Driver

The Redis driver stores packed metric payloads in Redis hashes and uses `HINCRBY`/`HSET`.

## Setup

```go
import (
  "github.com/redis/go-redis/v9"
  TrifleStats "github.com/trifle-io/trifle_stats_go"
)

client := redis.NewClient(&redis.Options{Addr: "localhost:6379"})
driver := TrifleStats.NewRedisDriver(client, "trfl")
```

## Options

- `prefix` — key prefix (default: `"trfl"`).
- `Separator` — key separator (default: `"::"`).
- `SystemTracking` — when true, writes are mirrored to `__system__key__`.

Redis uses joined key mode only. `JoinedPartial` and `JoinedSeparated` are not applicable to Redis key layout.
