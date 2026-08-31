---
title: Usage
description: Trace messages, results, state, tags, and artifacts.
nav_order: 4
---

# Usage

## Lines and nested results

```elixir
Trifle.Traces.trace("Starting")
Trifle.Traces.trace("Validation", head: true)
Trifle.Traces.trace("Gateway timeout", state: :warning)

response =
  Trifle.Traces.trace("POST /payments", fn ->
    Gateway.create_payment(payload)
  end)
```

A function trace records an opening line, closing line, and serialized result.
Nested calls increase the `level` for the calling process. It returns the
original result unchanged.

## Trace state

```elixir
Trifle.Traces.warn()
Trifle.Traces.fail()
Trifle.Traces.success()
Trifle.Traces.ignore()
```

A running trace becomes successful automatically at wrapup. Ignored live
traces delete already-written data; ignored deferred traces never write.

## Tags and artifacts

```elixir
Trifle.Traces.tag("invoice:42")
Trifle.Traces.artifact("response.json", "/tmp/gateway-response.json")
```

Tags are searchable metadata. Artifacts retain the explicit public name even
when it differs from the source filename.

Messages over `payload_size_limit` are automatically stored as text artifacts
and replaced inline by a `:media` entry with the original byte size.

## Manual lifecycle

```elixir
{:ok, tracer} = Trifle.Traces.start_tracer("services/sync")

Trifle.Traces.trace("Started", tracer: tracer)
Trifle.Traces.tag("store:42", tracer: tracer)

snapshot = Trifle.Traces.wrapup(tracer: tracer)
```

`wrapup` returns the final immutable snapshot and terminates the supervised
tracer process.
