#!/bin/bash

# Define the version of the SNMP Exporter to download
SNMP_EXPORTER_VERSION="0.23.0"
SNMP_EXPORTER_TAR="snmp_exporter-${SNMP_EXPORTER_VERSION}.linux-amd64.tar.gz"
SNMP_EXPORTER_URL="https://github.com/prometheus/snmp_exporter/releases/download/v${SNMP_EXPORTER_VERSION}/${SNMP_EXPORTER_TAR}"

# Download and extract the SNMP Exporter
cd /opt
wget $SNMP_EXPORTER_URL
tar -xzvf $SNMP_EXPORTER_TAR
mv snmp_exporter-${SNMP_EXPORTER_VERSION}.linux-amd64/snmp_exporter /usr/local/bin/
chmod +x /usr/local/bin/snmp_exporter

# Clean up
rm -rf snmp_exporter-${SNMP_EXPORTER_VERSION}.linux-amd64*
rm -f $SNMP_EXPORTER_TAR

# Create a systemd service for the SNMP Exporter
echo "[Unit]
Description=SNMP Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/snmp_exporter \
  --config.file=/etc/snmp_exporter/snmp.yml
SyslogIdentifier=snmp-exporter
Restart=always

[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/snmp-exporter.service >/dev/null

# Reload systemd and enable the service
systemctl daemon-reload
systemctl enable snmp-exporter.service
systemctl start snmp-exporter.service
systemctl status snmp-exporter.service
