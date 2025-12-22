# NGINX Monitoring with Prometheus Exporter and Grafana

This guide sets up monitoring for an NGINX web server using the NGINX Prometheus Exporter. It enables scraping of metrics by Prometheus and visualization in Grafana, including total requests, 4xx errors, and 5xx errors.

## Prerequisites
- NGINX installed and running (`sudo apt install nginx` on Debian/Ubuntu).
- Prometheus and Grafana installed and configured.
- A user (e.g., `prometheus`) for running the exporter service (create if needed: `sudo useradd --no-create-home --shell /bin/false prometheus`).

## Step 1: Install NGINX Prometheus Exporter

Download and install the exporter (using an older version as per provided info; for latest, check [GitHub releases](https://github.com/nginxinc/nginx-prometheus-exporter/releases)):

```bash
cd /opt
wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v0.10.0/nginx-prometheus-exporter_0.10.0_linux_amd64.tar.gz
tar -xzvf nginx-prometheus-exporter_0.10.0_linux_amd64.tar.gz
sudo mv nginx-prometheus-exporter /usr/local/bin/
sudo chmod +x /usr/local/bin/nginx-prometheus-exporter
```

## Step 2: Configure NGINX for Stub Status

Create or edit a config file (e.g., `/etc/nginx/sites-enabled/stub.conf`):

```nginx
server {
    listen 8090;

    location = /basic_status {
        stub_status;
        allow 127.0.0.1;  # Optional: restrict to localhost
        deny all;
    }
}
```

Test and reload NGINX:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

This exposes basic status metrics at `http://127.0.0.1:8090/basic_status`.

## Step 3: Run NGINX Exporter as a Systemd Service

Create the service file:

```bash
sudo tee /etc/systemd/system/nginx-exporter.service > /dev/null <<EOF
[Unit]
Description=Nginx Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/nginx-prometheus-exporter \\
  -nginx.scrape-uri=http://127.0.0.1:8090/basic_status
SyslogIdentifier=nginx-exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable nginx-exporter --now
```

The exporter listens on port **9113** by default and exposes metrics at `/metrics`.

## Step 4: Add Exporter to Prometheus

Add the following job to your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: NGINX
    static_configs:
      - targets:
        - 192.168.4.182:9113  # Replace with your exporter's IP:port (or localhost:9113 if on same machine)
    metrics_path: /metrics
```

Reload Prometheus:

```bash
sudo systemctl reload prometheus
```

## Step 5: Visualize in Grafana

Import a dashboard in Grafana using your Prometheus data source.

Recommended dashboards:
- Official NGINX Exporter Dashboard: [ID 12708](https://grafana.com/grafana/dashboards/12708-nginx/)
- Another official variant: [ID 11199](https://grafana.com/grafana/dashboards/11199-nginx/)

These dashboards display key metrics such as:
- Total requests
- Requests per second
- Connections (active, reading, writing, waiting)
- Status code breakdowns (including 4xx and 5xx errors)

### Example Dashboard Screenshots












### Key Metrics Queries (for custom panels)
- Total requests: `nginx_http_requests_total`
- 4xx errors: `sum(increase(nginx_http_requests_total{status=~"4.."}[5m]))`
- 5xx errors: `sum(increase(nginx_http_requests_total{status=~"5.."}[5m]))`
- Requests per second: `rate(nginx_http_requests_total[5m])`

You now have complete NGINX monitoring with request counts, error rates, and more visible in Grafana!
```
