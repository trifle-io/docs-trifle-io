---
title: Tags and Artifacts
description: Learn how to tag and add attachments to tracer.
nav_order: 10
---

# Tags

Tags are simple strings stored on the tracer. They end up on the trace record, indexed for search.

```ruby
Trifle::Traces.tag("invoice:42")
Trifle::Traces.tag('billing')
```

## Searching by tags

```ruby
Trifle::Traces.search(tags: { any: ['invoice:42', 'invoice:43'] })
```

Use `any` when at least one tag must match, `all` when every tag must match, or
combine them:

```ruby
Trifle::Traces.search(
  tags: {
    any: ['invoice:42', 'invoice:43'],
    all: ['billing', 'failed']
  }
)
```

This means `(invoice:42 OR invoice:43) AND billing AND failed`. Empty groups
are ignored. Search accepts only the structured hash; `tags: 'invoice:42'` and
`tags: ['invoice:42']` are not supported.

# Artifacts

Artifacts are files attached to a trace. Each call adds a line with `type: :media` and queues the file for upload — the [data driver](/trifle-traces/drivers) stores it next to the trace payload on the next flush.

```ruby
file = '/tmp/screenshot.png'
Trifle::Traces.artifact(File.basename(file), file)
```

## Reading artifacts back

```ruby
record = Trifle::Traces.find(reference)
Trifle::Traces.read_artifact(record, 'screenshot.png')
```

## Oversized messages

Trace messages larger than `config.payload_size_limit` (default 100KB) are automatically offloaded as artifacts and replaced inline with a `type: :media` entry carrying the artifact name and original `size`. This keeps payload parts small while preserving the full output.
