---
title: Track values
description: Learn how to increment values.
nav_order: 1
---

# Track values

Tracking values runs `inc` on the driver. Each call increments the counters for the given key and all configured granularities.

## `Track(cfg *Config, key string, at time.Time, values map[string]any, opts ...TrackOption) error`

:::signature Track(cfg *Config, key string, at time.Time, values map[string]any, opts ...TrackOption) error
cfg | *Config | required |  | Configuration with a driver.
key | string | required |  | Metric identifier (e.g. `event::logs`).
at | time.Time | required |  | Timestamp for the sample. It is floored to configured granularities and normalized to `cfg.TimeZone`.
values | map[string]any | required |  | Nested maps are allowed; every leaf must be numeric.
opts | ...TrackOption | optional |  | Supports `TrifleStats.Untracked()` to use `__untracked__` for system tracking.
:::

## Examples

:::tabs
@tab Basic
```go
TrifleStats.Track(cfg, "event::logs", time.Now().UTC(), map[string]any{
  "count": 1,
  "duration": 2,
  "lines": 241,
})
```

Adds a single set of counters.

@tab Repeat increments
```go
TrifleStats.Track(cfg, "event::logs", time.Now().UTC(), map[string]any{"count": 1, "duration": 1})
TrifleStats.Track(cfg, "event::logs", time.Now().UTC(), map[string]any{"count": 1, "duration": 5})
```

Use the same key to keep rollups consistent.

@tab Nested values
```go
TrifleStats.Track(cfg, "event::logs", time.Now().UTC(), map[string]any{
  "count": 1,
  "duration": 30,
  "duration_breakdown": map[string]any{
    "parsing": 21,
    "compression": 8,
    "upload": 1,
  },
  "lines": 25432754,
})
```

Nested maps are supported as long as leaf values are numeric.

@tab Untracked system key
```go
TrifleStats.Track(
  cfg,
  "event::logs",
  time.Now().UTC(),
  map[string]any{"count": 1},
  TrifleStats.Untracked(),
)
```
:::

:::callout warn "Common mistakes"
- Passing non-numeric values in `values` will return an error.
:::

## Verify values

```go
from := time.Now().UTC().Add(-24 * time.Hour)
result, _ := TrifleStats.Values(cfg, "event::logs", from, time.Now().UTC(), "1d", false)
_ = result
```
