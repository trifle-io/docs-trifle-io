---
title: Performance
description: Learn more about performance of each driver.
nav_order: 1
---

# Performance

One note about performance of the drivers. While these are small operations against any database, these drivers differ in approach they take.

`Redis` driver is performing single `inc`/`set` operation for each key/value pair for every specified period. That means to store hash with 10 key/value pairs, it will make 10 calls to database multiplied by tracked periods. It adds up quickly.

`Mongo`, `Postgres` and `Sqlite` on the other side supports single `inc`/`set` operation on multiple key/value pairs at a time. This allows it to make single call to database even if you are tracking 50 values for multiple periods. `Mongo` executes all periods as a bulk action, while `Postgres` an `Sqlite` executes all periods as a single transaction. This makese them behave somewhat similar.

> `Sqlite` has hard-limit of maximum 23 keys it can track. For anything over that it raises `parser stack overflow (SQLite3::SQLException)`.

Keep that in mind when working with data. Each driver fits better for different usecase.

- `Redis` is best if the content you are tracking has simple structure and persistence is not an issue. Use it for simple stats you _could_ loose.
- `Postgres` is _somewhat slower_ at writing stats, but really great at reading them. Use it for structured stats that you access often, but don't write too often.
- `Mongo` is best for writing large data sets. Super fast for writing no matter how many stats you track, but bit slower for reading when compared to postgres.
- `Sqlite` is kinda living in it's own world. It holds up next the the rest of the drivers, while being bit slower, but still fast when reading. It's the only one that doesn't need running process, so kinda great for embeded _stuff_.

## (Not so) Sicentific evaluation

Here is a summary of a performance test of each driver. You can check the code under `specs/performance` and run it on your own. Change some connection details in `specs/performance/drivers.rb` that creates configurations.

Then simply run `specs/performance/run COUNT JSON` where `COUNT` represents number of reads and writes to be performed and `JSON` needs to be valid JSON structure being tracked.

```sh
specs/performance/ruby run.rb 100 '{"a":1}'
```

Databases are dropped and re-created on each `run`.

Below is a comparison of tests running on AWS EC2 `t3.medium` instance running all databases as a linked docker containers (no special configuration) via `docker compose -f .devops/docker/local/docker-compose.yml up`.

### Most simple tracking

The simplest tracking you can do is to track 1 value. Lets see how drivers perform writing/reading these 100 and 1000 times.

```sh
root@3b5545595714:~/trifle-stats/spec/performance# ruby run.rb 100 '{"a":1}'
Testing 100x {"a"=>1} increments
DRIVER                                          ASSORT          ASSERT          TRACK           VALUES          BEAM            SCAN
Trifle::Stats::Driver::Redis(J)                 0.0898s         0.0687s         0.0879s         0.056s          0.0003s         0.0004s
Trifle::Stats::Driver::Postgres(J)              0.2536s         0.2473s         0.2508s         0.0648s         0.0004s         0.0002s
Trifle::Stats::Driver::Mongo(S)                 0.2157s         0.1918s         0.2171s         0.2914s         0.089s          0.0891s
Trifle::Stats::Driver::Mongo(J)                 0.1944s         0.1711s         0.1911s         0.2628s         0.0904s         0.0002s
Trifle::Stats::Driver::Process(J)               0.0134s         0.0109s         0.0104s         0.0126s         0.0002s         0.0003s
Trifle::Stats::Driver::Sqlite(J)                0.6624s         0.0451s         0.5881s         0.0327s         0.0002s         0.0002s

root@3b5545595714:~/trifle-stats/spec/performance# ruby run.rb 1000 '{"a":1}'
Testing 1000x {"a"=>1} increments
DRIVER                                          ASSORT          ASSERT          TRACK           VALUES          BEAM            SCAN
Trifle::Stats::Driver::Redis(J)                 0.8289s         0.7688s         0.7752s         0.5612s         0.0029s         0.002s
Trifle::Stats::Driver::Postgres(J)              2.9269s         2.7549s         2.6881s         0.7926s         0.0022s         0.0022s
Trifle::Stats::Driver::Mongo(S)                 2.1924s         1.9317s         2.1801s         2.9633s         0.8935s         0.9059s
Trifle::Stats::Driver::Mongo(J)                 1.9813s         1.8104s         2.0321s         2.6252s         0.9061s         0.0017s
Trifle::Stats::Driver::Process(J)               0.1255s         0.1076s         0.1096s         0.1198s         0.0026s         0.0019s
Trifle::Stats::Driver::Sqlite(J)                6.0297s         0.3333s         6.013s          0.2985s         0.0022s         0.0021s
```

It's easy to see that this is where Redis shines. You simply can't beat it.

### Bit more complex tracking

Now lets compare what happens if we track 5 values. Either stored on top level or nested.

First lets start with top level values.

```sh
root@3b5545595714:~/trifle-stats/spec/performance# ruby run.rb 100 '{"a":1,"b":2,"c":3,"d":4,"e":5}'
Testing 100x {"a"=>1, "b"=>2, "c"=>3, "d"=>4, "e"=>5} increments
DRIVER                                          ASSORT          ASSERT          TRACK           VALUES          BEAM            SCAN
Trifle::Stats::Driver::Redis(J)                 0.3795s         0.0903s         0.331s          0.0748s         0.0004s         0.0002s
Trifle::Stats::Driver::Postgres(J)              0.3525s         0.3235s         0.3471s         0.084s          0.0002s         0.0009s
Trifle::Stats::Driver::Mongo(S)                 0.2499s         0.1951s         0.2268s         0.3104s         0.0973s         0.0942s
Trifle::Stats::Driver::Mongo(J)                 0.2313s         0.1783s         0.205s          0.2645s         0.0943s         0.0002s
Trifle::Stats::Driver::Process(J)               0.033s          0.0254s         0.0248s         0.0149s         0.0002s         0.0001s
Trifle::Stats::Driver::Sqlite(J)                0.6216s         0.0527s         0.6345s         0.0387s         0.0002s         0.0006s

root@3b5545595714:~/trifle-stats/spec/performance# ruby run.rb 1000 '{"a":1,"b":2,"c":3,"d":4,"e":5}'
Testing 1000x {"a"=>1, "b"=>2, "c"=>3, "d"=>4, "e"=>5} increments
DRIVER                                          ASSORT          ASSERT          TRACK           VALUES          BEAM            SCAN
Trifle::Stats::Driver::Redis(J)                 3.125s          0.8677s         3.0453s         0.7355s         0.0025s         0.0024s
Trifle::Stats::Driver::Postgres(J)              3.4178s         3.079s          3.2887s         0.7703s         0.0024s         0.0027s
Trifle::Stats::Driver::Mongo(S)                 2.5272s         2.0293s         2.4189s         2.942s          0.8996s         0.8706s
Trifle::Stats::Driver::Mongo(J)                 2.169s          1.8717s         2.1065s         2.6879s         1.0577s         0.0018s
Trifle::Stats::Driver::Process(J)               0.3355s         0.2761s         0.2826s         0.1714s         0.0023s         0.0024s
Trifle::Stats::Driver::Sqlite(J)                6.3657s         0.4858s         6.3099s         0.3172s         0.0027s         0.0021s
```

And next with nested values.

```sh
root@3b5545595714:~/trifle-stats/spec/performance# ruby run.rb 100 '{"a":1,"b":2,"c":{"d":3,"e":{"f":4,"g":5}}}'
Testing 100x {"a"=>1, "b"=>2, "c"=>{"d"=>3, "e"=>{"f"=>4, "g"=>5}}} increments
DRIVER                                          ASSORT          ASSERT          TRACK           VALUES          BEAM            SCAN
Trifle::Stats::Driver::Redis(J)                 0.3566s         0.095s          0.3309s         0.0745s         0.0002s         0.0003s
Trifle::Stats::Driver::Postgres(J)              0.3403s         0.3039s         0.3225s         0.0816s         0.0003s         0.0001s
Trifle::Stats::Driver::Mongo(S)                 0.2483s         0.2104s         0.2314s         0.2914s         0.0906s         0.0895s
Trifle::Stats::Driver::Mongo(J)                 0.216s          0.1753s         0.2086s         0.2643s         0.0915s         0.0001s
Trifle::Stats::Driver::Process(J)               0.0351s         0.0284s         0.0277s         0.0172s         0.0003s         0.0001s
Trifle::Stats::Driver::Sqlite(J)                0.6245s         0.0581s         0.6176s         0.0359s         0.0002s         0.0003s

root@3b5545595714:~/trifle-stats/spec/performance# ruby run.rb 1000 '{"a":1,"b":2,"c":{"d":3,"e":{"f":4,"g":5}}}'
Testing 1000x {"a"=>1, "b"=>2, "c"=>{"d"=>3, "e"=>{"f"=>4, "g"=>5}}} increments
DRIVER                                          ASSORT          ASSERT          TRACK           VALUES          BEAM            SCAN
Trifle::Stats::Driver::Redis(J)                 3.3048s         0.919s          3.015s          0.7291s         0.0025s         0.002s
Trifle::Stats::Driver::Postgres(J)              3.5198s         3.1653s         3.3407s         0.8125s         0.0029s         0.002s
Trifle::Stats::Driver::Mongo(S)                 2.5012s         1.9965s         2.3716s         2.948s          0.9349s         0.905s
Trifle::Stats::Driver::Mongo(J)                 2.3691s         1.8022s         2.1464s         2.6389s         0.9311s         0.0017s
Trifle::Stats::Driver::Process(J)               0.3465s         0.2789s         0.2881s         0.1617s         0.0021s         0.0024s
Trifle::Stats::Driver::Sqlite(J)                6.3521s         0.4859s         6.3591s         0.3205s         0.0024s         0.0024s
```

`Trifle::Stats` normalizes nested values to top level before storing them, so overall there is not much performance difference between these. `Mongo` is performing the best, while `Postgres` and `Sqlite` are doing bit worse on writes, but still rocking those reads.

### Some really _large_ tracking

Lets see what happens when we increase the number of keys to 23.

```sh
root@3b5545595714:~/trifle-stats/spec/performance# ruby run.rb 100 '{"a":1,"b":2,"c":1,"d":2,"e":1,"f":2,"g":1,"h":2,"i":1,"j":2,"k":1,"l":2,"m":1,"n":2,"o":1,"p":2,"q":1,"r":2,"s":1,"t":2,"u":1,"v":2,"w":1}'
Testing 100x {"a"=>1, "b"=>2, "c"=>1, "d"=>2, "e"=>1, "f"=>2, "g"=>1, "h"=>2, "i"=>1, "j"=>2, "k"=>1, "l"=>2, "m"=>1, "n"=>2, "o"=>1, "p"=>2, "q"=>1, "r"=>2, "s"=>1, "t"=>2, "u"=>1, "v"=>2, "w"=>1} increments
DRIVER                                          ASSORT          ASSERT          TRACK           VALUES          BEAM            SCAN
Trifle::Stats::Driver::Redis(J)                 1.3922s         0.1398s         1.3135s         0.149s          0.0004s         0.0003s
Trifle::Stats::Driver::Postgres(J)              0.7082s         0.5231s         0.7147s         0.1047s         0.0004s         0.0007s
Trifle::Stats::Driver::Mongo(S)                 0.3173s         0.228s          0.2654s         0.2973s         0.098s          0.0905s
Trifle::Stats::Driver::Mongo(J)                 0.2906s         0.227s          0.2528s         0.2726s         0.0994s         0.0001s
Trifle::Stats::Driver::Process(J)               0.1193s         0.0887s         0.0893s         0.0297s         0.0005s         0.0002s
Trifle::Stats::Driver::Sqlite(J)                0.8216s         0.1326s         0.7571s         0.0369s         0.0006s         0.0001s

root@3b5545595714:~/trifle-stats/spec/performance# ruby run.rb 1000 '{"a":1,"b":2,"c":1,"d":2,"e":1,"f":2,"g":1,"h":2,"i":1,"j":2,"k":1,"l":2,"m":1,"n":2,"o":1,"p":2,"q":1,"r":2,"s":1,"t":2,"u":1,"v":2,"w":1}'
Testing 1000x {"a"=>1, "b"=>2, "c"=>1, "d"=>2, "e"=>1, "f"=>2, "g"=>1, "h"=>2, "i"=>1, "j"=>2, "k"=>1, "l"=>2, "m"=>1, "n"=>2, "o"=>1, "p"=>2, "q"=>1, "r"=>2, "s"=>1, "t"=>2, "u"=>1, "v"=>2, "w"=>1} increments
DRIVER                                          ASSORT          ASSERT          TRACK           VALUES          BEAM            SCAN
Trifle::Stats::Driver::Redis(J)                 13.1988s        2.1129s         12.8526s        1.505s          0.0048s         0.0031s
Trifle::Stats::Driver::Postgres(J)              7.0472s         5.0418s         7.038s          1.0097s         0.0043s         0.0027s
Trifle::Stats::Driver::Mongo(S)                 3.201s          2.3651s         2.8283s         2.9752s         0.9912s         0.8972s
Trifle::Stats::Driver::Mongo(J)                 2.9527s         2.0794s         2.4688s         3.575s          1.1913s         0.0018s
Trifle::Stats::Driver::Process(J)               1.2234s         0.8951s         0.902s          0.2959s         0.0042s         0.0027s
Trifle::Stats::Driver::Sqlite(J)                8.3348s         1.2615s         7.6094s         0.373s          0.0044s         0.0021s
```

Here you can really see how `Redis` crumbles under the volume and `Mongo` shines instead. It doesn't matter if you track 1, 5, or 100 values, `Mongo` will perform (almost) the same. `Postgres` and `Sqlite` slow down a bit more in comparison to `Mongo`.

> If you're interest in running test on your own, check out related blog post about [Running performance test for Trifle::Stats on your own](https://trifle.io/blog/2022-08-running_performance_test_for_stats).
