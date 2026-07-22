---
title: API
description: Send Go metrics directly to a Trifle Cloud project.
nav_order: 1
---

# API driver

Use the API driver with a project token that has write permission and the project UUID.

```go
driver, err := triflestats.NewAPIDriver(
    os.Getenv("TRIFLE_TOKEN"),
    os.Getenv("TRIFLE_PROJECT_ID"),
)
if err != nil {
    log.Fatal(err)
}

cfg := triflestats.DefaultConfig()
cfg.Driver = driver

err = triflestats.Track(ctx, cfg, "orders", time.Now(), map[string]any{"count": 1})
err = triflestats.Assert(ctx, cfg, "state::orders", time.Now(), map[string]any{"pending": 4})
```

The endpoint is fixed to `https://app.trifle.io/api/v1/metrics`. Each call blocks its calling goroutine while one gzip-compressed request runs, with a default 10-second timeout. The driver bypasses the local buffer regardless of `BufferEnabled`.

Values, Beam, and Scan return `UnsupportedAPIOperationError`. Failed writes return `APIError`, which exposes `StatusCode`, `ResponseBody`, `RetryAfter`, and `DeliveryUnknown`. `WithAPIHTTPClient` can inject a transport without changing the endpoint.

:::callout warn "Retries"
The driver never retries automatically. A timed-out Track request may already have committed, so blindly retrying can double-count.
:::
