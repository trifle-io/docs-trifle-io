---
title: Callbacks
description: Learn how to hook into the tracer lifecycle.
nav_order: 7
---

# Callbacks

Callbacks are notification hooks into the tracer lifecycle. Persistence is handled by [drivers](/trifle-traces/drivers) — use callbacks for side effects: emitting metrics, notifications, logging.

Each callback receives the tracer. Return values are ignored.

## Liftoff

Executed when a tracer is initialized, after the drivers created the trace entry.

## Bump

Executed every `bump_every` seconds while tracing, after the drivers flushed a payload part. Useful for live progress side effects.

## Wrapup

Executed when you call `tracer.wrapup`, after the drivers finalized the trace.

## Example: emit metrics on wrapup

```ruby
Trifle::Traces.configure do |config|
  config.on(:wrapup) do |tracer|
    next if tracer.ignore

    tracer.keys.each do |key|
      Trifle::Stats.track(
        key: "traces::#{key}",
        at: Time.now,
        values: { count: 1, state: { tracer.state => 1 } }
      )
    end
  end
end
```

`tracer.keys` splits the tracer key into cumulative prefixes (`jobs/invoice_charge` → `["jobs", "jobs/invoice_charge"]`), which pairs nicely with `Trifle::Stats` key hierarchies.

## What callbacks see

Inside callbacks you can access `tracer.key`, `tracer.meta`, `tracer.tags`, `tracer.state`, `tracer.reference`, `tracer.ignore` and `tracer.mode`.

:::callout note "Trace data is drained by drivers"
When drivers are configured, the dispatcher drains `tracer.data` into payload parts as the trace runs — callbacks should not rely on it. Read the persisted payload back with `Trifle::Traces.payload(record)` instead. Without configured drivers, `tracer.data` keeps accumulating and is yours to use.
:::

## Custom persistence

If the built-in drivers don't fit your storage, implement a custom driver rather than persisting in callbacks — you get the lifecycle handling, write modes, and error handling for free. See [Drivers](/trifle-traces/drivers#writing-your-own-driver).
