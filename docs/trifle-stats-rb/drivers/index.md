---
title: Drivers
description: Learn how driver wraps around regular ruby drivers.
nav_order: 5
---

# Driver

Driver is a wrapper class that persists and retrieves values from backend. It needs to implement:

- `inc(keys:, **values)` method increment values for keys
- `set(keys:, **values)` method set values for keys
- `ping(key:, **values)` method that sets values for key and updates timestamp
- `get(keys:)` method to retrieve values for keys
- `scan(key:)` method that looks up for last ping received for a key

The keys array to build identifiers for objects that needs to modify or retrieve values for. Driver then decides on the optimal way to implement these actions.

## Feature Parity

Not all databases support same functionality. While it is important to keep these as close as possible, some features are not reasonable to achieve in some databases. Here is matrix of these drivers.

| Driver   | prefix | collection_name | joined_identifiers | expire_after |
|----------|--------|-----------------|--------------------|--------------|
| Redis    | YES    | NO              | NO                 | YES          |
| Postgres | NO     | YES             | YES                | NO           |
| MySQL    | NO     | YES             | YES                | NO           |
| Mongo    | NO     | YES             | YES                | YES          |
| Sqlite   | NO     | YES             | YES                | NO           |
| Process  | NO     | NO              | NO                 | NO           |
| Dummy    | WTF    | WTF             | WTF                | WTF          |

Features like [`Beam`](./usage/beam) and [`Scan`](./usage/scan) require `joined_identifiers: nil` configuration and while it is not required, you want to expire this data otherwise it will polute your database quickly.

## Timestamp Compatibility

Timestamp format matters for `:partial` and separated (`nil`) identifier modes, and for `ping`/`scan` data.

| Backend | Timestamp storage | Driver write format | Cross-driver compatibility |
|---------|-------------------|---------------------|----------------------------|
| SQLite | `TEXT` | RFC3339 UTC (`2026-02-25T00:00:00Z`) | Compatible across Ruby, Elixir, and Go SQLite drivers when values are RFC3339 UTC. Legacy SQLite rows stored as `YYYY-MM-DD HH:MM:SS` are not matched/read by strict RFC3339 drivers. |
| Postgres | `TIMESTAMPTZ` | Native DB timestamp with timezone | Compatible across Ruby, Elixir, and Go Postgres drivers. |
| MySQL | `DATETIME(6)` | Native DB datetime (normalized to UTC by drivers) | Compatible across Ruby, Elixir, and Go MySQL drivers. |
| MongoDB | BSON DateTime | Native DB datetime | Compatible across Ruby, Elixir, and Go Mongo drivers. |
| Redis / Process | No dedicated `at` column in joined mode | `at` is part of joined key payload for full-joined mode | Keep joined mode + separator aligned when sharing data patterns across apps. |

## Cross-Driver Rules

- Keep identifier mode aligned across services (`:full`, `:partial`, or `nil`).
- Keep separator aligned for joined identifiers (default: `::`).
- In full-joined mode, `at` is encoded as unix seconds in the joined key segment; keep key construction consistent across clients.
- For SQLite `at` fields, use RFC3339 UTC.
- If migrating legacy SQLite text timestamps (`YYYY-MM-DD HH:MM:SS`), rewrite to RFC3339 UTC before cross-language reuse.

## Performance

Here you have a rough estimate in performance over different drivers running on very basic `t3.small` EC2 instance.

```sh
root@3b5545595714:~/trifle-stats/spec/performance# ruby run.rb 1000 '{"a":1,"b":2,"c":{"d":3,"e":{"f":4,"g":5}}}'
Testing 1000x {"a"=>1, "b"=>2, "c"=>{"d"=>3, "e"=>{"f"=>4, "g"=>5}}}
DRIVER                                          ASSORT          ASSERT          TRACK           VALUES          BEAM            SCAN
Trifle::Stats::Driver::Redis(J)                 3.3048s         0.919s          3.015s          0.7291s         0.0025s         0.002s
Trifle::Stats::Driver::Postgres(J)              3.5198s         3.1653s         3.3407s         0.8125s         0.0029s         0.002s
Trifle::Stats::Driver::Mongo(S)                 2.5012s         1.9965s         2.3716s         2.948s          0.9349s         0.905s
Trifle::Stats::Driver::Mongo(J)                 2.3691s         1.8022s         2.1464s         2.6389s         0.9311s         0.0017s
Trifle::Stats::Driver::Process(J)               0.3465s         0.2789s         0.2881s         0.1617s         0.0021s         0.0024s
Trifle::Stats::Driver::Sqlite(J)                6.3521s         0.4859s         6.3591s         0.3205s         0.0024s         0.0024s
```

Use that to make up your mind in what you're looking for. You can read more in [performance](./drivers/performance) to find which database will fit your usecase the best.

Hope Feature Parity and Performance will help you make a decision when choosing the right database for your `Trifle::Stats`.


## Packer Mixin

Some databases cannot store nested hashes/values. Or they cannot perform increment on nested values that does not exist. For this reason you can use Packer mixin that helps you convert values to dot notation.

```ruby
class Sample
  include Trifle::Stats::Mixins::Packer
end

values = { a: 1, b: { c: 22, d: 33 } }
=> {:a=>1, :b=>{:c=>22, :d=>33}}

packed = Sample.pack(hash: values)
=> {"a"=>1, "b.c"=>22, "b.d"=>33}

Sample.unpack(hash: packed)
=> {"a"=>1, "b"=>{"c"=>22, "d"=>33}}
```
