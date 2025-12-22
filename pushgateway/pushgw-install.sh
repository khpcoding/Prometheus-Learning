#!/bin/bash
VERSION="1.11.1"
wget "https://github.com/prometheus/pushgateway/releases/download/v${VERSION}/pushgateway-${VERSION}.linux-amd64.tar.gz"
tar xvzf "pushgateway-${VERSION}.linux-amd64.tar.gz" "pushgateway-${VERSION}.linux-amd64/pushgateway"
rm -f "pushgateway-${VERSION}.linux-amd64.tar.gz"
mv "pushgateway-${VERSION}.linux-amd64/pushgateway" /usr/local/bin/pushgateway
rmdir "pushgateway-${VERSION}.linux-amd64"
groupadd --system pushgateway
useradd -s /sbin/nologin -r -g pushgateway pushgateway

echo -n "[Unit]
Description=Pushgateway
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
User=pushgateway 
Group=pushgateway
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/pushgateway 
SyslogIdentifier=pushgateway
Restart=always
[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/pushgateway.service >/dev/null
systemctl daemon-reload
systemctl restart pushgateway
systemctl enable  pushgateway
