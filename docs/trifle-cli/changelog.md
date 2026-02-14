---
title: Changelog
description: Releases and changes in a chronological order.
nav_order: 100
---

# Changelog

### **0.2.0** - *February 14, 2026*
  - Feat: Add support for Redis, MongoDB, Postgres and MySQL.
  - Feat: Add support for Buffering.

### **0.1.2** - *February 1, 2026*
  - Fix: Improve numeric rendering for CSV and table outputs (float and integer types).
  - Fix: Keep CLI output stable across JSON number and native numeric values.

### **0.1.1** - *February 1, 2026*
  - Fix: Decode API JSON responses with `UseNumber` to preserve numeric precision in CLI output.
  - Fix: Improve numeric formatting for table/CSV cells.
  - Chore: Apply linter cleanups across API and output packages.

### **0.1.0** - *February 1, 2026*
  - Feature: Initial public release of `trifle-cli`.
  - Feature: Add metrics commands for API and local SQLite (`get`, `keys`, `aggregate`, `timeline`, `category`, `push`, `setup`).
  - Feature: Add transponder management commands (`list`, `create`, `update`, `delete`).
  - Feature: Add MCP server mode for agent integrations.
  - Chore: Set up CI, linting, and Goreleaser release workflow.
  - Chore: Add README and pin `trifle_stats_go` dependency for standalone releases.
