#!/bin/bash

# Define Variables
RELEASE=0.17.1
DATA_SOURCE_NAME="postgresql://postgres_exporter:password@localhost:5432/postgres?sslmode=disable"
EXPORTER_USER="postgres-exp"
INSTALL_DIR="/opt/postgres_exporter"
BIN_PATH="/usr/local/bin"
SERVICE_PATH="/etc/systemd/system/postgres_exporter.service"
QUERY_PATH="/etc/query.yml"

# Update system packages
sudo apt update -y

# Download and extract PostgreSQL Exporter
wget https://github.com/prometheus-community/postgres_exporter/releases/download/v$RELEASE/postgres_exporter-$RELEASE.linux-amd64.tar.gz

tar -xzvf postgres_exporter-$RELEASE.linux-amd64.tar.gz
sudo mv postgres_exporter-$RELEASE.linux-amd64/postgres_exporter $BIN_PATH/
rm -rf postgres_exporter-$RELEASE.linux-amd64*

# Create postgres-exporter user
sudo useradd -rs /bin/false $EXPORTER_USER

# Download the query file
sudo curl -k "https://raw.githubusercontent.com/farshadnick/prometheus-stack-installation-bashscript/main/postgres/query.yml" -o $QUERY_PATH
sudo chown $EXPORTER_USER:$EXPORTER_USER $QUERY_PATH

# Create Environment File
sudo mkdir -p $INSTALL_DIR
echo "DATA_SOURCE_NAME=$DATA_SOURCE_NAME" | sudo tee $INSTALL_DIR/postgres_exporter.env > /dev/null

# Create systemd service file
sudo tee $SERVICE_PATH > /dev/null <<EOF
[Unit]
Description=Prometheus exporter for PostgreSQL
Wants=network-online.target
After=network-online.target

[Service]
User=$EXPORTER_USER
Group=$EXPORTER_USER
WorkingDirectory=$INSTALL_DIR
EnvironmentFile=$INSTALL_DIR/postgres_exporter.env
ExecStart=$BIN_PATH/postgres_exporter --web.listen-address=:9187 --web.telemetry-path=/metrics --extend.query-path=$QUERY_PATH
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable postgres_exporter
sudo systemctl start postgres_exporter

# Show service status
sudo systemctl status postgres_exporter --no-pager
