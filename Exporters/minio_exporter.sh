#!/bin/bash
# Set MinIO Exporter settings
export MINIO_PORT=9000
export MINIO_CONSOLE_PORT=9001
export MINIO_ROOT_USER=minioadmin
export MINIO_ROOT_PASSWORD=minioadmin
export MINIO_METRICS_PORT=9002

# Set MinIO Exporter version
# export MINIO_EXPORTER_RELEASE=0.9.0

# Download and install MinIO Exporter
# wget https://github.com/disaster37/minio-exporter/releases/download/v${MINIO_EXPORTER_RELEASE}/minio-exporter_${MINIO_EXPORTER_RELEASE}_linux_amd64.tar.gz
# tar -xvf minio-exporter_${MINIO_EXPORTER_RELEASE}_linux_amd64.tar.gz
# mv minio-exporter /usr/local/bin/

# Create a systemd service for MinIO Exporter
# echo -n "[Unit]
# Description=MinIO Exporter for Prometheus
# Wants=network-online.target
# After=network-online.target minio.service
#
# [Service]
# Type=simple
# User=minio
# Group=minio
# ExecStart=/usr/local/bin/minio-exporter \
#   --minio-server-address=http://localhost:${MINIO_PORT} \
#   --minio-access-key=${MINIO_ROOT_USER} \
#   --minio-secret-key=${MINIO_ROOT_PASSWORD} \
#   --web.listen-address=0.0.0.0:${MINIO_METRICS_PORT}
# Restart=always
#
# [Install]
# WantedBy=multi-user.target" | tee /etc/systemd/system/minio-exporter.service >/dev/null

# systemctl daemon-reload
# systemctl restart minio-exporter
# systemctl enable minio-exporter
