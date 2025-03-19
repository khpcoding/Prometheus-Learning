#!/bin/bash

# Define the version of the RabbitMQ Exporter to download
RABBITMQ_EXPORTER_VERSION="1.0.0"
RABBITMQ_EXPORTER_TAR="rabbitmq_exporter-${RABBITMQ_EXPORTER_VERSION}.linux-amd64.tar.gz"
RABBITMQ_EXPORTER_URL="https://github.com/kbudde/rabbitmq_exporter/releases/download/v${RABBITMQ_EXPORTER_VERSION}/${RABBITMQ_EXPORTER_TAR}"

# Download and extract the RabbitMQ Exporter
cd /opt
wget $RABBITMQ_EXPORTER_URL
tar -xzvf $RABBITMQ_EXPORTER_TAR
mv rabbitmq_exporter-${RABBITMQ_EXPORTER_VERSION}.linux-amd64/rabbitmq_exporter /usr/local/bin/
chmod +x /usr/local/bin/rabbitmq_exporter

# Clean up
rm -rf rabbitmq_exporter-${RABBITMQ_EXPORTER_VERSION}.linux-amd64*
rm -f $RABBITMQ_EXPORTER_TAR

# Create a systemd service for the RabbitMQ Exporter
echo "[Unit]
Description=RabbitMQ Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/rabbitmq_exporter \
  --rabbit.url=http://<RABBITMQ_USER>:<RABBITMQ_PASSWORD>@127.0.0.1:15672  # Replace with your RabbitMQ management URL
SyslogIdentifier=rabbitmq-exporter
Restart=always

[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/rabbitmq-exporter.service >/dev/null

# Reload systemd and enable the service
systemctl daemon-reload
systemctl enable rabbitmq-exporter.service
systemctl start rabbitmq-exporter.service
systemctl status rabbitmq-exporter.service
