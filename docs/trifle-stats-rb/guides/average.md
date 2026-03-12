---
title: Average
description: Learn how to keep track of your average.
nav_order: 1
---

# Average

This may sound bit un-intuitive, but `Trifle::Stats.track` method only increments whatever you tell it to increment. It doesn't keep track of how many times you've run it. If you want to keep track of duration, simply passing `{ duration: 3 }` will increment the duration by 3.

```ruby
irb(main):001:0> require 'redis'
=> true
irb(main):002:1* Trifle::Stats.configure do |config|
irb(main):003:1*   config.driver = Trifle::Stats::Driver::Redis.new(Redis.new)
irb(main):004:1*   config.track_ranges = [:hour]
irb(main):005:1*   config.time_zone = 'Europe/Bratislava'
irb(main):006:1*   config.beginning_of_week = :monday
irb(main):007:1*   config.designator = Trifle::Stats::Designator::Linear.new(min: 0, max: 100, step: 10)
irb(main):008:0> end
=>
#<Trifle::Stats::Configuration:0x0000ffff7ea49fd8
 @beginning_of_week=:monday,
 @designator=#<Trifle::Stats::Designator::Linear:0x0000ffff7ea48688 @max=100, @min=0, @step=10>,
 @driver=#<Trifle::Stats::Driver::Redis:0x0000ffff7ea48840 @client=#<Redis client v4.3.1 for redis://redis:6379/0>, @prefix="trfl", @separator="::">,
 @ranges=[:minute, :hour, :day, :week, :month, :quarter, :year],
 @time_zone="Europe/Bratislava",
 @track_ranges=[:hour]>
irb(main):009:0> Trifle::Stats.track(key: 'event::average::test_1', at: Time.now, values: { duration: 3 })
=> [{"duration"=>3}]
irb(main):010:0> Trifle::Stats.track(key: 'event::average::test_1', at: Time.now, values: { duration: 4 })
=> [{"duration"=>4}]
irb(main):011:0> Trifle::Stats.track(key: 'event::average::test_1', at: Time.now, values: { duration: 1 })
=> [{"duration"=>1}]
irb(main):012:0> Trifle::Stats.track(key: 'event::average::test_1', at: Time.now, values: { duration: 2 })
=> [{"duration"=>2}]

irb(main):013:0> Trifle::Stats.values(key: 'event::average::test_1', from: Time.now, to: Time.now, range: :hour)
=> {:at=>[2023-03-06 04:00:00 +0100], :values=>[{"duration"=>10}]}
```

As you can see in the above sample, all you get back is the `{"duration"=>10}` and that wont help you calculate average. To be able to calculate average duration, you will need to keep track of counter. It's up to you if you want to use `count`, `total` or any other attribute name. Just make sure you know what you've used so you can use it when retrieving data.

```ruby
irb(main):001:0> require 'redis'
=> true
irb(main):002:1* Trifle::Stats.configure do |config|
irb(main):003:1*   config.driver = Trifle::Stats::Driver::Redis.new(Redis.new)
irb(main):004:1*   config.track_ranges = [:hour]
irb(main):005:1*   config.time_zone = 'Europe/Bratislava'
irb(main):006:1*   config.beginning_of_week = :monday
irb(main):007:1*   config.designator = Trifle::Stats::Designator::Linear.new(min: 0, max: 100, step: 10)
irb(main):008:0> end
=>
#<Trifle::Stats::Configuration:0x0000ffff7ea49fd8
 @beginning_of_week=:monday,
 @designator=#<Trifle::Stats::Designator::Linear:0x0000ffff7ea48688 @max=100, @min=0, @step=10>,
 @driver=#<Trifle::Stats::Driver::Redis:0x0000ffff7ea48840 @client=#<Redis client v4.3.1 for redis://redis:6379/0>, @prefix="trfl", @separator="::">,
 @ranges=[:minute, :hour, :day, :week, :month, :quarter, :year],
 @time_zone="Europe/Bratislava",
 @track_ranges=[:hour]>
irb(main):009:0> Trifle::Stats.track(key: 'event::average::test_2', at: Time.now, values: { count: 1, duration: 2 })
=> [{"count"=>1, "duration"=>2}]
irb(main):010:0> Trifle::Stats.track(key: 'event::average::test_2', at: Time.now, values: { count: 1, duration: 3 })
=> [{"count"=>1, "duration"=>3}]
irb(main):011:0> Trifle::Stats.track(key: 'event::average::test_2', at: Time.now, values: { count: 1, duration: 8 })
=> [{"count"=>1, "duration"=>8}]
irb(main):012:0> Trifle::Stats.track(key: 'event::average::test_2', at: Time.now, values: { count: 1, duration: 2 })
=> [{"count"=>1, "duration"=>2}]
irb(main):013:0> Trifle::Stats.values(key: 'event::average::test_2', from: Time.now, to: Time.now, range: :hour)
=> {:at=>[2023-03-06 04:00:00 +0100], :values=>[{"count"=>4, "duration"=>15}]}
```

And from this point, all you need to do is to divide `duration` by `count` to get the average value.

## Expression transponder

Alternatively you can calculate average with the [expression transponder](../transponders).

```ruby
series.transpond.expression(
  paths: ['duration', 'count'],
  expression: 'a / b',
  response: 'average'
)
```
