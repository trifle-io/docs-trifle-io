---
title: File and S3 Data
description: Store payload parts and artifacts locally or in object storage.
nav_order: 2
---

# File and S3 Data

## File

```elixir
driver = Trifle.Traces.Driver.Data.File.new(path: "/var/lib/trifle-traces", gzip: true)
Trifle.Traces.Driver.Data.File.setup!(path: "/var/lib/trifle-traces")
```

Schedule `Trifle.Traces.Driver.Data.File.cleanup!/1` to remove expired trace
directories according to their retention prefix.

## S3-compatible storage

```elixir
driver =
  Trifle.Traces.Driver.Data.S3.new(
    buckets: ["traces-a", "traces-b"],
    prefix: "traces",
    gzip: true,
    client: [region: "us-east-1"]
  )
```

The included adapter uses ExAws. Pass `adapter:` and `client:` to inject
another implementation of `Trifle.Traces.Driver.Data.S3Client`.

Configure retention lifecycle rules once:

```elixir
Trifle.Traces.Driver.Data.S3.setup!(
  buckets: ["traces-a", "traces-b"],
  retentions: [3, 7, 30, 90]
)
```

Both drivers use `retention/key/reference` directories. S3 inserts the
configured prefix after retention. Payload files are named `data_N.json` or
`data_N.json.gz`; artifacts live below `artifacts/`.
