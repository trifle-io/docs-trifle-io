---
title: Designators
description: Learn how to classify values into buckets.
nav_order: 7
---

# Designators

Designators classify numeric values into buckets. Use them to convert raw values into stable, comparable labels before calling `Track` or `Assert`.

## Available designators

- [Custom](/trifle-stats-go/designators/custom)
- [Linear](/trifle-stats-go/designators/linear)
- [Geometric](/trifle-stats-go/designators/geometric)

## Example

```go
linear := TrifleStats.NewLinearDesignator(0, 100, 10)
bucket := linear.Designate(37)

_ = TrifleStats.Track(cfg, "latency", time.Now().UTC(), map[string]any{bucket: 1})
```
