---
title: Usage
description: Learn how to use Trifle Stats (Go).
nav_order: 4
---

# Usage

Trifle Stats (Go) exposes a small set of top-level functions that map directly to driver operations. You can use them as-is, or wrap returned data in `Series` for richer analysis.

By default, `DefaultConfig()` enables buffered writes. Set `cfg.BufferEnabled = false` if you need fully synchronous writes.

:::callout note "Main methods"
- `Track` increments counters for a key.
- `Assert` sets values for a key at a specific time.
- `Values` retrieves raw series for a time range.
- `SeriesFromResult` wraps `ValuesResult` so you can aggregate, format, or transpond.
:::

Trifle Stats keeps the raw pieces so you can build the calculations you need. For example, if you want an average, track both `sum` and `count`, then derive the average with a transponder or a simple division.

## Track and fetch

```go
TrifleStats.Track(cfg, "event::logs", time.Now().UTC(), map[string]any{
  "count": 1,
  "duration": 2.1,
})

from := time.Now().UTC().Add(-24 * time.Hour)
result, _ := TrifleStats.Values(cfg, "event::logs", from, time.Now().UTC(), "1h", false)
```

## Series workflow

```go
series := TrifleStats.SeriesFromResult(result)
paths := series.AvailablePaths()
_ = paths

sum := series.AggregateSum("count", 1)
_ = sum
```

## Granularities

Granularities are defined as `<number><unit>`:

:::callout warn "Supported units"
- `s` - second
- `m` - minute
- `h` - hour
- `d` - day
- `w` - week
- `mo` - month
- `q` - quarter
- `y` - year
:::

## Paths

Values can be nested maps. Paths are dot-separated, e.g. `orders.shipped.count` maps to `{ orders: { shipped: { count: ... } } }`.

## Next steps

- [Track values](/trifle-stats-go/usage/track)
- [Assert values](/trifle-stats-go/usage/assert)
- [Get values](/trifle-stats-go/usage/values)
- [Series helpers](/trifle-stats-go/usage/series)
- [Aggregators](/trifle-stats-go/aggregators)
- [Formatters](/trifle-stats-go/formatters)
- [Transponders](/trifle-stats-go/transponders)
