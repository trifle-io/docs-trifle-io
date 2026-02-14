---
title: MCP Server
description: Run Trifle CLI in MCP mode for AI agents.
nav_order: 4
---

# MCP Server

The Trifle CLI ships an MCP server mode that exposes your Trifle App data to AI agents over stdio JSON-RPC.

:::callout note "Protocol"
- MCP protocol version: `2024-11-05`.
:::

## Run the server

:::tabs
@tab SaaS
```sh
TRIFLE_URL=https://app.trifle.io TRIFLE_TOKEN=<TOKEN> trifle mcp
```

@tab Self-hosted
```sh
TRIFLE_URL=https://<your-host> TRIFLE_TOKEN=<TOKEN> trifle mcp
```
:::

:::callout warn "Token required"
- MCP mode does **not** prompt for a token.
- Pass `--token` or set `TRIFLE_TOKEN`.
:::

:::callout warn "URL scheme matters"
- If you omit the scheme, the CLI assumes `http://`.
- Use `https://` for SaaS and most self-hosted deployments.
:::

## Configuration

MCP uses the same configuration as the CLI:

:::signature Common flags
--config | String | optional |  | YAML config path.
--source | String | optional |  | Source name from the config file.
--url | String | optional |  | Trifle base URL (fallback: `TRIFLE_URL`).
--token | String | optional |  | API token (fallback: `TRIFLE_TOKEN`).
--timeout | Duration | optional | `30s` | HTTP timeout.
:::

:::callout note "Local sources"
- MCP can use local drivers when your config source uses `driver: sqlite`, `postgres`, `mysql`, `redis`, or `mongo`.
- Transponder tools/resources are only available for API sources.
:::

## MCP Server Configuration

### Claude Desktop Setup

```json
{
  "mcpServers": {
    "trifle": {
      "command": "trifle",
      "args": ["mcp"],
      "env": {
        "TRIFLE_URL": "http://localhost:3000",
        "TRIFLE_TOKEN": "<TOKEN>"
      }
    }
  }
}
```

## Agent MCP config snippets

Use these examples to register the Trifle MCP server in popular clients.

:::tabs
@tab Claude Desktop
Path: use **Settings → Developer → Edit Config** to open the file.

```json
{
  "mcpServers": {
    "trifle": {
      "command": "trifle",
      "args": ["mcp"],
      "env": {
        "TRIFLE_URL": "https://app.trifle.io",
        "TRIFLE_TOKEN": "<TOKEN>"
      }
    }
  }
}
```

@tab Cursor
File: `~/.cursor/mcp.json` (global) or `.cursor/mcp.json` (per project).

```json
{
  "mcpServers": {
    "trifle": {
      "command": "trifle",
      "args": ["mcp"],
      "env": {
        "TRIFLE_URL": "https://app.trifle.io",
        "TRIFLE_TOKEN": "<TOKEN>"
      }
    }
  }
}
```

@tab Cline (VS Code)
File: `cline_mcp_settings.json` (open via **Cline → MCP Servers → Configure → Configure MCP Servers**).

```json
{
  "mcpServers": {
    "trifle": {
      "command": "trifle",
      "args": ["mcp"],
      "env": {
        "TRIFLE_URL": "https://app.trifle.io",
        "TRIFLE_TOKEN": "<TOKEN>"
      },
      "disabled": false
    }
  }
}
```

@tab Continue
File: `.continue/mcpServers/mcp.json` in your workspace.

```json
{
  "mcpServers": {
    "trifle": {
      "command": "trifle",
      "args": ["mcp"],
      "env": {
        "TRIFLE_URL": "https://app.trifle.io",
        "TRIFLE_TOKEN": "<TOKEN>"
      }
    }
  }
}
```
:::

:::callout note "Agent mode required"
- Some clients only enable MCP tools in **agent mode** (e.g. Continue, Cursor).
:::

:::callout note "Binary path"
- If `trifle` is not on your PATH, replace `command` with the absolute path (e.g. `/usr/local/bin/trifle`).
- On Windows, use `trifle.exe` or a full path like `C:\\path\\to\\trifle.exe`.
:::

## Available MCP Tools

| Tool | Description | Parameters |
|------|-------------|------------|
| `list_metrics` | List metric keys from the system series | `from`, `to`, `granularity` |
| `fetch_series` | Fetch raw series for a metric key | `key`, `from`, `to`, `granularity` |
| `aggregate_series` | Aggregate a metric path | `key`, `value_path`, `aggregator`, `from`, `to`, `granularity`, `slices` |
| `format_timeline` | Timeline format for a metric path | `key`, `value_path`, `from`, `to`, `granularity`, `slices` |
| `format_category` | Category format for a metric path | `key`, `value_path`, `from`, `to`, `granularity`, `slices` |
| `write_metric` | Track a metric event | `key`, `values`, `at` |
| `list_transponders` | List transponders | - |
| `delete_transponder` | Delete a transponder | `id` |

:::callout note "Scope"
- Dashboards and monitors are not exposed via MCP yet. Use the API or UI for those.
:::

## Example Prompts for AI Agents

- "Track a signup event in Trifle."
- "Show me the API latency timeline for the last 24 hours."
- "What were yesterday's error rates by category?"

## Resources

The MCP server exposes these read-only resources:

:::signature Resource URIs
trifle://source | JSON |  |  | Source configuration, defaults, granularities.
trifle://metrics?from&to&granularity | JSON |  |  | Available metric keys (system series).
trifle://metrics/{key}?from&to&granularity | JSON |  |  | Raw series for a specific key.
trifle://transponders | JSON |  |  | Transponders for the active source (API sources only).
:::

Example URIs:

```text
trifle://source
trifle://metrics?from=2026-01-24T00:00:00Z&to=2026-01-25T00:00:00Z&granularity=1h
trifle://metrics/event::signup?from=2026-01-24T00:00:00Z&to=2026-01-25T00:00:00Z&granularity=1h
trifle://transponders
```
