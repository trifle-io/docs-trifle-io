---
title: Transponders
description: Learn how to add derived values with the expression transponder.
nav_order: 7
---

# Transponders

`Trifle::Stats` ships with a single built-in transponder: `expression`.

It reads a list of `paths`, maps them to `a`, `b`, `c`, and writes the result to `response`.

```ruby
series = Trifle::Stats.series(...)

series.transpond.expression(
  paths: ['events.sum', 'events.count'],
  expression: 'a / b',
  response: 'events.avg'
)
```

> Note: `path` is a list of keys joined by dot. Ie `orders.shipped.count` would represent value at `{orders: { shipped: { count: ... } } }`.

## Rules

- `paths` are assigned in order: first path -> `a`, second path -> `b`, third path -> `c`.
- Missing input values or divide-by-zero return `nil` for that row.
- Nested `response` paths are created automatically when intermediate hashes are missing.
- Wildcard paths (`*`) are reserved for a future expansion and are rejected for now.

## Common recipes

```ruby
# Average
series.transpond.expression(
  paths: ['events.sum', 'events.count'],
  expression: 'a / b',
  response: 'events.avg'
)

# Ratio
series.transpond.expression(
  paths: ['events.success', 'events.total'],
  expression: '(a / b) * 100',
  response: 'events.success_rate'
)

# Standard deviation
series.transpond.expression(
  paths: ['events.sum', 'events.count', 'events.square'],
  expression: 'sqrt((b * c - a * a) / (b * (b - 1)))',
  response: 'events.sd'
)
```

## Custom transponders

You can still register custom transponders with `Trifle::Stats::Series.register_transponder`, but the built-in API is intentionally limited to `expression`.
