---
title: API Endpoints
description: HTTP API for metrics, dashboards, and monitors.
nav_order: 2
---

# API Endpoints

Base URL depends on your deployment.

:::tabs
@tab SaaS
`https://app.trifle.io/api/v1`

@tab Self-hosted
`https://<your-host>/api/v1`
:::

## Authentication

All API requests (except health) use bearer tokens.

- **Organization API tokens** authenticate both `/api/v1/bootstrap/*` and regular `/api/v1/*` endpoints.
- For source-bound endpoints, include `X-Trifle-Source-Id: <SOURCE_UUID>`.

### Request

:::tabs
@tab CURL
```sh
curl -H "Authorization: Bearer <TOKEN>" \
  -H "X-Trifle-Source-Id: <SOURCE_UUID>" \
  https://app.trifle.io/api/v1/source
```

@tab HTTPie
```sh
http GET https://app.trifle.io/api/v1/source \
  Authorization:"Bearer <TOKEN>"
```

@tab Ruby
```ruby
require "net/http"

base = ENV.fetch("TRIFLE_APP_URL", "https://app.trifle.io")
token = ENV.fetch("TRIFLE_TOKEN")
uri = URI("#{base}/api/v1/source")

req = Net::HTTP::Get.new(uri)
req["Authorization"] = "Bearer #{token}"
req["X-Trifle-Source-Id"] = ENV.fetch("TRIFLE_SOURCE_ID")

res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
  http.request(req)
end

puts res.code
puts res.body
```

@tab Elixir
```elixir
base = System.get_env("TRIFLE_APP_URL") || "https://app.trifle.io"
token = System.fetch_env!("TRIFLE_TOKEN")
url = "#{base}/api/v1/source"

headers = [
  {'authorization', to_charlist("Bearer " <> token)},
  {'x-trifle-source-id', to_charlist(System.fetch_env!("TRIFLE_SOURCE_ID"))}
]

:inets.start()
:ssl.start()
{:ok, {{_, status, _}, _resp_headers, body}} =
  :httpc.request(:get, {String.to_charlist(url), headers}, [], [])

IO.puts(status)
IO.puts(body)
```

@tab Node.js
```js
const base = process.env.TRIFLE_APP_URL ?? "https://app.trifle.io";
const token = process.env.TRIFLE_TOKEN;

const res = await fetch(`${base}/api/v1/source`, {
  headers: {
    Authorization: `Bearer ${token}`,
    "X-Trifle-Source-Id": process.env.TRIFLE_SOURCE_ID,
  },
});

console.log(await res.json());
```

@tab Python
```python
import os
import requests

base = os.getenv("TRIFLE_APP_URL", "https://app.trifle.io")
token = os.environ["TRIFLE_TOKEN"]

resp = requests.get(
  f"{base}/api/v1/source",
  headers={
    "Authorization": f"Bearer {token}",
    "X-Trifle-Source-Id": os.environ["TRIFLE_SOURCE_ID"],
  },
)

print(resp.status_code)
print(resp.json())
```

@tab PHP
```php
<?php
$base = getenv("TRIFLE_APP_URL") ?: "https://app.trifle.io";
$token = getenv("TRIFLE_TOKEN");

$ch = curl_init("$base/api/v1/source");
curl_setopt($ch, CURLOPT_HTTPHEADER, [
  "Authorization: Bearer $token",
  "X-Trifle-Source-Id: " . getenv("TRIFLE_SOURCE_ID"),
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$body = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo $code . PHP_EOL;
echo $body;
```
:::

- Wildcard and per-source `read` / `write` permissions are enforced by token policy.
- Write permissions are required for metrics ingestion (`POST /metrics`).

:::callout note "Self-hosted defaults"
- If you self-host and keep `features.projects.enabled: false`, project sources are disabled.
- In that mode, the API is read-only (database sources only).
:::

## OpenAPI

Machine-readable spec is available at:

`/trifle-app/api/openapi.yaml`

## Error format

### Response

:::tabs
@tab 401 Bad token
```json
{
  "errors": { "detail": "Bad token" }
}
```

@tab 403 Forbidden
```json
{
  "errors": { "detail": "Forbidden" }
}
```

@tab 422 Query error
```json
{
  "errors": {
    "status": "error",
    "error": "Aggregator must be provided (options: max, mean, min, sum)."
  }
}
```
:::

## Status codes

- `200` / `201` Success.
- `400` Invalid request or parameter.
- `401` Missing or invalid token.
- `403` Token does not have permission (e.g. write with a read-only token).
- `404` Resource not found.
- `422` Validation error.

## Troubleshooting

- **Check API health**: `GET /api/v1/health`.
- **Check token context**: `GET /api/v1/source` (with `X-Trifle-Source-Id`) shows source defaults and effective scope.

## Endpoints

- [/health](/trifle-app/api/health)
- [/bootstrap](/trifle-app/api/bootstrap)
- [/source](/trifle-app/api/source)
- [/metrics](/trifle-app/api/metrics)
- [/transponders](/trifle-app/api/transponders)
- [/dashboards](/trifle-app/api/dashboards)
- [/monitors](/trifle-app/api/monitors)
