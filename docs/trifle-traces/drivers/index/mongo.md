---
title: Mongo
description: Learn in depth about the Mongo index driver implementation.
nav_order: 2
---

# Mongo (index driver)

Mongo index driver uses the `mongo` client gem to store one document per trace. It is built for high write volume: dedicated compound indexes serve the supported search anchors, and a native TTL index handles retention without cleanup jobs.

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

- `{segments: 1, first_at: -1, _id: -1}` — materialized segment prefix search
- `{tags: 1, first_at: -1, _id: -1}` — tag `any` / `all` search
- `{state: 1, first_at: -1, _id: -1}` — exact state search
- `{first_at: -1, _id: -1}` — unanchored newest-first and start-time range search
- `{duration: 1, first_at: -1, _id: -1}` — minimum-duration search
- `{expires_at: 1}` with `expireAfterSeconds: 0` — TTL retention; MongoDB deletes expired documents itself

MongoDB also creates its standard `{_id: 1}` index. That standalone index is
not a replacement for the `_id` suffixes above: `first_at` is the authoritative
start timestamp and range field, while `_id` uniquely orders traces that share
the same `first_at`. BSON ObjectIds are only approximately chronological, and
custom references need not be chronological at all.

`segments` and `tags` remain separate index families because both fields are
arrays. `segments` stores cumulative paths, so searching for `jobs/import` is
an indexed equality match rather than a regular expression.

## Storage

Each trace is one document: `_id` (normally a `BSON::ObjectId`, which doubles as the trace reference), `key`, `segments` (materialized key-path prefixes), `tags`, `state`, `meta` (JSON string), `context`, `duration`, `counters`, `length`, `parts`, `first_at`, `last_at`, `retention`, `expires_at` and `bucket_id`.

`search` uses exact array-element equality for `segments`, `$in` / `$all` for
tag groups, exact state, `$gte` / `$lt` for `first_at`, and `$gte` for
`duration`. Results sort by `first_at` descending and `_id` descending. The
opaque cursor carries both values for stable pagination; search does not run a
count query.

## Capabilities

`{ update: true, delete: true, search: true, ttl: :native }` — supports both `:live` and `:deferred` tracers.
