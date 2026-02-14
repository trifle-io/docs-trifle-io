---
title: Assert values
description: Learn how to set values directly.
nav_order: 2
---

# Assert values

Asserting values runs `set` on the driver. Use it for gauges or values you want to overwrite at a timestamp and across configured granularities.

If buffering is enabled (`cfg.BufferEnabled = true`), writes may be delayed until buffer flush conditions are met.

## `Assert(cfg *Config, key string, at time.Time, values map[string]any, opts ...TrackOption) error`

:::signature Assert(cfg *Config, key string, at time.Time, values map[string]any, opts ...TrackOption) error
cfg | *Config | required |  | Configuration with a driver.
key | string | required |  | Metric identifier (e.g. `event::logs`).
at | time.Time | required |  | Timestamp for the sample. It is floored to configured granularities and normalized to `cfg.TimeZone`.
values | map[string]any | required |  | Nested maps are allowed; every leaf must be numeric.
opts | ...TrackOption | optional |  | Supports `TrifleStats.Untracked()` to use `__untracked__` for system tracking.
:::

## Examples

:::tabs
@tab Gauge
```go
TrifleStats.Assert(cfg, "server::load", time.Now().UTC(), map[string]any{
  "load": 0.42,
  "memory": 0.71,
})
```

Use for measurements that should replace prior values.

@tab Overwrite
```go
at := time.Now().UTC()
TrifleStats.Assert(cfg, "cache::hit", at, map[string]any{"ratio": 0.82})
TrifleStats.Assert(cfg, "cache::hit", at, map[string]any{"ratio": 0.87})
```

The later call wins for the same bucket.
:::

Use `TrifleStats.Untracked()` to group system tracking under `__untracked__`.
