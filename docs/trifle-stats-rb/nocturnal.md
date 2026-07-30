---
title: Nocturnal
description: How Trifle::Stats floors timestamps, builds timelines, and stays compatible across timezones and languages.
nav_order: 6
---

# Nocturnal

`Trifle::Stats::Nocturnal` is the internal bucketing engine used by `track`, `assert`, `values`, and `series`. Most applications do not call it directly, but its rules determine the timestamp stored for every metric bucket.

Writing and reading use the same process:

1. Convert the input instant into `config.time_zone`.
2. Floor it to the requested granularity.
3. Resolve that local boundary to an absolute instant.
4. Store or query the resulting Unix timestamp.

`values` floors both ends of the requested range and returns an inclusive timeline. After advancing a timeline point, Nocturnal floors it again. This re-anchors dynamic segments such as `33m`, `6h`, or `7d` when they cross an hour, day, or year boundary and ensures every timeline timestamp is a bucket the write path can produce.

## Elapsed and calendar units

Nocturnal deliberately uses two kinds of arithmetic:

| Units | Semantics | Anchor |
| --- | --- | --- |
| seconds | elapsed duration | beginning of the local minute |
| minutes | elapsed duration | beginning of the local hour |
| hours | elapsed duration | beginning of the local day |
| days | civil-calendar movement | beginning of the local year |
| weeks | civil-calendar movement | configured first weekday |
| months and quarters | civil-calendar movement | beginning of the local year |
| years | civil-calendar movement | calendar year |

Elapsed units measure real time. Calendar units preserve the local wall-clock fields while allowing the UTC offset to change.

For example, adding one day to `2026-03-28 12:00 +01:00` in `Europe/Bratislava` produces `2026-03-29 12:00 +02:00`. The two instants are 23 elapsed hours apart, but they represent consecutive local calendar days.

## Daylight saving transitions

Timezone offsets are resolved from TZInfo for every target boundary:

- A spring-forward hourly timeline skips the nonexistent local hour.
- A fall-back hourly timeline contains both occurrences of the repeated hour. They have different UTC offsets and Unix timestamps.
- Daily and larger buckets remain on their local calendar boundary when the offset changes.
- If calendar movement targets an ambiguous local time, Nocturnal prefers the occurrence with the source timestamp's UTC offset and otherwise uses the earlier occurrence.
- If calendar movement targets a nonexistent local time, Nocturnal moves it forward by the actual transition gap. The gap is not assumed to be one hour.

Use an IANA timezone such as `Europe/Bratislava`, not a fixed offset such as `+01:00`. A fixed offset has no transition rules.

## Timezone support

Nocturnal accepts timestamps representing any instant and converts them into `config.time_zone` before calculating bucket boundaries. IANA timezones include historical and future offset rules, so the same configuration handles standard time, daylight saving time, and transitions that are not exactly one hour.

> Treat `config.time_zone` as part of the persisted metric schema. Set it before writing data and do not change it for an existing dataset.

The timezone name is not stored with each bucket. Trifle stores the absolute instant produced after flooring in the configured timezone. Changing `config.time_zone` does not rewrite those persisted buckets: subsequent reads build their lookup timestamps using the new local boundaries, which can produce different Unix timestamps. The original data still exists, but it may no longer be returned and can appear as empty or split buckets. Some boundaries may happen to coincide, but that is not a safe compatibility guarantee.

To change timezone safely, keep the original configuration available for historical reads and write the new timezone to a separate key prefix, collection, or dataset. Alternatively, rebuild the metrics from source events. Aggregated buckets cannot always be losslessly converted because the old and new calendar boundaries may overlap differently.

## Cross-language compatibility

Ruby, Elixir, and Go resolve the same bucket to the same Unix instant. This allows one runtime to write a metric and another to read it.

Keep these settings identical in every runtime:

- granularity string, including its numeric offset;
- IANA timezone;
- beginning of week;
- key, prefix, separator, and identifier mode;
- sufficiently current timezone data.

Joined identifiers contain `prefix`, metric key, granularity, and Unix timestamp. Partial and separated identifiers store the same logical components in separate fields. Drivers normalize database timestamp columns to the same instant, and all three libraries use the compatible Trifle payload format.

Timezone databases can change when governments update civil-time rules. Keep TZInfo data, Tzdata, and the Go timezone database current when multiple runtimes share storage.

## Direct Nocturnal operations

The Ruby implementation exposes the primitives used by the public operations:

```ruby
parser = Trifle::Stats::Nocturnal::Parser.new('1d')
nocturnal = Trifle::Stats::Nocturnal.new(at, config: config)

bucket = nocturnal.floor(parser.offset, parser.unit)
tomorrow = nocturnal.add(1, :day)
timeline = Trifle::Stats::Nocturnal.timeline(
  from: from,
  to: to,
  offset: parser.offset,
  unit: parser.unit,
  config: config
)
```

Prefer `track`, `assert`, and `values` in application code so timezone normalization, key construction, and driver behavior stay consistent.

`beam` and `scan` are status operations. They retain the raw ping timestamp and do not use Nocturnal time-series bucketing.
