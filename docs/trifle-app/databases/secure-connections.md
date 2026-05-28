---
title: Secure Connections
description: Choose how Trifle App reaches private database sources.
nav_order: 1
---

# Secure Connections

Trifle App supports several ways to reach database sources. Pick the smallest connection surface that works for your deployment.

:::callout note "Rule of thumb"
- **Self-hosted, same cluster/VPC**: use direct connection.
- **Trifle Cloud with a public firewall**: use direct connection plus IP allowlist.
- **Private network with a bastion**: use SSH tunnel.
- **No inbound network path, multiple clusters, or stronger isolation**: use Private Connector.
:::

## Options at a glance

| Option | Best for | Inbound access required? | Operational shape |
| --- | --- | --- | --- |
| Direct | Self-hosted Trifle App near the database | No, if already on the same private network | Trifle App connects to the database host directly. |
| Direct + IP allowlist | Trifle Cloud to a database with a controlled public endpoint | Yes, from Trifle Cloud egress IPs | Add Trifle egress IPs to the database firewall or security group. |
| SSH tunnel | Private database behind a bastion host | Yes, SSH to the bastion | Trifle App opens an SSH tunnel, then connects to the private database through it. |
| Private Connector | Networks that do not allow inbound traffic from Trifle | No | A container inside your network polls Trifle over outbound HTTPS and handles private connectivity. |

## Direct connection

Use direct connection when Trifle App can already resolve and reach the database host.

This is usually the right choice for:

- Self-hosted Trifle App and database in the same Kubernetes cluster.
- Self-hosted Trifle App and database in the same VPC or private network.
- Development and staging environments where the database is intentionally reachable.

When creating or editing a database source, set **Connection Method** to **Direct + IP allowlist** and enter the normal database host, port, database name, and credentials. If Trifle App already runs on the same private network as the database, no allowlist step is needed.

:::callout warn "Avoid public-by-default databases"
Direct does not mean unauthenticated. Keep database authentication, TLS, firewall rules, and least-privilege database users in place.
:::

## Direct + IP allowlist

Use IP allowlisting when Trifle Cloud needs to connect to a database endpoint that is reachable from the internet but protected by a firewall, cloud security group, or database access list.

Flow:

1. In Trifle App, open the database form and choose **Direct + IP allowlist**.
2. Copy the Trifle Cloud egress IPs shown in the form.
3. Add those IPs to your database firewall, security group, or provider access list.
4. Save the database source and test the connection.

If the form says static egress IPs are not configured, the current deployment cannot show a fixed allowlist. For self-hosted deployments, set `TRIFLE_CLOUD_EGRESS_IPS` in the app environment if you want the UI to display your own egress addresses.

Example:

```sh
TRIFLE_CLOUD_EGRESS_IPS="203.0.113.10,203.0.113.11"
```

## SSH tunnel

Use an SSH tunnel when the database is private but a bastion host is intentionally reachable from Trifle.

The tunnel keeps the database itself off the public internet. Trifle connects to the bastion over SSH, then opens a local tunnel to the database host and port you configured.

Required fields:

| Field | Meaning |
| --- | --- |
| Bastion Host | Public or private hostname of the SSH bastion. |
| Bastion Port | SSH port. Defaults to `22`. |
| SSH Username | User Trifle should authenticate as on the bastion. |
| Trifle Public Key | Add this generated key to the bastion user's `authorized_keys`. |
| Host Key Fingerprint | Expected bastion host key fingerprint, such as `SHA256:...`. |

Recommended bastion setup:

- Create a dedicated SSH user for Trifle.
- Restrict that user to port forwarding where possible.
- Allow forwarding only to the database hosts and ports Trifle needs.
- Pin the bastion host key fingerprint in Trifle.
- Rotate the key if access is no longer needed.

## Private Connector

Private Connector is the outbound-only option. It is a small container image that runs inside your network and connects back to Trifle over HTTPS. You do not open inbound firewall rules from Trifle Cloud to your network.

:::callout note "Availability"
The connector registers with Trifle, reports health, checks database reachability, and serves connector-backed database queries over outbound HTTPS.
:::

Use Private Connector when:

- Your database has no public endpoint.
- Your security policy rejects inbound SSH from SaaS services.
- You run databases across multiple clusters, VPCs, regions, or customer-isolated networks.
- You want a separate connector per network boundary.

### Create a connector

1. Go to **Organization -> Connectors**.
2. Click **New connector**.
3. Give it a descriptive name, such as `Production VPC` or `EU Redis Cluster`.
4. Copy the token immediately. It is only shown once.
5. Run the generated install command inside the network that can reach the database.

The generated command includes the connector ID and one-time token. Choose the deployment shape that matches your environment:

::::tabs
@tab Docker

```sh
docker run -d --name trifle-connector \
  -e TRIFLE_CLOUD_URL='https://app.trifle.io' \
  -e TRIFLE_CONNECTOR_ID='<connector-id>' \
  -e TRIFLE_CONNECTOR_TOKEN='<one-time-token>' \
  -e TRIFLE_CONNECTOR_NAME='Production VPC' \
  -e TRIFLE_CONNECTOR_ALLOWED_HOSTS='db.internal:5432' \
  trifle/connector:latest
```

@tab Kubernetes

```sh
cat > trifle-connector.yaml <<'YAML'
apiVersion: v1
kind: Secret
metadata:
  name: trifle-connector
type: Opaque
stringData:
  TRIFLE_CONNECTOR_TOKEN: '<one-time-token>'
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trifle-connector
  labels:
    app.kubernetes.io/name: trifle-connector
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: trifle-connector
  template:
    metadata:
      labels:
        app.kubernetes.io/name: trifle-connector
    spec:
      containers:
        - name: connector
          image: trifle/connector:latest
          imagePullPolicy: Always
          env:
            - name: TRIFLE_CLOUD_URL
              value: 'https://app.trifle.io'
            - name: TRIFLE_CONNECTOR_ID
              value: '<connector-id>'
            - name: TRIFLE_CONNECTOR_NAME
              value: 'Production VPC'
            - name: TRIFLE_CONNECTOR_ALLOWED_HOSTS
              value: 'db.internal:5432'
            - name: TRIFLE_CONNECTOR_HEALTH_ADDR
              value: '0.0.0.0:8080'
            - name: TRIFLE_CONNECTOR_TOKEN
              valueFrom:
                secretKeyRef:
                  name: trifle-connector
                  key: TRIFLE_CONNECTOR_TOKEN
          ports:
            - name: http
              containerPort: 8080
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 10
            periodSeconds: 30
YAML

kubectl apply -f trifle-connector.yaml
```
::::

Then edit the database source:

1. Set **Connection Method** to **Private Connector**.
2. Choose the connector.
3. Keep database credentials on the database source. Do not put database usernames or passwords into the connector container environment.

### Connector environment

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `TRIFLE_CONNECTOR_TOKEN` | Yes | | Bearer token issued when you create the connector. |
| `TRIFLE_CLOUD_URL` | No | `https://app.trifle.io` | Trifle App base URL. Use your own host for self-hosted control planes. |
| `TRIFLE_CONNECTOR_ID` | No | container hostname | Stable connector identifier. The generated command sets this. |
| `TRIFLE_CONNECTOR_NAME` | No | | Human-readable connector name. |
| `TRIFLE_CONNECTOR_ALLOWED_HOSTS` | Yes | | Comma-separated allowlist such as `db.internal:5432,redis.internal:6379,10.20.0.0/16`. Connector-backed database checks and queries are blocked unless the target is allowed. |
| `TRIFLE_CONNECTOR_CAPABILITIES` | No | `postgres,mysql,mongo,redis` | Capabilities reported to Trifle. |
| `TRIFLE_CONNECTOR_HEALTH_ADDR` | No | `127.0.0.1:8080` | Local health server bind address. |
| `TRIFLE_CONNECTOR_POLL_INTERVAL` | No | `5s` | Control-plane polling interval. Numeric values are seconds. |
| `TRIFLE_CONNECTOR_HEARTBEAT_INTERVAL` | No | `30s` | Heartbeat interval. Numeric values are seconds. |
| `TRIFLE_CONNECTOR_REQUEST_TIMEOUT` | No | `15s` | Control-plane request timeout. |
| `TRIFLE_CONNECTOR_CA_FILE` | No | | PEM bundle for private CAs. |
| `TRIFLE_CONNECTOR_INSECURE_SKIP_VERIFY` | No | `false` | Disables TLS verification. Development only. |
| `TRIFLE_CONNECTOR_CONTROL_PLANE_DISABLED` | No | `false` | Runs health checks only, useful for deployment smoke tests. |

:::callout warn "Connector names are final"
Use the `TRIFLE_CONNECTOR_*` variables and the `trifle/connector` image. Older `TRIFLE_AGENT_*` names are not supported.
:::

### Allowed hosts

`TRIFLE_CONNECTOR_ALLOWED_HOSTS` is the connector's network guardrail. Keep it as narrow as practical.

Supported entries:

- `host` - any port on that host.
- `host:port` - one host and one port.
- `*.svc.cluster.local` - subdomains only.
- `10.20.0.0/16` - CIDR range.
- `*` - any host, useful only for short development tests.

Prefer explicit `host:port` rules in production.

### Health checks

The image includes a Docker health check:

```sh
docker inspect --format '{{json .State.Health}}' trifle-connector
```

If you expose the health endpoint locally, the connector serves:

- `GET /healthz` - process health.
- `GET /readyz` - runtime status, including last heartbeat, last poll, and last error.

To expose it:

```sh
docker run -d --name trifle-connector \
  -p 8080:8080 \
  -e TRIFLE_CONNECTOR_HEALTH_ADDR='0.0.0.0:8080' \
  -e TRIFLE_CONNECTOR_TOKEN='<one-time-token>' \
  -e TRIFLE_CONNECTOR_ALLOWED_HOSTS='db.internal:5432' \
  trifle/connector:latest
```

Do not expose the health endpoint publicly unless your platform adds its own authentication and network controls.

## Credentials and rotation

Database credentials are configured on the database source and stored by Trifle App. Use least-privilege database users that can read Trifle Stats tables, collections, or keys.

Recommended rotation practices:

- Rotate database passwords independently from connection method changes.
- Rotate SSH keys by creating a new Trifle public key and removing the old key from the bastion.
- Rotate connector access by deleting the connector and creating a new one, then updating database sources to use the new connector.
- Remove unused direct allowlist IPs and connector allowed-host entries.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Direct connection times out | Database firewall, cloud security group, DNS, and whether Trifle's egress IPs are allowlisted. |
| SSH tunnel fails before database connection | Bastion hostname, SSH port, username, authorized key, and host key fingerprint. |
| Connector remains pending | Container logs, `TRIFLE_CLOUD_URL`, `TRIFLE_CONNECTOR_TOKEN`, TLS trust, and outbound HTTPS access. |
| Connector blocks a target | `TRIFLE_CONNECTOR_ALLOWED_HOSTS` must include the exact host or CIDR and, if specified, the target port. |
| Works in self-hosted but not Trifle Cloud | Cloud needs an explicit network path: IP allowlist, SSH tunnel, or Private Connector. |

When in doubt, start with the narrowest possible target and test one database host and port at a time.
