---
title: Percentiles
description: Learn how to approximate percentiles from average and standard deviation.
nav_order: 2
---

# Percentiles

Average or mean can easily be biased by skewed distribution. Therefore knowing just whats the average may not always be enough. If you want to avoid displaying distribution, you may want to use 95th and/or 99th percentiles instead.

To approximate percentiles from summary data, you need standard deviation and a normal-distribution assumption.

:::callout warn "Approximation only"
This is a **normal approximation**, not an exact percentile calculation. It works best when your data is close to a normal distribution. For skewed data such as latency, duration, or revenue, `average + z * sd` can be materially off.
:::

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

Once you have average and standard deviation `sd`, you can approximate upper percentiles using the corresponding one-sided z-scores.

```ruby
p95 = average + sd * 1.645
p99 = average + sd * 2.326
```

These are the standard normal z-scores for the 95th and 99th percentiles:

- `P95 ≈ average + 1.645 * sd`
- `P99 ≈ average + 2.326 * sd`

And voila. Now you have average, 95th percentile as well as 99th percentile approximations.

## Expression transponder

You can derive standard deviation with the [expression transponder](../transponders), then derive percentile approximations the same way.

```ruby
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
```
