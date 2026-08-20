---
title: Ruby Case Studies
description: See how Ruby teams use Trifle::Stats to monitor high-volume background work and business operations.
nav_order: 91
---

# Ruby Case Studies

These production stories show how Ruby teams use `Trifle::Stats` to turn application events into operational signals. The examples cover metric design, useful aggregation windows, and the dashboards built on top of the resulting series.

## DropBot: monitoring product calculations

DropBot uses `Trifle::Stats` to observe source-data refreshes, queue events, and the product calculations they trigger. Hourly and daily series make spikes and long-term data-quality changes visible across tens of millions of calculations.

[Read the DropBot case study](./case_studies/dropbot)

If your Ruby application uses Trifle and you want to share what you built, [join the Trifle Discord](https://discord.gg/8rfPvNKVnf).
