---
title: Getting Started
description: Capture and inspect a first Elixir trace.
nav_order: 3
---

# Getting Started

Start without persistence. The final callback receives the completed tracer
snapshot:

```elixir
parent = self()

config =
  Trifle.Traces.Configuration.new(
    on_wrapup: fn tracer -> send(parent, {:trace, tracer}) end
  )

Trifle.Traces.with_tracer("jobs/invoices/charge", [config: config], fn ->
  Trifle.Traces.tag("invoice:42")
  Trifle.Traces.trace("Validating invoice", head: true)

  charge =
    Trifle.Traces.trace("Calling payment gateway", fn ->
      Gateway.charge(42)
    end)

  Trifle.Traces.trace("Gateway accepted charge #{charge.id}")
end)

receive do
  {:trace, tracer} -> IO.inspect(tracer.data)
end
```

`with_tracer/3` always restores any previous tracer. If the function raises or
exits, it records the error, marks the trace failed, wraps up, and re-raises the
original failure with its stacktrace.

To retain traces beyond the callback, configure an [index and data
driver](/trifle-traces-ex/drivers).
