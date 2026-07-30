---
title: Nocturnal
description: How Trifle Stats floors timestamps, builds timelines, and stays compatible across timezones and languages.
nav_order: 10
---

# Nocturnal

`Nocturnal` is the bucketing engine used by `Track`, `Assert`, and `Values`. Most applications do not call it directly, but its rules determine the timestamp stored for every metric bucket.

Writing and reading use the same process:

1. Convert the input instant into `cfg.TimeZone`.
2. Floor it to the requested granularity.
3. Resolve that local boundary through the configured Go location.
4. Store or query the resulting Unix timestamp.

`Values` floors both ends of the requested range and returns an inclusive timeline. After advancing a timeline point, Nocturnal floors it again. This re-anchors dynamic segments such as `33m`, `6h`, or `7d` when they cross an hour, day, or year boundary and ensures every timeline timestamp is a bucket the write path can produce.

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

Offsets are resolved from `time.Location` for every target boundary:

- A spring-forward hourly timeline skips the nonexistent local hour.
- A fall-back hourly timeline contains both occurrences of the repeated hour. They have different offsets and Unix timestamps.
- Daily and larger buckets remain on their local calendar boundary when the offset changes.
- If calendar movement targets an ambiguous local time, Nocturnal prefers the occurrence with the source timestamp's UTC offset and otherwise uses the earlier occurrence.
- If calendar movement targets a nonexistent local time, Nocturnal moves it forward by the actual transition gap. The gap is not assumed to be one hour.

Use an IANA timezone such as `Europe/Bratislava`, not `time.FixedZone`. A fixed offset has no transition rules.

## Timezone support

Nocturnal accepts timestamps representing any instant and converts them into `cfg.TimeZone` before calculating bucket boundaries. IANA timezones include historical and future offset rules, so the same configuration handles standard time, daylight saving time, and transitions that are not exactly one hour.

> Treat `cfg.TimeZone` as part of the persisted metric schema. Set it before writing data and do not change it for an existing dataset.

The timezone name is not stored with each bucket. Trifle stores the absolute instant produced after flooring in the configured timezone. Changing `cfg.TimeZone` does not rewrite those persisted buckets: subsequent reads build their lookup timestamps using the new local boundaries, which can produce different Unix timestamps. The original data still exists, but it may no longer be returned and can appear as empty or split buckets. Some boundaries may happen to coincide, but that is not a safe compatibility guarantee.

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

The Go implementation exposes the primitives used by the public operations:

```go
offset, unit, ok := ParseGranularity("1d")
if !ok {
  return
}

nocturnal := NewNocturnal(at, cfg)
bucket := nocturnal.Floor(offset, unit)
tomorrow := nocturnal.Add(1, UnitDay)
timeline := Timeline(from, to, offset, unit, cfg)
```

Prefer `Track`, `Assert`, and `Values` in application code so timezone normalization, key construction, and driver behavior stay consistent.

`Beam` and `Scan` are status operations. They retain the raw ping timestamp and do not use Nocturnal time-series bucketing.
