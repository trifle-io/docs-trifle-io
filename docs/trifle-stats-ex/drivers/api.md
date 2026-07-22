---
title: API
description: Send Elixir metrics directly to a Trifle Cloud project.
nav_order: 1
---

# API driver

Use the API driver with a project token that has write permission and the project UUID.

```elixir
driver = Trifle.Stats.Driver.Api.new(
  System.fetch_env!("TRIFLE_TOKEN"),
  System.fetch_env!("TRIFLE_PROJECT_ID")
)

Trifle.Stats.configure(driver: driver)

Trifle.Stats.track("orders", DateTime.utc_now(), %{count: 1})
Trifle.Stats.assert("state::orders", DateTime.utc_now(), %{pending: 4})
```

The endpoint is fixed to `https://app.trifle.io/api/v1/metrics`. The calling process waits for each gzip-compressed request for up to 10 seconds; other BEAM processes continue normally. The API driver always bypasses the local buffer.

Values, Beam, and Scan return unsupported-operation errors. HTTP failures return `{:error, %Trifle.Stats.Driver.Api.Error{}}`, including status, bounded response body, `Retry-After`, and whether delivery is unknown.

:::callout warn "Retries"
There are no automatic retries. In particular, retrying Track after a timeout can double-count because the original request may already have committed.
:::
