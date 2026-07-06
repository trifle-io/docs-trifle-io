---
title: State
description: Learn how to trace state of a log.
nav_order: 6
---

# State

Each trace line can have its own `state`, and the tracer itself has a **global** state.

## Line state

```ruby
Trifle::Traces.trace('Gateway timeout', state: :error)
```

## Trace state

Use these helpers to set the overall trace state:

- `Trifle::Traces.fail!` → sets tracer state to `:error`
- `Trifle::Traces.warn!` → sets tracer state to `:warning`
- `Trifle::Traces.tracer.success!` → sets tracer state to `:success`

```ruby
Trifle::Traces.tracer = Trifle::Traces::Tracer::Hash.new(key: 'jobs/invoice_charge')
Trifle::Traces.trace('Started')
Trifle::Traces.fail!
Trifle::Traces.tracer.wrapup
```

The tracer state is stored on the trace record, so you can [search](/trifle-traces/usage#5-read-traces-back) by it: `Trifle::Traces.search(state: :error)`.

## Ignore

If a trace isn't worth persisting, mark it as ignored.

```ruby
Trifle::Traces.ignore!
```

Drivers handle ignored traces at `wrapup`: a `:live` tracer's already-written index entry and payload are deleted, a `:deferred` tracer simply never writes. If you use callbacks for side effects, skip ignored traces yourself:

```ruby
config.on(:wrapup) do |tracer|
  next if tracer.ignore
  # emit metrics, notify, ...
end
```
