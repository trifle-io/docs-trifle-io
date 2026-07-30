---
title: Formatters
description: Prepare series for charts.
nav_order: 10
---

# Formatters

Formatters transform a series into shapes that are easy to plot. Trifle Stats (Go) includes two helpers: `FormatTimeline` and `FormatCategory`.

```go
series := TrifleStats.SeriesFromResult(result)

timeline := series.FormatTimeline("events.count", 1, nil)
category := series.FormatCategory("events.country", 1, nil)
```

:::callout note "Slices"
Like aggregators, formatters accept `slices`. Use it to split the series and format each slice separately.
:::

:::callout note "Wildcards"
Formatter paths can include `*` to expand dynamic keys (e.g. `events.*.count`). The formatter returns a map for each resolved path.
:::

## Available formatters

- [Timeline](/trifle-stats-go/formatters/timeline)
- [Category](/trifle-stats-go/formatters/category)
