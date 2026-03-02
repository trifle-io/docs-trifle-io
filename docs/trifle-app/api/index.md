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

- **Bootstrap user tokens** authenticate `/api/v1/bootstrap/*` endpoints (signup/login/source setup flow).
- **Source tokens** authenticate metrics/dashboards/monitors/transponders endpoints.

### Request

:::tabs
@tab CURL
```sh
curl -H "Authorization: Bearer <TOKEN>" \
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
  {'authorization', to_charlist("Bearer " <> token)}
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
  headers: { Authorization: `Bearer ${token}` },
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
  headers={"Authorization": f"Bearer {token}"},
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
curl_setopt($ch, CURLOPT_HTTPHEADER, ["Authorization: Bearer $token"]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$body = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo $code . PHP_EOL;
echo $body;
```
:::

- **Project tokens** can be read or write.
- **Database tokens** are read-only.
- Write permissions are enforced for metrics ingestion only.
- **User API tokens** are bootstrap/control-plane tokens. Use them to create organizations/sources and mint source tokens.

:::callout note "Self-hosted defaults"
- If you self-host and keep `features.projects.enabled: false`, you won’t have project tokens.
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
- **Check token context**: `GET /api/v1/source` shows source type, granularity rules, and token scope.

## Endpoints

- [/health](/trifle-app/api/health)
- [/bootstrap](/trifle-app/api/bootstrap)
- [/source](/trifle-app/api/source)
- [/metrics](/trifle-app/api/metrics)
- [/transponders](/trifle-app/api/transponders)
- [/dashboards](/trifle-app/api/dashboards)
- [/monitors](/trifle-app/api/monitors)
