---
title: Memory
description: Learn in depth about the Memory index driver implementation.
nav_order: 2
---

# Memory (index driver)

Memory index driver keeps trace entries in the current process. It implements the full contract — including `find` and `search` with cursor pagination — and exists for tests and development. Nothing survives a restart, and nothing is shared between processes.

```ruby
Trifle::Traces.configure do |config|
  config.index_driver = Trifle::Traces::Driver::Index::Memory.new
end
```

It is also the reference implementation: if you write a custom index driver, its behavior should match what Memory does under the shared contract specs (`spec/support/index_driver_contract.rb`).

## Capabilities

`{ update: true, delete: true, search: true, ttl: :none }`
