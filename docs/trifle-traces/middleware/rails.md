---
title: Rails
description: Learn how to integrate Trifle::Traces into your Rails app.
nav_order: 3
---

# Rails

`Trifle::Traces::Middleware::RailsController` wraps selected controller actions via `around_action`.

## Quick setup

```ruby
class SessionsController < ApplicationController
  include Trifle::Traces::Middleware::RailsController
  with_trifle_traces only: %i[create]

  def create
    Trifle::Traces.trace('Authenticating', head: true)
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      Trifle::Traces.trace('Authenticated') { user.id }
      session[:user_id] = user.id
      redirect_to root_path
    else
      Trifle::Traces.ignore!
      redirect_to new_session_path, flash: { error: 'Invalid credentials' }
    end
  end

  private

  # Optional overrides
  def trace_key
    "auth/sessions/#{params[:action]}"
  end

  def trace_meta
    [params[:email]]
  end

  def trace_mode
    :deferred
  end
end
```

## Defaults

If you don’t override them:

- `trace_key` → `"<controller>/<action>"`
- `trace_meta` → `[params[:id]]`
- `trace_mode` → `nil` (falls back to `config.default_mode`)
