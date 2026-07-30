---
title: Get values
description: Learn how to retrieve values.
nav_order: 4
---

# Get values

Getting values runs `get` on the driver.

The inclusive read axis is generated with the same [Nocturnal bucketing rules](/trifle-stats-rb/nocturnal) used when values are written.

:::callout note "Use Series"
You can work with values by using [Series](./series) method as well which allows you to perform additional actions on a series of data easily. Values serves as raw accessor where you want to perform further calculations and formattings yourself.
:::

## `values(key: String, from: Time, to: Time, granularity: Symbol, **options)`

Use to retrieve raw values from driver.

:::signature values(key: String, from: Time, to: Time, granularity: String, **options) -> Hash
key | String | required |  | Identifier for metrics.
from | Time | required |  | Timestamp identifying beginning of a timerange.
to | Time | required |  | Timestamp identifying end of timerange.
granularity | String | required |  | Specific granularity you want your values in.
config | Trifle::Stats::Configuration | optional | `nil` | Instance of Configuration. Defaults to global configuration.
skip_blanks | Boolean | optional | `false` | Instruct driver not to return empty hash in timeline when no value is being tracked.
:::

Using `from` and `to` gives you flexibility to exactly specify what data you are interested in.

Use `granularity` to specify _sensitivity_ of returned data (aka how many data points you want to get). For example if you're trying to get daily values for current a specific month, use `granularity: '1d'`. This will give you ~30 data points. If you need to increase your sensitivity for chart, you may use `granularity: '1h'` which will give you ~30 * 24 data points.

The more data you're fetching, the slower the response time. Thats a trade-off you need to decide.

## Examples

:::tabs
@tab Today values

Here is an example how to get today values for specific key.

```ruby
Trifle::Stats.values(key: 'event::logs', from: Time.now, to: Time.now, granularity: '1d')
=> {:at=>[2021-01-25 00:00:00 +0200], :values=>[{"count"=>3, "duration"=>8, "lines"=>658}]}
```
@tab Last 30 days

Here is another how to get daily values for a last 30 days for specific key.

```ruby
Trifle::Stats.values(key: 'event::logs', from: Time.now - 60 * 60 * 24 * 30, to: Time.now, granularity: '1d')
=> {:at=>[2021-01-25 00:00:00 +0200, 2021-01-24 00:00:00 +0200, ...], values: [{"count"=>3, "duration"=>8, "lines"=>658}, {"count"=>1, "duration"=>3, "lines"=>311}, ...]}
```
:::

> If you're integrating with Rails, don't forget you can use _things_ like `1.month.ago` or `Time.zone.now - 30.days`.

### Skip Blanks

Sometimes you may not have event occurence every hour or every day. Whenever you pull longer period of data, you may end up with timestamps and values where no values has been tracked. `Trifle::Stats` drivers by default return empty hash in these so you can perform continuous calculations (ie slicing in aggregators, etc). The disadvantage of this is that it may create lots of _empty_ data. For example lets say you track something ~4 times a day and you wanna pull data per minute for last 30 days. By default `Trifle::Stats` would give you 30 (days) * 24 (hours) * 60 (minutes) ~43k of points. Good luck plotting that. But if you know you have lots of empty values in between, you may decide to skip those and then you would get back 30 (days) * 4 (times a day) ~= 120 points. Theres a big difference.

:::tabs
@tab With Blanks

```ruby
Trifle::Stats.values(key: 'events::logs', from: Time.now - 60 * 60 * 24 * 30, to: Time.now, granularity: '1d')
=> {
  :at => [
    2021-01-20 00:00:00 +0200,
    2021-01-21 00:00:00 +0200,
    2021-01-22 00:00:00 +0200,
    2021-01-23 00:00:00 +0200,
    2021-01-24 00:00:00 +0200,
    2021-01-25 00:00:00 +0200,
    2021-01-26 00:00:00 +0200,
    2021-01-27 00:00:00 +0200,
    ...
  ],
  values: [
    {"count"=>3, "duration"=>8, "lines"=>658},
    {},
    {"count"=>1, "duration"=>3, "lines"=>311},
    {},
    {},
    {"count"=>2, "duration"=>4, "lines"=>541},
    {},
    {},
    ...
  ]
}
```

@tab Without Blanks

```ruby
Trifle::Stats.values(key: 'events::logs', from: Time.now - 60 * 60 * 24 * 30, to: Time.now, granularity: '1d', skip_blanks: true)
=> {
  :at => [
    2021-01-20 00:00:00 +0200,
    2021-01-22 00:00:00 +0200,
    2021-01-25 00:00:00 +0200,
    ...
  ],
  values: [
    {"count"=>3, "duration"=>8, "lines"=>658},
    {"count"=>1, "duration"=>3, "lines"=>311},
    {"count"=>2, "duration"=>4, "lines"=>541},
    ...
  ]
}
```
:::

Sometimes needed, othertimes not. The difference it makes is when you're formatting these values to a Bar chart or a Timeline chart. Do you want to see missing values or 0s? It's your call.
