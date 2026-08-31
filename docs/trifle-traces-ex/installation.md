---
title: Installation
description: Install the Trifle.Traces release candidate in an Elixir application.
nav_order: 1
---

# Installation

`Trifle.Traces` 2.0 is currently distributed as a Git release candidate, not a
Hex package:

```elixir
def deps do
  [
    {:trifle_traces,
     github: "trifle-io/trifle_traces",
     tag: "v2.0.0-rc.1"}
  ]
end
```

Then run:

```sh
$ mix deps.get
```

The core requires Elixir 1.15 or newer. Its mandatory runtime dependencies are
`jason` for persisted payloads and `telemetry` for lifecycle integrations.

## Optional dependencies

Add only what your application uses:

```elixir
{:mongodb_driver, "~> 1.2.0"} # Mongo index
{:ex_aws, "~> 2.5"}           # S3 data
{:ex_aws_s3, "~> 2.5"}
{:hackney, "~> 4.0"}
{:sweet_xml, "~> 0.7"}
{:plug, "~> 1.14"}            # Plug/Phoenix
{:oban, "~> 2.17"}            # Oban
```

Driver clients are supplied by your application. Installing the library does
not connect to databases, create Mongo indexes, create buckets, or alter S3
lifecycle rules.
