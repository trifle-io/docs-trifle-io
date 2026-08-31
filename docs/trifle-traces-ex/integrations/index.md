---
title: Integrations
description: Trace Phoenix requests, generic Plug endpoints, and Oban jobs.
nav_order: 7
---

# Integrations

- [Phoenix](/trifle-traces-ex/integrations/phoenix) uses endpoint Telemetry
  events and captures both normal responses and exceptions.
- [Plug](/trifle-traces-ex/integrations/plug) wraps generic endpoints or
  traces successful responses as a pipeline plug.
- [Oban](/trifle-traces-ex/integrations/oban) uses job Telemetry events.

Integration callbacks execute in the request or job process, so the current
tracer is available to application code without passing its PID manually.
