---
title: Trifle CLI
description: Command line interface for Trifle App and local metrics drivers.
nav_order: 2
svg: m6.75 7.5 3 2.25-3 2.25m4.5 0h3m-9 8.25h13.5A2.25 2.25 0 0 0 21 18V6a2.25 2.25 0 0 0-2.25-2.25H5.25A2.25 2.25 0 0 0 3 6v12a2.25 2.25 0 0 0 2.25 2.25Z
---

# Trifle CLI

The Trifle CLI lets you query and push metrics over the Trifle App API or local drivers (`sqlite`, `postgres`, `mysql`, `redis`, `mongo`). It also ships an MCP server mode for AI agents.

## Quick links

- [Installation](/trifle-cli/installation)
- [Configuration](/trifle-cli/configuration)
- [Usage](/trifle-cli/usage)
- [MCP server](/trifle-cli/mcp)
- [Changelog](/trifle-cli/changelog)

## Example

```sh
trifle metrics get \
  --key event::signup \
  --from 2026-01-24T00:00:00Z \
  --to 2026-01-25T00:00:00Z \
  --granularity 1h
```
