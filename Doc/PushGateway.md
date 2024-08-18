# Understanding Pushgateway in Prometheus
## **Introduction**

Pushgateway is a service provided by Prometheus for handling metrics from jobs that cannot be scraped directly. It's often used in environments where short-lived jobs need to push metrics to Prometheus. Unlike the standard Prometheus model where exporters expose metrics that Prometheus scrapes, Pushgateway allows jobs to push their metrics to it.

## **Use Case** 

Pushgateway is useful in scenarios where:

- Batch Jobs:
Jobs that run for a short duration and finish before Prometheus can scrape them.
- Job Results:
Collecting results from jobs that produce metrics but don’t run continuously.
- Intermediate Metrics:
Metrics from jobs that are transient in nature and may not be available at scrape time.

## How It Works

- Push Metrics:
Jobs push their metrics to Pushgateway.
- Prometheus Scrapes:
Prometheus scrapes the metrics from Pushgateway.
- Metrics Storage:
Metrics are stored in Prometheus and can be queried and visualized.


![Pushgateway Overview](https://miro.medium.com/v2/resize:fit:720/format:webp/1*mhMKB_iWA2Kz6L0qTT_i9w.png)


## Setup and Example
Here’s a step-by-step guide to set up Pushgateway and test it with a simple example.

### Prerequisites
- Prometheus: Ensure you have Prometheus installed and running.
- Pushgateway: Download and run Pushgateway.

### Install and Run Pushgateway

1. Download Pushgateway:

```bash
wget https://github.com/prometheus/pushgateway/releases/download/v1.4.0/pushgateway-1.4.0.linux-amd64.tar.gz
```
2. Extract the Archive:

```bash
tar xvf pushgateway-1.4.0.linux-amd64.tar.gz
```
3. Run Pushgateway:

```bash
./pushgateway-1.4.0.linux-amd64/pushgateway
```
Pushgateway will start running on port `9091` by default.

## Configure Prometheus to Scrape Pushgateway

Edit your `prometheus.yml` configuration file to add Pushgateway as a scrape target.

```bash
scrape_configs:
  - job_name: 'pushgateway'
    static_configs:
      - targets: ['localhost:9091']
```
Restart Prometheus to apply the configuration changes.

### Push Metrics to Pushgateway

You can use curl or any HTTP client to push metrics to Pushgateway. Here’s an example of pushing a simple counter metric:

1. Push Metric Example:

``` bash
echo "example_counter{label1=\"value1\"} 1" | curl --data-binary @- http://localhost:9091/metrics/job/example_job
```

In this example:

- `example_counter` is the name of the metric.
- `{label1="value1"}` adds a label to the metric.
- `1` is the value of the metric.
- `example_job` is the name of the job.

2. Verify Metric in Prometheus:

After pushing the metric, you should be able to see it in Prometheus by querying for example_counter or checking the Prometheus target page (http://localhost:9090/targets).

Done !



