---
title: Assert values
description: Learn how to set values.
nav_order: 2
---

# Assert values

Asserting values works same way like incrementing, but instead of increment, it sets the value. Asserting values runs `set` on the driver. Every time you assert a value, it will set the metrics.

## `assert(key: String, at: Time, values: Hash, **options)`

Use when you want to track counters at specific times, ie end of day count.

:::signature assert(key: String, at: Time, values: Hash, **options) -> nil
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
Trifle::Stats.assert(key: 'event::logs', at: Time.now, values: {count: 1, duration: 2, lines: 241})
=> [{2021-01-25 16:00:00 +0100=>{:count=>1, :duration=>2, :lines=>241}}, {2021-01-25 00:00:00 +0100=>{:count=>1, :duration=>2, :lines=>241}}]
```

Sets a single set of counters. 

@tab Repeat setters

```ruby
Trifle::Stats.assert(key: 'event::logs', at: Time.now, values: {count: 1, duration: 1, lines: 56})
=> [{2021-01-25 16:00:00 +0100=>{:count=>1, :duration=>1, :lines=>56}}, {2021-01-25 00:00:00 +0100=>{:count=>1, :duration=>1, :lines=>56}}]
Trifle::Stats.assert(key: 'event::logs', at: Time.now, values: {count: 1, duration: 5, lines: 361})
=> [{2021-01-25 16:00:00 +0100=>{:count=>1, :duration=>5, :lines=>361}}, {2021-01-25 00:00:00 +0100=>{:count=>1, :duration=>5, :lines=>361}}]
```

Use the same `key` to set latest values correctly.
:::

Use `untracked: true` when you want system tracking to group under `__untracked__`.

:::callout warn "Common mistakes"
- Passing non-numeric objects in `values` raises an error.
- Assert will store only latest set value in specific bucket. If you call Assert hourly, each `'1h'` will have its own values, but the value from `'1d'` bucket will be same as value from last hour of the day. As that represents state at the end of the day.
:::


## Verify values

Retrieve your values for specific `range`. As you just used `assert` above, it will return latest value you've asserted.

```ruby
Trifle::Stats.values(key: 'event::logs', from: Time.now, to: Time.now, granularity: '1d')
=> {:at=>[2021-01-25 00:00:00 +0200], :values=>[{"count"=>1, "duration"=>5, "lines"=>361}]}
```

And that was it.
