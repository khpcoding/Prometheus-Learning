#!/bin/bash

# Set Redis Exporter version
export RELEASE=1.58.0

# Download and install Redis Exporter
wget https://github.com/oliver006/redis_exporter/releases/download/v$RELEASE/redis_exporter-v$RELEASE.linux-amd64.tar.gz
tar -xvf redis_exporter-v$RELEASE.linux-amd64.tar.gz && cd redis_exporter-v$RELEASE.linux-amd64
mv ./redis_exporter /usr/local/bin/

# Create a system user for Redis Exporter
groupadd --system redis_exporter
useradd -s /sbin/nologin -r -g redis_exporter redis_exporter

# Create a systemd service for Redis Exporter
echo -n "[Unit]
Description=Redis Exporter for Prometheus
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=redis_exporter
Group=redis_exporter
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/redis_exporter \
  --redis.addr=redis://localhost:6379 \
  --web.listen-address=0.0.0.0:9121
SyslogIdentifier=redis_exporter
Restart=always

[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/redis_exporter.service >/dev/null

# Reload systemd and start Redis Exporter service
systemctl daemon-reload
systemctl restart redis_exporter
systemctl enable redis_exporter
