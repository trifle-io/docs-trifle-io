---
title: Data Drivers
description: Learn how data drivers store trace payloads and artifacts.
nav_order: 2
---

# Data Drivers

A data driver stores the trace payload — the actual trace lines — as numbered parts, plus named artifacts. It is the backend behind `Trifle::Traces.payload` and `Trifle::Traces.read_artifact`.

## Available drivers

- [S3](/trifle-traces/drivers/data/s3) — any S3-compatible object storage, multi-bucket sharding, gzip.
- [File](/trifle-traces/drivers/data/file) — local filesystem.
- [Memory](/trifle-traces/drivers/data/memory) — in-process, for tests and development.
- [Null](/trifle-traces/drivers/data/null) — discards payloads (the default).

## Feature parity

| Driver | gzip | sharding | retention |
|--------|------|----------|-----------|
| S3     | YES  | YES (buckets) | bucket lifecycle rules |
| File   | YES  | NO       | `cleanup!` for cron |
| Memory | NO   | NO       | none |
| Null   | n/a  | n/a      | n/a |

## Parts and artifacts

A trace payload accumulates as **parts**: in `:live` mode each flush (liftoff, every bump, wrapup) writes the next numbered part; in `:deferred` mode the whole trace is a single part. `record.parts` tracks the count, and `Trifle::Traces.payload(record)` concatenates them back in order.

**Artifacts** are named files stored next to the parts — files you attach with `Trifle::Traces.artifact(name, path)`, and trace messages larger than `config.payload_size_limit`, which are offloaded automatically and replaced inline with a `type: :media` entry.

## Storage layout

File-based drivers (S3, File) share one layout:

```
<retention>/<prefix>/<key>/<reference>/data_<part>.json[.gz]
<retention>/<prefix>/<key>/<reference>/artifacts/<name>
```

Retention days come first so payload expiry is one lifecycle rule (or one cleanup sweep) per retention class — never per tenant or namespace.

## The contract

A data driver is duck-typed and implements:

- `generate_bucket_id` — returns an `Integer` shard id, chosen once per trace at liftoff and stored as `record.bucket_id`.
- `write_part(record, part:, entries:)` — persist an array of trace entries. Must raise on failure — the dispatcher re-queues entries and retries on the next flush.
- `write_artifact(record, name:, payload: nil, path: nil)` — store an inline payload or a file from disk; returns the stored name.
- `read_part(record, part:)` — return the entries of one part (symbol keys).
- `read(record)` — return all parts concatenated, in order.
- `read_artifact(record, name:)` — return the artifact body.
- `delete(record)` — best-effort purge (used by `ignore!`).
- `self.setup!(...)` — create directories or lifecycle rules; run once.

See `lib/trifle/traces/driver/README.md` in the gem for the full contract and run the shared contract specs (`spec/support/data_driver_contract.rb`) against your implementation.
