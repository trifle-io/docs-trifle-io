---
title: /transponders
description: Create and manage expression transponders.
nav_order: 4
---

# /api/v1/transponders

Transponders let you add derived metrics with one expression-based contract:

```json
{
  "paths": ["success", "count"],
  "expression": "a / b",
  "response": "success_rate"
}
```

`paths` are assigned in order to `a`, `b`, `c`, and the result is written to `response`.

:::callout note "Base URL"
Replace `<TRIFLE_APP_URL>` with `https://app.trifle.io` or your self-hosted URL.
:::

## Auth

`Authorization: Bearer <TOKEN>`

---

## GET /transponders

List transponders for the current source.

### Response fields

- `id`, `name`, `key`
- `config`, `enabled`, `order`
- `source_type`, `source_id`

### Request

```sh
curl -s "<TRIFLE_APP_URL>/api/v1/transponders" \
  -H "Authorization: Bearer <TOKEN>"
```

### Response

```json
{
  "data": [
    {
      "id": "transponder-uuid",
      "name": "Success rate",
      "key": "event::signup",
      "config": {
        "paths": ["success", "count"],
        "expression": "a / b",
        "response": "success_rate"
      },
      "enabled": true,
      "order": 1,
      "source_type": "database",
      "source_id": "db-uuid"
    }
  ]
}
```

---

## POST /transponders

Create a transponder.

:::signature POST /api/v1/transponders
name | String | required |  | Display name.
key | String | required |  | Metric key to transform.
config | Map | optional |  | Transponder config (see below). If omitted, you can send `paths`, `expression`, and `response` at the top level.
enabled | Boolean | optional | `true` | Toggle on/off.
order | Integer | optional | next | Display order.
:::

:::callout note "Config shortcuts"
- You can send `config` **or** top-level `paths`, `expression`, `response`.
:::

### Expression config

:::signature config
paths | Array<String> | required |  | Metric paths assigned to `a`, `b`, `c`, ...
expression | String | required |  | Math expression using those variables.
response | String | required |  | Where to store the computed result.
:::

### Request

```sh
curl -X POST "<TRIFLE_APP_URL>/api/v1/transponders" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Success rate",
    "key": "event::signup",
    "config": {
      "paths": ["success", "count"],
      "expression": "(a / b) * 100",
      "response": "metrics.rates.success"
    }
  }'
```

### Response

```json
{
  "data": {
    "id": "transponder-uuid",
    "name": "Success rate",
    "key": "event::signup",
    "config": {
      "paths": ["success", "count"],
      "expression": "(a / b) * 100",
      "response": "metrics.rates.success"
    },
    "enabled": true,
    "order": 1,
    "source_type": "database",
    "source_id": "db-uuid"
  }
}
```

---

## PUT /transponders/:id

Update an existing transponder by id.

:::signature PUT /api/v1/transponders/:id
name | String | optional |  | Display name.
key | String | optional |  | Metric key to transform.
config | Map | optional |  | Transponder config (paths/expression/response).
enabled | Boolean | optional |  | Toggle on/off.
order | Integer | optional |  | Sort order.
:::

### Request

```sh
curl -X PUT "<TRIFLE_APP_URL>/api/v1/transponders/TRANS_ID" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "config": {
      "paths": ["success", "count"],
      "expression": "(a / b) * 100",
      "response": "metrics.rates.success"
    }
  }'
```

:::callout note "Variable mapping"
- `paths` are assigned in order: first path -> `a`, second -> `b`, third -> `c`, etc.
- `response` can be nested, for example `metrics.rates.success`.
- Wildcard paths (`*`) are reserved for a future expansion and are rejected for now.
:::

---

## DELETE /transponders/:id

Delete a transponder by id. Returns the deleted transponder.

### Request

```sh
curl -X DELETE "<TRIFLE_APP_URL>/api/v1/transponders/TRANS_ID" \
  -H "Authorization: Bearer <TOKEN>"
```
