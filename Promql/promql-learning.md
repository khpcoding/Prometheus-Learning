```markdown
# PromQL Cheat Sheet

Usage and examples of basics, aggregations & functions in PromQL (Prometheus Query Language)

## Metric Types

[Official reference](https://prometheus.io/docs/concepts/metric_types)

### Counters
- Always increasing metric, e.g. `http_requests_total`
- Gets reset (to zero) on process restarts
- Use safe functions like `rate()` or `increase()` which handle resets correctly

### Gauge
- Value that can go up and down, e.g. `cpu_memory_usage`, `number_of_go_routines`
- Spikes between scrapes are missed

### Histogram
- Client-side sampling of observations, counted in buckets
- Exposes counter-type metrics internally:
  - `_sum` → Sum of all observed values
  - `_count` → Total number of observations
  - `_bucket{le="v1"}`, `_bucket{le="v2"}`, ..., `_bucket{le="+Inf"}` → Cumulative count of observations ≤ each bucket boundary
- Does not miss spikes between scrapes (client samples everything)

### Summary
- Use with caution! [Reference](https://prometheus.io/docs/concepts/metric_types/#summary)
- Quantiles cannot be aggregated accurately across instances

## Aggregation Basics

### Gauge Examples
Metric: `node_filesystem_size_bytes` (labels: `device`, `fstype`, `mountpoint`)

- Total filesystem size across all machines:
  ```promql
  sum(node_filesystem_size_bytes)
  ```

- Filesystem size per instance and device:
  ```promql
  sum by(instance, device)(node_filesystem_size_bytes)
  ```

- Filesystem size per instance (ignoring other labels):
  ```promql
  sum without(device, fstype, mountpoint)(node_filesystem_size_bytes)
  ```

- Largest filesystem per instance:
  ```promql
  max by(instance)(node_filesystem_size_bytes)
  ```

- Memory usage change over the last hour:
  ```promql
  process_resident_memory_bytes{job="node"}
  -
  process_resident_memory_bytes{job="node"} offset 1h
  ```

### Counter Examples
- Network receive rate (bytes/second):
  ```promql
  rate(node_network_receive_bytes_total[5m])
  ```

- Total receive rate per instance:
  ```promql
  sum by(instance)(rate(node_network_receive_bytes_total[5m]))
  ```

### Histogram Examples
Metric: `prometheus_tsdb_compaction_duration_seconds`

- Compactions per second per instance:
  ```promql
  sum by(instance)(rate(prometheus_tsdb_compaction_duration_seconds_count[5m]))
  ```

- Average compaction duration (over 5m):
  ```promql
  sum by(instance)(rate(prometheus_tsdb_compaction_duration_seconds_sum[5m]))
  /
  sum by(instance)(rate(prometheus_tsdb_compaction_duration_seconds_count[5m]))
  ```

- 90th percentile compaction duration (over 1d):
  ```promql
  histogram_quantile(0.90, rate(prometheus_tsdb_compaction_duration_seconds_bucket[1d]))
  ```

## Aggregation Operators

### Grouping
- `by(label1, label2)` → Keep only listed labels
- `without(label1, label2)` → Remove listed labels

### Operators
- **sum** → Sum of values in group
- **count** → Number of series in group
- **avg** → Average of values in group
- **min** / **max** → Minimum or maximum value in group
- **stddev** / **stdvar** → Population standard deviation / variance
- **topk(k, metric)** → k highest-valued series per group
- **bottomk(k, metric)** → k lowest-valued series per group
- **quantile(φ, metric)** → φ-quantile (0 ≤ φ ≤ 1) of values in group

  Example: 90th percentile system CPU usage per instance:
  ```promql
  quantile without(cpu)(0.9, rate(node_cpu_seconds_total{mode="system"}[5m]))
  ```

- **count_values("label", metric)** → Frequency histogram of values

  Example input:
  ```
  software_version{instance="a",job="j"} 7
  software_version{instance="b",job="j"} 4
  software_version{instance="c",job="j"} 8
  software_version{instance="d",job="j"} 4
  software_version{instance="e",job="j"} 7
  software_version{instance="f",job="j"} 4
  ```

  Query:
  ```promql
  count_values without(instance)("version", software_version)
  ```

  Result:
  ```
  {job="j",version="4"} 3
  {job="j",version="7"} 2
  {job="j",version="8"} 1
  ```

## PromQL Operators & Functions Reference

| Category            | Operator / Function                  | Description                                                                 |
|---------------------|--------------------------------------|-----------------------------------------------------------------------------|
| **Arithmetic**      | `+`, `-`, `*`, `/`, `%`, `^`         | Basic math (vectors or scalars)                                             |
| **Comparison**      | `==`, `!=`, `>`, `<`, `>=`, `<=`     | Return 1 (true) or 0 (false); `bool` modifier changes behavior              |
| **Logical/Set**     | `and`, `or`, `unless`                | Vector intersection, union, exclusion                                       |
| **Aggregation**     | `sum()`, `avg()`, `min()`, `max()`   | Over dimension(s)                                                           |
|                     | `count()`, `stddev()`, `stdvar()`    | Count, standard deviation, variance                                         |
|                     | `topk()`, `bottomk()`                | Top/bottom k series by value                                                |
|                     | `count_values()`, `quantile()`       | Value frequency histogram, φ-quantile                                        |
| **Vector Matching** | `on(labels)`, `ignoring(labels)`     | Control label matching                                                      |
|                     | `group_left`, `group_right`          | Many-to-one or one-to-many matching                                         |
| **Functions**       | `rate(v[range])`                     | Average per-second increase (counters)                                      |
|                     | `irate(v[range])`                    | Instantaneous per-second rate                                               |
|                     | `increase(v[range])`                 | Total increase over range                                                   |
|                     | `delta(v[range])`                    | Difference (first - last) for gauges                                        |
|                     | `*_over_time(v[range])`              | avg/min/max/sum/quantile/stddev/stdvar over range                           |

## References
- [Official Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- Book: *Prometheus: Up & Running* (O'Reilly)
```
