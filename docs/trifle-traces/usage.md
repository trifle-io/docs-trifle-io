---
title: Usage
description: Learn how to use Trifle::Traces DSL.
nav_order: 4
---

# Usage

`Trifle::Traces` exposes module-level helpers that delegate to the current tracer stored in `Thread.current`.

## 1) Create a tracer

```ruby
Trifle::Traces.tracer = Trifle::Traces::Tracer::Hash.new(
  key: 'jobs/invoice_charge',
  meta: [42]
)
```

:::callout note "Thread-local storage"
`Trifle::Traces.tracer` lives in `Thread.current`, so each thread must set its own tracer.
:::

The tracer accepts an optional `mode:` (`:live` or `:deferred`, defaults to `config.default_mode`) controlling how it persists — see [Drivers](/trifle-traces/drivers#write-modes) — and a `reference:` if you want to supply your own instead of the driver-generated one.

## 2) Trace lines

### Simple line

```ruby
Trifle::Traces.trace('Started processing')
```

### Head line

Use `head: true` to mark a header line (`type: :head`).

```ruby
Trifle::Traces.trace('Charging invoice', head: true)
```

### Line with custom state

```ruby
Trifle::Traces.trace('Gateway timeout', state: :error)
```

### Trace a block

When you pass a block, Trifle::Traces records the block result on its own line.

```ruby
response = Trifle::Traces.trace('Calling gateway') do
  { status: 'ok', took_ms: 123 }
end
```

## 3) Tags and artifacts

```ruby
Trifle::Traces.tag('invoice:42')
Trifle::Traces.artifact('screenshot.png', '/tmp/screenshot.png')
```

## 4) Finish the trace

```ruby
Trifle::Traces.tracer.wrapup
```

## 5) Read traces back

With an index driver configured, look up a single trace by reference:

```ruby
record = Trifle::Traces.find(reference)
record.key        #=> "jobs/invoice_charge"
record.state      #=> :success
record.tags       #=> ["invoice:42"]
record.duration   #=> 5321 (integer milliseconds)
record.counters   #=> {
                  #     states: { success: 8, warning: 1, error: 0, debug: 2 },
                  #     types: { text: 7, head: 1, raw: 2, media: 1 },
                  #     max_level: 2
                  #   }
record.parts      #=> 2
```

Or search by key-path segment, tags, state, start time and minimum duration:

```ruby
result = Trifle::Traces.search(
  segment: 'jobs',
  tags: {
    any: ['invoice:42', 'invoice:43'],
    all: ['billing']
  },
  state: :error,
  from: Time.utc(2026, 8, 30),
  to: Time.utc(2026, 8, 31),
  duration_min: 5_000,
  limit: 50,
  cursor: nil # pass result[:cursor] to fetch the next page
)
result[:traces]  #=> [TraceRecord, ...]
result[:cursor]  #=> opaque cursor or nil on the last page
```

All supplied filters are combined. `segment` matches one of the materialized
key prefixes, so `'jobs'` matches `jobs/invoice_charge` without a regular
expression. Tag groups mean `(invoice:42 OR invoice:43) AND billing`; empty
groups are ignored. Scalar and array tag shorthand are not supported.

Time filtering selects traces that started in the half-open interval
`first_at >= from` and `first_at < to`. `duration_min` is inclusive and uses
milliseconds. Results sort by `first_at` descending and then reference
descending, making the opaque cursor deterministic even when traces share a
start timestamp.

Load the payload and artifacts through the data driver:

```ruby
entries = Trifle::Traces.payload(record)             # all parts, in order
Trifle::Traces.read_artifact(record, 'screenshot.png')
```

## Example output shape

Each entry looks like:

```ruby
{
  at: 1700000000,
  message: "Charging invoice",
  state: :success,
  type: :text,
  level: 0
}
```
