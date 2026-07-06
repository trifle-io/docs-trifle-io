---
title: Middleware
description: Learn how to integrate Trifle::Traces into your application automatically.
nav_order: 8
---

# Middleware

Middleware creates tracers for you and wraps execution so you don’t have to manually set `Trifle::Traces.tracer` each time.

Available integrations:
- [Sidekiq](/trifle-traces/middleware/sidekiq)
- [Rails controllers](/trifle-traces/middleware/rails)
- [Rack (WIP)](/trifle-traces/middleware/rack)

## What middleware does (conceptually)

```ruby
def traced(&block)
  Trifle::Traces.tracer = Trifle::Traces.default.tracer_class.new(key: trace_key)
  yield
rescue => e
  Trifle::Traces.tracer&.trace("Exception: #{e}", state: :error)
  Trifle::Traces.tracer&.fail!
  raise e
ensure
  Trifle::Traces.tracer&.wrapup
end
```
