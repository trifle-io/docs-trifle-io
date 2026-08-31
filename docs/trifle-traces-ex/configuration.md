---
title: Configuration
description: Configure Trifle.Traces globally or for one tracer.
nav_order: 2
---

# Configuration

Configure defaults at application startup:

```elixir
Trifle.Traces.configure(
  index_driver: Trifle.Traces.Driver.Index.Memory.new(),
  data_driver: Trifle.Traces.Driver.Data.Memory.new(),
  bump_every: 15,
  default_mode: :live,
  payload_size_limit: 100 * 1024,
  context: %{},
  retention: 7
)
```

Or build an isolated configuration and pass it to one tracer:

```elixir
config = Trifle.Traces.Configuration.new(
  index_driver: index_driver,
  data_driver: data_driver,
  default_mode: :deferred
)

{:ok, tracer} = Trifle.Traces.start_tracer("jobs/import", config: config)
```

## Options

- `index_driver` stores searchable trace metadata. The default Null driver does
  not persist.
- `data_driver` stores payload parts and artifacts. The default Null driver
  does not persist.
- `serializer` serializes traced function results. The default is Inspect.
- `bump_every` is the minimum number of seconds between live flushes. Default:
  `15`.
- `default_mode` is `:live` or `:deferred`. Default: `:live`.
- `payload_size_limit` offloads larger messages into artifacts. Default: 100KB.
- `context` is a map or `fn tracer -> map end` stored on the index record.
- `retention` is a positive number of days or `fn tracer -> days end`. Default:
  `7`.
- `error_handler` receives `(error, tracer, phase)`.
- `on_liftoff`, `on_bump`, and `on_wrapup` accept one-argument callbacks.

Callbacks are notification hooks and their return values are ignored.
Persistence completes before the callback runs.

```elixir
Trifle.Traces.configure(
  context: fn tracer ->
    meta = tracer.meta || %{}
    %{tenant_id: meta[:tenant_id] || meta["tenant_id"]}
  end,
  retention: fn tracer -> if String.starts_with?(tracer.key, "audit/"), do: 90, else: 7 end,
  on_wrapup: fn tracer -> Metrics.trace_finished(tracer.key, tracer.state) end
)
```
