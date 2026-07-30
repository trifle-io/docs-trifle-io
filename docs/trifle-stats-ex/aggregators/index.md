---
title: Aggregators
description: Learn how to compute totals from a series.
nav_order: 9
---

# Aggregators

Aggregators compute derived values from a series. In Elixir they live on `Trifle.Stats.Series` and accept a dot-separated `path` into the values map. They return a list of computed values (one per slice).

> Note: `path` is a list of keys joined by dot. Example: `"orders.shipped.count"` maps to `%{"orders" => %{"shipped" => %{"count" => ...}}}`.

## Available aggregators

- [Min](/trifle-stats-ex/aggregators/min)
- [Max](/trifle-stats-ex/aggregators/max)
- [Sum](/trifle-stats-ex/aggregators/sum)
- [Mean](/trifle-stats-ex/aggregators/mean)

## Example

```elixir
series |> Trifle.Stats.Series.aggregate_sum("events.count")
```
