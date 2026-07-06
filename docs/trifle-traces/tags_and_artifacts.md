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
Trifle::Traces.search(tags: ['invoice:42'])
```

Tags use any-match: a trace matches when it carries at least one of the given tags.

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
