---
title: Changelog
description: Releases and changes in a chronological order.
nav_order: 100
---

# Changelog

### **2.4.1** - *February 25, 2026*
  - Fix: Nocturnal timezone flooring.

### **2.4.0** - *February 25, 2026*
  - Fix: Better SQLite cross-platform compatibility

### **2.3.0** - *January 23, 2026*
  Another bulk of changes released all at once.
  - Feat: Buffering.
  - Feat: System Tracking.
  - Feat: Postgres and SQLite support for Joined identifiers.
  - Feat: Move from Range to Granularity.
  - Feat: Changes to Transponders and Formatters.
  - Feat: Joined Identifiers with multiple modes.
  - Feat: Deprecate Assort in favor of inline designators.
  - Feat: Mongo Driver option to disable bulk-writes.
  Yea, its a big one.

### **1.6.0** - *July 28, 2025*
  A lot has been introduced in the first half of 2025 but never released. It all finally piled up in this version release.

  - Feat: Beam and Scan for liveness checks
  - Feat: Introduce Aggregators
  - Feat: Introduce Formatters
  - Feat: Introduce Transponders
  - Feat: MongoDB with expire_after
  - Feat: MongoDB with joined_identifier

### **1.3.1** - *August 29, 2022*
  - Fix: Do not require database gems by default.

### **1.3.0** - *August 1, 2022*
  - Feat: Introduce Sqlite driver.
  - Feat: Optimise Postgres driver to use transactions for all periods.
  - Chore: Add performance testing.

### **1.2.0** - *July 31, 2022*
  - Feat: Optimise Postgres driver to `inc` and `set` all values at once.
  - Feat: Optimise Postgres driver to `get` all keys at once.

### **1.1.2** - *July 30, 2022*
  - Fix: Postgres driver does not use `.try` to stay _pure ruby_.

### **1.1.1** - *July 12, 2022*
  - Fix: Obviously wrong order of mongo operations.
  - Chore: Prune 1.1.0 version. Sorry about that.

### **1.1.0** - *July 12, 2022*
  - Feature: MongoDB driver sets and increments all periods at once (single query per operation).

### **1.0.0** - *June 18, 2022*
  - Final stable release.
  - Feature: Change structure of `.values` return hash.
  - Feature: MongoDB driver gets all values at once.
  - Chore: Unify Docker folder structure.

### **0.4.1** - *July 11, 2021*
  - Fix: Update MIT license.
  - Chore: Remove ruby 2.x from github actions.

### **0.4.0** - *July 11, 2021*
  - Feature: Add MongoDB driver.

### **0.3.2** - *April 20, 2021*
  - Fix: Postgres returns empty hash instead of `nil` for missing values.

### **0.3.1** - *April 18, 2021*
  - Fix: `.set` uses correct value in Postgres driver.

### **0.3.0** - *April 18, 2021*
  - Feature: Add Postgres driver.

### **0.2.1** - *April 14, 2021*
  - Fix: Forgotten `set` method on a process driver.

### **0.2.0** - *April 14, 2021*
  - Feature: Add `.assert` method to set values at timestamp.

### **0.1.0** - *January 30, 2021*
  - Feature: Initial version (Transition from BellyWash to Trifle::Ruby 3.x to Trifle::Stats 0.1.0)
  - Chore: Lots of code moved around, but basic functionality is here (`.track` and `.values` methods).
