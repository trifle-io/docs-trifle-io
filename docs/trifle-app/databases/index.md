---
title: Databases
description: Database sources and secure connection options.
nav_order: 2.5
---

# Databases

Database sources let Trifle App read metrics that your application already writes through Trifle Stats. They are useful when you want dashboards and monitors without sending every metric through the Trifle API.

## What lives here

- [Secure Connections](/trifle-app/databases/secure-connections): choose between direct access, IP allowlists, SSH tunnels, and Private Connectors.

## Source model

Database sources are read-only from Trifle App's perspective. Your application writes metrics into Redis, Postgres, MongoDB, MySQL, or SQLite through a Trifle Stats driver. Trifle App connects to that same storage to query series for Explore, dashboards, and monitors.

:::callout note "Cloud vs self-hosted"
- In Trifle Cloud, secure connectivity is mostly about letting Trifle reach a database that lives in your network.
- In self-hosted deployments, Trifle App often runs next to the database already. You may still need SSH tunnels or Private Connectors for multi-cluster, multi-VPC, or stricter isolation setups.
:::
