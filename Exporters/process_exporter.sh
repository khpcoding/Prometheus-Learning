#!/bin/bash
set -e

# Variables
VERSION="0.7.10"
URL="https://github.com/ncabatoff/process-exporter/releases/download/v${VERSION}/process-exporter-${VERSION}.linux-amd64.tar.gz"
CONFIG_FILE="/etc/process-exporter.yaml"
SERVICE_FILE="/etc/systemd/system/process_exporter.service"

# Install process-exporter
echo "Downloading process-exporter v${VERSION}..."
wget -q $URL -O /tmp/process-exporter.tar.gz

echo "Extracting..."
tar -xzf /tmp/process-exporter.tar.gz -C /tmp

echo "Installing binary..."
sudo mv /tmp/process-exporter-${VERSION}.linux-amd64/process-exporter /usr/local/bin/
sudo chmod +x /usr/local/bin/process-exporter

# Create config
echo "Creating config file at $CONFIG_FILE..."
sudo tee $CONFIG_FILE > /dev/null <<EOF
process_names:
  - name: "{{.Matches}}"
    cmdline:
      - '.+'
EOF

# Create systemd service
echo "Creating systemd service at $SERVICE_FILE..."
sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Process Exporter

[Service]
ExecStart=/usr/local/bin/process-exporter -config.path /etc/process-exporter.yaml

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
echo "Enabling and starting process_exporter..."
sudo systemctl daemon-reload
sudo systemctl enable --now process_exporter

# Show status
sudo systemctl status process_exporter --no-pager
