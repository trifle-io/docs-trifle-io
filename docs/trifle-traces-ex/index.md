---
title: Trifle.Traces
nav_order: 7
svg: M7.864 4.243A7.5 7.5 0 0119.5 10.5c0 2.92-.556 5.709-1.568 8.268M5.742 6.364A7.465 7.465 0 004.5 10.5a7.464 7.464 0 01-1.15 3.993m1.989 3.559A11.209 11.209 0 008.25 10.5a3.75 3.75 0 117.5 0c0 .527-.021 1.049-.064 1.565M12 10.5a14.94 14.94 0 01-3.6 9.75m6.633-4.596a18.666 18.666 0 01-2.485 5.33
lang: <path d="M64 3c15 19 32 37 32 61a32 32 0 11-64 0C32 40 49 22 64 3zm-7 45c-7 8-11 15-11 22a18 18 0 0036 0c0-7-5-14-12-22a7 7 0 01-13 0z"></path>
---

# Trifle.Traces

`Trifle.Traces` is the Elixir implementation of structured execution tracing.
It captures the complete flow of a request, job, or integration and can persist
the searchable metadata separately from the larger trace payload.

It is data-compatible with [Trifle::Traces for Ruby](/trifle-traces): both
implementations can share Mongo index records and File or S3 payloads.

## What it does

- Records messages, nested function results, state, tags, and file artifacts.
- Uses one supervised tracer process per execution.
- Supports explicit propagation into concurrent Tasks.
- Persists continuously in `:live` mode or once at wrapup in `:deferred` mode.
- Finds and searches traces without loading their payloads.
- Integrates with Phoenix, generic Plug endpoints, and Oban.

## Quick example

```elixir
Trifle.Traces.with_tracer("jobs/orders/sync", fn ->
  Trifle.Traces.tag("store:42")

  orders =
    Trifle.Traces.trace("Fetching orders", fn ->
      Orders.fetch_all()
    end)

  Trifle.Traces.trace("Fetched #{length(orders)} orders")
end)
```

## Next steps

- [Installation](/trifle-traces-ex/installation)
- [Configuration](/trifle-traces-ex/configuration)
- [Getting Started](/trifle-traces-ex/getting_started)
- [Usage](/trifle-traces-ex/usage)
- [Processes and Tasks](/trifle-traces-ex/processes_and_tasks)
- [Drivers](/trifle-traces-ex/drivers)
- [Integrations](/trifle-traces-ex/integrations)
- [Ruby interoperability](/trifle-traces-ex/interoperability)
