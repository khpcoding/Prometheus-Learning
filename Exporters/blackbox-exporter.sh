#!/bin/bash
RELEASE=0.25.0
wget https://github.com/prometheus/blackbox_exporter/releases/download/v$RELEASE/blackbox_exporter-$RELEASE.linux-amd64.tar.gz
tar xvzf blackbox_exporter-$RELEASE.linux-amd64.tar.gz
mv   blackbox_exporter-$RELEASE.linux-amd64/blackbox_exporter /usr/local/bin 

mkdir -p /etc/blackbox
mv blackbox_exporter-$RELEASE.linux-amd64/blackbox.yml /etc/blackbox && rm -rf ./blackbox_exporter-$RELEASE.linux-amd64
 sudo useradd -rs /bin/false blackbox && sudo chown blackbox:blackbox /usr/local/bin/blackbox_exporter &&   sudo chown -R blackbox:blackbox /etc/blackbox/*

 echo -n "[Unit]
Description=Blackbox Exporter Service
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=blackbox
Group=blackbox
ExecStart=/usr/local/bin/blackbox_exporter \
  --config.file=/etc/blackbox/blackbox.yml \
  --web.listen-address=":9115"

Restart=always

[Install]
WantedBy=multi-user.target" > /lib/systemd/system/blackbox.service
systemctl daemon-reload
systemctl enable blackbox.service
systemctl start blackbox.service
