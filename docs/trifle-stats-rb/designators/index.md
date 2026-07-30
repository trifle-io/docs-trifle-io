---
title: Designators
description: Learn how designators designate values into buckets.
nav_order: 7
---

# Designators

Designators are classes used to create buckets for histograms. You can either use one of the existing Designators or define your own Designator class and use it in Configuration. Every Designator needs to implement one method:

- `designate(value:)` returns bucket for a value.

Thats it. This returned bucket will be used in `assort` method to categorize values. In other words histogram. It is OK to use decimal points in bucket.

## Configuration

You can assign an instance of a designator in the `Trifle::Stats` configuration. Either use pre-defined designators, or your own.

```ruby
Trifle::Stats.configure do |config|
  # ...
  config.designator = Trifle::Stats::Designator::Linear.new(min: 0, max: 100, step: 10)
end
```
