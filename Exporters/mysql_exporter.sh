#!/bin/bash
export RELEASE=0.14.0
export DATA_SOURCE_NAME='prom:Packops2022@(localhost:3306)/'
wget https://github.com/prometheus/mysqld_exporter/releases/download/v$RELEASE/mysqld_exporter-$RELEASE.linux-amd64.tar.gz
tar -xvf mysqld_exporter-$RELEASE.linux-amd64.tar.gz && cd mysqld_exporter-$RELEASE.linux-amd64
mv ./mysqld_exporter /usr/local/bin



groupadd --system mysql_exporter
useradd -s /sbin/nologin -r -g mysql_exporter mysql_exporter

chown mysql_exporter:mysql_exporter /etc/.mysqld_exporter.cnf

echo -n "[client]
user=prom
password=Packops2022" >/etc/.mysqld_exporter.cnf

echo -n "[Unit]
Description=Mysql Exporter service unit
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
User=mysql_exporter
Group=mysql_exporter
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/mysqld_exporter \
--config.my-cnf /etc/.mysqld_exporter.cnf \
--collect.global_status \
--collect.info_schema.innodb_metrics \
--collect.auto_increment.columns \
--collect.info_schema.processlist \
--collect.binlog_size \
--collect.info_schema.tablestats \
--collect.global_variables \
--collect.info_schema.query_response_time \
--collect.info_schema.userstats \
--collect.info_schema.tables \
--collect.perf_schema.tablelocks \
--collect.perf_schema.file_events \
--collect.perf_schema.eventswaits \
--collect.perf_schema.indexiowaits \
--collect.perf_schema.tableiowaits \
--collect.slave_status \
--web.listen-address=0.0.0.0:9104
SyslogIdentifier=mysqld-exporter
Restart=always
[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/mysql_exporter.service >/dev/null
systemctl daemon-reload
systemctl restart mysql_exporter
systemctl enable  mysql_exporter
