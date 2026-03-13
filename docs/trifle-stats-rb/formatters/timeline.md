---
title: Timeline
description: Learn how to use Timeline Formatter.
nav_order: 1
---

# Timeline

Timeline formatter will help you to prepare data for (pretty much) any (reasonable) charting library that supports timestamps.

`format` method accepts a block where `at` and `value` variables are available. You can use this to format `at` timestamp into desired version, or return only `value`, or return hash or multi-dimensional array. The choice is yours!

```ruby
series = Trifle::Stats.series(...)
=> #<Trifle::Stats::Series:0x0000ffffa14256e8 @series={:at=>[2024-03-22 19:38:00 +0000, 2024-03-22 19:39:00 +0000], :values=>[{events: {count: 42, sum: 2184}}, {events: {count: 33, sum: 1553}}]}>
sample_data = series.format.timeline(path: 'events.count') do |at, value|
  value.to_i
end
=> [[42, 33]]

array_data = series.format.timeline(path: 'events.count') do |at, value|
  [at.to_i, value.to_i]
end
=> [[[1711136280, 42], [1711136340, 33]]]

hash_data = series.format.timeline(path: 'events.count') do |at, value|
  { x: at.to_i, y: value.to_i }
end
=> [[{ x: 1711136280, y: 42 }, { x: 1711136340, y: 33 }]]
 ```

> Note: `path` is a list of keys joined by dot. Ie `orders.shipped.count` would represent value at `{orders: { shipped: { count: ... } } }`.

If you want to plot percentile approximations, first derive them from average and standard deviation, then format those derived paths.

:::callout warn "Approximation only"
`P95 = average + 1.645 * sd` and `P99 = average + 2.326 * sd` are **normal approximations**. They are not exact percentiles and can be inaccurate for skewed data such as latency.
:::

```ruby
series = Trifle::Stats.series(...)
series.transpond.expression(
  paths: ['events.sum', 'events.count', 'events.square'],
  expression: 'sqrt((b * c - a * a) / (b * (b - 1)))',
  response: 'events.sd'
)

series.transpond.expression(
  paths: ['events.sum', 'events.count', 'events.sd'],
  expression: '(a / b) + c * 1.645',
  response: 'events.p95'
)

series.transpond.expression(
  paths: ['events.sum', 'events.count', 'events.sd'],
  expression: '(a / b) + c * 2.326',
  response: 'events.p99'
)

p95 = series.format.timeline(path: 'events.p95') do |at, value|
  {x: at.to_i, y: value}
end
=> [[{ x: 1711136280, y: 243.54 }, { x: 1711136340, y: 902.88 }]]

p99 = series.format.timeline(path: 'events.p99') do |at, value|
  {x: at.to_i, y: value}
end
=> [[{ x: 1711136280, y: 317.34 }, { x: 1711136340, y: 1176.48 }]
```

And thats it. Now you prepared series for plotting your percentile approximations.
