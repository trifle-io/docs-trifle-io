---
title: Configuration
description: Learn how to configure Trifle::Stats for your Ruby application.
nav_order: 2
---

# Configuration

You don't need to use it with Rails, but you still need to run `Trifle::Stats.configure`.

Configuration allows you to specify:

:::signature Trifle::Stats.configure
driver | Trifle::Stats::Driver | required |  | Backend driver used to store and retrieve data.
granularities | Array | optional | `["1m","1h","1d","1w","1mo","1q","1y"]` | List of timeline granularities you would like to track. Value must be list of strings in format of "#{number}#{unit}". For example `['10m', '1h', '6h', '1d', '1w', '1mo']`.
time_zone | String | optional | `"GMT"` | Time zone to properly generate timeline buckets. Value must be valid TZ string identifier.
beginning_of_week | Symbol/String | optional | `:monday` | First day of a week to properly calculate weekly buckets.
buffer_enabled | Boolean | optional | `true` | Enable in-memory buffer before writes.
buffer_duration | Float | optional | `1` | Flush interval (seconds).
buffer_size | Integer | optional | `256` | Max buffered operations before flush.
buffer_aggregate | Boolean | optional | `true` | Aggregate increments by key before flush.
:::

:::callout note "Buffering"
Disable buffering to write directly to the driver:

```ruby
config.buffer_enabled = false
```
:::

The [API driver](/trifle-stats-rb/drivers/api) always bypasses this buffer. Its remote writes are synchronous and never batched or retried.

Gem fallbacks to global configuration if custom configuration is not passed to method. You can do this by creating initializer, or calling it on the beginning of your ruby script.

## Global configuration

If youre running it with Rails, create `config/initializers/trifle.rb` and configure the gem.

```ruby
Trifle::Stats.configure do |config|
  config.driver = Trifle::Stats::Driver::Redis.new
  config.granularities = ['10m', '1h', '1d', '1w', '1mo']
  config.time_zone = 'Europe/Bratislava'
  config.beginning_of_week = 'monday'
end
```

## Custom configuration

Custom configuration can be passed as a keyword argument to main `Trifle::Stats` module methods (`track`, `values`, etc). This way you can pass different driver or ranges for different type of data youre storing - ie set different ranges or set expiration date on your data.

:::tabs
@tab Configuration 1

```ruby
configuration = Trifle::Stats::Configuration.new
configuration.driver = Trifle::Stats::Driver::Redis.new
configuration.granularities = ['1h', '1d', '1w', '1mo']
configuration.time_zone = 'GMT'
```

You can then pass it into module methods as a `config` keyword argument.

```ruby
Trifle::Stats.track(key: 'event#checkout', at: Time.now, values: {count: 1}, config: configuration)
```

@tab Configuration 2

```ruby
mongo_configuration = Trifle::Stats::Configuration.new
mongo_configuration.driver = Trifle::Stats::Driver::MongoDB.new
mongo_configuration.granularities = ['1h', '1d', '1w', '1mo']
mongo_configuration.time_zone = 'Asia/Dubai'
```

You can then pass it into module methods as a `config` keyword argument.

```ruby
Trifle::Stats.track(key: 'event#checkout', at: Time.now, values: {count: 1}, config: mongo_configuration)
```
:::
