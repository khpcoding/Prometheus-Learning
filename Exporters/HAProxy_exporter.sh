#!/bin/bash

# Define the version of the HAProxy Exporter to download
HAPROXY_EXPORTER_VERSION="0.15.0"
HAPROXY_EXPORTER_TAR="haproxy_exporter-${HAPROXY_EXPORTER_VERSION}.linux-amd64.tar.gz"
HAPROXY_EXPORTER_URL="https://github.com/prometheus/haproxy_exporter/releases/download/v${HAPROXY_EXPORTER_VERSION}/${HAPROXY_EXPORTER_TAR}"

# Download and extract the HAProxy Exporter
cd /opt
wget $HAPROXY_EXPORTER_URL
tar -xzvf $HAPROXY_EXPORTER_TAR
mv haproxy_exporter-${HAPROXY_EXPORTER_VERSION}.linux-amd64/haproxy_exporter /usr/local/bin/
chmod +x /usr/local/bin/haproxy_exporter

# Clean up
rm -rf haproxy_exporter-${HAPROXY_EXPORTER_VERSION}.linux-amd64*
rm -f $HAPROXY_EXPORTER_TAR

# Create a systemd service for the HAProxy Exporter
echo "[Unit]
Description=HAProxy Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/haproxy_exporter \
  --haproxy.scrape-uri=http://<HAPROXY_USER>:<HAPROXY_PASSWORD>@127.0.0.1:8404/stats  # Replace with your HAProxy stats URI
SyslogIdentifier=haproxy-exporter
Restart=always

[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/haproxy-exporter.service >/dev/null

# Reload systemd and enable the service
systemctl daemon-reload
systemctl enable haproxy-exporter.service
systemctl start haproxy-exporter.service
systemctl status haproxy-exporter.service
