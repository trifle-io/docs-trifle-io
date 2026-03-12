---
title: Transponders
description: Add derived values with the expression transponder.
nav_order: 7
---

# Transponders

Go exposes one built-in transponder API:

```go
series := triflestats.SeriesFromResult(result)
series, err := series.TransformExpression(
    []string{"events.sum", "events.count"},
    "a / b",
    "events.avg",
)
if err != nil {
    panic(err)
}
```

:::callout note "Paths"
`paths` use dotted notation (`events.count`) and map to `a`, `b`, `c`, ... in order.
:::

:::callout note "Response"
`response` is required and can be nested, for example `events.rates.success`.
:::

:::callout note "Missing values"
Missing inputs or divide-by-zero write `nil` for that row.
:::

:::callout note "Wildcards"
Wildcard paths (`*`) are reserved for a future expansion and are rejected for now.
:::

## `TransformExpression(paths []string, expression, response string) (Series, error)`

:::signature TransformExpression(paths []string, expression, response string) (Series, error)
paths | []string | required |  | Paths assigned to `a`, `b`, `c`, ...
expression | string | required |  | Math expression using those variables.
response | string | required |  | Output path for the result.
:::

```go
series, err = series.TransformExpression(
    []string{"events.success", "events.total"},
    "(a / b) * 100",
    "events.success_rate",
)
```

## Common recipes

```go
// Average
series, _ = series.TransformExpression(
    []string{"events.sum", "events.count"},
    "a / b",
    "events.avg",
)

// Ratio
series, _ = series.TransformExpression(
    []string{"events.success", "events.total"},
    "(a / b) * 100",
    "events.success_rate",
)

// Standard deviation
series, _ = series.TransformExpression(
    []string{"events.sum", "events.count", "events.square"},
    "sqrt((b * c - a * a) / (b * (b - 1)))",
    "events.sd",
)
```
