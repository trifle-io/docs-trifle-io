---
title: Changelog
description: Releases and changes in a chronological order.
nav_order: 100
---

# Changelog

### **2.0.0** - *July 6, 2026*
  - Feature: Driver-based persistence. Trace metadata persists through an index driver (`Mongo`, `Memory`, `Null`) and payloads through a data driver (`S3`, `File`, `Memory`, `Null`).
  - Feature: Per-tracer write modes: `:live` (default) and `:deferred` (single write at wrapup for high-volume jobs). Configurable via `sidekiq_options tracer_mode:` or the tracer's `mode:` argument.
  - Feature: Read API: `Trifle::Traces.find`, `.search` (segment/tags/state, newest-first, cursor pagination), `.payload` and `.read_artifact`.
  - Feature: Retention as data (`retention` days, `expires_at`) mapped to Mongo TTL and S3 lifecycle rules; oversized messages offload to artifacts.
  - Breaking: `:liftoff` callback return values no longer become `tracer.reference`; references come from the index driver. Callbacks are notification hooks; persistence belongs in drivers.
  - Breaking: persistence errors surface instead of being swallowed; `bump` failures re-queue data and retry on the next flush (`config.error_handler`).
  - Fix: serializer fallback no longer crashes when the configured serializer raises.

### **1.2.0** - *July 7, 2025*
  - Feature: Hash supports nesting of blocks.

### **1.1.2** - *August 13, 2023*
  - Feature: Fallback to `inspect` serializer if cerrent serializer crashes serialization.

### **1.1.1** - *August 13, 2023*
  - Fix: Do not ignore default configuration when picking serializer. (Sorry bout that.)

### **1.1.0** - *August 13, 2023*
  - Feature: Introduce payload serializers.

### **1.0.2** - *November 21, 2022*
  - Feature: Sidekiq 7 middleware support.

### **1.0.1** - *November 16, 2022*
  - Fix: No refactoring ends up without a typo. Am I right? 1.0.0 has been yanked.

### **1.0.0** - *November 16, 2022*
  - Feature: Rename from Trifle::Logger to Trifle::Traces and release as stable.

### **0.4.1** - *March 28, 2022*
  - Feature: Pop data and artifacts.

### **0.4.0** - *March 28, 2022*
  - Feature: Tracer line uses `type` instead of multiple flags.

### **0.3.1** - *January 11, 2022*
  - Feature: Allow reference to be passed into Tracer directly.

### **0.3.0** - *January 11, 2022*
  - Feature: Rename `tracer_klass` to `tracer_class` and use it consistently througout middlewarees.

### **0.2.2** - *January 11, 2022*
  - Feature: Allow tracer to accept custom configuration.

### **0.2.1** - *July 11, 2021*
  - Fix: Remove ruby 2.x from github actions.
  - Chore: Update MIT license.

### **0.2.0** - *June 01, 2021*
  - Feature: Add Liftoff and Bump callbacks.

### **0.1.4** - *May 18, 2021*
  - Feature: Tracer with warning state.

### **0.1.3** - *May 07, 2021*
  - Feature: Allow logger to be ignored.

### **0.1.2** - *March 29, 2021*
  - Fix: Something?

### **0.1.1** - *March 29, 2021*
  - Fix: Wrong preffix for artifacts.

### **0.1.0** - *March 28, 2021*
  - Feature: Artifacts and media lines.

### **0.0.2** - *February 08, 2021*
  - Fix: Something?

### **0.0.1** - *February 08, 2021*
  - Feature: Initial version. Introduces Tracer, Callback and Middlewares.
