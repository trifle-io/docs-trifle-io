---
title: Null
description: Learn in depth about the Null data driver implementation.
nav_order: 4
---

# Null (data driver)

Null data driver is the default when no data driver is configured. It discards payload writes and returns empty reads — useful for index-only setups where you want searchable trace metadata without storing the payload.

```ruby
Trifle::Traces.configure do |config|
  config.index_driver = Trifle::Traces::Driver::Index::Mongo.new(mongo_client)
  # no data_driver: payloads are discarded, metadata is still searchable
end
```
