---
title: Trifle App
description: Trifle is the companion app to your Stats.
nav_order: 1
svg: M9 17.25v1.007a3 3 0 0 1-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0 1 15 18.257V17.25m6-12V15a2.25 2.25 0 0 1-2.25 2.25H5.25A2.25 2.25 0 0 1 3 15V5.25m18 0A2.25 2.25 0 0 0 18.75 3H5.25A2.25 2.25 0 0 0 3 5.25m18 0V12a2.25 2.25 0 0 1-2.25 2.25H5.25A2.25 2.25 0 0 1 3 12V5.25
---

# Trifle App

Trifle App is the visual and automation layer for Trifle Stats. It lets you create dashboards, build monitors (alerts + scheduled reports), and expose metrics to the UI or an AI agent.

## Deployment modes

:::tabs
@tab SaaS
- Hosted at [app.trifle.io](https://app.trifle.io).
- Projects are enabled by default (API ingestion works out of the box).
- You manage data sources, dashboards, and tokens in the UI.

@tab Self-hosted
- You own the infrastructure and data plane.
- **Projects are disabled by default**, so only **Database sources** are available.
- To ingest metrics via API, enable projects and configure Mongo (see [Configuration](/trifle-app/deployment/configuration)).
:::

## Why?

Building charts is easy; aligning teams around data is not. Trifle App gives non-technical folks the power to explore metrics, build dashboards, and schedule reports without pulling engineers into every request. The data stays inside your own infrastructure, while the UI stays fast and friendly.

## What you get

- The Metrics API (read + write for project sources)
- Dashboards, monitors, and report delivery
- Integrations with Slack, Discord, Google SSO, and more
- Self-hosted deployment with Helm or a SaaS option
- Developer tooling: [CLI](/trifle-cli/) and [MCP server](/trifle-cli/mcp)

## Core concepts

- **Sources**: project sources can read/write; database sources are read-only.
- **Ingestion**: project metrics go through `/api/v1/metrics`; database metrics come from Trifle Stats writing to your DB.
- **Dashboards vs monitors**: dashboards are saved views; monitors schedule reports or fire alerts.

:::callout note "Self-hosted defaults"
- If you are self-hosting and don’t enable projects, the UI hides **Projects** and the API only supports database sources.
:::
