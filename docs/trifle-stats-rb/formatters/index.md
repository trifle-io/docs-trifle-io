---
title: Formatters
description: Learn how to use Formatters to prepare series for charts.
nav_order: 10
---

# Formatters

Having series of data available is cool, but you know whats even cooler? Having bunch of charts to visualize them. Sorry, I couldn't help myself.

The purpose of formatters is exactly that. To help you to prepare series for a charting library. Every library is different, but they all come together in requiring the data to be in a list of values. Sometimes this can be a list of simple values, list of hashes with `x` and `y` keys or list of lists with coordinates.

They plug seamelessly into `Series`and can be used through `dot` notation.

Fomatter allows you to pass also `slices: Integer` that will split the series into equal chunks and format values on top of each slice. It defaults to 1 (obviously).

```ruby
series = Trifle::Stats.series(...)
=> #<Trifle::Stats::Series:0x0000ffffa14256e8 @series={:at=>[2024-03-22 19:38:00 +0000, 2024-03-22 19:39:00 +0000], :values=>[{events: {count: 42, sum: 2184}}, {events: {count: 33, sum: 1553}}]}>
series.format.timeline(path: 'events.count')
=> [[[2024-03-22 19:38:00 +0000, 42], [2024-03-22 19:39:00 +0000, 33]]]
series.format.timeline(path: 'events.count', slices: 2)
=> [[[2024-03-22 19:38:00 +0000, 42]], [[2024-03-22 19:39:00 +0000, 33]]]
```

> Note: `path` is a list of keys joined by dot. Ie `orders.shipped.count` would represent value at `{orders: { shipped: { count: ... } } }`.

## Custom Formatters

You can use one of predefined formatters or write your own. Formatter needs to implement at least one method that accepts key parameters `series:`and `path:` and returns array of _formatted_ results. The `series:`is passed in automatically.

```ruby
class MyFormatter
  def format(series:, path:)
    series[:at].map do |at|
      [at.to_i, rand(1000)]
    end
  end
end
```

If you write your own formatter and would like to access it through `dot` notation, you need to register it through `Trifle::Stats::Series.register_formatter(NAME, self)` inside of your formatter class.

```ruby
class MyFormatter
  Trifle::Stats::Series.register_formatter(:rand, self)

  def format(series:, path:)
    series[:at].map do |at|
      [at.to_i, rand(1000)]
    end
  end
end
```

And from there you can access it through `series.format.rand(path: 'a.count')`
