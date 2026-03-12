---
title: /bootstrap
description: User-authenticated bootstrap API for signup/login and source provisioning.
nav_order: 2.5
---

# /api/v1/bootstrap

Bootstrap endpoints are authenticated with an **organization API token** (except `signup` and `login`).

Use this flow for agents:

1. `POST /bootstrap/signup` or `POST /bootstrap/login`
2. `GET /bootstrap/me`
3. `POST /bootstrap/organizations` (if user has no organization)
4. `POST /bootstrap/databases` or `POST /bootstrap/projects`
5. `POST /bootstrap/databases/:id/setup` (database sources)
6. (Optional) `POST /bootstrap/tokens` to mint additional organization tokens
7. Use the token with regular `/api/v1/*` endpoints + `X-Trifle-Source-Id`

## Endpoints

:::signature POST /bootstrap/signup
email | String | required |  | User email.
password | String | required |  | User password.
name | String | optional |  | Display name.
organization_name | String | optional |  | Create organization on signup.
token_name | String | optional | `CLI token` | Organization token label.
:::

:::signature POST /bootstrap/login
email | String | required |  | User email.
password | String | required |  | User password.
token_name | String | optional | `CLI token` | Organization token label.
:::

:::signature GET /bootstrap/me
 |  |  |  | Returns user + organization/membership context for the current token.
:::

:::signature POST /bootstrap/organizations
name | String | required |  | Organization name.
:::

:::signature GET /bootstrap/sources
 |  |  |  | Lists visible projects and databases.
:::

:::signature POST /bootstrap/databases
display_name | String | required |  | Source name.
driver | String | required |  | `sqlite`, `postgres`, `mysql`, `redis`, `mongo`.
sqlite_file | File | optional |  | SQLite upload via `multipart/form-data`.
file_path | String | optional |  | Manual server path fallback for SQLite.
... | Object | optional |  | Driver fields (`host`, `port`, `database_name`, etc.).
:::

:::signature POST /bootstrap/databases/:id/setup
 |  |  |  | Runs setup for the given database source.
:::

:::signature POST /bootstrap/projects
name | String | required |  | Project name.
project_cluster_id | String | optional |  | Cluster UUID.
... | Object | optional |  | Optional project defaults.
:::

:::signature GET /bootstrap/tokens
 |  |  |  | Lists organization-visible tokens.
:::

:::signature POST /bootstrap/tokens
name | String | optional | `CLI token` | Token label.
wildcard_read | Bool | optional | `false` | Global read permission.
wildcard_write | Bool | optional | `false` | Global write permission.
source_type | String | optional |  | Optional `database` or `project` (legacy helper for a single source grant).
source_id | String | optional |  | Optional source UUID (legacy helper for a single source grant).
read | Bool | optional | `true` | Source read permission when `source_id` is provided.
write | Bool | optional | `false` | Source write permission when `source_id` is provided.
grants | Array<Object> | optional |  | Source grants payload (`source_id`, optional `source_type`, `read`, `write`).
permissions | Object | optional |  | Full permissions object (`wildcard`, `sources`).
:::

:::signature PUT /bootstrap/tokens/:id
name | String | optional |  | Token label.
expires_at | String | optional |  | RFC3339 expiration.
wildcard_read | Bool | optional |  | Global read permission override.
wildcard_write | Bool | optional |  | Global write permission override.
grants | Array<Object> | optional |  | Source grants patch payload.
permissions | Object | optional |  | Full permissions object replacement.
:::

:::signature DELETE /bootstrap/tokens/:id
 |  |  |  | Revokes token.
:::

## Example (login + token)

```sh
curl -s https://app.trifle.io/api/v1/bootstrap/login \
  -H "content-type: application/json" \
  -d '{"email":"user@example.com","password":"secret"}'
```

Then use returned token:

```sh
curl -s https://app.trifle.io/api/v1/bootstrap/tokens \
  -H "authorization: Bearer <TOKEN>" \
  -H "content-type: application/json" \
  -d '{"name":"CLI project write","source_type":"project","source_id":"<PROJECT_ID>","read":true,"write":true}'
```

The returned `data.token.value` can be used with `/api/v1/*` endpoints.  
For source-bound endpoints, include `X-Trifle-Source-Id: <SOURCE_ID>`.

## Example (SQLite upload)

Use multipart when uploading a SQLite file directly:

```sh
curl -s https://app.trifle.io/api/v1/bootstrap/databases \
  -H "authorization: Bearer <TOKEN>" \
  -F "display_name=SQLite Upload" \
  -F "driver=sqlite" \
  -F "sqlite_file=@./metrics.sqlite"
```

Storage location depends on deployment config:
- `app.sqliteStorage.backend: local` stores files under `app.sqliteUpload.rootPath` (for example `organization_<organization_id>/sqlite/...`).
- `app.sqliteStorage.backend: s3` stores files in the configured S3-compatible bucket/prefix and caches locally on app nodes for reads.

Upload size is enforced by `TRIFLE_SQLITE_UPLOAD_MAX_BYTES` (Helm: `app.sqliteUpload.maxBytes`).
