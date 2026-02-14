---
title: Installation
description: Install trifle_stats_go and import it into your Go project.
nav_order: 1
---

# Installation

Add the Go module to your project:

```sh
go get github.com/trifle-io/trifle_stats_go
```

The SQLite driver uses the pure-Go `modernc.org/sqlite` module. No CGO is required.

Optional driver dependencies used by `trifle_stats_go`:

- PostgreSQL: `github.com/jackc/pgx/v5/stdlib`
- MySQL: `github.com/go-sql-driver/mysql`
- Redis: `github.com/redis/go-redis/v9`
- MongoDB: `go.mongodb.org/mongo-driver`
