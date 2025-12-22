# Nginx + Prometheus + Grafana Monitoring Setup

In this scenario, we will install NGINX on a server, along with the NGINX Prometheus Exporter. We will then configure Prometheus to scrape it, and finally display useful metrics in Grafana — such as the total number of requests sent to the web server, 4xx errors, and 5xx errors.

## Step 1: Install NGINX

```bash
sudo apt update
sudo apt install nginx -y
```


## Step 2: Install NGINX Prometheus Exporter

The official NGINX Prometheus Exporter can be downloaded from GitHub releases:


# Download the latest version (replace with the current latest version)
wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v1.3.0/nginx-prometheus-exporter_1.3.0_linux_amd64.tar.gz

# Extract and move the binary
tar -xzf nginx-prometheus-exporter_*.tar.gz
sudo mv nginx-prometheus-exporter /usr/local/bin/

# Make it executable
sudo chmod +x /usr/local/bin/nginx-prometheus-exporter


Run the exporter (typically on port 9113):

```bash
nginx-prometheus-exporter -nginx.scrape-uri=http://localhost/nginx_status
```

For production, it is recommended to run it as a systemd service.

## Step 3: Enable NGINX Stub Status Module

To allow the exporter to collect metrics, enable the `stub_status` module in NGINX.

Edit or create a configuration file (e.g., `/etc/nginx/sites-available/status`):

```nginx
server {
    listen 8080;  # or any unused port

    location /nginx_status {
        stub_status;
        allow 127.0.0.1;      # Only allow localhost (exporter runs locally)
        deny all;
    }
}
```

Enable the site and reload NGINX:

```bash
sudo ln -s /etc/nginx/sites-available/status /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

Now the exporter can scrape metrics from `http://localhost:8080/nginx_status`.

## Step 4: Configure Prometheus to Scrape the Exporter

Add the following job to your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'nginx'
    static_configs:
      - targets: ['localhost:9113']
```

Reload Prometheus:

```bash
sudo systemctl reload prometheus
```

## Step 5: Import Dashboard in Grafana

After Prometheus successfully scrapes the NGINX exporter, you can import a ready-made dashboard in Grafana.

Recommended dashboard IDs (from Grafana.com):

- **NGINX Dashboard**: [ID 1474](https://grafana.com/grafana/dashboards/1474) (Classic NGINX)
- **NGINX Plus Dashboard**: [ID 12569](https://grafana.com/grafana/dashboards/12569) (More advanced)
- Popular open-source one: [ID 9614](https://grafana.com/grafana/dashboards/9614-nginx/)

### Example Key Metrics You Can Visualize

- Total requests: `nginx_requests_total`
- 4xx errors: `nginx_requests_total{status=~"4.."}`
- 5xx errors: `nginx_requests_total{status=~"5.."}`
- Requests per second: `rate(nginx_requests_total[5m])`

After importing the dashboard and selecting the correct Prometheus data source, all metrics (including request counts, 4xx/5xx errors, connections, etc.) will be visible.

Done! You now have full monitoring of your NGINX web server with Prometheus and Grafana.
```
