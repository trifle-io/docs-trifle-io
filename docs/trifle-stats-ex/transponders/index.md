---
title: Transponders
description: Learn how to add derived values with the expression transponder.
nav_order: 7
---

# Transponders

`Trifle.Stats` exposes one built-in transponder API:

:::signature Trifle.Stats.Series.transform_expression
series | Trifle.Stats.Series | required |  | Series wrapper.
paths | list(String) | required |  | Dot paths assigned to `a`, `b`, `c`, ...
expression | String | required |  | Math expression using those variables.
response | String | required |  | Dot path where the result is stored.
slices | integer | optional | 1 | Number of slices.
:::

```elixir
series
|> Trifle.Stats.Series.transform_expression(
  ["events.sum", "events.count"],
  "a / b",
  "events.avg"
)
```

> Note: `path` is a list of keys joined by dot. Example: `"orders.shipped.count"` maps to `%{"orders" => %{"shipped" => %{"count" => ...}}}`.

## Rules

- `paths` are assigned in order: first path -> `a`, second path -> `b`, third path -> `c`.
- Missing input values or divide-by-zero return `nil` for that row.
- Nested `response` maps are created automatically when intermediate maps are missing.
- Wildcard paths (`*`) are reserved for a future expansion and are rejected for now.

## Examples

:::tabs
@tab Average
```elixir
now = DateTime.utc_now()

series = Trifle.Stats.Series.new(%{
  at: [DateTime.add(now, -60, :second), now],
  values: [
    %{events: %{count: 2, sum: 40}},
    %{events: %{count: 3, sum: 60}}
  ]
})

series
|> Trifle.Stats.Series.transform_expression(
  ["events.sum", "events.count"],
  "a / b",
  "events.avg"
)
|> Trifle.Stats.Series.aggregate_mean("events.avg")
```

@tab Ratio
```elixir
series
|> Trifle.Stats.Series.transform_expression(
  ["events.success", "events.total"],
  "(a / b) * 100",
  "events.success_rate"
)
|> Trifle.Stats.Series.format_timeline("events.success_rate")
```

@tab Stddev
```elixir
series
|> Trifle.Stats.Series.transform_expression(
  ["events.sum", "events.count", "events.square"],
  "sqrt((b * c - a * a) / (b * (b - 1)))",
  "events.stddev"
)
|> Trifle.Stats.Series.format_timeline("events.stddev")
```
:::
