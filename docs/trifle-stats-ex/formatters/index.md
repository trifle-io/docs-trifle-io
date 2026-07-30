---
title: Formatters
description: Learn how to format series for charts.
nav_order: 10
---

# Formatters

Formatters shape a series into data structures that are easy to plot. In Elixir they live on `Trifle.Stats.Series` and accept a dot-separated `path` into the values map.

Formatters resolve `*` wildcards and also expand map targets when no wildcard is provided. That makes it easy to format `"events"` and get `events.count`, `events.duration`, and other fields automatically.

> Note: `path` is a list of keys joined by dot. Example: `"orders.shipped.count"` maps to `%{"orders" => %{"shipped" => %{"count" => ...}}}`.

## Available formatters

- [Timeline](/trifle-stats-ex/formatters/timeline)
- [Category](/trifle-stats-ex/formatters/category)

## Example

```elixir
series |> Trifle.Stats.Series.format_timeline("events.count")
```
