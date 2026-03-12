---
title: /metrics
description: Ingest and query metrics.
nav_order: 1
---

# /api/v1/metrics

Metrics endpoints for ingesting and reading time series.

:::callout note "Base URL"
Replace `<TRIFLE_APP_URL>` with `https://app.trifle.io` (SaaS) or your self-hosted URL.
:::

## Auth

- **GET /metrics** and **POST /metrics/query** require token permission `read=true`.
- **POST /metrics** requires token permission `write=true`.

`Authorization: Bearer <TOKEN>`
`X-Trifle-Source-Id: <SOURCE_UUID>`

:::callout note "Source context"
- `X-Trifle-Source-Id` is required on all metrics calls.
- If self-hosted with projects disabled, `POST /metrics` is not available.
:::

---

## GET /metrics

Fetch a time series for a metric key.

:::signature GET /api/v1/metrics
key | String | optional | `__system__key__` | Metric key. If omitted, the system key is used.
from | ISO8601 | required |  | Start timestamp.
to | ISO8601 | required |  | End timestamp.
granularity | String | required |  | Bucket size (e.g. `5m`, `1h`, `1d`).
:::

:::callout note "System key"
- If `key` is omitted, Trifle uses an internal system key and disables transponders for the query.
- For normal metrics, always pass your metric key.
:::

### Request

:::tabs
@tab CURL Basic
```sh
curl "<TRIFLE_APP_URL>/api/v1/metrics?key=event::signup&from=2026-01-24T00:00:00Z&to=2026-01-25T00:00:00Z&granularity=1h" \
  -H "Authorization: Bearer <READ_TOKEN>"
```

@tab CURL Longer range
```sh
curl "<TRIFLE_APP_URL>/api/v1/metrics?key=service.latency&from=2026-01-20T00:00:00Z&to=2026-01-25T00:00:00Z&granularity=6h" \
  -H "Authorization: Bearer <READ_TOKEN>"
```

@tab HTTPie
```sh
http GET "<TRIFLE_APP_URL>/api/v1/metrics?key=event::signup&from=2026-01-24T00:00:00Z&to=2026-01-25T00:00:00Z&granularity=1h" \
  Authorization:"Bearer <READ_TOKEN>"
```
:::

### Language examples

:::tabs
@tab Ruby
```ruby
require "net/http"

base = ENV.fetch("TRIFLE_APP_URL")
token = ENV.fetch("TRIFLE_TOKEN")
uri = URI("#{base}/api/v1/metrics")
uri.query = URI.encode_www_form(
  key: "event::signup",
  from: "2026-01-24T00:00:00Z",
  to: "2026-01-25T00:00:00Z",
  granularity: "1h"
)

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
base = System.fetch_env!("TRIFLE_APP_URL")
token = System.fetch_env!("TRIFLE_TOKEN")

url =
  "#{base}/api/v1/metrics?key=event::signup&from=2026-01-24T00:00:00Z&to=2026-01-25T00:00:00Z&granularity=1h"

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
const base = process.env.TRIFLE_APP_URL;
const token = process.env.TRIFLE_TOKEN;

const params = new URLSearchParams({
  key: "event::signup",
  from: "2026-01-24T00:00:00Z",
  to: "2026-01-25T00:00:00Z",
  granularity: "1h",
});

const res = await fetch(`${base}/api/v1/metrics?${params}`, {
  headers: { Authorization: `Bearer ${token}` },
});

console.log(await res.json());
```

@tab Python
```python
import os
import requests

base = os.environ["TRIFLE_APP_URL"]
token = os.environ["TRIFLE_TOKEN"]

params = {
  "key": "event::signup",
  "from": "2026-01-24T00:00:00Z",
  "to": "2026-01-25T00:00:00Z",
  "granularity": "1h",
}

resp = requests.get(
  f"{base}/api/v1/metrics",
  params=params,
  headers={"Authorization": f"Bearer {token}"},
)

print(resp.status_code)
print(resp.json())
```

@tab PHP
```php
<?php
$base = getenv("TRIFLE_APP_URL");
$token = getenv("TRIFLE_TOKEN");

$params = http_build_query([
  "key" => "event::signup",
  "from" => "2026-01-24T00:00:00Z",
  "to" => "2026-01-25T00:00:00Z",
  "granularity" => "1h",
]);

$ch = curl_init("$base/api/v1/metrics?$params");
curl_setopt($ch, CURLOPT_HTTPHEADER, ["Authorization: Bearer $token"]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$body = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo $code . PHP_EOL;
echo $body;
```
:::

### Response

:::tabs
@tab Body
```json
{
  "data": {
    "at": ["2026-01-24T00:00:00Z", "2026-01-24T01:00:00Z"],
    "values": [
      {"count": 1, "duration": 0.42},
      {"count": 3, "duration": 1.09}
    ]
  }
}
```
:::

:::callout warn "Granularity matters"
- Invalid granularity returns `400`.
- If your source restricts granularities, only allowed values pass.
:::

---

## POST /metrics

Ingest metrics into Trifle (token must have write permission for the selected project source).

:::signature POST /api/v1/metrics
key | String | required |  | Metric key (e.g. `event::signup`).
at | ISO8601 | required |  | Timestamp of the event.
values | Map | required |  | Metrics payload. Leaves must be numeric.
:::

### Request

:::tabs
@tab CURL Signup events

```sh
curl -X POST "<TRIFLE_APP_URL>/api/v1/metrics" \
  -H "Authorization: Bearer <WRITE_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "event::signup",
    "at": "2026-01-24T10:00:00Z",
    "values": {
      "count": 1,
      "failed": 0,
      "duration": 0.42,
      "country": { "US": 1 },
      "channel": { "organic": 1 }
    }
  }'
```

@tab CURL Latency

```sh
curl -X POST "<TRIFLE_APP_URL>/api/v1/metrics" \
  -H "Authorization: Bearer <WRITE_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "service.latency",
    "at": "2026-01-24T12:00:00Z",
    "values": {
      "count": 1,
      "p50": 180,
      "p95": 420,
      "p99": 900
    }
  }'
```

@tab CURL Revenue

```sh
curl -X POST "<TRIFLE_APP_URL>/api/v1/metrics" \
  -H "Authorization: Bearer <WRITE_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "billing.revenue",
    "at": "2026-01-24T13:00:00Z",
    "values": {
      "amount": 129.99,
      "count": 1,
      "plan": { "pro": 1 }
    }
  }'
```

@tab HTTPie
```sh
http POST "<TRIFLE_APP_URL>/api/v1/metrics" \
  Authorization:"Bearer <WRITE_TOKEN>" \
  Content-Type:application/json \
  key=event::signup \
  at=2026-01-24T10:00:00Z \
  values:='{"count":1,"duration":0.42}'
```
:::

### Language examples

:::tabs
@tab Ruby
```ruby
require "net/http"
require "json"

base = ENV.fetch("TRIFLE_APP_URL")
token = ENV.fetch("TRIFLE_TOKEN")
uri = URI("#{base}/api/v1/metrics")

payload = {
  key: "event::signup",
  at: "2026-01-24T10:00:00Z",
  values: { count: 1, duration: 0.42 }
}

req = Net::HTTP::Post.new(uri)
req["Authorization"] = "Bearer #{token}"
req["Content-Type"] = "application/json"
req.body = payload.to_json

res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
  http.request(req)
end

puts res.code
puts res.body
```

@tab Elixir
```elixir
base = System.fetch_env!("TRIFLE_APP_URL")
token = System.fetch_env!("TRIFLE_TOKEN")
url = "#{base}/api/v1/metrics"

payload = %{
  "key" => "event::signup",
  "at" => "2026-01-24T10:00:00Z",
  "values" => %{"count" => 1, "duration" => 0.42}
}

headers = [
  {'authorization', to_charlist("Bearer " <> token)},
  {'content-type', 'application/json'}
]

:inets.start()
:ssl.start()
{:ok, {{_, status, _}, _resp_headers, body}} =
  :httpc.request(:post, {String.to_charlist(url), headers, 'application/json', Jason.encode!(payload)}, [], [])

IO.puts(status)
IO.puts(body)
```

@tab Node.js
```js
const base = process.env.TRIFLE_APP_URL;
const token = process.env.TRIFLE_TOKEN;

const res = await fetch(`${base}/api/v1/metrics`, {
  method: "POST",
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    key: "event::signup",
    at: "2026-01-24T10:00:00Z",
    values: { count: 1, duration: 0.42 },
  }),
});

console.log(await res.json());
```

@tab Python
```python
import os
import requests

base = os.environ["TRIFLE_APP_URL"]
token = os.environ["TRIFLE_TOKEN"]

payload = {
  "key": "event::signup",
  "at": "2026-01-24T10:00:00Z",
  "values": {"count": 1, "duration": 0.42},
}

resp = requests.post(
  f"{base}/api/v1/metrics",
  headers={"Authorization": f"Bearer {token}"},
  json=payload,
)

print(resp.status_code)
print(resp.json())
```

@tab PHP
```php
<?php
$base = getenv("TRIFLE_APP_URL");
$token = getenv("TRIFLE_TOKEN");

$payload = [
  "key" => "event::signup",
  "at" => "2026-01-24T10:00:00Z",
  "values" => ["count" => 1, "duration" => 0.42],
];

$ch = curl_init("$base/api/v1/metrics");
curl_setopt($ch, CURLOPT_HTTPHEADER, [
  "Authorization: Bearer $token",
  "Content-Type: application/json",
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$body = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo $code . PHP_EOL;
echo $body;
```
:::

### Response

:::tabs
@tab Body
```json
{ "data": { "created": "ok" } }
```
:::

:::callout note "Nested values are fine"
- `values` can be a nested map, but every leaf has to be numeric.
:::

---

## POST /metrics/query

Query, aggregate, or format a metric series.

:::signature POST /api/v1/metrics/query
key | String | required |  | Metric key.
from | ISO8601 | required |  | Start timestamp.
to | ISO8601 | required |  | End timestamp.
granularity | String | required |  | Bucket size (e.g. `5m`, `1h`).
mode | String | required |  | `aggregate`, `timeline`, or `category`. (`format` is an alias.)
value_path | String | required |  | Dot path into the metric payload.
aggregator | String | required |  | Only for `aggregate`. One of `sum`, `mean`, `min`, `max`.
slices | Integer | optional | `1` | Number of slices for the aggregation.
:::

:::callout note "Slices"
- `slices: 1` returns a single `value` plus `values: [value]`.
- `slices: n` returns `values` with `n` entries (no single `value`).
:::

### Request

:::tabs
@tab CURL Aggregate

```sh
curl -X POST "<TRIFLE_APP_URL>/api/v1/metrics/query" \
  -H "Authorization: Bearer <READ_TOKEN>" \
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

@tab CURL Timeline

```sh
curl -X POST "<TRIFLE_APP_URL>/api/v1/metrics/query" \
  -H "Authorization: Bearer <READ_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "service.latency",
    "from": "2026-01-24T00:00:00Z",
    "to": "2026-01-25T00:00:00Z",
    "granularity": "1h",
    "mode": "timeline",
    "value_path": "p95"
  }'
```

@tab CURL Category

```sh
curl -X POST "<TRIFLE_APP_URL>/api/v1/metrics/query" \
  -H "Authorization: Bearer <READ_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "event::signup",
    "from": "2026-01-24T00:00:00Z",
    "to": "2026-01-25T00:00:00Z",
    "granularity": "1h",
    "mode": "category",
    "value_path": "country"
  }'
```

@tab CURL Aggregate (slices)
```sh
curl -X POST "<TRIFLE_APP_URL>/api/v1/metrics/query" \
  -H "Authorization: Bearer <READ_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "event::signup",
    "from": "2026-01-24T00:00:00Z",
    "to": "2026-01-25T00:00:00Z",
    "granularity": "1h",
    "mode": "aggregate",
    "value_path": "count",
    "aggregator": "sum",
    "slices": 6
  }'
```
:::

### Language examples

:::tabs
@tab Ruby
```ruby
require "net/http"
require "json"

base = ENV.fetch("TRIFLE_APP_URL")
token = ENV.fetch("TRIFLE_TOKEN")
uri = URI("#{base}/api/v1/metrics/query")

payload = {
  key: "event::signup",
  from: "2026-01-24T00:00:00Z",
  to: "2026-01-25T00:00:00Z",
  granularity: "1h",
  mode: "aggregate",
  value_path: "count",
  aggregator: "sum"
}

req = Net::HTTP::Post.new(uri)
req["Authorization"] = "Bearer #{token}"
req["Content-Type"] = "application/json"
req.body = payload.to_json

res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
  http.request(req)
end

puts res.code
puts res.body
```

@tab Elixir
```elixir
base = System.fetch_env!("TRIFLE_APP_URL")
token = System.fetch_env!("TRIFLE_TOKEN")
url = "#{base}/api/v1/metrics/query"

payload = %{
  "key" => "event::signup",
  "from" => "2026-01-24T00:00:00Z",
  "to" => "2026-01-25T00:00:00Z",
  "granularity" => "1h",
  "mode" => "aggregate",
  "value_path" => "count",
  "aggregator" => "sum"
}

headers = [
  {'authorization', to_charlist("Bearer " <> token)},
  {'content-type', 'application/json'}
]

:inets.start()
:ssl.start()
{:ok, {{_, status, _}, _resp_headers, body}} =
  :httpc.request(:post, {String.to_charlist(url), headers, 'application/json', Jason.encode!(payload)}, [], [])

IO.puts(status)
IO.puts(body)
```

@tab Node.js
```js
const base = process.env.TRIFLE_APP_URL;
const token = process.env.TRIFLE_TOKEN;

const res = await fetch(`${base}/api/v1/metrics/query`, {
  method: "POST",
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    key: "event::signup",
    from: "2026-01-24T00:00:00Z",
    to: "2026-01-25T00:00:00Z",
    granularity: "1h",
    mode: "aggregate",
    value_path: "count",
    aggregator: "sum",
  }),
});

console.log(await res.json());
```

@tab Python
```python
import os
import requests

base = os.environ["TRIFLE_APP_URL"]
token = os.environ["TRIFLE_TOKEN"]

payload = {
  "key": "event::signup",
  "from": "2026-01-24T00:00:00Z",
  "to": "2026-01-25T00:00:00Z",
  "granularity": "1h",
  "mode": "aggregate",
  "value_path": "count",
  "aggregator": "sum",
}

resp = requests.post(
  f"{base}/api/v1/metrics/query",
  headers={"Authorization": f"Bearer {token}"},
  json=payload,
)

print(resp.status_code)
print(resp.json())
```

@tab PHP
```php
<?php
$base = getenv("TRIFLE_APP_URL");
$token = getenv("TRIFLE_TOKEN");

$payload = [
  "key" => "event::signup",
  "from" => "2026-01-24T00:00:00Z",
  "to" => "2026-01-25T00:00:00Z",
  "granularity" => "1h",
  "mode" => "aggregate",
  "value_path" => "count",
  "aggregator" => "sum",
];

$ch = curl_init("$base/api/v1/metrics/query");
curl_setopt($ch, CURLOPT_HTTPHEADER, [
  "Authorization: Bearer $token",
  "Content-Type: application/json",
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$body = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo $code . PHP_EOL;
echo $body;
```
:::

### Response

:::tabs
@tab Aggregate Body

```json
{
  "data": {
    "status": "ok",
    "aggregator": "sum",
    "metric_key": "event::signup",
    "value_path": "count",
    "slices": 1,
    "value": 42.0,
    "values": [42.0],
    "count": 1,
    "timeframe": {
      "from": "2026-01-24T00:00:00Z",
      "to": "2026-01-25T00:00:00Z",
      "label": "custom",
      "granularity": "1h"
    },
    "available_paths": ["count", "duration"],
    "matched_paths": ["count"],
    "table": {
      "columns": ["at", "count"],
      "rows": [
        ["2026-01-24T00:00:00Z", 1.0],
        ["2026-01-24T01:00:00Z", 2.0]
      ]
    }
  }
}
```

@tab Timeline Body

```json
{
  "data": {
    "status": "ok",
    "formatter": "timeline",
    "metric_key": "service.latency",
    "value_path": "p95",
    "slices": 1,
    "timeframe": {
      "from": "2026-01-24T00:00:00Z",
      "to": "2026-01-25T00:00:00Z",
      "label": "custom",
      "granularity": "1h"
    },
    "result": {
      "p95": [
        { "at": "2026-01-24T12:00:00Z", "value": 350.0 }
      ]
    },
    "available_paths": ["count", "p50", "p95", "p99"],
    "matched_paths": ["p95"]
  }
}
```

@tab Category Body

```json
{
  "data": {
    "status": "ok",
    "formatter": "category",
    "metric_key": "event::signup",
    "value_path": "country",
    "slices": 1,
    "timeframe": {
      "from": "2026-01-24T00:00:00Z",
      "to": "2026-01-25T00:00:00Z",
      "label": "custom",
      "granularity": "1h"
    },
    "result": {
      "country.US": 3.0,
      "country.UK": 1.0
    },
    "available_paths": ["count", "country.US", "country.UK"],
    "matched_paths": ["country.US", "country.UK"]
  }
}
```
:::

:::callout note "Tabular payloads"
- Some responses include a `table` object with `columns` and `rows` for quick CSV-style exports.
:::

:::callout warn "Common failure modes"
- Missing `aggregator` in aggregate mode returns `422`.
- Wildcards in `value_path` are rejected.
:::
