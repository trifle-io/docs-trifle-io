---
title: Series helpers
description: Wrap values in Series for richer analysis.
nav_order: 4
---

# Series helpers

`Series` wraps the raw values returned by `Values` and unlocks aggregators, formatters, and transponders.

## `SeriesFromResult(result ValuesResult) Series`

:::signature SeriesFromResult(result ValuesResult) Series
result | ValuesResult | required |  | Result returned by `Values`.
:::

## `NewSeries(at []time.Time, values []map[string]any) Series`

:::signature NewSeries(at []time.Time, values []map[string]any) Series
at | []time.Time | required |  | Timestamps for each bucket.
values | []map[string]any | required |  | Values aligned with `at`.
:::

## Helpers

### `AvailablePaths() []string`

Returns a sorted list of numeric paths found in the series.

### `FetchPath(data map[string]any, path string) any`

Returns the value at a dotted path for a single row.

## Example

```go
from := time.Now().UTC().Add(-24 * time.Hour)
result, _ := TrifleStats.Values(cfg, "event::logs", from, time.Now().UTC(), "1h", false)
series := TrifleStats.SeriesFromResult(result)

paths := series.AvailablePaths()
_ = paths

first := series.Values[0]
value := TrifleStats.FetchPath(first, "count")
_ = value
```

You can chain helpers to build derived metrics:

```go
series, _ = series.TransformExpression(
    []string{"success", "count"},
    "(a / b) * 100",
    "success_rate",
)
timeline := series.FormatTimeline("success_rate", 1, nil)
_ = timeline
```
