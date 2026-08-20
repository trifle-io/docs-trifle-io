---
title: Elixir Case Studies
description: Learn how Elixir and Phoenix applications use Trifle.Stats for lightweight operational metrics.
nav_order: 91
---

# Elixir Case Studies

`Trifle.Stats` brings hierarchical time-series metrics to BEAM applications without requiring a separate analytics pipeline. It fits Phoenix request metrics, Oban job throughput, ingestion pipelines, and other workloads where counters and nested values need to be aggregated as events happen.

## From the field

The original Elixir port was built while instrumenting a Phoenix application. The implementation began with tracking, assertions, values, the Mongo driver, and the same time-bucket model used by the Ruby library.

[Read why Trifle.Stats was ported to Elixir](https://trifle.io/blog/2023-06-15-trifle-stats-elixir)

If your Elixir application uses Trifle and you want to share what you built, [join the Trifle Discord](https://discord.gg/8rfPvNKVnf).
