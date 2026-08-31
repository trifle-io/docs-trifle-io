---
title: Processes and Tasks
description: Propagate a tracer safely across BEAM processes.
nav_order: 5
---

# Processes and Tasks

The current tracer is process-local. A Task does not inherit it automatically.
Pass the tracer PID and attach it explicitly:

```elixir
tracer = Trifle.Traces.current_tracer()

1..4
|> Enum.map(fn item ->
  Task.async(fn ->
    Trifle.Traces.attach(tracer, fn ->
      Trifle.Traces.trace("Processing #{item}", fn -> process(item) end)
    end)
  end)
end)
|> Task.await_many()
```

The tracer serializes state updates and tracks nesting depth independently for
each caller. Parallel Tasks can therefore share one timeline without making
each other's entries look nested.

`attach/2` restores the Task's previous tracer after the function completes.
It does not wrap up the shared tracer; the process that owns the overall
operation remains responsible for wrapup.
