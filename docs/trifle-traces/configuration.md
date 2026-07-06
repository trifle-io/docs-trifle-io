---
title: Configuration
description: Learn how to configure Trifle::Traces for your Ruby application.
nav_order: 2
---

# Configuration

You can set a global configuration or build a configuration object for a specific tracer.

## Global configuration

```ruby
Trifle::Traces.configure do |config|
  config.index_driver = Trifle::Traces::Driver::Index::Mongo.new(
    Mongoid.client(:default), collection_name: 'trifle_traces'
  )
  config.data_driver = Trifle::Traces::Driver::Data::S3.new(
    client: s3_client, buckets: %w[traces-a traces-b], gzip: true
  )

  config.context = ->(tracer) { { tenant_id: tracer.meta&.first } }
  config.retention = ->(tracer) { tracer.key.start_with?('commodity/') ? 3 : 180 }
  config.bump_every = 10

  config.on(:wrapup) do |tracer|
    # side effects like metrics; persistence is handled by drivers
  end
end
```

### Available settings

- `index_driver` — where trace metadata lives; answers `find`/`search` (default: `Trifle::Traces::Driver::Index::Null`, which persists nothing). See [Drivers](/trifle-traces/drivers).
- `data_driver` — where the trace payload lives (default: `Trifle::Traces::Driver::Data::Null`).
- `context` — extra index fields extracted from the tracer, stored on the trace record. A hash, or anything responding to `call(tracer)` (default: `{}`).
- `retention` — retention in days. An integer, or anything responding to `call(tracer)` for per-trace resolution (default: `7`).
- `default_mode` — write mode for tracers that don't specify one, `:live` or `:deferred` (default: `:live`). See [Drivers](/trifle-traces/drivers#write-modes).
- `payload_size_limit` — messages larger than this many bytes are offloaded to artifacts and replaced inline with a `type: :media` entry (default: `102400`).
- `error_handler` — receives `(error, tracer, phase)` when persistence fails. The default raises for `:liftoff`/`:wrapup` and warns for `:bump` (bumped data is re-queued and retried on the next flush).
- `tracer_class` — class used by middleware to instantiate tracers (default: `Trifle::Traces::Tracer::Hash`).
- `serializer_class` — how block return values are serialized (default: `Trifle::Traces::Serializer::Inspect`).
- `bump_every` — seconds between flushes while tracing (default: `15`).
- `on(:liftoff|:bump|:wrapup)` — register [callbacks](/trifle-traces/callbacks) for side effects.

## Per-tracer configuration

If you want isolated behavior, pass a configuration object directly to a tracer.

```ruby
config = Trifle::Traces::Configuration.new
config.index_driver = Trifle::Traces::Driver::Index::Memory.new
config.data_driver = Trifle::Traces::Driver::Data::Memory.new

tracer = Trifle::Traces::Tracer::Hash.new(
  key: 'jobs/invoice_charge',
  config: config
)
```

## Serializer choice

See [Serializers](/trifle-traces/serializers) for built-in options and custom serializers.
