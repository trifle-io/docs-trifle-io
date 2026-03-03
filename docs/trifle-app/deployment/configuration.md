---
title: Configuration
description: All Helm values for Trifle App.
nav_order: 2
---

# Configuration

Everything below maps 1:1 to the Helm chart values in `.devops/kubernetes/helm/trifle/values.yaml`.

:::callout note "Self-hosted only"
These settings apply to the Helm chart. SaaS users don’t need to configure any of this.
:::

## High-impact values

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `app.secretKeyBase` | String | `""` | **Required**. 64+ char secret for Phoenix. |
| `app.host` | String | `"trifle.local"` | Public host name for links and redirects. |
| `app.deploymentMode` | String | `"self_hosted"` | `self_hosted` or `saas`. |
| `features.projects.enabled` | Boolean | `false` | Enable project sources (requires Mongo). |
| `app.mongodbUrl` | String | `""` | External Mongo URL (required if projects enabled). |
| `postgresql.enabled` | Boolean | `true` | Use bundled Postgres. Disable when using external. |
| `externalPostgresql.host` | String | `""` | External Postgres host (used when bundled DB disabled). |
| `ingress.enabled` | Boolean | `false` | Expose via ingress. |
| `initialUser.enabled` | Boolean | `true` | Create initial admin user at install. |
| `initialUser.email` | String | `""` | Email for initial admin user (set this). |
| `initialUser.password` | String | `"password"` | Initial admin password (change immediately). |
| `app.registration.enabled` | Boolean | `true` | Allow new user signups. |
| `app.timezone` | String | `"UTC"` | Default time zone for UI and exports. |
| `app.logLevel` | String | `"info"` | Log verbosity. |
| `app.sqliteUpload.maxBytes` | Integer | `104857600` | Max SQLite upload size in bytes (100MB). |
| `app.sqliteUpload.rootPath` | String | `"/home/app/uploads/sqlite"` | Root path for uploaded SQLite files. |
| `healthCheck.enabled` | Boolean | `true` | Enable readiness/liveness probes. |
| `persistence.enabled` | Boolean | `true` | Persist uploads on a PVC. |

:::callout warn "Required secrets"
- Set `app.secretKeyBase` in production.
- If `features.projects.enabled: true`, configure Mongo (`app.mongodbUrl` or the Mongo sidecar).
:::

## Example configurations

:::tabs
@tab Minimal self-hosted
```yaml
app:
  secretKeyBase: "<your-64-char-secret>"
  host: "trifle.example.com"
  registration:
    enabled: false

initialUser:
  enabled: true
  email: "admin@trifle.example.com"
  password: "change-me"
  admin: true

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: trifle.example.com
      paths:
        - path: /
          pathType: Prefix
```

@tab External Postgres (secret)
```yaml
postgresql:
  enabled: false

externalPostgresql:
  host: "postgres.example.com"
  port: 5432
  username: "trifle"
  database: "trifle_prod"
  existingSecret: "postgres-credentials"
  existingSecretPasswordKey: "password"

app:
  secretKeyBase: "<your-64-char-secret>"
  host: "trifle.example.com"
```

@tab Projects + external Mongo
```yaml
features:
  projects:
    enabled: true

app:
  mongodbUrl: "mongodb://mongo.example.com:27017/trifle"

mongo:
  sidecar:
    enabled: false
```

@tab SMTP mailer
```yaml
app:
  mailer:
    adapter: "smtp"
    from:
      name: "Trifle"
      email: "no-reply@example.com"
    smtp:
      relay: "smtp.example.com"
      username: "smtp-user"
      password: "smtp-password"
      port: 587
      auth: "if_available"
      tls: "if_available"
      ssl: false
```

@tab Slack + Google SSO
```yaml
app:
  slack:
    clientId: "<SLACK_CLIENT_ID>"
    clientSecret: "<SLACK_CLIENT_SECRET>"
    signingSecret: "<SLACK_SIGNING_SECRET>"
    redirectUri: "https://trifle.example.com/integrations/slack/oauth/callback"
  googleOAuth:
    clientId: "<GOOGLE_OAUTH_CLIENT_ID>"
    clientSecret: "<GOOGLE_OAUTH_CLIENT_SECRET>"
    redirectUri: "https://trifle.example.com/auth/google/callback"
```

@tab Ingress + cert-manager
```yaml
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: trifle.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: trifle-tls
      hosts:
        - trifle.example.com

certManager:
  enabled: true
  kind: "Issuer"
  email: "admin@example.com"
```
:::

## Core

- `replicaCount` (int, default: `2`) Number of app replicas when autoscaling is disabled.
- `nameOverride` (string) Override the chart name.
- `fullnameOverride` (string) Override the release name.

## Image

- `image.repository` (string, default: `trifle/app`) Container image repository.
- `image.pullPolicy` (string, default: `IfNotPresent`) K8s pull policy.
- `image.tag` (string, default: `""`) Image tag. Empty means use chart `appVersion`.
- `imagePullSecrets` (list) Secrets for pulling from private registries.

## Service Account

- `serviceAccount.create` (bool, default: `true`) Create a dedicated service account.
- `serviceAccount.annotations` (map) Annotations for the service account.
- `serviceAccount.name` (string) Use an existing service account name.

## Pod + Security

- `podAnnotations` (map) Extra pod annotations.
- `podSecurityContext` (map) Pod-level security context.
- `securityContext` (map) Container-level security context.

## Service

- `service.type` (string, default: `ClusterIP`) Service type.
- `service.port` (int, default: `80`) Service port.
- `service.targetPort` (int, default: `4000`) Container port.

## Ingress

- `ingress.enabled` (bool, default: `false`) Enable ingress.
- `ingress.className` (string) Ingress class (e.g. `nginx`).
- `ingress.annotations` (map) Ingress annotations.
- `ingress.hosts` (list)
  - `host` (string) Hostname (e.g. `app.trifle.io`).
  - `paths` (list)
    - `path` (string, default: `/`) Path.
    - `pathType` (string, default: `Prefix`) Path type.
- `ingress.tls` (list)
  - `secretName` (string) TLS secret.
  - `hosts` (list) Hosts covered by the cert.

## cert-manager

- `certManager.enabled` (bool, default: `false`) Create Issuer/ClusterIssuer.
- `certManager.kind` (string, default: `Issuer`) Use `Issuer` or `ClusterIssuer`.
- `certManager.server` (string) ACME directory URL.
- `certManager.email` (string) Email for ACME registration.

## Resources

- `resources.limits.cpu` (string, default: `1000m`) CPU limit.
- `resources.limits.memory` (string, default: `1Gi`) Memory limit.
- `resources.requests.cpu` (string, default: `500m`) CPU request.
- `resources.requests.memory` (string, default: `512Mi`) Memory request.

## Autoscaling

- `autoscaling.enabled` (bool, default: `false`) Enable HPA.
- `autoscaling.minReplicas` (int, default: `2`) Minimum replicas.
- `autoscaling.maxReplicas` (int, default: `10`) Maximum replicas.
- `autoscaling.targetCPUUtilizationPercentage` (int, default: `80`) CPU utilization target.
- `autoscaling.targetMemoryUtilizationPercentage` (int, optional) Memory utilization target.

## Scheduling

- `nodeSelector` (map) Node selection.
- `tolerations` (list) Tolerations.
- `affinity` (map) Affinity/anti-affinity rules.

## App

### Core settings

- `app.secretKeyBase` (string, required) Maps to `SECRET_KEY_BASE`.
- `app.host` (string, default: `trifle.local`) Maps to `PHX_HOST`.
- `app.port` (int, default: `4000`) Maps to `PORT`.
- `app.poolSize` (int, default: `10`) Maps to `POOL_SIZE`.
- `app.timezone` (string, default: `UTC`) Maps to `TZ`.
- `app.logLevel` (string, default: `info`) Maps to `LOGGER_LEVEL`.
- `app.mongodbUrl` (string, optional) Maps to `MONGODB_URL`. If empty, Mongo defaults to `mongodb://localhost:27017/trifle` (useful with the sidecar).

### SQLite uploads

- `app.sqliteUpload.maxBytes` (int, default: `104857600`) Maps to `TRIFLE_SQLITE_UPLOAD_MAX_BYTES`.
- `app.sqliteUpload.rootPath` (string, default: `/home/app/uploads/sqlite`) Maps to `TRIFLE_SQLITE_UPLOAD_ROOT`.
- Use a path on persistent storage when `persistence.enabled: true`.

### Environment overrides

- `app.env` (map) Key-value env vars injected into the app container and jobs.
  - Defaults: `MIX_ENV=prod`, `PHX_SERVER=true`, `LOG_TO_STDOUT=auto`.
  - You can still override `TRIFLE_SQLITE_UPLOAD_MAX_BYTES` and `TRIFLE_SQLITE_UPLOAD_ROOT` here if needed.

### Registration + deployment mode

- `app.registration.enabled` (bool, default: `true`) Maps to `REGISTRATION_ENABLED`.
- `app.deploymentMode` (string, default: `self_hosted`) Maps to `TRIFLE_DEPLOYMENT_MODE` (`self_hosted` or `saas`).

### Honeybadger

- `app.honeybadger.apiKey` (string) Maps to `HONEYBADGER_API_KEY`.

### AppSignal

- `app.appsignal.enabled` (bool, default: `false`)
- `app.appsignal.otpApp` (string, default: `trifle`) Maps to `APPSIGNAL_OTP_APP`.
- `app.appsignal.appName` (string, default: `Trifle App`) Maps to `APPSIGNAL_APP_NAME`.
- `app.appsignal.appEnv` (string, default: `prod`) Maps to `APPSIGNAL_APP_ENV`.
- `app.appsignal.pushApiKey` (string) Maps to `APPSIGNAL_PUSH_API_KEY`.

### New Relic

- `app.newrelic.enabled` (bool, default: `false`)
- `app.newrelic.appName` (string, default: `Trifle App`) Maps to `NEW_RELIC_APP_NAME`.
- `app.newrelic.appEnv` (string, default: `prod`) Maps to `NEW_RELIC_APP_ENV`.
- `app.newrelic.licenseKey` (string) Maps to `NEW_RELIC_LICENSE_KEY`.

### OpenAI (chat)

- `app.openai.apiKey` (string) Maps to `OPENAI_API_KEY`.
- `app.openai.model` (string, default: `gpt-5`) Maps to `OPENAI_MODEL`.

### Slack

- `app.slack.clientId` (string) Maps to `SLACK_CLIENT_ID`.
- `app.slack.clientSecret` (string) Maps to `SLACK_CLIENT_SECRET`.
- `app.slack.signingSecret` (string) Maps to `SLACK_SIGNING_SECRET`.
- `app.slack.redirectUri` (string) Maps to `SLACK_REDIRECT_URI`.
- `app.slack.scopes` (string, default: `chat:write,chat:write.public,channels:read,groups:read,incoming-webhook`) Maps to `SLACK_SCOPES`.

### Google OAuth (SSO)

- `app.googleOAuth.clientId` (string) Maps to `GOOGLE_OAUTH_CLIENT_ID`.
- `app.googleOAuth.clientSecret` (string) Maps to `GOOGLE_OAUTH_CLIENT_SECRET`.
- `app.googleOAuth.redirectUri` (string) Maps to `GOOGLE_OAUTH_REDIRECT_URI`.

### Mailer

- `app.mailer.adapter` (string, default: `local`) Supported: `local`, `smtp`, `postmark`, `sendgrid`, `mailgun`, `sendinblue`/`brevo`.
- `app.mailer.from.name` (string, default: `Trifle`) Maps to `MAILER_FROM_NAME`.
- `app.mailer.from.email` (string, default: `contact@example.com`) Maps to `MAILER_FROM_EMAIL`.

SMTP:
- `app.mailer.smtp.relay` (string) Maps to `SMTP_RELAY`.
- `app.mailer.smtp.username` (string) Maps to `SMTP_USERNAME` (secret).
- `app.mailer.smtp.password` (string) Maps to `SMTP_PASSWORD` (secret).
- `app.mailer.smtp.port` (int, default: `587`) Maps to `SMTP_PORT`.
- `app.mailer.smtp.auth` (string, default: `if_available`) Maps to `SMTP_AUTH`.
- `app.mailer.smtp.tls` (string, default: `if_available`) Maps to `SMTP_TLS`.
- `app.mailer.smtp.ssl` (bool, default: `false`) Maps to `SMTP_SSL`.
- `app.mailer.smtp.retries` (int, default: `2`) Maps to `SMTP_RETRIES`.

Postmark:
- `app.mailer.postmark.apiKey` (string) Maps to `POSTMARK_API_KEY`.

SendGrid:
- `app.mailer.sendgrid.apiKey` (string) Maps to `SENDGRID_API_KEY`.

Mailgun:
- `app.mailer.mailgun.apiKey` (string) Maps to `MAILGUN_API_KEY`.
- `app.mailer.mailgun.domain` (string) Maps to `MAILGUN_DOMAIN`.
- `app.mailer.mailgun.baseUrl` (string) Maps to `MAILGUN_BASE_URL`.

Sendinblue/Brevo:
- `app.mailer.sendinblue.apiKey` (string) Maps to `SENDINBLUE_API_KEY`.

## Features

- `features.projects.enabled` (bool, default: `false`) Maps to `TRIFLE_PROJECTS_ENABLED`. Enables project-level metrics and Mongo support.

:::callout note "Project sources require Mongo"
- Enable `features.projects.enabled` **and** provide Mongo (sidecar or `app.mongodbUrl`).
- Without this, the UI hides Projects and API ingestion is disabled.
:::

## Initial User

- `initialUser.enabled` (bool, default: `true`) Run the init-user job on install.
- `initialUser.email` (string) Email for the initial user.
- `initialUser.password` (string, default: `password`) Password for the initial user.
- `initialUser.admin` (bool, default: `true`) Make the user an admin.

## Health Checks

- `healthCheck.enabled` (bool, default: `true`) Enable readiness/liveness.
- `healthCheck.path` (string, default: `/api/v1/health`) Health path.
- `healthCheck.initialDelaySeconds` (int, default: `30`)
- `healthCheck.periodSeconds` (int, default: `10`)
- `healthCheck.timeoutSeconds` (int, default: `5`)
- `healthCheck.failureThreshold` (int, default: `3`)

## Persistence (uploads)

- `persistence.enabled` (bool, default: `true`) Enable PVC for uploads.
- `persistence.storageClass` (string) Storage class.
- `persistence.accessMode` (string, default: `ReadWriteOnce`) Access mode.
- `persistence.size` (string, default: `10Gi`) PVC size.
- `persistence.mountPath` (string, default: `/home/app/uploads`) Mount path inside the container.

## PostgreSQL (internal)

- `postgresql.enabled` (bool, default: `true`) Deploy internal Postgres.
- `postgresql.image.repository` (string, default: `postgres`)
- `postgresql.image.tag` (string, default: `17.6`)
- `postgresql.image.pullPolicy` (string, default: `IfNotPresent`)
- `postgresql.auth.username` (string, default: `trifle`)
- `postgresql.auth.password` (string, default: `changeme`)
- `postgresql.auth.database` (string, default: `trifle_prod`)
- `postgresql.auth.existingSecret` (string) Use an existing secret for the password.
- `postgresql.auth.existingSecretPasswordKey` (string, default: `postgres-password`)
- `postgresql.service.port` (int, default: `5432`)
- `postgresql.persistence.enabled` (bool, default: `true`)
- `postgresql.persistence.storageClass` (string)
- `postgresql.persistence.size` (string, default: `20Gi`)
- `postgresql.persistence.accessModes` (list, default: `[ReadWriteOnce]`)
- `postgresql.resources` (map) Resource requests/limits.
- `postgresql.nodeSelector` (map)
- `postgresql.tolerations` (list)
- `postgresql.affinity` (map)

## PostgreSQL (external)

- `externalPostgresql.host` (string)
- `externalPostgresql.port` (int, default: `5432`)
- `externalPostgresql.username` (string)
- `externalPostgresql.password` (string)
- `externalPostgresql.database` (string)
- `externalPostgresql.existingSecret` (string) Use a secret instead of plain password.
- `externalPostgresql.existingSecretPasswordKey` (string)

Set `postgresql.enabled: false` when using external Postgres.

## Mongo (sidecar)

- `mongo.sidecar.enabled` (bool, default: `true`) Run Mongo sidecar (only used when `features.projects.enabled: true`).
- `mongo.image.repository` (string, default: `mongo`)
- `mongo.image.tag` (string, default: `7.0`)
- `mongo.image.pullPolicy` (string, default: `IfNotPresent`)
- `mongo.resources` (map) Resource requests/limits.
- `mongo.persistence.enabled` (bool, default: `false`)
- `mongo.persistence.storageClass` (string)
- `mongo.persistence.size` (string, default: `10Gi`)
- `mongo.persistence.accessModes` (list, default: `[ReadWriteOnce]`)

:::callout note "Secrets and env vars"
- The Helm chart stores secrets (like API keys and passwords) in a Kubernetes Secret and wires them into env vars automatically.
- Anything under `app.env` is injected directly with no extra opinionated logic.
:::
