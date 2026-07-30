---
title: Aggregators
description: Learn how to aggregate data from the series.
nav_order: 9
---

# Aggregators

Aggregators allows you to perform calculations on top of the whole series. They plug seamelessly into `Series` and can be used through `dot` notation.

For example you want to know the number of events that happened during the specific timeframe. Of course you can calculate that manually with some form of reduce, but you can also use build in `Trifle::Stats` methods to calculate this.

Aggregator allows you to pass also `slices: Integer` that will split the series into equal chunks and calculate specific action on top of each slice. It defaults to 1 (obviously).

```ruby
series = Trifle::Stats.series(...)
=> #<Trifle::Stats::Series:0x0000ffffa14256e8 @series={:at=>[2024-03-22 19:38:00 +0000, 2024-03-22 19:39:00 +0000], :values=>[{events: {count: 42, sum: 2184}}, {events: {count: 33, sum: 1553}}]}>
series.aggregate.sum(path: 'events.count')
=> [75]
series.aggregate.sum(path: 'events.count', slices: 2)
=> [42, 33]
```

> Note: `path` is a list of keys joined by dot. Ie `orders.shipped.count` would represent value at `{orders: { shipped: { count: ... } } }`.

## Custom Aggregators

You can use one of predefined aggregators or write your own. Aggregator needs to implement at least one method that accepts key parameters `series:` and `path:` and returns _something_. The `series:`is passed in automatically.

```ruby
class MyAggregator
  def aggregate(series:, path:)
    # perform some calculation on top of series
    rand(1000)
  end
end
```

If you write your own aggregator and would like to access it through `dot` notation, you need to register it through `Trifle::Stats::Series.register_aggregator(NAME, self)` inside of your aggregator class.

```ruby
class MyAggregator
  Trifle::Stats::Series.register_aggregator(:rand, self)

  def aggregate(series:, path:)
    # perform some calculation on top of series
    rand(1000)
  end
end
```

And from there you can access it through `series.aggregate.rand(path: 'a.count')`
