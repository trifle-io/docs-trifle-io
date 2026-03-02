---
title: Changelog
description: Releases and changes in a chronological order.
nav_order: 100
---

# Changelog

### **0.7.0** - *February 15, 2026*
  - Feat: Add Bootstrap endpoints.
  - Feat: Add Database endpoints.
  - Feat: Add Source endpoints.
  - Yup, agents can go all the way from 0 to dashboard with API only!

### **0.6.0** - *February 25, 2026*
  - Feat: better SQLite compatibility

### **0.5.1** - *February 21, 2026*
  - Fix: Ugh, release with correctly tagged version.

### **0.5.0** - *February 21, 2026*
  - Feat: Homebrew tap auto-release.

### **0.4.0** - *February 15, 2026*
  - Fix: Just readme, lol.

### **0.3.0** - *February 16, 2026*
  - Feat: Automate release process. 

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
