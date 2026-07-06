---
title: Getting Started
description: Learn how to start using Trifle::Traces.
nav_order: 3
---

# Getting Started

`Trifle::Traces` collects trace lines and persists them through two drivers: an index driver for searchable metadata and a data driver for the payload.

## 1) Configure drivers

```ruby
Trifle::Traces.configure do |config|
  config.index_driver = Trifle::Traces::Driver::Index::Mongo.new(
    Mongo::Client.new('mongodb://mongo:27017/traces')
  )
  config.data_driver = Trifle::Traces::Driver::Data::File.new(
    path: './storage/traces'
  )
end
```

Run the one-time setup for your index driver (creates indexes):

```ruby
Trifle::Traces::Driver::Index::Mongo.setup!(
  Mongo::Client.new('mongodb://mongo:27017/traces')
)
```

## 2) Create a tracer and trace code

```ruby
Trifle::Traces.tracer = Trifle::Traces::Tracer::Hash.new(
  key: 'jobs/invoice_charge',
  meta: [42]
)

Trifle::Traces.trace('Charging invoice', head: true)
result = Trifle::Traces.trace('Calling gateway') do
  { status: 'ok', took_ms: 123 }
end

Trifle::Traces.tracer.wrapup
```

The tracer gets its `reference` from the index driver at liftoff, payload parts flush to the data driver while the trace runs, and `wrapup` finalizes the entry.

## 3) Read it back

```ruby
record = Trifle::Traces.find(Trifle::Traces.tracer.reference)
record.state  #=> :success
record.key    #=> "jobs/invoice_charge"

entries = Trifle::Traces.payload(record)
entries.first[:message]  #=> "Tracer has been initialized for jobs/invoice_charge"
```

Each entry is a hash with these keys: `:at`, `:message`, `:state`, `:type`, `:level`.

## Next steps

- [Usage](/trifle-traces/usage)
- [Drivers](/trifle-traces/drivers)
- [Callbacks](/trifle-traces/callbacks)
- [State](/trifle-traces/state)
- [Tags and Artifacts](/trifle-traces/tags_and_artifacts)
