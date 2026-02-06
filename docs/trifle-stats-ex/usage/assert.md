---
title: Assert values
description: Learn how to set values.
nav_order: 2
---

# Assert values

`assert/4` (or `assert/5` with options) sets values instead of incrementing them.

:::signature Trifle.Stats.assert
key | String | required |  | Metric key (e.g., `"event::logs"`).
at | DateTime | required |  | Timestamp of the sample.
values | map | required |  | Nested maps allowed, all leaf values must be numeric.
config | Trifle.Stats.Configuration | optional | `nil` | Overrides global config.
opts | keyword | optional | `[]` | Supports `untracked: true` to use `__untracked__` for system tracking.
:::

## Examples

```elixir
Trifle.Stats.assert("event::logs", DateTime.utc_now(), %{count: 1, duration: 2})
Trifle.Stats.assert("event::logs", DateTime.utc_now(), %{count: 2, duration: 9})
```

```elixir
Trifle.Stats.assert("event::logs", DateTime.utc_now(), %{count: 1}, untracked: true)
```

## Verify values

```elixir
now = DateTime.utc_now()
Trifle.Stats.values("event::logs", now, now, "1d")
```
