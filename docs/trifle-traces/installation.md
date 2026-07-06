---
title: Installation
description: Learn how to install Trifle::Traces in your Ruby application.
nav_order: 1
---

# Installation

Add this line to your application's Gemfile:

```ruby
gem 'trifle-traces'
```

And then execute:

```sh
$ bundle install
```

Or install it yourself as:

```sh
$ gem install trifle-traces
```

## Dependencies

`Trifle::Traces` has zero runtime dependencies and is framework-agnostic. Rails, Sidekiq, and Rack integrations are optional.

To persist traces, configure an index and a data driver (see [Drivers](/trifle-traces/drivers)). Database and storage clients (`mongo`, `aws-sdk-s3`, ...) are supplied by your application — add the ones your drivers need to your Gemfile.
