---
title: Memory
description: Learn in depth about the Memory data driver implementation.
nav_order: 3
---

# Memory (data driver)

Memory data driver keeps payload parts and artifacts in the current process. It implements the full contract — including multi-part reads — and exists for tests and development. Nothing survives a restart, and nothing is shared between processes.

```ruby
Trifle::Traces.configure do |config|
  config.data_driver = Trifle::Traces::Driver::Data::Memory.new
end
```

It is also the reference implementation: if you write a custom data driver, its behavior should match what Memory does under the shared contract specs (`spec/support/data_driver_contract.rb`).
