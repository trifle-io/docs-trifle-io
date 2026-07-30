---
title: Aggregators
description: Aggregate data from a series.
nav_order: 9
---

# Aggregators

Aggregators summarize numeric paths across a series. Each aggregator returns a slice of values; use `slices` to split the series into equal chunks.

```go
series := TrifleStats.SeriesFromResult(result)

sum := series.AggregateSum("events.count", 1)
mean := series.AggregateMean("events.duration", 2)
```

:::callout note "Slices"
- `slices = 1` returns a single aggregate for the full series.
- `slices > 1` splits the series into equal parts (oldest items may be dropped to keep slices even).
:::

:::callout note "Paths"
Paths are dot-separated (`orders.shipped.count`) and refer to nested map values.
:::

:::callout note "Empty data"
`AggregateMin` and `AggregateMax` return `nil` if no numeric values are present in a slice.
:::

## Available aggregators

- [Sum](/trifle-stats-go/aggregators/sum)
- [Mean](/trifle-stats-go/aggregators/mean)
- [Min](/trifle-stats-go/aggregators/min)
- [Max](/trifle-stats-go/aggregators/max)
