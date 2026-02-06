---
title: Track values
description: Learn how to increment values.
nav_order: 1
---

# Track values

Tracking values runs `inc` on the driver. Every time you track a value, it will increment the metrics.

## `track(key: String, at: Time, values: Hash, **options)`

Use when you need to track events as they happen.

:::signature track(key: String, at: Time, values: Hash, **options) -> nil
key | String | required |  | Identifier for the metric (e.g., `event::logs`).
at | Time | required |  | Timestamp for the sample, usually `Time.now` or `Time.zone.now`. `Trifle::Stats` will convert to configured timezone.
values | Hash<String, Numeric or Hash> | required |  | Nested hashes are allowed; every leaf must be numeric (Integer, Float, BigDecimal).
config | Trifle::Stats::Configuration | optional | `nil` | Override configuration for this call. Defaults to the global configuration when omitted.
untracked | Boolean | optional | `false` | When true, system tracking uses `__untracked__` instead of the metric key.
:::

## Examples

:::tabs
@tab Basic
```ruby
Trifle::Stats.track(key: 'event::logs', at: Time.now, values: { count: 1, duration: 2, lines: 241 })
# => [{2021-01-25 16:00:00 +0100=>{:count=>1, :duration=>2, :lines=>241}}, {2021-01-25 00:00:00 +0100=>{:count=>1, :duration=>2, :lines=>241}}]
```

Adds a single set of counters.

@tab Repeat increments
```ruby
Trifle::Stats.track(key: 'event::logs', at: Time.now, values: { count: 1, duration: 1, lines: 56 })
Trifle::Stats.track(key: 'event::logs', at: Time.now, values: { count: 1, duration: 5, lines: 361 })
# => [{2021-01-25 16:00:00 +0100=>{:count=>1, :duration=>5, :lines=>361}}, {2021-01-25 00:00:00 +0100=>{:count=>1, :duration=>5, :lines=>361}}]
```

Use the same `key` to keep aggregations rolling up correctly.

@tab Nested counters
```ruby
Trifle::Stats.track(key: 'event::logs', at: Time.now, values: {
  count: 1,
  duration: 30,
  duration_breakdown: {
    parsing: 21,
    compression: 8,
    upload: 1
  },
  lines: 25432754
})
```

Nested hashes are allowed; each leaf must be numeric so rollups stay safe.

@tab Untracked system key
```ruby
Trifle::Stats.track(
  key: 'event::logs',
  at: Time.now,
  values: { count: 1 },
  untracked: true
)
```

System tracking records under `__untracked__` instead of the metric key.
:::

:::callout warn "Common mistakes"
- Passing non-numeric objects in `values` raises an error.
:::

## Verify values

Retrieve your values for specific `range`. Adding increments above will return sum of all the values you've tracked.

```ruby
Trifle::Stats.values(key: 'event::logs', from: Time.now, to: Time.now, granularity: '1d')
# => {:at=>[2021-01-25 00:00:00 +0200], :values=>[{"count"=>3, "duration"=>8, "lines"=>658}]}
```

And that was it.
