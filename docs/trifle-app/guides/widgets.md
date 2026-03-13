---
title: Widget Cookbook
description: Practical layout patterns for Trifle dashboards.
nav_order: 4
---

# Widget Cookbook

This is the pragmatic stuff: layouts that read fast, survive real data, and match how widgets work in Trifle today.

## Grid basics

- Grid is **12 columns** wide.
- Widgets use `x`, `y`, `w`, `h`.
- Missing values default to `w: 3`, `h: 2`, `x: 0`, `y: 0`.

## Metric widgets now use `series`

All metric widgets use the same ordered `series` model:

- `kpi`
- `timeseries`
- `category`
- `table`
- `list`
- `distribution`
- `heatmap`

`text` widgets are the exception. They do not use metric series.

Each `series` row is either:

- a `path` row that reads one metric path
- an `expression` row that computes from previous rows

```json
{
  "series": [
    { "kind": "path", "path": "orders", "label": "Orders", "visible": false },
    { "kind": "path", "path": "revenue", "label": "Revenue", "visible": false },
    { "kind": "expression", "expression": "b / a", "label": "Average order value", "visible": true }
  ]
}
```

### How series rows behave

- Order matters. Expression rows can reference previous rows as `a`, `b`, `c`, and so on.
- Hidden rows still evaluate. Use hidden source rows to feed one visible derived row.
- Path rows can use wildcards such as `country.*` or `latency.*.count`.
- Expression rows use the same syntax as transponders.
- Each row can also set `label`, `visible`, and `color_selector`.
- For wildcard path rows, leave `label` blank if you want the emitted binding names to stay unchanged.

:::callout note "Widget-specific behavior"
- KPI widgets display the **first visible resolved series**. Keep source rows hidden when you want one derived expression row to drive the KPI.
- Table widgets render configured series as **rows**, while timestamps stay the **columns**.
- List widgets behave like category widgets. Wildcard paths can fan out into many items, and expression rows can rank or combine those items.
- Distribution and heatmap widgets apply expressions bucket-by-bucket after matching bindings and compatible bucket layouts.
:::

:::callout note "Good formula examples"
- `b / a`
- `(a / b) * 100`
- `sum(a, b, c)`
- `mean(a, b, c)`
- `max(a, b)`
:::

## Pattern: KPI strip + trend

Good for exec overviews or status boards.

```json
{
  "grid": [
    {
      "id": "kpi-1",
      "type": "kpi",
      "title": "Total Orders",
      "function": "sum",
      "series": [
        { "kind": "path", "path": "orders", "label": "Orders", "visible": true }
      ],
      "x": 0,
      "y": 0,
      "w": 3,
      "h": 2
    },
    {
      "id": "kpi-2",
      "type": "kpi",
      "title": "Failed Orders",
      "function": "sum",
      "series": [
        { "kind": "path", "path": "failed", "label": "Failed", "visible": true }
      ],
      "x": 3,
      "y": 0,
      "w": 3,
      "h": 2
    },
    {
      "id": "kpi-3",
      "type": "kpi",
      "title": "Average Order Value",
      "function": "sum",
      "series": [
        { "kind": "path", "path": "orders", "label": "Orders", "visible": false },
        { "kind": "path", "path": "revenue", "label": "Revenue", "visible": false },
        { "kind": "expression", "expression": "b / a", "label": "AOV", "visible": true }
      ],
      "x": 6,
      "y": 0,
      "w": 3,
      "h": 2
    },
    {
      "id": "kpi-4",
      "type": "kpi",
      "title": "Revenue",
      "function": "sum",
      "series": [
        { "kind": "path", "path": "revenue", "label": "Revenue", "visible": true }
      ],
      "x": 9,
      "y": 0,
      "w": 3,
      "h": 2
    },
    {
      "id": "ts-1",
      "type": "timeseries",
      "title": "Order Volume",
      "chart_type": "area",
      "stacked": true,
      "legend": true,
      "series": [
        { "kind": "path", "path": "orders", "label": "Orders", "visible": true },
        { "kind": "path", "path": "failed", "label": "Failed", "visible": true }
      ],
      "x": 0,
      "y": 2,
      "w": 12,
      "h": 4
    }
  ]
}
```

:::callout note "Why `function: sum` for AOV?"
For KPI widgets, each path row is aggregated first and the expression runs on those aggregated values. That makes `sum(revenue) / sum(orders)` a good fit for average order value across the selected timeframe.
:::

## Pattern: Goal progress + split KPI

Great for leadership scorecards with targets and change deltas.

```json
{
  "grid": [
    {
      "id": "goal-1",
      "type": "kpi",
      "title": "ARR Target",
      "function": "sum",
      "subtype": "goal",
      "goal_target": 100000,
      "goal_progress": true,
      "goal_invert": false,
      "series": [
        { "kind": "path", "path": "revenue", "label": "Revenue", "visible": true }
      ],
      "x": 0,
      "y": 0,
      "w": 4,
      "h": 2
    },
    {
      "id": "kpi-2",
      "type": "kpi",
      "title": "New Logos",
      "function": "sum",
      "subtype": "split",
      "diff": true,
      "timeseries": true,
      "series": [
        { "kind": "path", "path": "logos", "label": "Logos", "visible": true }
      ],
      "x": 4,
      "y": 0,
      "w": 4,
      "h": 2
    },
    {
      "id": "ts-1",
      "type": "timeseries",
      "title": "Revenue Trend",
      "chart_type": "line",
      "legend": false,
      "series": [
        { "kind": "path", "path": "revenue", "label": "Revenue", "visible": true }
      ],
      "x": 0,
      "y": 2,
      "w": 12,
      "h": 4
    }
  ]
}
```

## Pattern: Breakdown board

Great when you need to explain why the number is moving.

```json
{
  "grid": [
    {
      "id": "kpi-1",
      "type": "kpi",
      "title": "Total",
      "function": "sum",
      "series": [
        { "kind": "path", "path": "count", "label": "Count", "visible": true }
      ],
      "x": 0,
      "y": 0,
      "w": 4,
      "h": 3
    },
    {
      "id": "ts-1",
      "type": "timeseries",
      "title": "Trend",
      "chart_type": "line",
      "legend": false,
      "series": [
        { "kind": "path", "path": "count", "label": "Count", "visible": true }
      ],
      "x": 4,
      "y": 0,
      "w": 8,
      "h": 3
    },
    {
      "id": "cat-1",
      "type": "category",
      "title": "By Country",
      "chart_type": "donut",
      "series": [
        { "kind": "path", "path": "country.*", "visible": true }
      ],
      "x": 0,
      "y": 3,
      "w": 4,
      "h": 3
    },
    {
      "id": "list-1",
      "type": "list",
      "title": "Top Channels",
      "limit": 6,
      "series": [
        { "kind": "path", "path": "channel.*", "visible": true }
      ],
      "x": 4,
      "y": 3,
      "w": 4,
      "h": 3
    },
    {
      "id": "tbl-1",
      "type": "table",
      "title": "Raw Data",
      "series": [
        { "kind": "path", "path": "count", "label": "Count", "visible": true },
        { "kind": "path", "path": "failed", "label": "Failed", "visible": true },
        { "kind": "path", "path": "duration", "label": "Duration", "visible": true }
      ],
      "x": 8,
      "y": 3,
      "w": 4,
      "h": 3
    }
  ]
}
```

## Pattern: Ops board (alerts + latency)

```json
{
  "grid": [
    {
      "id": "text-1",
      "type": "text",
      "title": "Service Health",
      "subtype": "header",
      "alignment": "left",
      "x": 0,
      "y": 0,
      "w": 12,
      "h": 1
    },
    {
      "id": "kpi-1",
      "type": "kpi",
      "title": "p95 Latency",
      "function": "mean",
      "series": [
        { "kind": "path", "path": "p95", "label": "p95", "visible": true }
      ],
      "x": 0,
      "y": 1,
      "w": 3,
      "h": 2
    },
    {
      "id": "kpi-2",
      "type": "kpi",
      "title": "Error Rate",
      "function": "sum",
      "series": [
        { "kind": "path", "path": "errors", "label": "Errors", "visible": false },
        { "kind": "path", "path": "requests", "label": "Requests", "visible": false },
        { "kind": "expression", "expression": "(a / b) * 100", "label": "Error Rate", "visible": true }
      ],
      "x": 3,
      "y": 1,
      "w": 3,
      "h": 2
    },
    {
      "id": "ts-1",
      "type": "timeseries",
      "title": "Latency",
      "chart_type": "line",
      "legend": true,
      "series": [
        { "kind": "path", "path": "p50", "label": "p50", "visible": true },
        { "kind": "path", "path": "p95", "label": "p95", "visible": true },
        { "kind": "path", "path": "p99", "label": "p99", "visible": true }
      ],
      "x": 6,
      "y": 1,
      "w": 6,
      "h": 4
    },
    {
      "id": "dist-1",
      "type": "distribution",
      "title": "Latency Dist",
      "mode": "2d",
      "chart_type": "bar",
      "designators": {
        "horizontal": { "type": "linear", "min": 0, "max": 1200, "step": 100 }
      },
      "series": [
        { "kind": "path", "path": "duration", "label": "Duration", "visible": true }
      ],
      "x": 0,
      "y": 3,
      "w": 6,
      "h": 4
    }
  ]
}
```

## Pattern: Channel mix board

Useful for marketing and growth teams that care about composition, not just totals.

```json
{
  "grid": [
    {
      "id": "ts-mix",
      "type": "timeseries",
      "title": "Channel Mix",
      "chart_type": "line",
      "normalized": true,
      "legend": true,
      "y_label": "%",
      "series": [
        { "kind": "path", "path": "channel.organic", "label": "Organic", "visible": true },
        { "kind": "path", "path": "channel.paid", "label": "Paid", "visible": true },
        { "kind": "path", "path": "channel.referral", "label": "Referral", "visible": true }
      ],
      "x": 0,
      "y": 0,
      "w": 8,
      "h": 4
    },
    {
      "id": "list-1",
      "type": "list",
      "title": "Top Channels",
      "limit": 8,
      "sort": "desc",
      "empty_message": "No channels yet.",
      "series": [
        { "kind": "path", "path": "channel.*", "visible": true }
      ],
      "x": 8,
      "y": 0,
      "w": 4,
      "h": 4
    },
    {
      "id": "tbl-1",
      "type": "table",
      "title": "Raw Breakdown",
      "series": [
        { "kind": "path", "path": "channel.*", "visible": true },
        { "kind": "path", "path": "count", "label": "Count", "visible": true }
      ],
      "x": 0,
      "y": 4,
      "w": 12,
      "h": 3
    }
  ]
}
```

## Pattern: Widget-only derived metrics

Use this when you want a computed metric in one widget without creating a source-level transponder.

```json
{
  "id": "ts-avg",
  "type": "timeseries",
  "title": "Average Revenue per Order",
  "chart_type": "bar",
  "series": [
    { "kind": "path", "path": "orders", "label": "Orders", "visible": false },
    { "kind": "path", "path": "revenue", "label": "Revenue", "visible": false },
    { "kind": "expression", "expression": "b / a", "label": "AOV", "visible": true }
  ],
  "x": 0,
  "y": 0,
  "w": 6,
  "h": 4
}
```

This pattern works especially well for:

- KPI widgets driven by one visible formula row
- list widgets that rank a computed ratio
- table widgets that show raw rows plus one derived row
- timeseries widgets where source rows stay hidden and only the derived line or bars are plotted

## Segment-aware dashboards

If you use segments, keep widget paths stable and let segments drive filtering. It keeps your dashboard readable and avoids path spaghetti.

:::callout warn "Edge case"
- If your metric payload is missing paths, widgets render empty. That is not a bug.
- If an expression depends on missing values or divides by zero, that result is empty for that binding or timestamp.
:::
