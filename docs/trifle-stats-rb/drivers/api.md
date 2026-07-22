---
title: API
description: Send Ruby metrics directly to a Trifle Cloud project.
nav_order: 1
---

# API driver

Use the API driver when Trifle hosts the project and its metric storage. Create a project token with write permission and copy the project UUID.

```ruby
Trifle::Stats.configure do |config|
  config.driver = Trifle::Stats::Driver::Api.new(
    token: ENV.fetch('TRIFLE_TOKEN'),
    project_id: ENV.fetch('TRIFLE_PROJECT_ID')
  )
end

Trifle::Stats.track(key: 'orders', at: Time.now, values: { count: 1 })
Trifle::Stats.assert(key: 'state::orders', at: Time.now, values: { pending: 4 })
```

The endpoint is fixed to `https://app.trifle.io/api/v1/metrics`. Track and Assert are synchronous, gzip-compressed HTTP requests with a 10-second timeout. The driver always bypasses the local buffer, even when `buffer_enabled` is true.

Values, Beam, and Scan are not supported in this first version. HTTP and transport failures raise `Trifle::Stats::Driver::Api::Error`; inspect `status`, `response_body`, and `retry_after`. A timeout has `delivery_unknown: true` because the write may already have committed.

:::callout warn "Retries"
The driver does not retry, including on `429` or `503`. Retrying Track without server-side idempotency can double-count. Apply application-specific backoff only when that risk is acceptable.
:::
