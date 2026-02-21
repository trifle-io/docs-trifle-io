---
title: 'Home'
svg: M8.25 21v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21m0 0h4.5V3.545M12.75 21h7.5V10.75M2.25 21h1.5m18 0h-18M2.25 9l4.5-1.636M18.75 3l-1.5.545m0 6.205l3 1m1.5.5l-1.5-.5M6.75 7.364V3h-3v18m3-13.636l10.5-3.819
---

# Welcome to Trifle Documentation

A collection of small, focused libraries for solving everyday problems — time-series metrics, execution tracing, structured logging, and more. Available for Ruby, Elixir, and Go.

Born out of frustration with bloated tools that do too much and none of it well. Each library does one thing, keeps a small footprint, and stays out of your way.

All libraries are released under the MIT license.

---

# Applications

Apps you can run to make your use of below plugins easier.

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
:::card "Trifle App" "Dashboards + API" "Docs" "/trifle-app/"
Visual and automation layer for Trifle Stats. Dashboards, monitors, API, and tokens.

```sh
trifle metrics push \
  --key event::signup \
  --values '{"count":1}'
```
:::

:::card "Trifle CLI" "API + SQLite" "Docs" "/trifle-cli/"
Command-line tooling for Trifle metrics with API or local SQLite drivers, plus MCP server mode.

```sh
trifle metrics setup --driver sqlite --db ./stats.db
trifle metrics get --driver sqlite --db ./stats.db --key event::signup --granularity 1h
```
:::
</div>

---

# Skills

Agent skills that teach AI coding agents (Claude Code, Codex, Cursor, and others) how to use Trifle effectively. Install a skill and your agent knows how to structure metrics payloads, trace execution flow, and run CLI analytics — following best practices out of the box. Available at [github.com/trifle-io/skills](https://github.com/trifle-io/skills). [Read more](/trifle-skills/).

---

# Plugins

These are gems and plugins you can plug into your app to start building.

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
:::card "Trifle::Stats" "Ruby · Time-series metrics" "Docs" "/trifle-stats-rb/"
Track counters and numeric payloads, then read back series by granularity.

```ruby
Trifle::Stats.configure do |c|
  c.driver = Trifle::Stats::Driver::Redis.new(Redis.new)
  c.granularities = ["1h"]
end

Trifle::Stats.track(
  key: "event::signup",
  at: Time.now.utc,
  values: { count: 1 }
)
```
:::

:::card "Trifle.Stats" "Elixir · Time-series metrics" "Docs" "/trifle-stats-ex/"
Minimal Elixir API for tracking counters and reading series.

```elixir
{:ok, pid} = Trifle.Stats.Driver.Process.start_link()
driver = Trifle.Stats.Driver.Process.new(pid)

Trifle.Stats.configure(driver: driver, track_granularities: ["1h"])
Trifle.Stats.track("event::signup", DateTime.utc_now(), %{count: 1})
```
:::

:::card "TrifleStats" "Go · Time-series metrics" "Docs" "/trifle-stats-go/"
Go library for tracking counters and reading series with SQLite, Postgres, MySQL, Redis, or MongoDB.

```go
import TrifleStats "github.com/trifle-io/trifle_stats_go"

db, _ := sql.Open("sqlite", "file:stats.db?cache=shared&mode=rwc")
driver := TrifleStats.NewSQLiteDriver(db, "trifle_stats", TrifleStats.JoinedFull)
_ = driver.Setup()

cfg := TrifleStats.DefaultConfig()
cfg.Driver = driver
TrifleStats.Track(cfg, "event::signup", time.Now().UTC(), map[string]any{"count": 1})
```
:::

:::card "Trifle::Traces" "Ruby · Execution tracing" "Docs" "/trifle-traces/"
Capture messages, return values, and metadata from code blocks.

```ruby
Trifle::Traces.tracer = Trifle::Traces::Tracer::Hash.new(
  key: "jobs/invoice_charge"
)

Trifle::Traces.trace("Charge invoice") { charge_invoice(42) }
Trifle::Traces.tracer.wrapup
```
:::

:::card "Trifle::Docs" "Ruby · Static docs router" "Docs" "/trifle-docs/"
Map a folder of Markdown/textile/static files to URLs and render them in-app.

```ruby
Trifle::Docs.configure do |c|
  c.path = Rails.root.join("docs")
  c.register_harvester(Trifle::Docs::Harvester::Markdown)
end

Trifle::Docs.content(url: "getting_started")
```
:::

:::card "Trifle::Logs" "Ruby · File-backed logs" "Docs" "/trifle-logs/"
Dump logs to disk and search them locally with fast paging.

```ruby
Trifle::Logs.configure do |c|
  c.driver = Trifle::Logs::Driver::File.new(path: "/var/logs/trifle")
end

Trifle::Logs.dump("billing", { event: "invoice_charged" })
```
:::
</div>
