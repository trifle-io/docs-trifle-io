---
title: Plug
description: Trace generic Plug endpoints and successful pipeline responses.
nav_order: 2
---

# Plug

To cover the complete downstream lifecycle, wrap the endpoint:

```elixir
def call(conn, options) do
  Trifle.Traces.Plug.wrap(conn, options, fn conn ->
    MyRouter.call(conn, MyRouter.init([]))
  end)
end
```

This form records exceptions, wraps up, restores the previous tracer, and
re-raises the original failure.

`Trifle.Traces.Plug` also implements `init/1` and `call/2`, so it can be placed
in a Plug pipeline. The standard Plug form starts tracing and finalizes through
`register_before_send`; use the wrapper or Phoenix integration when exception
coverage is required because an ordinary pipeline plug cannot wrap plugs that
execute after it returns.

The trace reference is available as
`conn.assigns.trifle_trace_reference`.
