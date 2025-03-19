#!/bin/bash

# Define the version of the Keepalived Exporter to download
KEEPALIVED_EXPORTER_VERSION="0.7.0"
KEEPALIVED_EXPORTER_TAR="keepalived_exporter-${KEEPALIVED_EXPORTER_VERSION}.linux-amd64.tar.gz"
KEEPALIVED_EXPORTER_URL="https://github.com/mehdy/keepalived-exporter/releases/download/v${KEEPALIVED_EXPORTER_VERSION}/${KEEPALIVED_EXPORTER_TAR}"

# Download and extract the Keepalived Exporter
cd /opt
wget $KEEPALIVED_EXPORTER_URL
tar -xzvf $KEEPALIVED_EXPORTER_TAR
mv keepalived_exporter-${KEEPALIVED_EXPORTER_VERSION}.linux-amd64/keepalived_exporter /usr/local/bin/
chmod +x /usr/local/bin/keepalived_exporter

# Clean up
rm -rf keepalived_exporter-${KEEPALIVED_EXPORTER_VERSION}.linux-amd64*
rm -f $KEEPALIVED_EXPORTER_TAR

# Create a systemd service for the Keepalived Exporter
echo "[Unit]
Description=Keepalived Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/keepalived_exporter \
  --keepalived.status-file=/var/run/keepalived.state  # Path to Keepalived state file
SyslogIdentifier=keepalived-exporter
Restart=always

[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/keepalived-exporter.service >/dev/null

# Reload systemd and enable the service
systemctl daemon-reload
systemctl enable keepalived-exporter.service
systemctl start keepalived-exporter.service
systemctl status keepalived-exporter.service
