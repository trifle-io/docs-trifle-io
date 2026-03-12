---
title: Getting Started
description: From zero to metrics in one pass.
nav_order: 1
---

# Getting Started

This is the shortest path from "no app" to "I can see a chart".

## 0. Install (self-hosted only)

:::tabs
@tab SaaS
- Skip this step and go straight to [app.trifle.io](https://app.trifle.io).
- Your base URL is `https://app.trifle.io`.

@tab Self-hosted
- Use the Helm chart in the Trifle repo and apply a minimal values file.
- See [Installation](/trifle-app/deployment/installation).
- Your base URL is your own host (e.g. `https://trifle.example.com`).
:::

Expected outcome: Trifle App is running and reachable.

:::callout note "Projects in self-hosted"
- Projects are **disabled by default** in self-hosted mode.
- If you need API ingestion, enable `features.projects.enabled` and configure Mongo (see [Configuration](/trifle-app/deployment/configuration)).
:::

## 1. Sign up or log in

:::tabs
@tab SaaS
- Navigate to [app.trifle.io](https://app.trifle.io).
- Sign up with your email address.

@tab Self-hosted
- Navigate to your Trifle URL.
- Sign in with the `initialUser` credentials.
- Change the password immediately.
:::

Expected outcome: you can access the UI with an admin account.

## 2. Create a source + token

There are two source types:

- **Project source**: supports reads and writes when token permission includes `write=true`.
- **Database source**: supports reads only.

If you want **Database source** metrics, integrate **Trifle::Stats** (Ruby), **Trifle.Stats** (Elixir), or another Trifle Stats plugin into your app so it writes metrics into your database directly.

Go to **Organization → Tokens** and create a token (or reuse the bootstrap token).  
For API calls, always pass `X-Trifle-Source-Id`.

Expected outcome: you have a token and know whether it can write.

## 3. Send your first metric

Replace `<TRIFLE_APP_URL>` with `https://app.trifle.io` or your self-hosted URL.

:::tabs
@tab CURL Basic event
```sh
curl -X POST "<TRIFLE_APP_URL>/api/v1/metrics" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "X-Trifle-Source-Id: <PROJECT_ID>" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "event::signup",
    "at": "2026-01-24T12:00:00Z",
    "values": { "count": 1, "duration": 0.42 }
  }'
```

@tab CURL Nested values
```sh
curl -X POST "<TRIFLE_APP_URL>/api/v1/metrics" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "X-Trifle-Source-Id: <PROJECT_ID>" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "checkout.completed",
    "at": "2026-01-24T12:15:00Z",
    "values": {
      "count": 1,
      "amount": 129.99,
      "country": { "US": 1 },
      "channel": { "organic": 1 }
    }
  }'
```

@tab CURL Latency + percentiles
```sh
curl -X POST "<TRIFLE_APP_URL>/api/v1/metrics" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "X-Trifle-Source-Id: <PROJECT_ID>" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "service.latency",
    "at": "2026-01-24T12:30:00Z",
    "values": { "count": 1, "p50": 180, "p95": 420, "p99": 900 }
  }'
```

@tab Trifle CLI
```sh
export TRIFLE_URL="<TRIFLE_APP_URL>"
export TRIFLE_TOKEN="<TOKEN>"
export TRIFLE_SOURCE_ID="<PROJECT_ID>"

trifle metrics push \
  --key event::signup \
  --at 2026-01-24T12:00:00Z \
  --values '{"count":1,"duration":0.42}'
```
:::

If this returns `201`, you're in.

Expected outcome: a `201` response and `{"data":{"created":"ok"}}`.

## 4. Explore the data

Visit `/explore` in the UI to see raw metrics aggregating over time. It’s the fastest way to validate that data is flowing.

### Query the series

:::tabs
@tab GET /metrics
```sh
curl "<TRIFLE_APP_URL>/api/v1/metrics?key=event::signup&from=2026-01-24T00:00:00Z&to=2026-01-25T00:00:00Z&granularity=1h" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "X-Trifle-Source-Id: <SOURCE_ID>"
```

@tab POST /metrics/query (aggregate)
```sh
curl -X POST "<TRIFLE_APP_URL>/api/v1/metrics/query" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "X-Trifle-Source-Id: <SOURCE_ID>" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "event::signup",
    "from": "2026-01-24T00:00:00Z",
    "to": "2026-01-25T00:00:00Z",
    "granularity": "1h",
    "mode": "aggregate",
    "value_path": "count",
    "aggregator": "sum"
  }'
```

@tab Trifle CLI
```sh
export TRIFLE_URL="<TRIFLE_APP_URL>"
export TRIFLE_TOKEN="<TOKEN>"
export TRIFLE_SOURCE_ID="<SOURCE_ID>"

trifle metrics get \
  --key event::signup \
  --from 2026-01-24T00:00:00Z \
  --to 2026-01-25T00:00:00Z \
  --granularity 1h
```
:::

Expected outcome: a JSON payload with `data.at` timestamps and `data.values` (or a formatted `data.result` for query).

## 5. Build a dashboard

Create a dashboard via the UI or via the API (see `/api/v1/dashboards`). Point widgets at your metric keys and paths.

Expected outcome: a dashboard with at least one widget rendering data.

:::callout note "Quick sanity check"
- `GET /api/v1/source` tells you what the token can see and which granularities are allowed.
:::

## 6. Optional: seed demo data

Useful for local development or when you need a quick data set.

:::tabs
@tab Seed database source
```sh
mix seed_metrics --source=database:<DATABASE_ID> --count=200 --hours=72
```

@tab Populate API (project source)
```sh
mix populate_metrics --token=<TOKEN> --source-id=<PROJECT_ID> --count=100 --hours=24
```
:::

:::callout note "Local defaults"
- `mix populate_metrics` targets `http://localhost:4000` by default.
- Run it inside the app container or adjust the task if your host is different.
:::
