# BIND9 DNS Server Monitoring with Prometheus Exporter and Grafana

This guide sets up monitoring for a BIND9 DNS server using the **BIND Exporter** (from prometheus-community). It enables Prometheus to scrape DNS metrics and visualize them in Grafana, including query rates, successes, failures, cache performance, and more.

## Prerequisites
- BIND9 installed and running (`sudo apt install bind9` on Debian/Ubuntu).
- Prometheus and Grafana installed and configured.
- A system user/group for the exporter (created in the steps below).

## Step 1: Create Prometheus System User

```bash
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin -r -g prometheus prometheus
```

## Step 2: Install BIND Exporter

Download and install the latest version (command fetches the latest automatically):

```bash
curl -s https://api.github.com/repos/prometheus-community/bind_exporter/releases/latest \
  | grep browser_download_url \
  | grep linux-amd64 \
  | cut -d '"' -f 4 \
  | wget -qi -

tar xvf bind_exporter*.tar.gz
sudo mv bind_exporter-*/bind_exporter /usr/local/bin/
sudo chmod +x /usr/local/bin/bind_exporter
```

## Step 3: Enable BIND Statistics Channel

Edit `/etc/bind/named.conf.options` and add the following inside the `options { ... };` block:

```conf
statistics-channels {
    inet 127.0.0.1 port 8053 allow { 127.0.0.1; };
};
```

Restart BIND9:

```bash
sudo systemctl restart named
```

This exposes BIND statistics at `http://localhost:8053/`.

## Step 4: Run BIND Exporter as a Systemd Service

Create the service file:

```bash
sudo tee /etc/systemd/system/bind_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus BIND Exporter
Documentation=https://github.com/prometheus-community/bind_exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/bind_exporter \\
  --bind.pid-file=/var/run/named/named.pid \\
  --bind.timeout=20s \\
  --web.listen-address=0.0.0.0:9153 \\
  --web.telemetry-path=/metrics \\
  --bind.stats-url=http://localhost:8053/ \\
  --bind.stats-groups=server,view,tasks
SyslogIdentifier=bind_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable bind_exporter --now
```

The exporter listens on port **9153** by default and exposes metrics at `/metrics`.

## Step 5: Add Exporter to Prometheus

Add the following job to your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: dns
    static_configs:
      - targets:
        - 192.168.4.182:9153  # Replace with your exporter's IP:port (or localhost:9153 if on the same machine)
    metrics_path: /metrics
```

Reload Prometheus:

```bash
sudo systemctl reload prometheus
```

## Step 6: Visualize in Grafana

Import a dashboard in Grafana using your Prometheus data source.

Recommended dashboards from Grafana.com:

- **Bind DNS** (Classic, ID **1666**): [https://grafana.com/grafana/dashboards/1666-bind-dns/](https://grafana.com/grafana/dashboards/1666-bind-dns/)
- **Bind9 Exporter DNS** (Updated, ID **12309**): [https://grafana.com/grafana/dashboards/12309-bind9-exporter-dns/](https://grafana.com/grafana/dashboards/12309-bind9-exporter-dns/)
- **Bind9 Exporter DNS (2024)** (Modern, Angular-free, ID **20723**): [https://grafana.com/grafana/dashboards/20723-bind9-dns/](https://grafana.com/grafana/dashboards/20723-bind9-dns/)

These dashboards display key metrics such as:
- Incoming queries (total, by type: A, AAAA, etc.)
- Query successes, failures, NXDOMAIN, SERVFAIL
- Cache hits/misses
- Recursion performance
- Server tasks and views












### Example Key Metrics Queries
- Incoming queries per second: `rate(bind_queries_in_total[5m])`
- Query failures: `rate(bind_query_failures_total[5m])`
- Cache hit ratio: `bind_cache_hits_total / (bind_cache_hits_total + bind_cache_misses_total)`

You now have comprehensive monitoring of your BIND9 DNS server with detailed query statistics and performance insights in Grafana!
