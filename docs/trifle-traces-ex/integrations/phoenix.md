---
title: Phoenix
description: Trace complete Phoenix endpoint lifecycles.
nav_order: 1
---

# Phoenix

Add the handler before your endpoint:

```elixir
children = [
  {Trifle.Traces.Phoenix, []},
  MyAppWeb.Endpoint
]
```

The default key is `http/<method>/<request-path>`. Metadata includes the
method, path, and query string.

Customize selection and metadata with functions receiving `Plug.Conn`:

```elixir
{Trifle.Traces.Phoenix,
 selector: fn conn -> not String.starts_with?(conn.request_path, "/health") end,
 key: fn conn -> "http/#{conn.method}/#{conn.path_info |> Enum.join("/")}" end,
 meta: fn conn -> %{request_id: List.first(Plug.Conn.get_req_header(conn, "x-request-id"))} end,
 mode: fn _conn -> :deferred end}
```

Endpoint exceptions mark the trace failed. HTTP status codes are recorded but
do not override application-selected trace state.
