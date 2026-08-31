---
title: Ruby Interoperability
description: Share persisted traces between Ruby and Elixir.
nav_order: 8
---

# Ruby Interoperability

Trifle.Traces 2.0 and Trifle::Traces 2.0 share these contracts:

- Mongo field names, BSON dates, ObjectId references, segments, counters, and
  TTL fields.
- PostgreSQL columns, JSONB values, timestamps, search indexes, and text
  references.
- Structured `any`/`all` tag filtering and opaque cursor encoding.
- JSON payload entry fields and known state/type values.
- Numbered File and S3 parts, gzip encoding, and artifact paths.
- Retention prefixes and S3 bucket selection through `bucket_id`.

This allows a trace written by a Ruby service to be searched and opened by an
Elixir service, and vice versa.

Each release candidate records its paired counterpart revision. The release
gate writes and reads File payloads and PostgreSQL metadata in both directions,
and runs PostgreSQL, Mongo, and S3-compatible integration suites before the
coordinated final 2.0 tag.

Changes to the persisted shape require compatibility fixtures in both
repositories. Application-level API names remain idiomatic to each language;
the storage and behavioral contracts are the compatibility boundary.
