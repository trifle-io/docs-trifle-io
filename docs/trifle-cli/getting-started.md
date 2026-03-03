---
title: Getting Started
description: Step-by-step bootstrap flow for Trifle CLI with Trifle App.
nav_order: 3
---

# Getting Started

This guide walks through the CLI bootstrap flow end-to-end:

1. Sign up and log in
2. Create a SQLite database source
3. Create a project source
4. Generate one source token for each
5. Fetch metrics from both sources
6. Push and read sample project metrics

## Prerequisites

- Trifle App running and reachable (default SaaS URL: `https://app.trifle.io`)
- `trifle` CLI installed
- `jq` installed

If you use a self-hosted Trifle App, provide your own base URL (for example `https://trifle.example.com`).

## End-to-end bootstrap script

```sh
#!/usr/bin/env bash
set -euo pipefail

CLI="${CLI:-trifle}"
BASE_URL="${BASE_URL:-https://app.trifle.io}"
STAMP="$(date +%s)"
CONFIG="${CONFIG:-/tmp/trifle-cli-e2e-${STAMP}.yaml}"
EMAIL="${EMAIL:-e2e-${STAMP}@example.com}"
PASSWORD="${PASSWORD:-hello world!}"
DB_FILE="${DB_FILE:-/tmp/trifle-cli-e2e-${STAMP}.sqlite}"
PROJECT_CLUSTER_ID="${PROJECT_CLUSTER_ID:-}"

touch "$CONFIG"

echo "Config: $CONFIG"
echo "Email:  $EMAIL"

echo "== Signup =="
$CLI auth signup \
  --config "$CONFIG" \
  --url "$BASE_URL" \
  --email "$EMAIL" \
  --password "$PASSWORD" \
  --name "E2E Agent" \
  --org-name "E2E Org ${STAMP}" \
  --token-name "E2E Signup Token"

echo "== Login =="
LOGIN_JSON="$($CLI auth login \
  --config "$CONFIG" \
  --url "$BASE_URL" \
  --email "$EMAIL" \
  --password "$PASSWORD" \
  --token-name "E2E Login Token")"
echo "$LOGIN_JSON"
USER_TOKEN="$(printf '%s' "$LOGIN_JSON" | jq -r '.data.token.value')"

echo "== Create database source (SQLite) =="
DB_JSON="$($CLI source create database \
  --config "$CONFIG" \
  --url "$BASE_URL" \
  --user-token "$USER_TOKEN" \
  --display-name "E2E SQLite ${STAMP}" \
  --driver sqlite \
  --sqlite-file "$DB_FILE")"
echo "$DB_JSON"
DB_ID="$(printf '%s' "$DB_JSON" | jq -r '.data.source.id')"

echo "== Setup database source =="
$CLI source setup \
  --config "$CONFIG" \
  --url "$BASE_URL" \
  --user-token "$USER_TOKEN" \
  --id "$DB_ID"

echo "== Create project source =="
if [ -n "$PROJECT_CLUSTER_ID" ]; then
  PROJECT_JSON="$($CLI source create project \
    --config "$CONFIG" \
    --url "$BASE_URL" \
    --user-token "$USER_TOKEN" \
    --name "E2E Project ${STAMP}" \
    --project-cluster-id "$PROJECT_CLUSTER_ID")"
else
  PROJECT_JSON="$($CLI source create project \
    --config "$CONFIG" \
    --url "$BASE_URL" \
    --user-token "$USER_TOKEN" \
    --name "E2E Project ${STAMP}")"
fi
echo "$PROJECT_JSON"
PROJECT_ID="$(printf '%s' "$PROJECT_JSON" | jq -r '.data.source.id')"

echo "== Create database source token =="
$CLI source token create \
  --config "$CONFIG" \
  --url "$BASE_URL" \
  --user-token "$USER_TOKEN" \
  --source-type database \
  --source-id "$DB_ID" \
  --name "E2E DB Token" \
  --source-name api-db \
  --save=true \
  --activate=false

# Keep active source explicit in config for follow-up commands.
$CLI source use --config "$CONFIG" --name api-db

echo "== Create project source token =="
$CLI source token create \
  --config "$CONFIG" \
  --url "$BASE_URL" \
  --user-token "$USER_TOKEN" \
  --source-type project \
  --source-id "$PROJECT_ID" \
  --name "E2E Project Token" \
  --source-name api-project \
  --save=true \
  --activate=false \
  --read=true \
  --write=true

echo "== List sources =="
$CLI source list --config "$CONFIG" --url "$BASE_URL" --user-token "$USER_TOKEN"

echo "== Fetch metrics (expected empty) =="
$CLI metrics get \
  --config "$CONFIG" \
  --source api-db \
  --key event::signup \
  --from 2026-01-01T00:00:00Z \
  --to 2026-01-02T00:00:00Z \
  --granularity 1d

$CLI metrics get \
  --config "$CONFIG" \
  --source api-project \
  --key event::signup \
  --from 2026-01-01T00:00:00Z \
  --to 2026-01-02T00:00:00Z \
  --granularity 1d

echo "Done. Config file: $CONFIG"
```

`--sqlite-file` uploads a local SQLite file through the bootstrap API.  
Use `--file-path` only when you want Trifle to reference an existing server-side path instead of uploading.

## Store sample data (project source)

Database source tokens are read-only. Use the project source token for writes.

```sh
CONFIG=/tmp/trifle-cli-e2e-<stamp>.yaml

trifle metrics push \
  --config "$CONFIG" \
  --source api-project \
  --key event::signup \
  --at 2026-03-01T12:00:00Z \
  --values '{"count":1,"duration":0.42}'

trifle metrics push \
  --config "$CONFIG" \
  --source api-project \
  --key checkout::completed \
  --at 2026-03-01T12:05:00Z \
  --values '{"count":1,"amount":{"usd":39}}'
```

## Fetch sample data

```sh
CONFIG=/tmp/trifle-cli-e2e-<stamp>.yaml
FROM=2026-03-01T00:00:00Z
TO=2026-03-02T00:00:00Z

# Raw time-series points
trifle metrics get \
  --config "$CONFIG" \
  --source api-project \
  --key event::signup \
  --from "$FROM" \
  --to "$TO" \
  --granularity 1h

# Aggregate over a numeric path
trifle metrics aggregate \
  --config "$CONFIG" \
  --source api-project \
  --key checkout::completed \
  --value-path amount.usd \
  --aggregator sum \
  --from "$FROM" \
  --to "$TO" \
  --granularity 1h

# Timeline projection for charting
trifle metrics timeline \
  --config "$CONFIG" \
  --source api-project \
  --key event::signup \
  --value-path count \
  --from "$FROM" \
  --to "$TO" \
  --granularity 1h
```
