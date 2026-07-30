---
title: Get values
description: Learn how to retrieve values.
nav_order: 100
---

# Get values

`values/5` retrieves time-series values for a given granularity.

The inclusive read axis is generated with the same [Nocturnal bucketing rules](/trifle-stats-ex/nocturnal) used when values are written.

:::signature Trifle.Stats.values
key | String | required |  | Metric key.
from | DateTime | required |  | Start timestamp.
to | DateTime | required |  | End timestamp.
granularity | String | required |  | Granularity string (e.g., `"1h"`, `"1d"`).
config | Trifle.Stats.Configuration | optional | `nil` | Overrides global config.
:::

## Examples

```elixir
now = DateTime.utc_now()
from = DateTime.add(now, -24, :hour)

Trifle.Stats.values("event::logs", from, now, "1h")
```

### Skip empty buckets

`values/5` accepts `skip_blanks: true` as an extra option.

```elixir
Trifle.Stats.values("event::logs", from, now, "1h", nil, skip_blanks: true)
```
