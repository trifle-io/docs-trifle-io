---
title: Serializers
description: Learn how to serialize blocks in Trifle::Traces.
nav_order: 9
---

# Serializers

Serializers control how block return values are stored in trace output. A serializer must implement:

```ruby
def sanitize(payload)
  payload.to_s
end
```

## Configure a serializer

```ruby
Trifle::Traces.configure do |config|
  config.serializer_class = Trifle::Traces::Serializer::Json
end
```

## Built-in serializers

- **Inspect** — uses `payload.inspect` (default)
- **String** — uses `payload.to_s`
- **Json** — uses `payload.to_json`

## Custom serializer example

```ruby
class LengthSerializer
  def sanitize(payload)
    payload.to_s.length
  end
end

Trifle::Traces.configure do |config|
  config.serializer_class = LengthSerializer
end
```
