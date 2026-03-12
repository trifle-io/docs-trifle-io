---
title: Percentiles
description: Learn how to calculate average with percentiles.
nav_order: 2
---

# Percentiles

Average or mean can easily be biased by skewed distribution. Therefore knowing just whats the average may not always be enough. If you want to avoid displaying distribution, you may want to use 95th and/or 99th percnetiles instead.

To be able to calculate percentiles you will need to calculate standard deviation and normal distribution. 

Usually standard deviation is caluclated on top of your data, but in this case we're not preserving all instances of events, just the summary of them. To get around it, we need to preserve three values:

- `count` - total number of events.
- `sum` - aggregated sum of the event value.
- `square` - aggregates square value of the event.

With these three values, we are able to calculate standard deviation. Lets take it to practical example of duration.

```ruby
def duration(seconds)
  {
    count: 1,
    sum: seconds,
    square: seconds**2
  }
end
```

When you run this couple times, you will see what kind of payload it will be generating. The `Trifle::Stats` will then preserve the sum of it.

```ruby
irb(main):001:1* def duration(seconds)
irb(main):002:2*   {
irb(main):003:2*     count: 1,
irb(main):004:2*     sum: seconds,
irb(main):005:2*     square: seconds**2
irb(main):006:1*   }
irb(main):007:0> end
=> :duration
irb(main):008:0> duration(10)
=> {:count=>1, :sum=>10, :square=>100}
irb(main):009:0> duration(12)
=> {:count=>1, :sum=>12, :square=>144}
irb(main):010:0> duration(8)
=> {:count=>1, :sum=>8, :square=>64}
irb(main):011:0> duration(16)
=> {:count=>1, :sum=>16, :square=>256}
irb(main):012:0> duration(12)
=> {:count=>1, :sum=>12, :square=>144}
irb(main):013:0> duration(10)
=> {:count=>1, :sum=>10, :square=>100}
```

With these values, the sum will be `{ count: 5, sum: 68, square: 808 }`. This is still bit far away from percentiles.

## Standard Deviation

Just like with `average`, `Trifle::Stats` wont give you that right away. To get the average, you need to calculate `sum / count`. Same with standard deviation, you need to use an equation for that. Luckily we can laverage Rapid calculation method for [Standard Deviation](https://en.wikipedia.org/wiki/Standard_deviation#Rapid_calculation_methods).

```ruby
average = (sum / count)
sd = Math.sqrt((count * square - sum * sum) / (count * (count - 1)))
```

Thats somewhat simple, but not so straight forward. There are also [other methods](https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance) how to calculate standard deviation that you may want to explore.

## 95th and 99th Percentile

Once you have standard deviation `sd`, it is easy to calculate [percentiles](https://en.wikipedia.org/wiki/68–95–99.7_rule).

```ruby
p95 = average + sd * 1.98
p99 = average + sd * 2.58
```

And voila. Now you have average, 95th percentile as well as 99th percentile. Which are the holy grail of performance monitoring.

## Expression transponder

You can derive standard deviation with the [expression transponder](../transponders) and then calculate percentiles in the [Timeline Formatter](../formatters/timeline).

```ruby
series.transpond.expression(
  paths: ['events.sum', 'events.count', 'events.square'],
  expression: 'sqrt((b * c - a * a) / (b * (b - 1)))',
  response: 'events.sd'
)
```
