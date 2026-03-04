---
title: /bootstrap
description: User-authenticated bootstrap API for signup/login and source provisioning.
nav_order: 2.5
---

# /api/v1/bootstrap

Bootstrap endpoints are authenticated with a **user API token** (except `signup` and `login`).

Use this flow for agents:

1. `POST /bootstrap/signup` or `POST /bootstrap/login`
2. `GET /bootstrap/me`
3. `POST /bootstrap/organizations` (if user has no organization)
4. `POST /bootstrap/databases` or `POST /bootstrap/projects`
5. `POST /bootstrap/databases/:id/setup` (database sources)
6. `POST /bootstrap/source-tokens` to mint a source token
7. Use the source token with regular `/api/v1/*` endpoints

## Endpoints

:::signature POST /bootstrap/signup
email | String | required |  | User email.
password | String | required |  | User password.
name | String | optional |  | Display name.
organization_name | String | optional |  | Create organization on signup.
token_name | String | optional | `CLI token` | User API token label.
:::

:::signature POST /bootstrap/login
email | String | required |  | User email.
password | String | required |  | User password.
token_name | String | optional | `CLI token` | User API token label.
:::

:::signature GET /bootstrap/me
 |  |  |  | Returns user + organization/membership context for the user API token.
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

:::signature POST /bootstrap/source-tokens
source_type | String | required |  | `database` or `project`.
source_id | String | required |  | Source UUID.
name | String | optional | `CLI source token` | Token label.
read | Bool | optional | `true` | Project token read permission.
write | Bool | optional | `true` | Project token write permission.
:::

## Example (login + source token)

```sh
curl -s https://app.trifle.io/api/v1/bootstrap/login \
  -H "content-type: application/json" \
  -d '{"email":"user@example.com","password":"secret"}'
```

Then use returned user token:

```sh
curl -s https://app.trifle.io/api/v1/bootstrap/source-tokens \
  -H "authorization: Bearer <USER_API_TOKEN>" \
  -H "content-type: application/json" \
  -d '{"source_type":"project","source_id":"<PROJECT_ID>","name":"CLI write"}'
```

The returned `data.token.value` is the source token used for `/api/v1/metrics`, `/api/v1/source`, etc.

## Example (SQLite upload)

Use multipart when uploading a SQLite file directly:

```sh
curl -s https://app.trifle.io/api/v1/bootstrap/databases \
  -H "authorization: Bearer <USER_API_TOKEN>" \
  -F "display_name=SQLite Upload" \
  -F "driver=sqlite" \
  -F "sqlite_file=@./metrics.sqlite"
```

Storage location depends on deployment config:
- `app.sqliteStorage.backend: local` stores files under `app.sqliteUpload.rootPath` (for example `organization_<organization_id>/sqlite/...`).
- `app.sqliteStorage.backend: s3` stores files in the configured S3-compatible bucket/prefix and caches locally on app nodes for reads.

Upload size is enforced by `TRIFLE_SQLITE_UPLOAD_MAX_BYTES` (Helm: `app.sqliteUpload.maxBytes`).
