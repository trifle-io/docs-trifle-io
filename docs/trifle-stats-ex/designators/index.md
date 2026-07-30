---
title: Designators
description: Learn how to classify values into buckets.
nav_order: 7
---

# Designators

Designators classify numeric values into buckets. Use them to convert raw values into stable, comparable labels before calling `track/4` or `assert/4`.

## Available designators

- [Custom](/trifle-stats-ex/designators/custom)
- [Linear](/trifle-stats-ex/designators/linear)
- [Geometric](/trifle-stats-ex/designators/geometric)

## Example

```elixir
linear = Trifle.Stats.Designator.Linear.new(0, 100, 10)
bucket = Trifle.Stats.Designator.Linear.designate(linear, 37)

Trifle.Stats.track("latency", DateTime.utc_now(), %{bucket => 1})
```
