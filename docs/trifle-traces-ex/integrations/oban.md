---
title: Oban
description: Trace Oban job execution with Telemetry.
nav_order: 3
---

# Oban

Add the handler before Oban in the supervision tree:

```elixir
children = [
  {Trifle.Traces.Oban, []},
  {Oban, Application.fetch_env!(:my_app, Oban)}
]
```

All jobs are traced by default. The key is `jobs/<worker-module>` and metadata
contains job ID, queue, worker, attempt, and arguments.

```elixir
{Trifle.Traces.Oban,
 selector: fn job -> job.queue in ["billing", "imports"] end,
 key: fn job -> "jobs/#{job.queue}/#{job.worker}" end,
 mode: fn job -> if job.queue == "imports", do: :deferred, else: :live end}
```

Stop events wrap up successfully. Exception events record the reason and mark
the trace failed without changing Oban's retry or discard behavior.
