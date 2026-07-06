---
title: Null
description: Learn in depth about the Null index driver implementation.
nav_order: 3
---

# Null (index driver)

Null index driver is the default when no index driver is configured. It still generates valid trace references (so `tracer.reference` always works) but persists nothing — `find` returns `nil` and `search` returns no traces.

With the Null driver in place the tracer behaves like a pure in-memory collector: data accumulates on `tracer.data` and your [callbacks](/trifle-traces/callbacks) can do whatever they want with it.

```ruby
# explicit, equivalent to not configuring an index driver at all
Trifle::Traces.configure do |config|
  config.index_driver = Trifle::Traces::Driver::Index::Null.new
end
```

## Capabilities

`{ update: true, delete: true, search: false, ttl: :none }`
