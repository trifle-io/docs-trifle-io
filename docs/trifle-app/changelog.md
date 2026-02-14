---
title: Changelog
description: Releases and changes in a chronological order.
nav_order: 100
---

# Changelog

### **0.12.6** - *February 13, 2026*
  - feat: improve navbar highlighting.
  - fix: project settings link.
  - feat: move retention mode setup to project creation flow.

### **0.12.5** - *February 12, 2026*
  - feat: add billing with Stripe subscriptions.
  - feat: add CI `.env` support and CI/devops configuration updates.
  - fix: apply follow-up fixes from testing and product feedback.
  - feat: clean up UI styling in billing-related screens.

### **0.12.4** - *February 10, 2026*
  - feat: update Trifle logo.
  - feat: update favicon assets.

### **0.12.3** - *February 5, 2026*
  - feat: support splat indicators with nested values.
  - feat: support scatter timeseries widgets.
  - feat: update Trifle.Stats dependency integration.
  - feat: improve Project Cluster setup.

### **0.12.2** - *February 5, 2026*
  - fix: convert timestamps to the correct project timezone in metrics API.

### **0.12.1** - *February 4, 2026*
  - feat: wire `TRIFLE_DB_ENCRYPTION_KEY` into deployment configuration.

### **0.12.0** - *February 4, 2026*
  - feat: support multiple Project Clusters.
  - feat: add database credential encryption plumbing for project clusters.
  - fix: seed script updates.

### **0.11.11** - *February 1, 2026*
  - feat: clean up series normalization.
  - fix: normalize string values in normalized responses.

### **0.11.10** - *February 1, 2026*
  - chore: release alignment tag (no additional app code changes vs `0.11.9`).

### **0.11.9** - *February 1, 2026*
  - feat: normalize API payloads.
  - feat: move CLI into separate `trifle-cli` repository.
  - fix: decimals handling and MongoProject driver parity.

### **0.11.8** - *January 17, 2026*
  - feat: API for Dashboards and Monitors
  - feat: improve content state between dashboard and form
  - feat: tweak CLI input validation

### **0.11.7** - *January 15, 2026*
  - fix: enable API for all deployments

### **0.11.6** - *January 15, 2026*
  - fix: Health endpoint change

### **0.11.5** - *January 15, 2026*
  - feat: move API to v1 and CLI with MCP
  - feat: Database with Tokens and API for metrics and transponders
  - fix: Copy public dashboard link
