---
title: Mongo
description: Learn in depth about the Mongo index driver implementation.
nav_order: 1
---

# Mongo (index driver)

Mongo index driver uses the `mongo` client gem to store one document per trace. It is built for high write volume: two compound search indexes plus a native TTL index handle retention without any cleanup jobs.

## Configuration

### `client (Mongo)`

First required argument is a client. You can configure it directly using the `mongo` gem:

```ruby
require 'mongo'

Trifle::Traces.configure do |config|
  config.index_driver = Trifle::Traces::Driver::Index::Mongo.new(
    Mongo::Client.new('mongodb://mongo:27017/traces')
  )
end
```

Or if you are using `mongoid`, you can reuse its client setup:

```ruby
Trifle::Traces.configure do |config|
  config.index_driver = Trifle::Traces::Driver::Index::Mongo.new(
    Mongoid.client(:default)
  )
end
```

### `collection_name: 'trifle_traces' (String)`

You can specify the collection name used to store trace documents:

```ruby
config.index_driver = Trifle::Traces::Driver::Index::Mongo.new(
  Mongoid.client(:default), collection_name: 'my_traces'
)
```

## Setup

Run once to create the indexes:

```ruby
Trifle::Traces::Driver::Index::Mongo.setup!(
  Mongo::Client.new('mongodb://mongo:27017/traces'),
  collection_name: 'trifle_traces'
)
```

This creates:

- `{segments: 1, state: 1, _id: -1}` — segment prefix search, newest-first
- `{tags: 1, state: 1, _id: -1}` — tag search, newest-first
- `{expires_at: 1}` with `expireAfterSeconds: 0` — TTL retention; MongoDB deletes expired documents itself

## Storage

Each trace is one document: `_id` (a `BSON::ObjectId`, which doubles as the trace reference), `key`, `segments` (materialized key-path prefixes), `tags`, `state`, `meta` (JSON string), `context` (your extracted fields), `length`, `parts`, `first_at`, `last_at`, `retention`, `expires_at` and `bucket_id`.

`search` maps directly onto the two compound indexes: `segments`/`tags` use `$in`, `state` matches exactly, results sort by `_id` descending and paginate with an `_id` cursor — no count queries.

## Capabilities

`{ update: true, delete: true, search: true, ttl: :native }` — supports both `:live` and `:deferred` tracers.
