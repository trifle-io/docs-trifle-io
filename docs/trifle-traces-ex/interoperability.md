---
title: Ruby Interoperability
description: Share persisted traces between Ruby and Elixir.
nav_order: 8
---

# Ruby Interoperability

Trifle.Traces 2.0 and Trifle::Traces 2.0 share these contracts:

- Mongo field names, BSON dates, ObjectId references, segments, counters, and
  TTL fields.
- Structured `any`/`all` tag filtering and opaque cursor encoding.
- JSON payload entry fields and known state/type values.
- Numbered File and S3 parts, gzip encoding, and artifact paths.
- Retention prefixes and S3 bucket selection through `bucket_id`.

This allows a trace written by a Ruby service to be searched and opened by an
Elixir service, and vice versa.

Each release candidate records its paired counterpart revision. The release
gate writes and reads File payloads in both languages and runs Mongo and
S3-compatible driver integration suites before the coordinated final 2.0 tag.

Changes to the persisted shape require compatibility fixtures in both
repositories. Application-level API names remain idiomatic to each language;
the storage and behavioral contracts are the compatibility boundary.
