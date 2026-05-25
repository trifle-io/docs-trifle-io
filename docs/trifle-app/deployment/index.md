---
title: Deployment
description: Learn how you can deploy Trifle App on your own.
nav_order: 3
---

# Deployment

Trifle App ships as a public Docker image, so you can run it anywhere that speaks containers. The supported path is Kubernetes via the built-in Helm chart.

:::callout note "SaaS vs self-hosted"
- If you want Trifle-managed hosting, use [app.trifle.io](https://app.trifle.io) and skip this section.
- Everything below assumes self-hosting.
:::

## What you’re deploying

- A single application container (Phoenix app) plus its dependencies (Postgres).
- The Helm chart can run Postgres for you or connect to an external database.
- The chart runs migrations and bootstraps the initial admin user.
- Database sources can use direct networking, IP allowlists, SSH tunnels, or [Private Connectors](/trifle-app/databases/secure-connections), depending on where Trifle App runs relative to the database.

:::callout note "Short version"
- Helm is the paved road. Docker is the dirt path that still gets you there.
:::

## Recommended path: Helm

The Helm chart lives in the Trifle repo and is the fastest way to get a stable install:

- **Chart location**: `.devops/kubernetes/helm/trifle`
- **Values**: start from `values.yaml` and override what you need
- **Typical flow**: install → set `initialUser` → configure ingress → go live

From there, follow the dedicated docs:

- [Installation](/trifle-app/deployment/installation)
- [Configuration](/trifle-app/deployment/configuration)

## Docker deployment (Compose example)

You can run the same image with plain Docker or Docker Compose. The Trifle repo ships a production-grade Compose setup you can start from.

:::tabs
@tab docker-compose.yml (excerpt)
```yaml
services:
  postgres:
    image: postgres:15-alpine
  mongodb:
    image: mongo:7-jammy
  redis:
    image: redis:7-alpine
  app:
    build:
      context: ../../..
      dockerfile: .devops/docker/production/Dockerfile
    environment:
      DATABASE_URL: "postgresql://trifle:${POSTGRES_PASSWORD:-changeme}@postgres:5432/trifle_prod"
      MONGODB_URL: "mongodb://trifle:${MONGO_PASSWORD:-changeme}@mongodb:27017/trifle_metrics"
      REDIS_URL: "redis://redis:6379"
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      PHX_HOST: ${PHX_HOST:-localhost}
```

@tab .env example
```sh
POSTGRES_PASSWORD=your_secure_postgres_password
MONGO_PASSWORD=your_secure_mongo_password
SECRET_KEY_BASE=your_64_character_secret_key_base
PHX_HOST=trifle.example.com
```
:::

Quick run (from the repo root):

```sh
cd trifle/.devops/docker/production
cp .env.example .env
docker-compose up -d
docker-compose exec app ./bin/trifle eval "Trifle.Release.migrate"
```

:::callout note "Self-hosted defaults"
- If you leave projects disabled, the UI exposes **Database** sources only.
- Enable projects (and Mongo) before using API ingestion.
:::
