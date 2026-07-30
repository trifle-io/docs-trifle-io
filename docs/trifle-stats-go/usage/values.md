---
title: Get values
description: Learn how to retrieve values.
nav_order: 3
---

# Get values

Getting values runs `get` on the driver and returns a time-bucketed series.

The inclusive read axis is generated with the same [Nocturnal bucketing rules](/trifle-stats-go/nocturnal) used when values are written.

:::callout note "Use Series"
If you want aggregators, formatters, or transponders, wrap the result with `SeriesFromResult`.
:::

:::callout note "Granularity"
`granularity` must be valid (e.g. `1h`) and should be included in your configured granularities.
:::

## `Values(cfg *Config, key string, from, to time.Time, granularity string, skipBlanks bool) (ValuesResult, error)`

:::signature Values(cfg *Config, key string, from, to time.Time, granularity string, skipBlanks bool) (ValuesResult, error)
cfg | *Config | required |  | Configuration with a driver.
key | string | required |  | Metric identifier.
from | time.Time | required |  | Start of the time range.
to | time.Time | required |  | End of the time range.
granularity | string | required |  | Bucket size (e.g. `1h`, `1d`).
skipBlanks | bool | optional | `false` | When true, omit empty buckets from the response.
:::

`ValuesResult` contains two parallel slices:

```go
type ValuesResult struct {
  At     []time.Time
  Values []map[string]any
}
```

## Examples

:::tabs
@tab Today values
```go
from := time.Now().UTC().Add(-24 * time.Hour)
result, _ := TrifleStats.Values(cfg, "event::logs", from, time.Now().UTC(), "1d", false)
_ = result
```

@tab Last 30 days
```go
from := time.Now().UTC().Add(-30 * 24 * time.Hour)
result, _ := TrifleStats.Values(cfg, "event::logs", from, time.Now().UTC(), "1d", false)
_ = result
```
:::

Example shape:

```json
{
  "at": ["2026-01-24T00:00:00Z"],
  "values": [
    { "count": 3, "duration": 8, "lines": 658 }
  ]
}
```

## Skip blanks

When `skipBlanks` is `true`, the driver omits empty buckets. This is useful for sparse data or when rendering charts with fewer points.

:::tabs
@tab With blanks
```go
result, _ := TrifleStats.Values(cfg, "event::logs", from, to, "1h", false)
```

@tab Without blanks
```go
result, _ := TrifleStats.Values(cfg, "event::logs", from, to, "1h", true)
```
:::
