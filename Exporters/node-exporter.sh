# Installation node exporter
#!/bin/bash
export RELEASE="1.9.0"
wget https://github.com/prometheus/node_exporter/releases/download/v$RELEASE/node_exporter-$RELEASE.linux-386.tar.gz
tar xzf node_exporter-$RELEASE.linux-386.tar.gz
cd node_exporter-$RELEASE.linux-386/
mv ./node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/
useradd --no-create-home --shell /bin/false node_exporter

echo  -n "
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target " >  /etc/systemd/system/node_exporter.service


systemctl daemon-reload
systemctl start node_exporter.service
systemctl enable node_exporter.service
systemctl status node_exporter.service
