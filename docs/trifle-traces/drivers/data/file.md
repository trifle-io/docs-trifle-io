---
title: File
description: Learn in depth about the File data driver implementation.
nav_order: 2
---

# File (data driver)

File data driver stores trace payloads on the local filesystem. Good fit for single-server apps and development — no external storage needed.

## Configuration

### `path: (String)`

Root directory for payloads:

```ruby
Trifle::Traces.configure do |config|
  config.data_driver = Trifle::Traces::Driver::Data::File.new(
    path: Rails.root.join('storage', 'traces').to_s
  )
end
```

### `gzip: false (Boolean)`

When enabled, payload parts are gzip-compressed (`data_1.json.gz`).

## Storage layout

Same layout as the S3 driver, under `path`:

```
<path>/<retention>/<key>/<reference>/data_<part>.json[.gz]
<path>/<retention>/<key>/<reference>/artifacts/<name>
```

## Setup

```ruby
Trifle::Traces::Driver::Data::File.setup!(path: '/var/traces')
```

## Cleanup

The filesystem has no lifecycle rules, so the driver ships a `cleanup!` method that removes trace directories older than their retention class (the retention days are encoded as the top-level directory name). Run it periodically, e.g. from cron:

```ruby
Trifle::Traces.default.data_driver.cleanup!
```
